-- Sanctum jug pet rebalance.

-- Crab: Crab Familiar / Courier Carrie

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 694; -- Bubble Curtain, was 3
UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 697; -- Metallic Body, was 1

UPDATE `pet_skills` SET `pet_skill_aoe` = 1, `pet_skill_radius` = 10 WHERE `pet_skill_id` = 694; -- Bubble Curtain, party
UPDATE `pet_skills` SET `pet_skill_aoe` = 1, `pet_skill_radius` = 10 WHERE `pet_skill_id` = 696; -- Scissor Guard, party

-- Funguar: Funguar Familiar

UPDATE `mob_pools` SET `mJob` = 5 WHERE `poolid` = 4614; -- Funguar Familiar
UPDATE `pet_list` SET `maxLevel` = 71 WHERE `petid` = 32; -- Funguar Familiar, was 65

-- Sheep: Sheep Familiar / Lullaby Melodia / Nursery Nazuna

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 689; -- Lamb Chop, was 1
UPDATE `abilities` SET `recastTime` = 3 WHERE `abilityId` = 690; -- Rage, was 2

UPDATE `pet_skills` SET `pet_skill_radius` = 14 WHERE `pet_skill_id` = 692; -- Sheep Song, was 10

-- Nursery Nazuna

UPDATE `mob_pools`
   SET `modelid`         = 0x0000550100000000000000000000000000000000,
       `modelSize`       = 1,
       `modelHitboxSize` = 24
 WHERE `poolid` = 4629; -- Nursery Nazuna

UPDATE `pet_list` SET `minLevel` = 73, `maxLevel` = 73 WHERE `petid` = 57; -- Nursery Nazuna, was 75 / 80

-- Lizard: Lizard Familiar / Coldblood Como / Audacious Anna

UPDATE `pet_skills` SET `pet_skill_aoe` = 1, `pet_skill_radius` = 10 WHERE `pet_skill_id` = 688; -- Secretion, party

UPDATE `mob_family_system` SET `STR` = 4, `INT` = 4 WHERE `familyID` = 338; -- Funguar, was STR 3 / INT 5
UPDATE `mob_family_system` SET `CHR` = 3 WHERE `familyID` = 111;            -- Sheep, was 4

UPDATE `mob_resistances` SET `earth_res_rank`      =  4 WHERE `resist_id` = 174; -- Lizard, was 0
UPDATE `mob_resistances` SET `slow_res_rank`       = -4 WHERE `resist_id` = 77;  -- Crab, was -2
UPDATE `mob_resistances` SET `earth_res_rank`      =  0 WHERE `resist_id` = 116; -- Funguar, was -2
UPDATE `mob_resistances` SET `light_sleep_res_rank` = 4 WHERE `resist_id` = 226; -- Sheep, was -2

UPDATE `mob_family_system` SET `AGI` = 3, `EVA` = 2 WHERE `familyID` = 106;      -- Rabbit, was AGI 4 / EVA 3
UPDATE `mob_resistances` SET `slow_res_rank`        = 4 WHERE `resist_id` = 206; -- Rabbit, was -1

-- Rabbit: Hare Familiar / Keeneared Steffi / Lucky Lulush

UPDATE `mob_pools` SET `mJob` = 19 WHERE `poolid` IN (4595, 4612, 4641);

-- Keeneared Steffi wears the Lapinion model (pool 4961, East Ulbuka).

UPDATE `mob_pools` SET `modelid` = 0x0000910700000000000000000000000000000000 WHERE `poolid` = 4595;

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 734; -- Snow Cloud, was 1

UPDATE `pet_skills` SET `pet_skill_aoe` = 1 WHERE `pet_skill_id` = 734; -- Snow Cloud, cone -> radial like Whirl Claws

-- Beetle: Beetle Familiar / Panzer Galahad

UPDATE `mob_resistances`
   SET `fire_res_rank`  =  2,
       `wind_res_rank`  = -2,
       `earth_res_rank` =  2,
       `dark_res_rank`  =  2,
       `blind_res_rank` =  2
 WHERE `resist_id` = 49; -- Beetle, all five were 0

