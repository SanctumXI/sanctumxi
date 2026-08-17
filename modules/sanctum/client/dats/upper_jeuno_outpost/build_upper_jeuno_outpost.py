#!/usr/bin/env python3

import argparse
import hashlib
import json
from pathlib import Path

from xi.dialog import xi_dialog
from xi.event import xi_event


SOURCE_ACTOR_ID = 0x010E70CD
SOURCE_EVENT_ID = 716
TARGET_ACTOR_ID = 0x010F4110
TARGET_EVENT_ID = 10000
EXPECTED_DIALOG_IDS = {
    13039,
    13045,
    13051,
    13053,
    13054,
    13055,
    13056,
    13057,
    13059,
    13061,
    13062,
}


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def find_raw_actor(actors, actor_id):
    return next((actor for actor in actors if actor.actor_id == actor_id), None)


def find_event(actor, event_id):
    return next((event for event in actor.events if event.event_id == event_id), None)


def build_patch(source_event_path, source_dialog_path, target_event_path, target_dialog_path):
    source_event_data = source_event_path.read_bytes()
    source_dialog_data = source_dialog_path.read_bytes()
    target_event_data = target_event_path.read_bytes()
    target_dialog_data = target_dialog_path.read_bytes()

    source_raw_actors = xi_event.parse_raw_actors(source_event_data)
    source_actor = find_raw_actor(source_raw_actors, SOURCE_ACTOR_ID)
    if source_actor is None:
        raise RuntimeError(f'source actor 0x{SOURCE_ACTOR_ID:08X} was not found')

    source_actor_record = next(
        actor for actor in xi_event.parse_event_dat(source_event_data)
        if actor.actor_id == SOURCE_ACTOR_ID
    )
    source_event = find_event(source_actor_record, SOURCE_EVENT_ID)
    if source_event is None:
        raise RuntimeError(f'source event {SOURCE_EVENT_ID} was not found')
    if set(source_event.dialog_ids) != EXPECTED_DIALOG_IDS:
        raise RuntimeError(
            f'source event dialogue changed: expected {sorted(EXPECTED_DIALOG_IDS)}, '
            f'found {sorted(source_event.dialog_ids)}'
        )

    source_index = source_actor.event_ids.index(SOURCE_EVENT_ID)
    source_start = source_actor.event_offsets[source_index]
    source_next_offset = min(
        offset for offset in source_actor.event_offsets
        if offset > source_start
    )
    source_end = source_start + source_event.opcodes[-1].offset + source_event.opcodes[-1].step
    if (
        source_start != 1
        or source_event.opcodes[-1].op != 0x21
        or source_end > source_next_offset
    ):
        raise RuntimeError('the retail outpost event layout no longer matches the tested layout')

    source_dialog_blobs, _ = xi_dialog.raw_entry_blobs(source_dialog_data)
    target_dialog_blobs, target_obfuscated = xi_dialog.raw_entry_blobs(target_dialog_data)

    existing_blobs = {bytes(blob): index for index, blob in enumerate(target_dialog_blobs)}
    dialog_map = {}
    for source_id in sorted(EXPECTED_DIALOG_IDS):
        blob = source_dialog_blobs[source_id]
        target_id = existing_blobs.get(bytes(blob))
        if target_id is None:
            target_id = len(target_dialog_blobs)
            target_dialog_blobs.append(blob)
            existing_blobs[bytes(blob)] = target_id
        dialog_map[source_id] = target_id

    target_refs = [dialog_map.get(value, value) for value in source_actor.references]
    target_scene = source_actor.scene_data[:source_start] + source_actor.scene_data[source_start:source_end]
    target_actor = xi_event.RawActor(
        actor_id=TARGET_ACTOR_ID,
        event_offsets=[source_start],
        event_ids=[TARGET_EVENT_ID],
        references=target_refs,
        scene_data=target_scene,
        block_pad=b'',
        raw_block=b'',
        dirty=True,
    )

    target_actors = xi_event.parse_raw_actors(target_event_data)
    existing_target = find_raw_actor(target_actors, TARGET_ACTOR_ID)
    if existing_target is None:
        target_actors.append(target_actor)
    elif existing_target.event_ids == [TARGET_EVENT_ID]:
        target_actors[target_actors.index(existing_target)] = target_actor
    else:
        raise RuntimeError(
            f'target actor 0x{TARGET_ACTOR_ID:08X} already contains unrelated events'
        )

    patched_event_data = xi_event.build_event_dat(target_actors)
    patched_dialog_data = xi_dialog.build_container(target_dialog_blobs, target_obfuscated)

    reparsed = xi_event.parse_raw_actors(patched_event_data)
    reparsed_target = find_raw_actor(reparsed, TARGET_ACTOR_ID)
    if reparsed_target is None or reparsed_target.event_ids != [TARGET_EVENT_ID]:
        raise RuntimeError('the patched event DAT did not round-trip correctly')
    if xi_event.build_event_dat(reparsed) != patched_event_data:
        raise RuntimeError('the patched event DAT failed byte-exact validation')

    original_target_by_id = {actor.actor_id: actor.raw_block for actor in xi_event.parse_raw_actors(target_event_data)}
    patched_target_by_id = {actor.actor_id: actor.raw_block for actor in reparsed}
    changed_existing = [
        actor_id for actor_id, block in original_target_by_id.items()
        if patched_target_by_id.get(actor_id) != block
    ]
    if changed_existing:
        raise RuntimeError(
            'existing Upper Jeuno actor blocks changed: '
            + ', '.join(f'0x{actor_id:08X}' for actor_id in changed_existing)
        )

    return patched_event_data, patched_dialog_data, dialog_map, {
        'source_event': {
            'path': str(source_event_path),
            'sha256': sha256(source_event_data),
            'actor_id': f'0x{SOURCE_ACTOR_ID:08X}',
            'event_id': SOURCE_EVENT_ID,
        },
        'source_dialog': {
            'path': str(source_dialog_path),
            'sha256': sha256(source_dialog_data),
        },
        'target_event': {
            'path': str(target_event_path),
            'original_sha256': sha256(target_event_data),
            'patched_sha256': sha256(patched_event_data),
            'original_size': len(target_event_data),
            'patched_size': len(patched_event_data),
            'actor_id': f'0x{TARGET_ACTOR_ID:08X}',
            'event_id': TARGET_EVENT_ID,
        },
        'target_dialog': {
            'path': str(target_dialog_path),
            'original_sha256': sha256(target_dialog_data),
            'patched_sha256': sha256(patched_dialog_data),
            'original_size': len(target_dialog_data),
            'patched_size': len(patched_dialog_data),
        },
        'dialog_map': {str(source): target for source, target in dialog_map.items()},
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--ffxi-dir', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()

    ffxi_dir = args.ffxi_dir.resolve()
    source_event_path = ffxi_dir / 'ROM' / '21' / '40.DAT'
    source_dialog_path = ffxi_dir / 'ROM' / '25' / '40.DAT'
    target_event_path = ffxi_dir / 'ROM' / '21' / '53.DAT'
    target_dialog_path = ffxi_dir / 'ROM' / '25' / '53.DAT'

    patched_event, patched_dialog, _, manifest = build_patch(
        source_event_path,
        source_dialog_path,
        target_event_path,
        target_dialog_path,
    )

    event_output = args.output / 'ROM' / '21' / '53.DAT'
    dialog_output = args.output / 'ROM' / '25' / '53.DAT'
    event_output.parent.mkdir(parents=True, exist_ok=True)
    dialog_output.parent.mkdir(parents=True, exist_ok=True)
    event_output.write_bytes(patched_event)
    dialog_output.write_bytes(patched_dialog)
    (args.output / 'manifest.json').write_text(
        json.dumps(manifest, indent=2) + '\n',
        encoding='utf-8',
    )

    print(f'Wrote {event_output}')
    print(f'Wrote {dialog_output}')
    print(f'Upper Jeuno actor 0x{TARGET_ACTOR_ID:08X}, event {TARGET_EVENT_ID}')


if __name__ == '__main__':
    main()
