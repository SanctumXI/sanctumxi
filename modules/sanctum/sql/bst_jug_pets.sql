-- Sanctum jug pet rebalance.
-- Loaded after the core abilities and pet_skills tables by dbtool.
--
-- Charge cost lives in abilities.recastTime for anything on a charge recast.
-- pet_skill_aoe 1 with valid_targets 3 reaches the master's whole party;
-- 0 only reaches the pet and the master. Party-facing moves use radius 10.

-- Crab: Crab Familiar / Courier Carrie

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 694; -- Bubble Curtain, was 3
UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 697; -- Metallic Body, was 1

UPDATE `pet_skills` SET `pet_skill_aoe` = 1, `pet_skill_radius` = 10 WHERE `pet_skill_id` = 694; -- Bubble Curtain, party
UPDATE `pet_skills` SET `pet_skill_aoe` = 1, `pet_skill_radius` = 10 WHERE `pet_skill_id` = 696; -- Scissor Guard, party

-- Funguar: Funguar Familiar
-- Charge costs are unchanged: the shrooms stay at 2, Silence Gas and Dark Spore
-- stay at 3.

-- WAR to RDM. Trades Attack Bonus II, Double Attack II, Smite II and 60 base HP
-- for Fast Cast, Magic Atk/Def Bonus and Resist Petrify. Net +9 INT, -11 STR.
UPDATE `mob_pools` SET `mJob` = 5 WHERE `poolid` = 4614; -- Funguar Familiar

-- Beast Affinity merits are applied after the master level cap, so 71 lands a
-- merited master at 74 to 76. The Funguar still never reaches the roster's 80.
UPDATE `pet_list` SET `maxLevel` = 71 WHERE `petid` = 32; -- Funguar Familiar, was 65

-- Sheep: Sheep Familiar / Lullaby Melodia / Nursery Nazuna
-- Sheep Charge opens Reverberation and Lamb Chop closes it for Impaction, so
-- the pair costs the full charge bar.

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 689; -- Lamb Chop, was 1
UPDATE `abilities` SET `recastTime` = 3 WHERE `abilityId` = 690; -- Rage, was 2

UPDATE `pet_skills` SET `pet_skill_radius` = 14 WHERE `pet_skill_id` = 692; -- Sheep Song, was 10

-- Nursery Nazuna wears the Wild Karakul model (pool 4342). Its sizes were NULL,
-- which left it with a zero hitbox and shorter reach than the other two sheep.
UPDATE `mob_pools`
   SET `modelid`         = 0x0000550100000000000000000000000000000000,
       `modelSize`       = 1,
       `modelHitboxSize` = 24
 WHERE `poolid` = 4629; -- Nursery Nazuna

-- Rage's 25% attack put Nazuna second on the roster for raw damage, which is
-- not what a sheep is for. Merits land it at 78 rather than 80.
UPDATE `pet_list` SET `maxLevel` = 73 WHERE `petid` = 57; -- Nursery Nazuna, was 80

-- Lizard: Lizard Familiar / Coldblood Como / Audacious Anna
-- Brain Crush opens Liquefaction and Tail Blow closes it for Fusion, a tier 2
-- chain for 2 charges. Blockhead into Tail Blow gives Impaction instead.
-- Infrasonics stays at 2 charges.

UPDATE `pet_skills` SET `pet_skill_aoe` = 1, `pet_skill_radius` = 10 WHERE `pet_skill_id` = 688; -- Secretion, party

-- Family-wide stat and resistance changes. These apply to every wild mob of the
-- family as well as the jug pets, which is intended.
UPDATE `mob_family_system` SET `STR` = 4, `INT` = 4 WHERE `familyID` = 338; -- Funguar, was STR 3 / INT 5
UPDATE `mob_family_system` SET `CHR` = 3 WHERE `familyID` = 111;            -- Sheep, was 4

UPDATE `mob_resistances` SET `earth_res_rank`      =  4 WHERE `resist_id` = 174; -- Lizard, was 0
UPDATE `mob_resistances` SET `slow_res_rank`       = -4 WHERE `resist_id` = 77;  -- Crab, was -2
UPDATE `mob_resistances` SET `earth_res_rank`      =  0 WHERE `resist_id` = 116; -- Funguar, was -2
UPDATE `mob_resistances` SET `light_sleep_res_rank` = 4 WHERE `resist_id` = 226; -- Sheep, was -2

