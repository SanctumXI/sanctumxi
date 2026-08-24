# Sanctum Combat Rework

This package owns Sanctum's coordinated combat rules. It replaces the former
experimental tree; because `modules/sanctum` is enabled in `modules/init.txt`,
every Lua and SQL file below is active with the main Sanctum module.

Keep these files together. The Lua overrides, status effects, job calculations,
mob calculations, and SQL rows describe one combat ruleset and are expected to
be reviewed and deployed as a unit.

## Layout

### Lua

- `Core/` contains the shared weapon-skill effect system, common combat math,
  and magic hit-rate calculations used by the domain modules.
- `Effects/` contains the Empowered and Resolve status-effect handlers.
- `Jobs/` contains job-specific combat behavior. Quick Draw belongs to Corsair,
  and avatar damage belongs to Summoner, so both are named for their owning job.
- `Mobs/` contains the shared monster TP-move calculations.
- `Spells/` contains Absorb/drain and direct-damage spell calculations.
- `WeaponSkills/` contains one file per weapon family. The pre-WotG sword
  extensions are kept beside the full sword rework instead of in a second era
  tree.

### SQL

- `Jobs/` owns complete current rows for abilities, ability charges, merits,
  and trait progression.
- `Mobs/` owns the custom HNM/KSNM pools, groups, spawn points, skill lists,
  skills, spell lists, and pool modifiers.
- `Spells/` owns spell definitions and Blue Magic spell, modifier, and trait
  data.

The SQL files use delete-and-replace ownership for their declared keys. Put a
new row in the folder for the system that owns it; do not create a catch-all SQL
file.

## Load-order contracts

The names in this package are deliberate:

1. `Lua/Core/effect_system.lua` loads before
   `Lua/Core/shared_calculations.lua`, leaving the shared calculation snapshot
   as the final owner of `xi.weaponskills.fTP`.
2. `Lua/WeaponSkills/era_sword_extensions.lua` loads before `sword.lua`. The
   extensions retain pre-WotG-only weapon skills, while the complete Sanctum
   sword rework remains authoritative for overlapping weapon skills.
3. `CombatRework` loads before `MiscFixes` and `SteelMobChanges`. Those packages
   may therefore apply narrow fixes on top of this combat baseline. The two
   intentional cross-package wrappers are Moonlight and `doDrainingSpell`, both
   owned by `MiscFixes/Lua/spells_and_abilities.lua`.

Do not change these paths or filenames without auditing duplicate
`Module:addOverride` targets.

## Native integration

The Lua effect system uses IDs that also exist in the server core:

- Effects: `EMPOWERED = 635` and `RESOLVE = 810`; see
  `scripts/enum/effect.lua` and `src/map/status_effect.h`.
- Modifiers: `BLADE_TEN_NINJUTSU = 1206`,
  `SPIRAL_HELL_FORCE_CRIT = 1207`, `SAVAGE_BLADE_ENMITY = 1208`, and
  `SAVAGE_BLADE_DAMAGE = 1209`; see `scripts/enum/mod.lua` and
  `src/map/modifier.h`.
- The matching behavior is implemented in `src/map/utils/battleutils.cpp`,
  `src/map/entities/battle_entity.cpp`, and `src/map/enmity_container.cpp`.

Treat those Lua and C++ definitions as one interface: changing an ID or its
meaning requires updating both sides in the same change.

## Adding or changing combat rules

Use a descriptive, domain-owned filename and a `sanctum_combat_*` module name.
Keep source-snapshot comments when a module mirrors a global script, and update
the snapshot and its override registration together. Before merging, run the
Lua style checks, SQL validation, and an override-collision audit for every file
touched here.
