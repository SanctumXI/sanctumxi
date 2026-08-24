# Sanctum Miscellaneous Fixes

This directory contains small, targeted era and gameplay corrections that do
not belong to a larger Sanctum feature module.

## Layout

- `Lua/quests_and_battlefields.lua`: quest, battlefield, and ENM behavior
- `Lua/items.lua`: item scripts, equipment listeners, and item-drop handling
- `Lua/spells_and_abilities.lua`: spell, pet ability, and weapon-skill behavior
- `Lua/mobs_and_world.lua`: mob scripts, encounter details, fishing mobs, and
  shared world services
- `SQL/combat.sql`: job abilities, weapon skills, and mob-skill selection
- `SQL/items.sql`: item data, latents, additional effects, and fishing items
- `SQL/mobs.sql`: mob pools, drops, jobs, and spawn levels

Keep new fixes with their matching domain. If a system grows beyond a handful
of related corrections, promote it to a clearly named top-level module instead
of turning this directory into another catch-all file.