UPDATE `mob_family_system` SET `AGI` = 3, `EVA` = 2 WHERE `familyID` = 106;      -- Rabbit, was AGI 4 / EVA 3
UPDATE `mob_resistances` SET `slow_res_rank`        = 4 WHERE `resist_id` = 206; -- Rabbit, was -1

-- Rabbit: Hare Familiar / Keeneared Steffi / Lucky Lulush
-- WAR to DNC. Trades Attack Bonus II, Double Attack III and 120 base HP for
-- Accuracy Bonus III, Evasion Bonus III, Subtle Blow IV and Skillchain Bonus
-- III. Net +4 AGI and +11 CHR against -12 STR and -3 VIT at level 78.
-- THF was the other candidate but carries Treasure Hunter and Gilfinder, which
-- a pet applies to the mob's hate list.
UPDATE `mob_pools` SET `mJob` = 19 WHERE `poolid` IN (4595, 4612, 4641);

-- Keeneared Steffi wears the Lapinion model (pool 4961, East Ulbuka).
-- Lucky Lulush already uses the snow rabbit model, same as Snowpaw Rabbit.
UPDATE `mob_pools` SET `modelid` = 0x0000910700000000000000000000000000000000 WHERE `poolid` = 4595;

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 734; -- Snow Cloud, was 1

UPDATE `pet_skills` SET `pet_skill_aoe` = 1 WHERE `pet_skill_id` = 734; -- Snow Cloud, cone -> radial like Whirl Claws

-- Beetle: Beetle Familiar / Panzer Galahad
-- Cannot self skillchain: Power Attack is Reverberation and Rhino Attack is
-- Detonation, and neither closes the other. Power Attack does close a party
-- member's Induration for Fragmentation.
-- Light sleep was already -3 and dark sleep already 0, so neither moved.

UPDATE `mob_resistances`
   SET `fire_res_rank`  =  2,
       `wind_res_rank`  = -2,
       `earth_res_rank` =  2,
       `dark_res_rank`  =  2,
       `blind_res_rank` =  2
 WHERE `resist_id` = 49; -- Beetle, all five were 0

UPDATE `abilities` SET `recastTime` = 1 WHERE `abilityId` = 708; -- Hi-Freq Field, was 2

-- Sabotender: Amigo Sabotender
-- Needleshot opens Transfixion; 1,000 Needles carries Darkness with
-- Fragmentation as its secondary, the best chain properties on any pet move.
-- Neither closes the other, so no self chain.

UPDATE `mob_family_system`
   SET `STR`   = 4,
       `DEX`   = 1,
       `AGI`   = 1,
       `EVA`   = 1,
       `speed` = 90
 WHERE `familyID` = 334; -- was STR 2 / DEX 5 / AGI 3 / EVA 3 / speed 40

UPDATE `mob_resistances`
   SET `fire_res_rank` = -3,
       `bind_res_rank` =  4,
       `slow_res_rank` =  4
 WHERE `resist_id` = 212; -- was fire -2 / bind -3 / slow 0

UPDATE `pet_skills` SET `pet_skill_radius` = 4 WHERE `pet_skill_id` = 699; -- 1,000 Needles, was 10

-- Merits land a merited master at 79. minLevel stays 75: that column gates the
-- master's level, not the pet's, so it is independent of the cap.
UPDATE `pet_list` SET `maxLevel` = 74 WHERE `petid` = 47; -- Amigo Sabotender, was 80

-- Diremite: Mite Familiar / Lifedrinker Lars
-- Skillchain properties are consolidated onto Spinning Top, which becomes the
-- family's premium closer. Darkness closes Darkness for Darkness II and
-- Fragmentation closes Fusion for Light. Nothing else in the kit carries a
-- property, so the Diremite no longer self chains.