UPDATE `abilities` SET `recastTime` = 1 WHERE `abilityId` = 708; -- Hi-Freq Field, was 2

-- Sabotender: Amigo Sabotender

UPDATE `mob_family_system`
   SET `STR` = 4,
       `DEX` = 1,
       `AGI` = 1,
       `EVA` = 1
 WHERE `familyID` = 334; -- was STR 2 / DEX 5 / AGI 3 / EVA 3

UPDATE `mob_resistances`
   SET `fire_res_rank` = -3,
       `bind_res_rank` =  4,
       `slow_res_rank` =  4
 WHERE `resist_id` = 212; -- was fire -2 / bind -3 / slow 0

UPDATE `pet_skills` SET `pet_skill_radius` = 4 WHERE `pet_skill_id` = 699; -- 1,000 Needles, was 10
UPDATE `pet_list` SET `minLevel` = 74, `maxLevel` = 74 WHERE `petid` = 47; -- Amigo Sabotender, was 75 / 80

-- Diremite: Mite Familiar / Lifedrinker Lars

UPDATE `mob_family_system`
   SET `VIT` = 5,
       `DEX` = 3,
       `CHR` = 3,
       `DEF` = 4,
       `EVA` = 4,
       `ATT` = 4
 WHERE `familyID` = 442; -- was VIT 4 / DEX 4 / CHR 4 / DEF 3 / EVA 3 / ATT 1

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

-- Ladybug: Lucky Lyra, formerly Dipper Yuly

UPDATE `pet_list` SET `name` = 'LuckyLyra' WHERE `petid` = 55; -- was DipperYuly

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 737; -- Spiral Spin, was 1

UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 736; -- Sudden Lunge, was Impaction
UPDATE `pet_skills` SET `primary_sc` = 6 WHERE `pet_skill_id` = 737; -- Spiral Spin: Detonation, was Scission

UPDATE `pet_skills`
   SET `pet_valid_targets` = 3,
       `pet_message`       = 238
 WHERE `pet_skill_id` = 738; -- was 4 (enemy) / 242

-- Pugil: Turbid Toloi
DELETE FROM `synth_recipes` WHERE `ID` = 74516; -- Auroral Broth, Cooking 93

-- Mandragora: Homunculus / Flowerpot Bill / Flowerpot Ben

UPDATE `mob_family_system` SET `INT` = 2 WHERE `familyID` = 350; -- was 4

-- Flowerpot Ben

UPDATE `pet_list` SET `maxLevel` = 63 WHERE `petid` = 38; -- Flowerpot Ben, was 75

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
UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 675; -- Head Butt, was Detonation
UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 677; -- Wild Oats, was Transfixion

UPDATE `pet_skills` SET `pet_skill_distance` = 5.0 WHERE `pet_skill_id` = 678; -- Leaf Dagger, was 3

-- Tiger: Tiger Familiar / Saber Siravarde

UPDATE `pet_list` SET `maxLevel` = 72 WHERE `petid` = 39; -- Saber Siravarde, was 75
UPDATE `mob_family_system` SET `STR` = 3, `AGI` = 3, `DEF` = 4 WHERE `familyID` = 114; -- was STR 4 / AGI 4 / DEF 3

UPDATE `pet_skills`
   SET `pet_valid_targets` = 3,
       `pet_message`       = 238
 WHERE `pet_skill_id` = 680; -- was 4 (enemy) / 242

UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 681; -- Razor Fang, was Impaction
UPDATE `pet_skills` SET `primary_sc` = 0 WHERE `pet_skill_id` = 682; -- Claw Cyclone, was Scission

-- Flytrap: Flytrap Familiar / Voracious Audrey

UPDATE `mob_family_system` SET `INT` = 3, `MND` = 2 WHERE `familyID` = 336; -- was INT 4 / MND 4
UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 718; -- Soporific, was 1
UPDATE `abilities` SET `recastTime` = 1 WHERE `abilityId` = 719; -- Gloeosuccus, was 2

UPDATE `pet_skills`
   SET `pet_skill_aoe`    = 4,
       `pet_skill_radius` = 10
 WHERE `pet_skill_id` = 720; -- was single target at radius 0

