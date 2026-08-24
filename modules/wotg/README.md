# Wings of the Goddess modules

This directory owns WotG-specific server changes.

- `lua/jobs/` contains job unlock and artifact-progression overrides.
- `sql/jobs/` contains the NPCs, quest markers, and encounters required by those overrides.
- `sql/world/` contains expansion-wide world-state changes.
- `lua/2007_exp_curve.lua` remains a separate, optional era rule and is not enabled by the WotG-free progression entries in `modules/init.txt`.

Keep Lua and SQL grouped by the feature they implement. Add a new subdirectory only when a category has more than one independent feature.

Cross-expansion job systems belong in `modules/sanctum/jobs/` instead of being duplicated here.