UPDATE `mob_family_system`
   SET `VIT` = 5,
       `DEX` = 3,
       `CHR` = 3,
       `DEF` = 4,
       `EVA` = 4
 WHERE `familyID` = 442; -- was VIT 4 / DEX 4 / CHR 4 / DEF 3 / EVA 3

UPDATE `mob_resistances` SET `light_sleep_res_rank` = -3 WHERE `resist_id` = 81; -- Diremite, was -2

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 727; -- Grapple, was 1
UPDATE `abilities` SET `recastTime` = 3 WHERE `abilityId` = 728; -- Spinning Top, was 1
UPDATE `abilities` SET `recastTime` = 1 WHERE `abilityId` = 729; -- Filamented Hold, was 2

-- 14 = Darkness, 12 = Fragmentation. The @SC_ variables are only defined while
-- pet_skills.sql itself is running, so these are the raw values.
UPDATE `pet_skills` SET `primary_sc` = 14, `secondary_sc` = 12 WHERE `pet_skill_id` = 728; -- Spinning Top, was Impaction
UPDATE `pet_skills` SET `primary_sc` = 0, `secondary_sc` = 0 WHERE `pet_skill_id` IN (
    699, -- 1,000 Needles, was Darkness / Fragmentation
    726, -- Double Claw, was Liquefaction
    727  -- Grapple, was Reverberation
);

-- Apkallu: Dapper Mac
-- Wing Slap becomes the Light counterpart to the Diremite's Spinning Top.
-- Fragmentation closes Fusion for Light; Light closes Light for Light II.

UPDATE `mob_resistances`
   SET `fire_res_rank`      =  2,
       `ice_res_rank`       =  2,
       `lightning_res_rank` = -3,
       `dark_res_rank`      = -2
 WHERE `resist_id` = 27; -- Apkallu, was fire +1 / ice +1 / lightning -2 / dark -1

-- 12 = Fragmentation, 13 = Light.
UPDATE `pet_skills` SET `primary_sc` = 12, `secondary_sc` = 13 WHERE `pet_skill_id` = 756; -- Wing Slap, was Gravitation / Liquefaction
UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 757;                       -- Beak Lunge, was Scission

-- Eft: Eft Familiar / Ambusher Allie / Bugeyed Broncha
-- WAR to RNG. Trades Attack Bonus II, Double Attack III and 120 base HP for
-- Accuracy Bonus IV and RNG's AGI grade 1, the best in the game. With the
-- family rank also moving that is +16 AGI against -15 STR at level 78; DEX
-- comes out level, since the family gain cancels the job's weaker grade.
UPDATE `mob_pools` SET `mJob` = 11 WHERE `poolid` IN (4621, 4622, 4633);

UPDATE `mob_family_system` SET `DEX` = 3, `AGI` = 2 WHERE `familyID` = 303; -- was DEX 4 / AGI 4

UPDATE `mob_resistances`
   SET `lightning_res_rank` = -2,
       `water_res_rank`     =  3,
       `poison_res_rank`    =  3,
       `blind_res_rank`     = -2
 WHERE `resist_id` = 98; -- Eft, was lightning -1 / water +2 / poison +2 / blind -1

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 721; -- Geist Wall, was 1
UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 722; -- Numbing Noise, was 1
UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 723; -- Nimble Snap, was 1
UPDATE `abilities` SET `recastTime` = 1 WHERE `abilityId` = 725; -- Toxic Spit, was 2

UPDATE `pet_skills` SET `pet_skill_radius` = 8, `primary_sc` = 0 WHERE `pet_skill_id` = 724; -- Cyclotail, was radius 10 / Impaction
UPDATE `pet_skills` SET `pet_skill_distance` = 20.0 WHERE `pet_skill_id` = 725;              -- Toxic Spit, was 3

-- Ladybug: Dipper Yuly
-- A THF pet, so it carries Treasure Hunter II and Gilfinder to the mob's hate
-- list. That is the reason to bring one; the rest of the kit is deliberately
-- feeble. Family VIT is rank 7, the worst on the roster, and the resist row
-- takes 25% extra piercing damage.

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 737; -- Spiral Spin, was 1

UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 736; -- Sudden Lunge, was Impaction
UPDATE `pet_skills` SET `primary_sc` = 6 WHERE `pet_skill_id` = 737; -- Spiral Spin: Detonation, was Scission

