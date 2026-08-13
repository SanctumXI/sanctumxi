# Sanctum customizations

- Put Sanctum-specific changes in `modules/sanctum` by default so upstream `src`, `scripts`, and `sql` files remain replaceable.
- Keep related Lua behavior in a clearly named module instead of making one file per mob or tiny fix.
- Put SQL overrides in `modules/sanctum/sql`. Make repeatable changes idempotent with upserts, and guard one-time setup data with a persistent version marker.
- Prefer Lua overrides, SQL module upserts, data modules, and supported C++ module hooks, in that order. Change a base file only when the module API cannot express the behavior safely, and identify that exception clearly.
- Write simple, human-readable code with few comments. Add a comment only when it explains a non-obvious constraint or safety decision.
