# Sanctum custom instances

The Sanctum instance manager is an opt-in layer over LandSandBoat's existing
`CInstance` loader. It gives custom scripts a stable server-only runtime ID for
each live copy while leaving the instance definition ID and client zone ID
unchanged.

## Runtime and definition IDs

- `instance:getID()` is the `instance_list.instanceid` definition ID. Its
  meaning is unchanged.
- `instance:getRuntimeID()` identifies one live `CInstance` object. It is unique
  only for the lifetime of the map process and is not persisted.
- `zone:getInstanceByRuntimeID(runtimeId)` resolves a live runtime without
  retaining Lua userdata after the call.
- `zone:getInstancesByDefinition(definitionId)` returns all currently live
  runtimes made from a definition.
- `zone:isInstanceAlive(runtimeId)` tests whether a runtime can still be joined.
- `zone:unregisterCharFromInstances(player)` removes that character's old
  registrations from live instances in that destination zone. The Sanctum
  manager calls this immediately before assigning the requested runtime, so
  reconnect lookup has only one matching custom copy. Retail instance entry
  code does not call this opt-in API.

The manager stores runtime IDs, not long-lived `CInstance` userdata. A missing
lookup is treated as cleanup or stale state, and the next entry request creates
a new runtime. Live empty instances are intentionally retained so players can
leave and re-enter; call `instanceManager.clear(config, true)` when the copy
should fail and be removed by the normal instance cleanup path.

## Minimum setup for another custom instanced zone

1. In `sql/zone_settings.sql`, add the `INSTANCED` bit (`256`) to the existing
   zone type. Preserve every existing bit. For example, a city changes from
   `CITY` (`1`) to `CITY | INSTANCED` (`257`). This changes only how the server
   stores entities; the client zone ID does not change.
2. Add a unique server-side definition to `sql/instance_list.sql`. Set
   `instance_zone` to the existing client zone ID, `entrance_zone` to the exit
   or entry zone, and provide the entry coordinates. A `time_limit` of `0`
   creates no automatic time limit.
3. Add only the mobs and NPCs needed by that definition to
   `sql/instance_entities.sql`. The loader accepts an empty result, so an entity
   row is not required merely to create a runtime.
4. Add `onInstanceZoneIn` and `onInstanceLoadFailed` to the destination
   zone's `Zone.lua`. The former should replace a zero position with the
   instance entry position; the latter must return a safe fallback zone.
5. Add `scripts/zones/<Zone_Name>/instances/<instance_name>.lua`, matching the
   `instance_list.instance_name`. Route its creation callback and its failure or
   completion callbacks through the Sanctum manager. Encounter-specific setup
   stays in this lifecycle script.
6. Define a small configuration table containing `definitionId`,
   `destinationZone`, `exitZone`, and a caller-chosen `copyKey`. Optional fields
   are `exitPosition`, `creationTimeoutMs`, and `canEnter(player)`.
7. From a command or NPC, call
   `instanceManager.enter(player, config)`. Calls using the same `copyKey` join
   the same live runtime; different keys create distinct runtimes from the same
   definition. `instanceManager.joinRuntime(player, config, runtimeId)` joins a
   specific known runtime.

The lifecycle script must call `instanceManager.onInstanceCreated(player,
instance)` from `onInstanceCreatedCallback`. It should also call
`instanceManager.onInstanceFailure(instance)` and
`instanceManager.onInstanceComplete(instance)` so tracked state is cleared and
registered players are sent to the configured exit.

## Library proof of concept

Celennia Memorial Library keeps client zone ID `284` and uses server-side
definition ID `28400`. `!librarya` and `!libraryb` select two independently
tracked runtime copies. A second player selecting the same command joins that
copy. After zoning out, the command re-registers the player with the same live
runtime. `!librarya clear` or `!libraryb clear` explicitly fails and clears the
selected test copy.

