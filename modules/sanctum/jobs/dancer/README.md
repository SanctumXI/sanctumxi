# Dancer audit and implementation

Reviewed against `steel-comitt` at `ad6187abeb`, including the existing Sanctum combat overrides. This is a source audit, not a guarantee of bug-free live behavior or encounter balance. Live settings and a running map server were not available.

## Organization and deployment

- Lua behavior: `modules/sanctum/jobs/dancer/lua/dancer.lua`.
- Idempotent SQL overrides: `modules/sanctum/sql/jobs/dancer.sql`.
- Unlock announcements: `modules/sanctum/level_up.lua`.
- Tests: `scripts/tests/modules/sanctum/jobs/dancer/`.

Load the Sanctum modules, apply the SQL through the normal module database update, rebuild the server, and perform a full restart. Avoid hot-reloading the new effect-owned modifiers over active effects created by the old scripts. This patch does not retroactively repair already-leaked live modifiers; a clean character reload should be part of deployment testing.

Base exceptions to the module-only preference are `src/map/utils/battleutils.cpp`, `src/map/status_effect_container.{h,cpp}`, `src/map/lua/lua_base_entity.{h,cpp}`, and the two per-hit Fan Dance calls in `scripts/globals/mobskills.lua`. The available module hooks cannot safely intercept these local per-hit calculations or Samba owner lookup. Monster skills use the same Fan Dance calculation through a Lua binding instead of duplicating its formula. Deploy the rebuilt binary and updated scripts together. The status-effect removal overload now accepts the same 32-bit owner IDs that status effects store.

No functional DAT change is required for these server-side fixes. Client help text for Samba costs, Chocobo Jig targeting, and changed unlock levels may still need manual DAT updates. Verify the early ability categories in the client after applying SQL.

## Implemented

