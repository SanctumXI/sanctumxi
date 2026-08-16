-- Steady Wing is available only when Dragoon is the character's main job.
UPDATE `abilities` SET `addType` = `addType` | 4 WHERE `abilityId` = 295;

-- Natural weapon skills introduced at 290 skill or later are out of era.
UPDATE `weapon_skills`
SET `jobs` = 0x00000000000000000000000000000000000000000000
WHERE `skilllevel` >= 290;

-- Tiny Goldfish require the event Super Scoop instead of ordinary fishing bait.
DELETE FROM `fishing_bait_affinity`
WHERE `fishid` = 4310 AND `baitid` <> 17003;

INSERT INTO `fishing_bait_affinity` (`baitid`, `fishid`, `power`)
VALUES (17003, 4310, 10)
ON DUPLICATE KEY UPDATE `power` = VALUES(`power`);
