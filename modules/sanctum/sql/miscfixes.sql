-- Steady Wing is available only when Dragoon is the character's main job.
UPDATE `abilities` SET `addType` = `addType` | 4 WHERE `abilityId` = 295;
