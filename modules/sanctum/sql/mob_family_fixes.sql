-- Sanctum: thematic corrections to shared family and resistance rows.
-- Separate from bst_jug_pets.sql because none of these are pet balance; they
-- apply to wild mobs of the type and were found auditing the wider table.

-- Skeletons were backwards on both elements they care about. Every row in the
-- Skeleton superfamily had them weak to dark and only mildly weak to light,
-- so Drain landed harder on a skeleton than Banish did. Undead are dark
-- aligned: they now resist dark and take extra from light.
--
-- All four rows are used exclusively by superfamily 178, so nothing outside
-- the skeletons moves. Draugar stay one step hardier than common skeletons,
-- which is the gap the original rows already had.

UPDATE `mob_resistances`
   SET `light_res_rank` = -3,
       `dark_res_rank`  =  3
 WHERE `resist_id` IN (
     227, -- Skeleton, 155 pools
     292  -- Skeleton - Velionis - ZNM Tier 1, 1 pool
 ); -- both were light -2 / dark -3

UPDATE `mob_resistances`
   SET `light_res_rank` = -2,
       `dark_res_rank`  =  4
 WHERE `resist_id` IN (
     88, -- Draugar - Vanquished_Einherjar, 4 pools
     89  -- Draugar, 32 pools
 ); -- both were light -1 / dark -2

-- Colibri and Toucalibri had agility rank E, the worst of any bird in the
-- game. They are hummingbirds. Rank A puts them where their model already
-- suggests; their mental ranks are already A across the board, which suits a
-- family built around mimicry and stealing buffs.
UPDATE `mob_family_system` SET `AGI` = 1 WHERE `familyID` IN (
    179, -- Colibri
    180  -- Toucalibri
); -- both were 5