-- Noisome Powder becomes Lucky Spots, a party buff rather than an enemy debuff.
-- 3 = SELF | PLAYER_PARTY, and 238 is the buff message the other party-facing
-- moves use.
UPDATE `pet_skills`
   SET `pet_valid_targets` = 3,
       `pet_message`       = 238
 WHERE `pet_skill_id` = 738; -- was 4 (enemy) / 242

-- Pugil: Turbid Toloi
-- Cut rather than rebalanced. The recipe is the only source of jug 17906 in the
-- database, so dropping it retires the pet.

DELETE FROM `synth_recipes` WHERE `ID` = 74516; -- Auroral Broth, Cooking 93

-- Mandragora: Homunculus / Flowerpot Bill / Flowerpot Ben
-- Dream Flower goes to a single charge, the cheapest area sleep in the game.
-- Wild Oats picks up the charge it gives away.
-- Family INT is rank 4 against MNK's INT grade 7, the worst pairing on the
-- roster; rank 2 buys back most of what the job costs. Sleep magic accuracy is
-- the A+ skill cap plus the INT difference and nothing else, so this is the
-- only lever the family has.

UPDATE `mob_family_system` SET `INT` = 2 WHERE `familyID` = 350; -- was 4

-- Flowerpot Ben lands a merited master at 66 to 68. Note Homunculus shares the
-- family and its kit, is available from level 23, and still caps at 75, so Ben
-- is now strictly the worse of the two.
UPDATE `pet_list` SET `maxLevel` = 63 WHERE `petid` = 38; -- Flowerpot Ben, was 75

-- 2500 is a quarter again as much damage taken. It moves from piercing to
-- slashing; the rest of the row is elemental and status ranks.
UPDATE `mob_resistances`
   SET `slash_sdt`          = 2500,
       `pierce_sdt`         =    0,
       `lightning_res_rank` =    0,
       `water_res_rank`     =    1,
       `light_res_rank`     =    3,
       `dark_res_rank`      =   -2,
       `poison_res_rank`    =   -1
 WHERE `resist_id` = 178; -- was slash 0 / pierce 2500 / lightning -3 / water 0 / light 0 / dark -3 / poison 0

UPDATE `abilities` SET `recastTime` = 1 WHERE `abilityId` = 676; -- Dream Flower, was 2
UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 677; -- Wild Oats, was 1

-- Scission on Leaf Dagger is the family's only skillchain property, so the
-- Mandragora cannot chain with itself.
UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 675; -- Head Butt, was Detonation
UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 677; -- Wild Oats, was Transfixion

UPDATE `pet_skills` SET `pet_skill_distance` = 5.0 WHERE `pet_skill_id` = 678; -- Leaf Dagger, was 3

-- Tiger: Tiger Familiar / Saber Siravarde
-- The party's attack buff on the best melee chassis on the roster: A ranks in
-- attack and accuracy, and WAR's A grade strength on top. Nearly all of WAR's
-- kit works on a pet, unlike MNK's; only Smite and the two shield traits are
-- dead.

-- Beast Affinity merits are added after the level cap in petutils, so this is a
-- soft cap: a master with the merits can still exceed it.
UPDATE `pet_list` SET `maxLevel` = 72 WHERE `petid` = 39; -- Saber Siravarde, was 75

UPDATE `mob_family_system` SET `STR` = 3, `AGI` = 3, `DEF` = 4 WHERE `familyID` = 114; -- was STR 4 / AGI 4 / DEF 3

-- Roar stops being an area paralyse and becomes the party's attack buff. It
-- already reached radius 10 from the pet; 3 = SELF | PLAYER_PARTY, and 238 is
-- the message the Crab's party buffs use.
UPDATE `pet_skills`
   SET `pet_valid_targets` = 3,
       `pet_message`       = 238
 WHERE `pet_skill_id` = 680; -- was 4 (enemy) / 242

-- Crossthrash keeps Distortion / Detonation and becomes the family's only
-- skillchain, so the Tiger cannot chain with itself.
UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 681; -- Razor Fang, was Impaction
UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 682; -- Claw Cyclone, was Scission

