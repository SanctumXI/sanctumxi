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
