# Zhayolm Remnants testing

Zhayolm Remnants is the first playable Salvage-I test slice. The supported milestone is a single
party of one to six level-65-or-higher players progressing from the Gilded Gateway through all
seven floors, defeating Battleclad Chariot, and exiting normally.

This is a functionality baseline, not a claim of capture-perfect retail behavior. The route and
spawn expectations below use the existing server data and the community-documented
[Zhayolm Remnants behavior](https://www.bg-wiki.com/ffxi/Zhayolm_Remnants).

## Starting a test

### Direct development entry

Start outside Alzadaal Undersea Ruins so the instance helper does not wait for an entrance event:

```text
!zone 210
!instance 7300
!instancecheck
!salvagecheck
```

Direct entry bypasses the gateway requirement check. It is the fastest way to test floor logic,
Pathos, temporary Fireflies, and instance completion. Do not use `!zone 73`; copied instance
entities only exist after an instance has been created.

Optional test conveniences:

```text
!godmode
!speed 80
```

### Gateway entry

Use this path to test the real entry checks:

```text
!zone 72
!pos -580 0 -405
```

Trigger the Gilded Gateway at that position. Every participating party member must:

- Be level 65 or higher.
- Have a Remnants Permit.
- Be in the same zone and within 50 yalms of the leader.
- Have no unused imbued cells.

On successful registration, verify that each player loses the permit, receives Zhayolm
Fireflies as a temporary item, is unequipped, and receives all five Pathos restrictions.

To test the normal permit purchase first, use a level-65-or-higher character that has completed
Treasures of Aht Urhgan mission 17. Zasshal is in Aht Urhgan Whitegate at `101.468 -1 -20.088`
(K-9). A permit costs 500 points from one of the five Assault areas.

```text
!zone 50
!pos 101.468 -1 -20.088
```

The purchase limit resets at Japanese midnight for every character.

For a disposable test character with no active Treasures of Aht Urhgan mission, these commands
prepare the mission gate and grant enough Leujaoam points to exercise the purchase menu:

```text
!addmission TOAU GUESTS_OF_THE_EMPIRE
!exec player:completeMission(xi.mission.log_id.TOAU, xi.mission.id.toau.GUESTS_OF_THE_EMPIRE)
!exec player:addAssaultPoint(xi.assault.assaultArea.LEUJAOAM_SANCTUM, 500)
```

Do not run the mission commands on a character whose normal mission progress matters.
Use `!addkeyitem REMNANTS_PERMIT` only when intentionally bypassing Zasshal to isolate gateway
or zone behavior. Every party member needs their own permit.

## Reading instance state

`!salvagecheck` prints the instance and runtime IDs, stage/progress, completion state, mob totals,
important Zhayolm local variables, permit/Fireflies state, and the five Pathos effects.

Use it:

- Immediately after entry.
- Before and after every floor transport.
- When an NM does not spawn.
- Before reporting a stuck door or exit.

`!checkinstance` remains useful for a minimal stage/progress check.

## Fast-forwarding safely

Do not use `!setstage` or `!setprogress` to skip a floor. Those commands only change numbers;
they do not run the transport event that despawns the old floor and spawns the next route.

To mark the current floor complete, use:

```text
!exec local i=player:getInstance(); i:setLocalVar('stageComplete', i:getStage())
```

Then walk onto a real transport pad and confirm the transport. This preserves the normal
transition path.

| Transition | Pad position(s) |
| --- | --- |
| Floor 1 to 2 | `420 0 -340`, `420 0 -500`, `260 0 -500`, `260 0 -340` |
| Floor 2 to 3 | `340 0 -60` |
| Floor 3 south/north to 4 | `340 0 420`, `340 0 500` |
| Floor 4 to 5 | `-380 0 -620`, `-300 0 -460` |
| Floor 5 to 6 | `-340 0 -100` |
| Floor 6 to 7 | `-340 0 140` |
| Floor 7 exits | `-380 0 500`, `-300 0 500` |

For a floor-six door-only check:

```text
!exec player:getInstance():setLocalVar('6th Door', 13)
```

Then interact with the door at `-340 -2 160`.

## Full smoke-test checklist

### Entry and floor 1

- Initial state is stage 1, progress 1.
- Starter mobs spawn and the entrance door opens.
- Opening one of the four route doors records the party size.
- Clearing a wing can spawn its Poroggo Gent and the first-floor Madame condition works.
- Only the selected floor-two route remains active.

### Floor 2

Test all four incoming routes in separate runs.

- The route boss appears after its eight base mobs die.
- Killing the boss reveals the correct Socket/Slot combination.
- All four exit doors open and the three unselected wings populate.
- Socket cell duplication and Slot card spawning complete without a Lua error.

### Floor 3

Test north and south in separate runs.

- Every required Mamool Ja and the route Rampart must be defeated.
- The Madame spawns even when the Rampart is the final kill.
- North Madame uses the armor drop set.
- South Madame uses the five-HP-cell/five-MP-cell drop set.

### Floor 4

- The timed Madame appears only inside the route's 30- or 47-minute window.
- Defeating the correct day-matched Rampart enables floor-five transport.
- A wrong Rampart returns the party to the alternate north room without corrupting the stage.
- Both randomized north layouts spawn distinct two-Savant/two-Sophist/two-Mimicker groups.

### Floor 5

- West and east routes spawn their own Chariot rather than the same entity.
- The path-specific Gear/Gears groups and Ramparts spawn.
- The Madame appears after the documented number of fully unlocked players is reached.

### Floors 6 and 7

- Engaging the floor-six Chariot spawns its twelve machinery mobs.
- The exit door opens at a count of 13 defeated central-room enemies.
- The floor-six Madame appears only after at least four earlier NMs were defeated.
- Battleclad Chariot completion enables exactly one of the two final exits.
- The completion cutscene returns every party member to Alzadaal Undersea Ruins.
- Fireflies and instance failure also return the activating player cleanly.

## Recording useful evidence

For every mismatch, record:

```text
Route:
Party size:
Vana'diel day:
Elapsed time:
Stage/progress before:
!salvagecheck output:
Enemy or door involved:
Expected:
Actual:
Relevant map-server log:
```

This makes player testing useful even without packet captures. Capture-dependent details can be
adjusted later without changing the stage/route structure.

## Known fidelity gaps

- The shared instance entry framework currently supports one party, not a full alliance.
- Mamool Ja Spearman and Strapper pets are present in SQL but their obsolete master-mixin scripts
  remain disabled pending a safe pet lifecycle implementation.
- Exact packets, cutscene timing, aggro details, and some drop rates have not been capture-verified.

## Pattern for the other Salvage zones

Keep each later zone split into the same responsibilities:

1. The Alzadaal gateway only validates and creates the instance.
2. The instance script owns stage transitions and route-to-spawn mappings.
3. Zone-local utilities own repeated route-completion and conditional-NM logic.
4. Mob scripts report kills to those utilities instead of duplicating full spawn tables.
5. `!salvagecheck` and a per-zone checklist provide the minimum observable test surface.
