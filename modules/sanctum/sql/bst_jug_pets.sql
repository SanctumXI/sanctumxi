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
