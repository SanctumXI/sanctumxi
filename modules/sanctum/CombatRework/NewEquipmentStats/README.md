# NewEquipmentStats

`NewEquipmentStats` adds six server-side equipment modifiers for Sanctum. Client DAT edits only control the text shown on an item; assign the matching modifier in `item_mods` to activate its gameplay effect.

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

## Buff Duration eligibility

This uses a safety filter rather than a brittle whitelist, so new normal buffs work without another code edit. A status is extended only when all of these are true:

- It has a positive timer and a visible icon.
- Its `origin` resolves to the equipped player, or to a pet or trust that player owns.
- The target is allied and is a player, pet, or trust.
- It is not a debuff, food/item effect, synthesis support, battlefield/influence effect, aura, bust, weakness, KO, skillchain window, or Overload.

Note the trade-off the filter makes: it never misses a new buff, but it extends anything detrimental that carries none of the excluded flags. Overload is the known case and is denied by name in `isEligibleBuff`. Add any future self- or pet-inflicted penalty to that same switch rather than assuming the flag filter covers it.

Buffs created with the standard Lua form should pass their source explicitly:

```lua
target:addStatusEffect(xi.effect.REGEN, { power = 5, duration = 60, origin = player })
```

Bard songs now set their origin in the C++ Lua binding, and Corsair rolls already carry it. Duration is extended once when the effect is created; loading, copying, stealing, and Corsair Double-Up do not apply the bonus a second time.

## Proc and recast scope

`PROC_RATE` covers the declarative `ITEM_ADDEFFECT_*` framework, all scripted weapons using the shared damage/status executors, and all ten direct-roll Excalibur variants currently in the repository. It intentionally does not alter enspells, spikes, double/triple attack, counters, or unrelated job-trait procs.

A proc chance of zero stays at zero. 115 items carry `ITEM_ADDEFFECT_TYPE` with no `ITEM_ADDEFFECT_CHANCE` row and therefore never proc today; `PROC_RATE` does not switch them on. The shared executors treat a missing `chance` as "always proc" (see `validateParameters`), and the override preserves that default before adding the bonus.

## Magic Burst MP coverage

A burst is detected from the message the spell script swaps in. `spell_list.magicBurstMessage` is the authoritative per-spell value and is used whenever it differs from the spell's normal message, which covers Aspir and MP Drainkiss (275) and the ninjutsu enfeebles (267). Cures (7), Paralyze (84) and elemental ninjutsu (2) reuse their normal message for the burst, so a burst on those is not detectable and pays nothing; none of them are meaningful MP refunds. Blue magic enfeebles hardcode their burst message instead of reading the column, so the known burst-only ids are checked as well.

## Recast behavior

`RECAST_RATE` is applied after the existing percentage reductions and caps, so it can push a spell past the usual 50% floor; ordinary recasts can reach zero.

Charge-based abilities are reduced per charge, not per use, and keep a one-second minimum per charge. Using two charges with `Recast -2` therefore takes four seconds off the total, not two. The reduced charge time is what gets stored in the recast container, so charge regeneration stays at the reduced rate for that timer even if the gear comes off afterwards.

Blood Pact timers are reduced at the point their delayed recast is snapshotted.

## Build note

`modules/init.txt` already lists `sanctum`, so both files load without an edit. The CMake glob that picks up module `.cpp` files is not `CONFIGURE_DEPENDS` — only `init.txt` is tracked — so adding this module needs one CMake re-configure before it appears in the build.