The legacy `!libraryinstance` command and Eppel-Treppel entry both select copy
A. A player who reaches zone 284 with no instance assignment is handled by the
zone's existing `onInstanceLoadFailed` fallback instead of being inserted into
an unisolated ordinary entity container.

## Reisenjima Henge hard-mode HNM test

Reisenjima Henge keeps client zone ID `292` and uses server-side definition ID
`29200`. `!hengeinstance` creates or joins one shared test runtime, while
`!hengeinstance clear` fails that runtime and clears its manager state. The
definition has no time limit and no automatic completion behavior.

Because zone 292 is now server-side instanced, a raw GM `!zone 292` cannot use
the ordinary `setPos()` path. The GM zone command routes only that destination
through the same Henge test helper as `!hengeinstance`; all other destinations
retain the command's normal behavior. Any other unassigned arrival at zone 292
is still rejected by `CZoneInstance` and sent to the configured safe fallback.

The instance loads only one custom `???` and the three custom, script-spawned
mobs `HM_Roc`, `HM_Simurgh`, and `HM_King_Arthro`. Roc and Simurgh are level
85, while King Arthro is level 90 with 70,000 HP. Touching the `???`
opens a selection menu. For testing, every selection requires exactly one Fire
Crystal and one Earth Crystal; those two constants are intentionally isolated
near the top of `Hard_Mode_HNM_QM.lua` for later replacement. Only one HNM can
be spawned at a time in each runtime.

The hard-mode King Arthro casts Waterga IV, Flood II, Burst II, or Comet every
eight seconds, with fast casting, shortened individual recasts, and no MP cost.
At 75%, 50%, and 25% HP it summons a separate pair of level-85, 4,500-HP
`HM_Knight_Crab` adds. Damage that crosses
more than one threshold summons every crossed wave. The six possible adds are
removed when King Arthro dies or despawns.

Instance-only entity scripts are cached after the loader's first
`onMobInitialize` pass. To keep runtime 1 consistent after a map restart, the
Henge instance applies display names in `onInstanceCreated`, and each custom
mob repeats its essential initialization when it spawns.

The custom pools copy the original monsters' family, model, jobs, skill list,
and resistance data. They use new pool, group, spawn, and Lua script names, so
the retail monsters and their scripts are unchanged. The custom groups
currently have no drop list.

## Applying the Library SQL to an existing test database

Editing the repository SQL files does not update an already-created database.
Apply equivalent statements manually, then restart the map server so zone 284
is reconstructed as `CZoneInstance`:

```sql
UPDATE zone_settings
SET zonetype = 257
WHERE zoneid = 284;

INSERT INTO instance_list
    (instanceid, instance_name, instance_zone, entrance_zone, time_limit,
     start_x, start_y, start_z, start_rot, music_day, music_night,
     battlesolo, battlemulti)
VALUES
    (28400, 'library_test', 284, 257, 0,
     -97.000, -2.000, -87.000, 96, NULL, NULL, NULL, NULL)
ON DUPLICATE KEY UPDATE
    instance_name = VALUES(instance_name),
    instance_zone = VALUES(instance_zone),
    entrance_zone = VALUES(entrance_zone),
    time_limit = VALUES(time_limit),
    start_x = VALUES(start_x),
    start_y = VALUES(start_y),
    start_z = VALUES(start_z),
    start_rot = VALUES(start_rot);

INSERT IGNORE INTO instance_entities (instanceid, id)
VALUES (28400, 17940508);
```

The final row loads only the Library's existing “Back to Town” door. It does
not duplicate the rest of the normal Library entity set.

## Applying the Henge SQL to an existing test database

Apply these statements to an already-created test database, then rebuild and
restart the map server so zone 292 is constructed as a `CZoneInstance`:

```sql
UPDATE zone_settings
SET zonetype = zonetype | 256
WHERE zoneid = 292;

REPLACE INTO instance_list VALUES
    (29200, 'hard_mode_hnm', 292, 291, 0,
     0.000, 0.000, 0.000, 127,
     NULL, NULL, NULL, NULL);

REPLACE INTO mob_pools VALUES
    (7555, 'HM_Roc', 'Roc', 125, 0x0000500100000000000000000000000000000000, 3, 10, 11, 200, 125, 0, 1, 0, 0, 2, 0, 32, 0, 155, 0, 0, 45, 0, 0, 1004, 125, 1, 32),
    (7556, 'HM_Simurgh', 'Simurgh', 125, 0x0000500100000000000000000000000000000000, 1, 10, 5, 200, 125, 0, 1, 0, 0, 2, 0, 32, 0, 157, 0, 0, 45, 0, 0, 1004, 125, 2, 36),
    (7557, 'HM_King_Arthro', 'King_Arthro', 77, 0x0000650100000000000000000000000000000000, 2, 5, 12, 240, 100, 0, 1, 0, 0, 2, 20, 32, 514, 157, 0, 0, 79, 0, 0, 77, 77, 2, 16),
    (7558, 'HM_Knight_Crab', 'Knight_Crab', 77, 0x0000640100000000000000000000000000000000, 7, 7, 4, 240, 100, 0, 1, 0, 1, 0, 0, 0, 2125, 131, 8, 0, 0, 0, 0, 77, 77, 1, 13);

REPLACE INTO mob_groups VALUES
    (79, 7555, 292, 'HM_Roc', 0, 128, 0, 28500, 0, 0, NULL),
    (80, 7556, 292, 'HM_Simurgh', 0, 128, 0, 51000, 0, 0, NULL),
    (81, 7557, 292, 'HM_King_Arthro', 0, 128, 0, 70000, 7500, 0, NULL),
    (82, 7558, 292, 'HM_Knight_Crab', 0, 128, 0, 4500, 0, 0, NULL);

REPLACE INTO mob_spawn_points VALUES
    (17973581, 0, 'HM_Roc', 'Roc', 79, 85, 85, 8.842, 5.515, -4.225, 11),
    (17973582, 0, 'HM_Simurgh', 'Simurgh', 80, 85, 85, 8.842, 5.515, -4.225, 11),
    (17973583, 0, 'HM_King_Arthro', 'King Arthro', 81, 90, 90, 8.842, 5.515, -4.225, 11),
    (17973585, 0, 'HM_Knight_Crab', 'Knight Crab', 82, 85, 85, 12.842, 5.515, -4.225, 128),
    (17973586, 0, 'HM_Knight_Crab', 'Knight Crab', 82, 85, 85, 4.842, 5.515, -4.225, 0),
    (17973587, 0, 'HM_Knight_Crab', 'Knight Crab', 82, 85, 85, 8.842, 5.515, -0.225, 192),
    (17973588, 0, 'HM_Knight_Crab', 'Knight Crab', 82, 85, 85, 8.842, 5.515, -8.225, 64),
    (17973589, 0, 'HM_Knight_Crab', 'Knight Crab', 82, 85, 85, 11.842, 5.515, -1.225, 160),
    (17973590, 0, 'HM_Knight_Crab', 'Knight Crab', 82, 85, 85, 5.842, 5.515, -7.225, 32);

REPLACE INTO npc_list VALUES
    (17973584, 'Hard_Mode_HNM_QM', '???', 11,
     8.842, 5.515, -4.225, 1, 50, 50, 0, 0, 0, 0, 3,
     0x0000340000000000000000000000000000000000, 0, NULL, 1);

REPLACE INTO instance_entities VALUES
    (29200, 17973581),
    (29200, 17973582),
    (29200, 17973583),
    (29200, 17973584),
    (29200, 17973585),
    (29200, 17973586),
    (29200, 17973587),
    (29200, 17973588),
    (29200, 17973589),
    (29200, 17973590);
```
