from __future__ import annotations

import argparse
import hashlib
import struct
from dataclasses import dataclass
from pathlib import Path

SOURCE_ACTOR_ID = 0x010E70CD
SOURCE_EVENT_ID = 716
SOURCE_EVENT_DAT = Path("ROM/21/40.DAT")
SOURCE_DIALOG_DAT = Path("ROM/25/40.DAT")
SOURCE_DIALOG_IDS = (
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
)


@dataclass(frozen=True)
class Target:
    name: str
    actor_id: int
    event_id: int
    entity_dat: Path
    event_dat: Path
    dialog_dat: Path


TARGETS = (
    Target(
        name="Tavnazian Safehold",
        actor_id=0x0101A0BA,
        event_id=10000,
        entity_dat=Path("ROM3/3/8.DAT"),
        event_dat=Path("ROM3/0/92.DAT"),
        dialog_dat=Path("ROM3/2/36.DAT"),
    ),
    Target(
        name="Aht Urhgan Whitegate",
        actor_id=0x0103227E,
        event_id=10000,
        entity_dat=Path("ROM4/1/49.DAT"),
        event_dat=Path("ROM4/0/55.DAT"),
        dialog_dat=Path("ROM4/0/123.DAT"),
    ),
)


@dataclass
class EventBlock:
    actor_id: int
    event_offsets: list[int]
    event_ids: list[int]
    immediate_data: list[int]
    event_data: bytes
    raw: bytes | None = None

    def build(self) -> bytes:
        if self.raw is not None:
            return self.raw

        block = bytearray(struct.pack("<II", self.actor_id, len(self.event_ids)))
        block.extend(struct.pack(f"<{len(self.event_offsets)}H", *self.event_offsets))
        block.extend(struct.pack(f"<{len(self.event_ids)}H", *self.event_ids))
        block.extend(struct.pack("<I", len(self.immediate_data)))
        block.extend(struct.pack(f"<{len(self.immediate_data)}I", *self.immediate_data))
        block.extend(struct.pack("<I", len(self.event_data)))
        block.extend(self.event_data)
        block.extend(bytes((-len(self.event_data)) % 4))
        return bytes(block)


def parse_event_dat(raw: bytes) -> list[EventBlock]:
    block_count = struct.unpack_from("<I", raw, 0)[0]
    block_sizes = struct.unpack_from(f"<{block_count}I", raw, 4)
    position = 4 + 4 * block_count
    blocks = []

    for block_size in block_sizes:
        block_raw = raw[position : position + block_size]
        actor_id, event_count = struct.unpack_from("<II", block_raw, 0)
        cursor = 8
        event_offsets = list(struct.unpack_from(f"<{event_count}H", block_raw, cursor))
        cursor += event_count * 2
        event_ids = list(struct.unpack_from(f"<{event_count}H", block_raw, cursor))
        cursor += event_count * 2
        immediate_count = struct.unpack_from("<I", block_raw, cursor)[0]
        cursor += 4
        immediate_data = list(
            struct.unpack_from(f"<{immediate_count}I", block_raw, cursor)
        )
        cursor += immediate_count * 4
        data_size = struct.unpack_from("<I", block_raw, cursor)[0]
        cursor += 4
        event_data = block_raw[cursor : cursor + data_size]

        if len(block_raw) != cursor + data_size + (-data_size % 4):
            raise ValueError(f"Invalid event block for actor 0x{actor_id:08X}")

        blocks.append(
            EventBlock(
                actor_id=actor_id,
                event_offsets=event_offsets,
                event_ids=event_ids,
                immediate_data=immediate_data,
                event_data=event_data,
                raw=block_raw,
            )
        )
        position += block_size

    if position != len(raw):
        raise ValueError("Event DAT contains trailing or truncated data")

    return blocks


def build_event_dat(blocks: list[EventBlock]) -> bytes:
    built_blocks = [block.build() for block in blocks]
    header = struct.pack("<I", len(built_blocks))
    header += struct.pack(f"<{len(built_blocks)}I", *(map(len, built_blocks)))
    return header + b"".join(built_blocks)


def extract_source_event(blocks: list[EventBlock]) -> tuple[bytes, bytes, list[int]]:
    source = next(block for block in blocks if block.actor_id == SOURCE_ACTOR_ID)
    event_index = source.event_ids.index(SOURCE_EVENT_ID)
    start = source.event_offsets[event_index]
    end = (
        source.event_offsets[event_index + 1]
        if event_index + 1 < len(source.event_offsets)
        else len(source.event_data)
    )
    return (
        source.event_data[:start],
        source.event_data[start:end],
        source.immediate_data,
    )


def patch_event_dat(
    raw: bytes,
    target: Target,
    event_prefix: bytes,
    event_data: bytes,
    immediate_data: list[int],
) -> bytes:
    blocks = [
        block for block in parse_event_dat(raw) if block.actor_id != target.actor_id
    ]
    blocks.append(
        EventBlock(
            actor_id=target.actor_id,
            event_offsets=[0, len(event_prefix)],
            event_ids=[65535, target.event_id],
            immediate_data=immediate_data,
            event_data=event_prefix + event_data,
        )
    )
    return build_event_dat(blocks)


