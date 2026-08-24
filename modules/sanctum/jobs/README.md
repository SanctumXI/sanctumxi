# Job modules

This directory contains job systems shared across expansions.

- `artifact/` owns shared artifact-equipment acquisition rules.
- `blue_mage/` owns Blue Mage spell and learning adjustments.
- `limit_breaks/` owns shared level-cap and retired job-quest rules.

Expansion-specific unlocks and quests stay with their expansion module. For example, Dancer and Scholar progression lives in `modules/wotg/lua/jobs/`.

Tests mirror this hierarchy under `scripts/tests/modules/`.
