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

-- Family stat ranks. These cannot be scoped to the pets: mob_family_system is
-- what every wild mob of the family loads from too.
UPDATE `mob_family_system` SET `STR` = 4, `INT` = 4 WHERE `familyID` = 338; -- Funguar, was STR 3 / INT 5
UPDATE `mob_family_system` SET `CHR` = 3 WHERE `familyID` = 111;            -- Sheep, was 4

-- Pet-scoped resistance rows, each a copy of the family row with one rank
-- changed. Point the pet pools at them so wild mobs keep the family values.
REPLACE INTO `mob_resistances` VALUES
(524,'Jug_Crab',0,0,0,0,0,0,0,0,0,0,0,0,0,-2,-3,-2,-2,-3,2,-2,-2,-3,-3,-2,-4,2,-2,-2,-2),      -- slow -2 -> -4
(525,'Jug_Funguar',0,0,0,0,0,0,0,0,0,0,0,0,0,-2,-2,-2,0,-2,4,-3,4,-2,-2,-2,-2,4,-3,4,6),       -- earth -2 -> 0
(526,'Jug_Sheep',0,0,0,0,0,0,0,0,0,0,0,0,0,-2,0,-2,-2,-3,-3,-2,-2,0,0,-2,-2,-3,4,-2,-2);       -- light sleep -2 -> 4

UPDATE `mob_pools` SET `resist_id` = 524 WHERE `poolid` IN (4610, 4611);       -- Crab Familiar, Courier Carrie
UPDATE `mob_pools` SET `resist_id` = 525 WHERE `poolid` IN (4614, 4615);       -- Funguar Familiar, Discreet Louise
UPDATE `mob_pools` SET `resist_id` = 526 WHERE `poolid` IN (4598, 4599, 4629); -- Sheep Familiar, Lullaby Melodia, Nursery Nazuna

-- Rabbit: Hare Familiar / Keeneared Steffi / Lucky Lulush
-- WAR to THF. Trades Attack Bonus II, Double Attack III and 120 base HP for
-- Evasion Bonus V, Triple Attack, Resist Gravity IV and Treasure Hunter II.
-- Net +8 DEX and +4 AGI against -12 STR at level 78.
UPDATE `mob_pools` SET `mJob` = 6 WHERE `poolid` IN (4595, 4612, 4641);

-- Keeneared Steffi wears the Lapinion model (pool 4961, East Ulbuka).
-- Lucky Lulush already uses the snow rabbit model, same as Snowpaw Rabbit.
UPDATE `mob_pools` SET `modelid` = 0x0000910700000000000000000000000000000000 WHERE `poolid` = 4595;

UPDATE `abilities` SET `recastTime` = 2 WHERE `abilityId` = 734; -- Snow Cloud, was 1

UPDATE `pet_skills` SET `pet_skill_aoe` = 1 WHERE `pet_skill_id` = 734; -- Snow Cloud, cone -> radial like Whirl Claws
