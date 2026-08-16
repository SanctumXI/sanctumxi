-- Steady Wing is available only when Dragoon is the character's main job.
UPDATE `abilities` SET `addType` = `addType` | 4 WHERE `abilityId` = 295;

-- Natural weapon skills introduced at 290 skill or later are out of era.
UPDATE `weapon_skills`
SET `jobs` = 0x00000000000000000000000000000000000000000000
WHERE `skilllevel` >= 290;

-- Wyvern Skulls do not stack.
UPDATE `item_basic` SET `stackSize` = 1 WHERE `itemid` = 905;

-- Tiny Goldfish have been removed from all fishing pools.
DELETE FROM `fishing_group` WHERE `fishid` = 4310;
DELETE FROM `fishing_bait_affinity` WHERE `fishid` = 4310;
