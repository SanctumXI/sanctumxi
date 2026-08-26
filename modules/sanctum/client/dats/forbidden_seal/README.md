# Forbidden Seal client DAT edits

These are edit instructions, not generated replacement DATs. No client files were changed.

The English paths and entry IDs below were checked against the local client's `FTABLE.DAT` and decoded resources on 2026-08-25. Always start from the server's current client/DAT pack so existing customizations remain intact. Resolve the file IDs through that client's tables if its paths differ.

| DAT path | File ID | Record | Change |
| --- | ---: | --- | --- |
| `ROM/181/72.DAT` | 55701 | Ability names, string index **850** | `Unbridled Wisdom` to `Forbidden Seal` |
| `ROM/181/74.DAT` | 55733 | Ability descriptions, string index **850** | Replace with the ability description below |
| `ROM/180/102.DAT` | 55725 | Status names, index **505**, both strings | `Forbidden Seal` for both menu and log names |
| `ROM/119/57.DAT` | 87 | Status info, record **505** | Replace its description; preserve icon image, cancellation flag, and other fields |
| `ROM/118/114.DAT` | 81 | **Comm** job-ability record **850** | Change `shared_timer_id` / `recast_id` from **254** to **82**; preserve other fields |

Ability ID 338 in server SQL and Windower's job-ability resources corresponds to combined action/string index **850 = 512 + 338**. Do not edit string index 338 or the unrelated spell record with ID 850. The server-only status is **514**, but the displayed status is **505**; no client status-514 edit is needed.

## Text

Ability name: `Forbidden Seal`

Ability description:

```text
Uses HP instead of MP for your next spell.
Consumes 1 HP per MP; cannot reduce HP below 1.
Duration: 60 sec. Recast: 10 min.
```

Status description:

```text
Your next spell consumes HP instead of MP.
HP cannot be reduced below 1.
```

The ability-description table uses fixed 256-byte records in the inspected client. These descriptions fit, but use a format-aware DAT editor/export-rebuild workflow, not an in-place plain-text replacement. Preserve record IDs, padding, encoding, and unrelated entries. Re-export the result and confirm only the intended fields changed.

BLU level 10 and the 600-second timer come from server SQL. Do not guess at unknown bytes in the ability record to change the level or timer duration. Changing the client shared timer to 82 is necessary for its cooldown display to match the server.

## Distribution

- Package the five edited DATs in your existing client patch/overlay with the same relative ROM paths, then restart the client. Back up the prior pack first.
- If supporting another language, edit its corresponding name/description tables as well.
- Windower addons that use static resources also need `job_abilities[338].en = 'Forbidden Seal'`, `job_abilities[338].recast_id = 82`, the recast-name entry for 82, and both English names in `buffs[505]` updated. Regenerate or patch the server's distributed resources rather than relying on a local addon edit surviving an update.
- Once the renamed ability resources are loaded, the macro is `/ja "Forbidden Seal" <me>`.
- The legacy English status-name dialog, file ID 7029 (`ROM/27/74.DAT`), contains `(None)` at 505 in the inspected client. It is not the current Unbridled Wisdom name table. Update it only if a specific legacy tool in your pack actually reads that table.
- Keep the original ability animation and buff icon unless a separate visual replacement is desired.

Reference implementations: [Windower resource IDs and action-index conversion](https://github.com/Windower/ResourceExtractor/blob/master/Program.cs), [XI Tinkerer DAT mappings](https://github.com/InoUno/xi-tinkerer/blob/develop/crates/dats/src/id_mapping.rs), [status-info record format](https://github.com/InoUno/xi-tinkerer/blob/develop/crates/dats/src/formats/status_info.rs).