- Subjob Waltzes divide the stat multiplier by three; main-job formulas and base healing remain unchanged.
- Samba costs are Haste 400, Drain 200/300/400, and Aspir 200/400. Trance permits all six at zero TP; Fan Dance still blocks them.
- Drain Daze applies `ATTP -10`; Aspir Daze applies `MATT -10`. Modifiers belong to the effects and are removed with them. Drain Daze no longer clears unrelated enspell damage when it ends.
- Quickstep and its Steps category unlock at 1. Animated Flourish and Flourishes I unlock at 10.
- Existing Subtle Blow data at 15/35/55 is preserved and its announcements corrected.
- Conserve TP at 50 and Subtle Blow IV at 70 are announced when Abyssea content is enabled, matching their existing trait-data tags. Their unlock data is unchanged.
- Chocobo Jig uses the existing Chocobo Jig II behavior, including party radius 10, power 10, base duration 120 seconds, duration modifiers, and Weight removal.
- Saber Dance stores its decay floor and owns its exact Double Attack/Samba-duration modifiers. Fan Dance owns its complete merit-scaled enmity bonus. Reapplication and removal no longer rely on mismatched add/remove amounts.
- Healing Waltz uses the caster's Fan Dance merits and the correct recast multiplier. Trance caps recast at six seconds and still schedules Contradance cleanup.
- Waltz costs and recasts cannot become negative. AoE Waltzes charge TP once, including Healing Waltz under Contradance.
- Step Accuracy merits now contribute to the hit check. Step TP eligibility respects the same gear reduction used when paying the cost. Temporary accuracy is restored even if the wrapped calculation errors.
- Reverse Flourish preserves finishing moves above the five it converts; the existing Sanctum TP formula is unchanged.
- Closed Position no longer grants melee accuracy while attacking from behind. The face-to-face requirement is present in the [extracted client merit descriptions](https://github.com/Windower/Resources/blob/master/resources_data/merit_points.lua).
- Violent Flourish applies physical damage reduction and Phalanx before Stoneskin, then uses the adjusted damage for HP, enmity, and the action record. Its existing hit/stun formulas are otherwise retained.
- Fan Dance loses ten percentage points after each landed physical hit, including physical/ranged monster-skill hits, and clamps to a fixed 20% floor at every merit rank. It uses the current reduction for the triggering hit; recasting resets the starting reduction. Normal misses, parries, and shadow-absorbed attacks bypass the decay path.
- Samba replacement retains full source IDs and includes party Trusts. Daze selection checks ownership before choosing a type, so another party's Drain Daze no longer masks this party's Aspir/Haste Daze.

## Fan Dance balance and preserved settings

Fan Dance now uses the requested fixed 20% sustained floor. Initial strength and enmity remain merit-scaled:

| Merit rank | Initial physical reduction | Sustained floor | Enmity bonus |
| --- | --- | --- | --- |
| 1 | 75% | 20% | 20 |
| 2 | 80% | 20% | 25 |
| 3 | 85% | 20% | 30 |
| 4 | 90% | 20% | 35 |
| 5 | 95% | 20% | 40 |

For example, rank five progresses 95 → 85 → 75 → 65 → 55 → 45 → 35 → 25 → 20%, then stays at 20% until expiration, removal, or recast. The last decrement is clamped so it cannot overshoot the floor. No time-based decay was added.

Saber Dance retains its existing 38–50% initial Double Attack and 14–22% floor, including the existing WAR-trait adjustment. Building Flourish's custom accuracy, attack, critical-rate, and weaponskill-damage bonuses were not retuned.

Wild Flourish intentionally has no accuracy roll on Sanctum. Its existing finishing-move cost and conflicting Chainbound/Skillchain checks remain unchanged; the upstream accuracy TODO does not apply to this server's chosen behavior.

`MATT -10` means ten Magic Attack Bonus points, not a universal 10% reduction to magic damage. `ATTP -10` is additive with other Attack-percent modifiers. The Waltz subjob change is also not a fixed 12% healing reduction: its percentage impact depends on stats and Waltz tier.

## Known remaining issues and limits

These were identified but not silently assigned new formulas or enabled:

- **Capped Steps:** the same utility still awards the normal finishing-move amount at maximum Daze stacks. Its TODO calls for reducing the award to one. The cap/Presto/Terpsichore interaction needs a chosen rule; changing it affects the TP economy.
- **Same-type Dazes across alliance parties:** the base status data permits only one instance of each Daze type. The owner-selection fix does not add independent same-type Dazes for every party. Enabling duplicate effects without redesigning the new debuffs would risk stacking Attack/Magic Attack penalties.
- **Modern Flourishes, if enabled:** Striking and Ternary check separate Finishing Move status IDs, while the utility stores the count in `FINISHING_MOVE_1` power. Climactic applies a hardcoded effect repeatedly, and the Climactic/Striking effect scripts have no combat implementation. Grand Pas has an empty effect script and does not bypass finishing-move checks/consumption.
- **Job points, if enabled:** Waltz Potency Bonus and Contradance Effect are declared but not used by the Waltz calculations. Waltz Potency Received also remains an upstream TODO.
- **Trusts, if enabled:** Uka Totlihn's Reverse Flourish and some Step gambits inspect obsolete separate status IDs rather than effect power. Mumor's healer-job Haste Samba gambit has malformed condition/action fields. These AI scripts need a dedicated correction and live AI test pass.
- **Other expansion-dependent announcements:** Conserve TP at 50 and Subtle Blow IV at 70 now follow their Abyssea content gate. The rest of the existing static announcement table does not comprehensively follow content tags or post-75 progression; those unrelated rows were not changed.
- Chocobo Jig intentionally inherits Jig II's existing uncertainty about which special Weight effects should resist removal. Violent Flourish's broader hit/stun/shadow behavior remains subject to the existing verification TODO.

## Validation

- 37 regression cases executed successfully under LuaJIT with mocked entities and the real base Lua functions plus module overrides, including Fan Dance recasting at all five merit ranks, guaranteed Wild Flourish, and enabled/disabled Abyssea announcements.
- The production C++ Fan Dance function was extracted and compiled in an isolated mock-entity harness: all five starting ranks, 100 successive hits, the final partial decrement, sustained floor, and absent-effect behavior pass. This does not replace a full server build.
- The new module and all three test files pass the repository Lua style checks. `level_up.lua` retains two pre-existing formatting warnings outside the Dancer edits. Changed C++ files pass the C++ sanity checker. `git diff --check` passes.
- SQL target selection and repeat application pass an in-memory fixture; unrelated ability rows remain unchanged.
- Ten server-backed lifecycle/party tests are provided but were not executed here. They cover repeated Saber/Fan use, expiration, Fan's per-hit floor and shared damage paths, missed attacks, Daze cleanup, and Chocobo Jig party selection.
- A complete C++ build, real database migration, packet/client validation, and encounter testing have not been run.

Before release, test DNC and /DNC unlocks at the changed levels, all six Sambas with/without Trance, both stances through overwrite/death/zone/cancel, Healing Waltz with Contradance on a full party, party/out-of-range Chocobo Jig, and distinct Samba types in separate alliance parties. Verify Fan Dance's 20% floor at every merit rank with normal attacks and multi-hit physical monster skills.
