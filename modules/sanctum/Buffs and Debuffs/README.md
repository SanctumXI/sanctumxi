# Buffs and Debuffs

## UnreliableStatuses

`UnreliableStatuses.lua` gives ordinary Sleep applied by a player or a player's pet to an enemy an independent 8% early-wake chance every 12 seconds. The first possible random wake is at 16 seconds: a successful check warns, then leaves four seconds of Sleep. Normal expiration also warns four seconds beforehand. Timing follows server updates; a delayed update never extends Sleep to make room for a warning.

The warning is the existing yellow weakness/proc animation plus `<mob name> begins to stir!` in nearby players' system messages. The animation does not apply Terror or trigger encounter-specific weakness rewards. Text is limited to players within 50 yalms in the same instance. No client modifications are required, but the visual should be checked in-client on several mob families before deployment.

The module handles the shared Sleep handler (including Sleep II, Sleepga, Repose, and ordinary Lullabies), plus the legacy Lullaby handler. Existing resistance, duration bonuses, overwrite rules, damage wake-up, and Nightmare cleanup are preserved. There is no post-wake immunity. Players and pets as targets, enemy-applied Sleep, Nightmare tiers, and scripted/self-applied sleeps are excluded. Encounters can also opt out with `mob:setLocalVar('UnreliableStatuses:Exempt', 1)` before applying Sleep.

One timer is scheduled per active application. Replacement or removal invalidates its token; callbacks never retain a status-effect pointer. Failed rolls continue silently, and an application warns at most once. Duration changes before the warning are re-evaluated at the next check. External removal or shortening can still wake a target immediately, just like damage.

Keep `sanctum` enabled in `modules/init.txt`. The supporting `sleep_i` and `sleep_ii` name mappings live in `modules/sanctum/data/status_effects.yaml`, where the data loader expects them. Restart the map server when deploying those mappings; a Lua-only reload is insufficient.

Before live rollout, verify the named text and animation during Sleepga, a four-second warning-to-wake interval, damage during a warning, Sleep II replacement, pet refresh, and re-sleep after wake. Also verify that enemy Sleep on players and scripted encounter sleeps remain unchanged.

The regression suites are `scripts/tests/modules/sanctum/unreliable_statuses.lua` (deterministic simulated entities/timers) and `unreliable_statuses_integration.lua` (real engine entities, data mapping, and expiration). With a configured test server, run `xi_test --file unreliable_statuses` from the repository root.