def parse_dialog_dat(raw: bytes) -> tuple[int, list[bytes]]:
    if int.from_bytes(raw[:3], "little") != len(raw) - 4:
        raise ValueError("Invalid event-dialogue resource length")

    flag = raw[3]
    decoded = bytes(byte ^ 0x80 for byte in raw[4:]) if flag == 0x10 else raw[4:]
    first_offset = struct.unpack_from("<I", decoded, 0)[0]
    if first_offset % 4:
        raise ValueError("Invalid event-dialogue offset table")

    entry_count = first_offset // 4
    offsets = list(struct.unpack_from(f"<{entry_count}I", decoded, 0))
    offsets.append(len(decoded))
    entries = [decoded[offsets[i] : offsets[i + 1]] for i in range(entry_count)]

    if offsets[0] != entry_count * 4 or offsets != sorted(offsets):
        raise ValueError("Invalid event-dialogue entry offsets")

    return flag, entries


def build_dialog_dat(flag: int, entries: list[bytes]) -> bytes:
    cursor = len(entries) * 4
    offsets = []
    for entry in entries:
        offsets.append(cursor)
        cursor += len(entry)

    decoded = struct.pack(f"<{len(offsets)}I", *offsets) + b"".join(entries)
    encoded = bytes(byte ^ 0x80 for byte in decoded) if flag == 0x10 else decoded
    return len(encoded).to_bytes(3, "little") + bytes([flag]) + encoded


def patch_dialog_dat(raw: bytes, source_entries: list[bytes]) -> bytes:
    flag, entries = parse_dialog_dat(raw)
    for dialog_id in SOURCE_DIALOG_IDS:
        if dialog_id >= len(entries) or dialog_id >= len(source_entries):
            raise ValueError(f"Dialogue ID {dialog_id} is outside the DAT table")
        entries[dialog_id] = source_entries[dialog_id]
    return build_dialog_dat(flag, entries)


def patch_entity_dat(raw: bytes, actor_id: int) -> bytes:
    if len(raw) % 32:
        raise ValueError("Invalid zone-entity DAT size")

    name = "Outpost Liaison".encode("shift_jis").ljust(28, b"\0")
    replacement = name + struct.pack("<I", actor_id)
    records = [raw[index : index + 32] for index in range(0, len(raw), 32)]
    matching = [
        index
        for index, record in enumerate(records)
        if struct.unpack_from("<I", record, 28)[0] == actor_id
    ]

    if matching:
        for index in matching:
            records[index] = replacement
    else:
        records.append(replacement)

    return b"".join(records)


def verify_target(
    output_root: Path, target: Target, source_dialog_entries: list[bytes]
) -> None:
    entity_raw = (output_root / target.entity_dat).read_bytes()
    entity_records = [
        entity_raw[index : index + 32] for index in range(0, len(entity_raw), 32)
    ]
    matching_names = [
        record[:28].split(b"\0", 1)[0].decode("shift_jis")
        for record in entity_records
        if struct.unpack_from("<I", record, 28)[0] == target.actor_id
    ]
    if matching_names != ["Outpost Liaison"]:
        raise ValueError(f"{target.name}: entity actor verification failed")

    event_blocks = parse_event_dat((output_root / target.event_dat).read_bytes())
    matching_events = [
        block for block in event_blocks if block.actor_id == target.actor_id
    ]
    if len(matching_events) != 1 or matching_events[0].event_ids != [
        65535,
        target.event_id,
    ]:
        raise ValueError(f"{target.name}: event actor verification failed")

    _, dialog_entries = parse_dialog_dat((output_root / target.dialog_dat).read_bytes())
    if any(
        dialog_entries[index] != source_dialog_entries[index]
        for index in SOURCE_DIALOG_IDS
    ):
        raise ValueError(f"{target.name}: dialogue verification failed")


def write_manifest(output_root: Path, paths: list[Path]) -> None:
    lines = []
    for relative_path in sorted(paths, key=lambda path: path.as_posix()):
        digest = hashlib.sha256((output_root / relative_path).read_bytes()).hexdigest()
        lines.append(f"{digest}  {relative_path.as_posix()}")
    (output_root / "manifest.sha256").write_text(
        "\n".join(lines) + "\n", encoding="ascii"
    )


def build(ffxi_root: Path, output_root: Path) -> None:
    source_blocks = parse_event_dat((ffxi_root / SOURCE_EVENT_DAT).read_bytes())
    event_prefix, source_event_data, immediate_data = extract_source_event(
        source_blocks
    )
    source_dialog_raw = (ffxi_root / SOURCE_DIALOG_DAT).read_bytes()
    _, source_dialog_entries = parse_dialog_dat(source_dialog_raw)

    output_root.mkdir(parents=True, exist_ok=True)
    generated_paths = []
    for target in TARGETS:
        patched = {
            target.entity_dat: patch_entity_dat(
                (ffxi_root / target.entity_dat).read_bytes(), target.actor_id
            ),
            target.event_dat: patch_event_dat(
                (ffxi_root / target.event_dat).read_bytes(),
                target,
                event_prefix,
                source_event_data,
                immediate_data,
            ),
            target.dialog_dat: patch_dialog_dat(
                (ffxi_root / target.dialog_dat).read_bytes(), source_dialog_entries
            ),
        }

        for relative_path, raw in patched.items():
            destination = output_root / relative_path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(raw)
            generated_paths.append(relative_path)

    for target in TARGETS:
        verify_target(output_root, target, source_dialog_entries)

    write_manifest(output_root, generated_paths)

    print(f"Built and verified {len(generated_paths)} DAT files in {output_root}")
    for path in sorted(generated_paths, key=lambda item: item.as_posix()):
        print(f"  {path.as_posix()}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build Sanctum non-Jeuno outpost DAT patches"
    )
    parser.add_argument("--ffxi-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    build(args.ffxi_root.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()
