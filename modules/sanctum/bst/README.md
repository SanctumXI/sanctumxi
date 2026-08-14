# Sanctum BST jug pet rebalance

Working notes for the jug pet pass. Read this before touching any family.

The goal is to give each jug pet family a distinct, legible role at the 75 cap.
Eleven of eighteen families are done. Balance and data changes live in this
module so upstream LSB data keeps flowing; only genuine engine bugs are patched
in core.

---

## Where everything lives

| What | Where |
|---|---|
| Per-family behaviour | `modules/sanctum/bst/<family>.lua`, via `m:addOverride('xi.actions.abilities.pets.<move>.onPetAbility', ...)` |
| Charge costs, AoE shape, skillchains, models, jobs, family stats, resistances | `modules/sanctum/sql/bst_jug_pets.sql` |
| Custom status effects | `modules/sanctum/data/status_effects.yaml` + `scripts/effects/<name>.lua` + alias in `scripts/enum/effect.lua` |
| Client skill **names** | `ROM/181/72.DAT` |
| Client **descriptions** | `ROM/181/74.DAT` |

DAT working copies:
`E:\FFXI\polplugins\DATs\Sanctum\ROM\181\` and a mirror in `...\Sanctum\Transfer\ROM\181\`
for upload. **Both must be written identically.** Back up before first touching a
new DAT file.

### DAT record maths

```
72.DAT  names:        record = 41040 + abilityId * 80          text at +24, 39 chars usable
74.DAT  descriptions: record = 303184 + (abilityId - 672) * 256 text at +24, 215 chars usable
```

Both use a 24-byte zero header and a constant 16-byte trailer at the end of the
record. Zero the whole text field before writing. Never change file length.

---

## Conventions

**Never edit `scripts/actions/abilities/pets/*.lua` or `scripts/actions/mobskills/*.lua`.**
Those are shared with every wild mob. Override `onPetAbility` from this module
instead. The one exception is engine bugs in shared globals, which get a small
core patch because overriding a 250-line function from a module would shadow
future upstream work on it.

**Tooltip house style**

```
N Charge(s): <what it does>.
```

- Optional `Skillchain: <Property>` at the end, **no trailing period** on that clause
- Two properties read `Skillchain: Darkness / Fragmentation`
- Never claim TP scaling that does not exist. Most jug fTPs are flat, so
  "Damage varies with TP" is usually false
- Never name the stat a move scales off. Scaling off max HP is fine to mention
- Charge counts in the text must match `abilities.recastTime`

**Family stat and resistance changes are family-wide by design** — they update
the shared `mob_family_system` and `mob_resistances` rows, so wild mobs of the
type change too. That is intended.

---

## Engine facts worth knowing

- **Charge cost lives in `abilities.recastTime`** for anything on recast id 102
- **Party reach** is `pet_skills.pet_skill_aoe`: `0` + valid_targets `3` reaches
  the pet and master only; `1` + `3` reaches the whole party. Party moves use
  radius 10
- **`mob_pool_mods` and `mob_family_mods` are never loaded for pets.** There is
  no per-pet modifier table. Passives come only from `mob_pools.mJob` traits and
  the family stat/resist rows. This was investigated and deliberately abandoned
- **Skillchain properties** are `pet_skills.primary_sc` / `secondary_sc`. Lookup
  key is `{new skill property, existing resonance}` so order matters. Same-property
  pairs never chain except Light+Light and Darkness+Darkness
- **Smite never applies to pets** — gated behind `objtype & TYPE_PC`
- **Martial Arts never applies to pets** — `isHandToHand()` checks weapon *skill
  type*, which jug pets never get
- **Dead Aim and Kick Attacks** do nothing for pets (unimplemented / auto-attack only)
- **`onMobSkillFinalize` is not called for pets** (commented out in `petskill_state.cpp`)
- **Pet Treasure Hunter applies to the mob's hate list** — a THF pet gives the party TH
- **Pet TP moves carry real TP.** `petskill_state` spends whatever the pet has
  banked and zeroes it, so a three-entry fTP is live: spam Ready and every move
  sits at fTP[1], let the pet swing and it climbs toward fTP[3]. fTP
  interpolates smoothly between entries
- Jug attack delay is hard-coded 240, discarding `mob_pools.cmbDelay` (open defect).
  `LoadJugStats` has a "reduce weapon delay of MNK" branch, but `CalculateJugPetStats`
  sets base delay to 240 two lines earlier, so `resetDelay()` restores 240 and the
  branch does nothing
- **Sleep is `overwrite: higher`**, a strict `>`. Sleep/Sleepga are power 1,
  Sleep II/Sleepga II power 2. A pet sleep at power 1 cannot overwrite either,
  and cannot refresh its own; `delStatusEffect` first is the only way round it
- Call Beast and Bestial Loyalty flatten every pet to base speed 55 after
  spawning; override both with `super()` first if a family needs different

### Core fixes already made

- `xi.combat.magicBurst` does not exist. Three call sites in `mobskills.lua`
  indexed it; one was reachable by any pet using a magical mobskill, so **every
  pet magical move dealt zero damage**. Now calls `xi.magicburst.formMagicBurst`
- `calculateNullification` / `calculateAbsorption` were called with six arguments
  against four- and three-parameter signatures
- Effect 611 pointed at a script that does not exist, so Magic Evasion Boost
  granted nothing

---

## Status

**Done:** Crab, Funguar, Sheep, Hill Lizard, Rabbit, Beetle, Sabotender,
Diremite, Apkallu, Eft, Ladybug, Mandragora, Tiger, Flytrap, Frog

**Cut:** Pugil. Recipe 74516 is deleted and nothing else in the database grants
jug 17906, so Turbid Toloi is retired instead of rebalanced.

**Remaining:** Coeurl, Antlion, Fly

### Per-family workflow

1. Report family stats (`mob_family_system`), resistances (`mob_resistances`,
   noting how many pools share the row), job traits at level 78-80, damage
   expectations, and how the repo's believed behaviour differs from the code
2. Wait for the numbers and design decisions
3. Implement: module Lua + SQL, then both DAT copies
4. Verify the DAT writes by reading the records back and diffing copies
5. Commit and push to `origin/steel-comitt`

### Known open items

- **Mandragora** Dream Flower is left at sleep power 1 and a random 15 to 45
  second duration, so it cannot overwrite a Sleepga or refresh itself. It is
  also centred on the pet and catches the pet's own target, which the pet then
  auto-attacks awake
- **Coeurl** has no damaging move at all. Charged Whisker and Frenzied Rage exist
  in `pet_skills` but are wired only to Jug_Lynx at 99
- **Frog Cheer is a new ability id (739)**, taken from a free slot inside the
  jug pet block whose client name and description records were empty
  placeholders. Needs in-game confirmation that it lists in the Ready menu.
  Its status effect reuses id 813, so the client will label the buff whatever
  it calls that effect until the status name DAT is edited too
- **Only Elemental ecosystem pets cast.** `CPetEntity::Spawn` calls
  `mobutils::GetAvailableSpells` behind `m_EcoSystem == Ecosystem::Elemental`,
  so spirits and avatars compile `mob_pools.spellList` into `SpellContainer` and
  every jug pet leaves it empty. `CanCastSpells` fails on `HasSpells()` first,
  so a jug pet never casts however full its list is. Confirmed in game. Flytrap
  (list 3), Antlion, Mite, Lifedrinker Lars and Chopsuey Chucky (list 5) all
  carry lists that have never fired
- **To make one pet cast**, call `pet:setSpellList(id)` on spawn:
  `mobutils::SetSpellList` compiles the container, which is the step the
  ecosystem gate skips. The hook is `xi.pets.jug.onMobSpawn` —
  `CPetEntity::Spawn` calls `OnMobSpawn` and `GetScriptName` returns `jug` for
  every jug pet. There is no `scripts/globals/pets/jug.lua` yet; the other pet
  types all have one
- **MP is granted by main job only**, in `LoadJugStats`: PLD, WHM, BLM, RDM,
  DRK, BLU and SCH. Any other job gets a flat 0 and cannot pay for a spell
- **Sabotender** moves fast but does not swing fast; needs the delay fix
- Wing Slap and Beak Lunge tooltips say fivefold/twofold; the code does 4 and 1
