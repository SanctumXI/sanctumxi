# NewEquipmentStats

`NewEquipmentStats` adds new server-side equipment modifiers.

| Gear text | Lua/C++ modifier | ID | Server behavior |
| --- | --- | ---: | --- |
| `Magic Burst MP +2%` | `MAGIC_BURST_MP` | 1221 | Restores `floor(base spell MP cost * value / 100)` MP once when a cast lands at least one magic burst. An AoE burst pays once per cast, not once per target. |
| `Tactics +1` | `TACTICS` | 1222 | Grants 5 TP per point after a shield block or guard that actually applies. This stacks with Shield Mastery and Tactical Guard. |
| `Buff Duration +1` | `BUFF_DURATION` | 1223 | Adds one second per point to eligible buffs applied by the wearer to themself, an allied player, or a player-owned companion (pet or trust). |
| `Additional Effect Rate +1` | `PROC_RATE` | 1224 | Adds one percentage point per point to weapon additional-effect proc chance, clamped to 100%. |
| `Skillchain TP +1` | `SKILLCHAIN_TP` | 1225 | Grants 10 TP per point when the wearer successfully closes a skillchain. |
| `Recast -1` | `RECAST_RATE` | 1226 | Subtracts one second per point from the final spell and job-ability recast. |

## Assigning stats to equipment

Replace `12345` with the server item ID. The normal modifier loader automatically totals these values while the item is equipped.

```sql
INSERT INTO `item_mods` (`itemId`, `modId`, `value`) VALUES
    (12345, 1221, 2), -- Magic Burst MP +2%
    (12345, 1222, 1), -- Tactics +1 (5 TP per block/guard)
    (12345, 1223, 3), -- Buff Duration +3 seconds
    (12345, 1224, 4), -- Additional Effect Rate +4 percentage points
    (12345, 1225, 1), -- Skillchain TP +1 (10 TP)
    (12345, 1226, 2)  -- Recast -2 seconds
ON DUPLICATE KEY UPDATE `value` = VALUES(`value`);
```

The names are also available to Lua as `xi.mod.MAGIC_BURST_MP`, `xi.mod.TACTICS`, `xi.mod.BUFF_DURATION`, `xi.mod.PROC_RATE`, `xi.mod.SKILLCHAIN_TP`, and `xi.mod.RECAST_RATE`.
