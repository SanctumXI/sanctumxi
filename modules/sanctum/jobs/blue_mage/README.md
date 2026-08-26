# Blue Mage

`blue_magic.lua` and `blue_magic.sql` contain the existing spell adjustments.
`forbidden_seal.lua` and `forbidden_seal.cpp` repurpose Unbridled Wisdom as Forbidden Seal.

## Forbidden Seal

- BLU level 10; self-target only. Normal subjob availability is retained at /BLU 10.
- Recast: 600 seconds, on the otherwise unused recast group 82. It no longer shares the SP2 timer.
- Duration: 60 seconds or until one spell requires a positive MP payment.
- Any MP-cost spell qualifies, regardless of school. MP can be zero.
- The payment is the final MP cost after the existing cost modifiers and Conserve MP, paid as HP instead.
- HP payment is `min(final MP cost, current HP - 1)`. Even a cost greater than maximum HP leaves 1 HP. Using it at 1 HP is allowed and consumes the seal.
- Payment and consumption occur once, before spell effects resolve. Resists, misses, shadows, no-effect results, and multiple AoE targets do not refund or multiply the payment.
- Interrupted or rejected casts do not spend HP or consume the seal. Removing/expiring the seal during a cast restores the normal MP check at completion.
- Songs, ninjutsu tools, trusts, Manafont/ignore-MP casts, and spells reduced to zero MP do not consume it. Summoning upkeep and other non-spell costs are unchanged.
- Death, zoning, job change, cancellation, or expiration remove the buff. The HP floor applies to this payment, not a spell's own self-damage or sacrifice effect.

Server status 514 is reserved by this module and displays Unbridled Wisdom's icon/name index 505. Keeping the server status separate prevents the retail effect from unlocking Unbridled Learning spells or adding its job-point Conserve MP bonus. The existing effect script is reused with guarded Lua overrides. The internal ability name remains `unbridled_wisdom` for script lookup; the client DAT supplies the displayed name.

## Core integration exception

The existing module API had no hook before MP validation or at payment. Four core files add generic `CPPModule::OnSpellCostCheck` and `OnSpellCostSpend` dispatch: `src/map/utils/moduleutils.h`, `moduleutils.cpp`, `battleutils.cpp`, and `src/map/ai/states/magic_state.cpp`. They contain no Forbidden Seal IDs or rules, and leave ordinary casting unchanged when no module handles the cost.

`OnSpellCostCheck` returns true when a module can provide alternative payment. `OnSpellCostSpend` returns true after handling the final cost. The spend hook runs only at the normal MP-payment point, after cast validation and cost reductions, before target resolution.

`src/test/CMakeLists.txt` also includes the enabled C++ module sources from `xi_map` in `xi_test`; previously the test executable did not register these modules.

## Deployment and verification

1. Keep `sanctum` enabled in `modules/init.txt` (already enabled on this branch).
2. Apply `modules/sanctum/sql/blue_mage_forbidden_seal.sql` to the server database. It is an idempotent upsert.
3. Re-run the normal CMake configure step to discover the new C++ module, rebuild, and restart all map processes. Lua hot reload alone is insufficient.
4. Apply the client changes in [the DAT guide](../../client/dats/forbidden_seal/README.md).
5. Against a test database with the module SQL loaded, run:

   ```text
   xi_test --file modules/sanctum/jobs/blue_mage/forbidden_seal
   ```

The integration suite covers unlock/recast/status identity, White/Black/Blue Magic, modified costs, Conserve MP, current/max-HP limits, one-HP use, AoE, interrupts, mid-cast buff removal, free casts, and return to normal MP costs.

Local verification used the actual C++ module compiled against a mock engine API (20 passing cases), the repository LuaJIT DLL for module behavior and syntax, static SQL/YAML/DAT checks, and isolated CMake configuration checks with and without enabled modules. A full server build and `xi_test` execution have not been performed. No retail captures were used; these are custom rules. Verify the new C++ hooks, zero-MP casting from both menus and macros, cooldown display, buff cancellation, and tool/summon behavior on a running test server and client before deployment.
