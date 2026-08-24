# Steel Mob Changes

This directory owns Steel's targeted corrections to shared mob behavior.

- `Lua/dark_ixion.lua`: Dark Ixion state, listener, and combat recovery fixes
- `Lua/physical_mobskills.lua`: physical damage mob-skill corrections
- `Lua/drain_and_buff_mobskills.lua`: drain and defensive buff mob skills

Keep encounter-specific behavior in its own clearly named file. Group related
mob skills by behavior instead of creating one module per skill.
