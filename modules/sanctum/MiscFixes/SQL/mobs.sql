UPDATE `mob_pools`
SET `mJob` = 7, `sJob` = 7
WHERE `packet_name` IN ('Buffalo', 'Giant_Buffalo', 'King_Buffalo', 'Mountain_Buffalo');

UPDATE `mob_droplist` SET `itemRate` = 1000 WHERE `dropId` = 578 AND `dropType` = 0 AND `itemId` = 1014;
UPDATE `mob_droplist` SET `itemRate` = 1000 WHERE `dropId` = 1827 AND `dropType` = 0 AND `itemId` = 1012;

UPDATE `mob_spawn_points` SET `minLevel` = 44, `maxLevel` = 45 WHERE `mobid` = 17268851;
UPDATE `mob_spawn_points` SET `minLevel` = 46, `maxLevel` = 47 WHERE `mobid` = 17231971;
UPDATE `mob_spawn_points` SET `minLevel` = 47, `maxLevel` = 49 WHERE `mobid` = 17568127;
