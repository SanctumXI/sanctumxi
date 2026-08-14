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

-- Lizard: Lizard Familiar / Coldblood Como / Audacious Anna
-- Brain Crush opens Liquefaction and Tail Blow closes it for Fusion, a tier 2
-- chain for 2 charges. Blockhead into Tail Blow gives Impaction instead.
-- Infrasonics stays at 2 charges.

UPDATE `pet_skills` SET `pet_skill_aoe` = 1, `pet_skill_radius` = 10 WHERE `pet_skill_id` = 688; -- Secretion, party

-- Earth resistance for the lizard pets. Resist row 174 is shared by 57 wild
-- lizard pools, so the pets get their own copy rather than changing the family.
-- Row 523 is 174 with earth_res_rank raised from 0 to 4; everything else matches.
REPLACE INTO `mob_resistances` VALUES
(523,'Jug_Lizard',0,0,0,0,0,0,0,0,0,0,0,0,0,0,-3,-3,4,0,-2,-2,-2,-3,-3,-3,0,-2,-2,-2,-2);

UPDATE `mob_pools` SET `resist_id` = 523 WHERE `poolid` IN (4600, 4601, 4631); -- Lizard Familiar, Coldblood Como, Audacious Anna