-- Flytrap: Flytrap Familiar / Voracious Audrey
-- The slow and paralyse specialist. Both moves drop to a single charge and the
-- area sleep pays for them, staying deliberately worse than Sheep Song and
-- Dream Flower. No behaviour changes, so the family needs no module file: the
-- upstream Slow 2000 over 120 seconds and Paralyze 30 over 60 are kept as they
-- are.
--
-- The pools already run RDM. Note their spellList is inert: petutils never
-- compiles it into the container the caster checks, so no pet has ever cast.

UPDATE `mob_family_system` SET `INT` = 3, `MND` = 2 WHERE `familyID` = 336; -- was INT 4 / MND 4

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 718; -- Soporific, was 1
UPDATE `abilities` SET `recastTime` = 1 WHERE `abilityId` = 719; -- Gloeosuccus, was 2

-- Palsy Pollen is Paralysis Pollen in the client now, and picks up the cone its
-- own script header always claimed it had. 4 = conal, same shape as
-- Gloeosuccus.
UPDATE `pet_skills`
   SET `pet_skill_aoe`    = 4,
       `pet_skill_radius` = 10
 WHERE `pet_skill_id` = 720; -- was single target at radius 0

-- Flytrap Familiar's sizes were NULL, which left it a zero hitbox and shorter
-- reach than Voracious Audrey. Both pools carried cmbDelay 200, which the
-- hard-coded jug delay of 240 discards; set to 240 so the data is honest.
UPDATE `mob_pools`
   SET `modelSize`       = 0,
       `modelHitboxSize` = 12
 WHERE `poolid` = 4619; -- Flytrap Familiar, both were NULL

UPDATE `mob_pools` SET `cmbDelay` = 240 WHERE `poolid` IN (4619, 4620); -- was 200

-- Frog: Slippery Silas
-- The only jug pet that casts. He had no skill list, no spell list and SMN as a
-- main job, which grants no MP at all, so he did nothing whatsoever.

-- SMN to BLM. BLM is one of the seven jobs LoadJugStats gives MP to, matches
-- what the wild Poroggos run, and takes family INT rank A to 75 at level 75,
-- the highest on the roster.
UPDATE `mob_pools` SET `mJob` = 4, `sJob` = 4 WHERE `poolid` = 4639;

-- A short list rather than the family's full Beastmen_BLM, which reaches
-- Ancient Magic. The spawn hook in modules/sanctum/bst/frog.lua is what
-- actually compiles it; setting the pool column keeps the data honest.
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 171, 1, 255); -- water_iii
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 200, 1, 255); -- waterga_ii
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 214, 1, 255); -- flood
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 240, 1, 255); -- drown
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 247, 1, 255); -- aspir

UPDATE `mob_pools` SET `spellList` = 900 WHERE `poolid` = 4639; -- was 0

-- Frog Cheer as a ready move. Ability 739 was a free slot inside the jug pet
-- block and already had empty name and description records in the client.
-- mob_skill 1960 and animation 1362 are the Poroggo's own, so the animation is
-- native to the model.
REPLACE INTO `abilities` VALUES (739, 'frog_cheer', 9, 25, 257, 3, 102, 0, 0, 0, 2000, 0, 6, 3.0, 0, 10, 1, 60, 0, 0, NULL);

-- 1 = radial from the pet, 3 = SELF | PLAYER_PARTY, 238 is the message the
-- other party-facing moves use. The literal 0s are SKILLFLAG_NONE and no
-- skillchain; the @ variables only exist while pet_skills.sql itself runs.
REPLACE INTO `pet_skills` VALUES (739, 1960, 1362, 'frog_cheer', 1, 10, 3, 2000, 1500, 3, 238, 0, 0, 11, 0, 0, 0, 0);

REPLACE INTO `mob_skill_lists` VALUES ('Jug_Frog', 30002, 739);

UPDATE `mob_pools` SET `skill_list_id` = 30002 WHERE `poolid` = 4639; -- was 0