UPDATE `mob_pools`
   SET `modelSize`       = 0,
       `modelHitboxSize` = 12
 WHERE `poolid` = 4619; -- Flytrap Familiar, both were NULL

UPDATE `mob_pools` SET `cmbDelay` = 240 WHERE `poolid` IN (4619, 4620); -- was 200

-- Frog: Slippery Silas

UPDATE `mob_pools` SET `mJob` = 4, `sJob` = 4 WHERE `poolid` = 4639;
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 171, 1, 255); -- water_iii
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 200, 1, 255); -- waterga_ii
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 214, 1, 255); -- flood
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 240, 1, 255); -- drown
REPLACE INTO `mob_spell_lists` VALUES ('Jug_Frog', 900, 247, 1, 255); -- aspir

UPDATE `mob_pools` SET `spellList` = 900 WHERE `poolid` = 4639; -- was 0

-- Frog Cheer uses unused ability 739. Its client action-metadata record must
-- also be populated with valid Ready targeting; the name and description DATs
-- alone are not enough. mob_skill 1960 and animation 1362 are the Poroggo's
-- own, so the animation is native to the model.
REPLACE INTO `abilities` VALUES (739, 'frog_cheer', 9, 25, 257, 3, 102, 0, 0, 0, 2000, 0, 6, 3.0, 0, 10, 1, 60, 0, 0, NULL);
REPLACE INTO `pet_skills` VALUES (739, 1960, 1362, 'frog_cheer', 1, 10, 3, 2000, 1500, 3, 238, 0, 0, 11, 0, 0, 0, 0);
REPLACE INTO `mob_skill_lists` VALUES ('Jug_Frog', 30002, 739);

UPDATE `mob_pools` SET `skill_list_id` = 30002 WHERE `poolid` = 4639; -- was 0

-- Antlion: Antlion Familiar / Chopsuey Chucky

UPDATE `mob_family_system` SET `STR` = 2, `EVA` = 4 WHERE `familyID` = 422; -- was STR 4 / EVA 3
UPDATE `mob_resistances` SET `earth_res_rank` = 6 WHERE `resist_id` = 26; -- was 3

UPDATE `pet_skills`
   SET `pet_skill_aoe`    = 4,
       `pet_skill_radius` = 10,
       `primary_sc`       = 0
 WHERE `pet_skill_id` = 717; -- Mandibular Bite, was single target at radius 0 / Detonation

UPDATE `pet_skills` SET `pet_skill_radius` = 12 WHERE `pet_skill_id` = 716; -- Venom Spray, was 10

-- Coeurl: Crafty Clyvonne

UPDATE `mob_family_system` SET `AGI` = 3, `CHR` = 2, `INT` = 2 WHERE `familyID` = 92; -- was AGI 4 / CHR 4 / INT 3

INSERT INTO `mob_family_mods` (`familyid`, `modid`, `value`, `is_mob_mod`) VALUES (92, 383, 2500, 0)
    ON DUPLICATE KEY UPDATE `value` = VALUES(`value`), `is_mob_mod` = VALUES(`is_mob_mod`); -- HASTE_ABILITY 25%

UPDATE `abilities` SET `recastTime` = 3 WHERE `abilityId` = 731; -- Blaster, was 2

UPDATE `mob_pools`
   SET `modelSize`       = 1,
       `modelHitboxSize` = 16
 WHERE `poolid` = 4608; -- Crafty Clyvonne, both were NULL

-- Fly: Mayfly Familiar / Shellbuster Orob

UPDATE `mob_pools` SET `mJob` = 4, `sJob` = 4 WHERE `poolid` IN (4596, 4597); -- was WAR
UPDATE `mob_family_system` SET `STR` = 1, `DEX` = 3, `AGI` = 2 WHERE `familyID` = 444; -- was STR 5 / DEX 4 / AGI 3
UPDATE `pet_list` SET `maxLevel` = 72 WHERE `petid` = 41; -- Shellbuster Orob, was 75
UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 712; -- Cursed Sphere, was 1

UPDATE `mob_pools`
   SET `modelSize`       = 0,
       `modelHitboxSize` = 15
 WHERE `poolid` = 4597; -- Shellbuster Orob, both were NULL