-- Antlion: Antlion Familiar / Chopsuey Chucky
-- The widest area coverage on the roster: one radial and two cones. DRK gives
-- it Attack Bonus V, the largest flat attack trait in the game, which is why
-- the family leans physical.
--
-- Sandblast stays radial rather than becoming a cone; a circle around the pet
-- covers more ground than a 45 degree wedge, which is the point of the family.

UPDATE `mob_family_system` SET `STR` = 2, `EVA` = 4 WHERE `familyID` = 422; -- was STR 4 / EVA 3

UPDATE `mob_resistances` SET `earth_res_rank` = 6 WHERE `resist_id` = 26; -- was 3

-- 4 = conal. Detonation goes, leaving the family with no skillchain property.
UPDATE `pet_skills`
   SET `pet_skill_aoe`    = 4,
       `pet_skill_radius` = 10,
       `primary_sc`       = 0
 WHERE `pet_skill_id` = 717; -- Mandibular Bite, was single target at radius 0 / Detonation

UPDATE `pet_skills` SET `pet_skill_radius` = 12 WHERE `pet_skill_id` = 716; -- Venom Spray, was 10

-- Coeurl: Crafty Clyvonne
-- Single target damage carried by attack speed. The resist row is -2 or worse
-- on every element and every status, the softest on the roster, which is the
-- price of it.

UPDATE `mob_family_system` SET `AGI` = 3, `CHR` = 2, `INT` = 2 WHERE `familyID` = 92; -- was AGI 4 / CHR 4 / INT 3

-- 25% haste for every coeurl in the game. 383 is HASTE_ABILITY, which caps at
-- exactly 25% and is a separate bucket from magic haste, so a Haste spell still
-- stacks on top instead of being wasted.
--
-- This row never reaches Crafty Clyvonne: AddSqlModifiers runs for mobs and
-- trusts only, never from petutils. She takes 40% on spawn in coeurl.lua.
INSERT INTO `mob_family_mods` (`familyid`, `modid`, `value`, `is_mob_mod`) VALUES (92, 383, 2500, 0)
    ON DUPLICATE KEY UPDATE `value` = VALUES(`value`), `is_mob_mod` = VALUES(`is_mob_mod`); -- HASTE_ABILITY 25%

UPDATE `abilities` SET `recastTime` = 3 WHERE `abilityId` = 731; -- Blaster, was 2

-- Sizes were NULL, so she had a zero hitbox and less melee reach than any wild
-- coeurl. 1 and 16 are the family standard.
UPDATE `mob_pools`
   SET `modelSize`       = 1,
       `modelHitboxSize` = 16
 WHERE `poolid` = 4608; -- Crafty Clyvonne, both were NULL

-- Fly: Mayfly Familiar / Shellbuster Orob
-- Magic damage out of ready moves, against Slippery Silas doing his with
-- spells. WAR gave this family neither of the two things magical mobskill
-- damage scales on, so both pets move to BLM for its intelligence grade and
-- Magic Attack Bonus 32.

UPDATE `mob_pools` SET `mJob` = 4, `sJob` = 4 WHERE `poolid` IN (4596, 4597); -- was WAR

-- Strength to rank A. BLM's own strength grade is F, the second worst in the
-- game, and auto-attacks are the bulk of any pet's output, so the family rank
-- is what stops a caster chassis from being dead weight between charges.
UPDATE `mob_family_system` SET `STR` = 1, `DEX` = 3, `AGI` = 2 WHERE `familyID` = 444; -- was STR 5 / DEX 4 / AGI 3

-- Beast Affinity merits are added after the cap, so 70 lands a merited master
-- at 73 to 75. Note this is a reduction: the row read 75, not the 65 assumed.
UPDATE `pet_list` SET `maxLevel` = 72 WHERE `petid` = 41; -- Shellbuster Orob, was 75

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 712; -- Cursed Sphere, was 1

-- Sizes were NULL, the same zero-hitbox defect as the Flytrap Familiar and
-- Crafty Clyvonne. 0 and 15 match Mayfly Familiar, which shares the model.
UPDATE `mob_pools`
   SET `modelSize`       = 0,
       `modelHitboxSize` = 15
 WHERE `poolid` = 4597; -- Shellbuster Orob, both were NULL
