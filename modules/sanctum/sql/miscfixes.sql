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

-- Fulminous Fury and No Quarter are centered AoEs, like Self-Destruct.
UPDATE `mob_skills` SET `mob_skill_aoe` = 1 WHERE `mob_skill_id` IN (3657, 3658);

-- Notorious Bombs do not randomly select Self-Destruct. NMs with scripted
-- Self-Destruct conditions can still explicitly select it from their Lua.
DELETE FROM `mob_skill_lists` WHERE `skill_list_id` = 31002;
INSERT INTO `mob_skill_lists` VALUES ('Sanctum_Bomb_NM', 31002, 510);

UPDATE `mob_pools`
SET `skill_list_id` = 31002
WHERE
    `familyid` = 46 AND
    (`mobType` & 2) != 0 AND
    `skill_list_id` = 56;

DELETE FROM `item_mods`
WHERE `itemId` = 13692 AND `modId` IN (946, 947);

UPDATE `mob_pools`
SET `mJob` = 7, `sJob` = 7
WHERE `packet_name` IN ('Buffalo', 'Giant_Buffalo', 'King_Buffalo', 'Mountain_Buffalo');

UPDATE `mob_droplist` SET `itemRate` = 1000 WHERE `dropId` = 578 AND `dropType` = 0 AND `itemId` = 1014;
UPDATE `mob_droplist` SET `itemRate` = 1000 WHERE `dropId` = 1827 AND `dropType` = 0 AND `itemId` = 1012;

UPDATE `mob_spawn_points` SET `minLevel` = 44, `maxLevel` = 45 WHERE `mobid` = 17268851;
UPDATE `mob_spawn_points` SET `minLevel` = 46, `maxLevel` = 47 WHERE `mobid` = 17231971;
UPDATE `mob_spawn_points` SET `minLevel` = 47, `maxLevel` = 49 WHERE `mobid` = 17568127;

-- Sand Gloves: Evasion +7 in earth weather.
DELETE FROM `item_latents` WHERE `itemId` = 14064 AND `modId` = 68;
INSERT INTO `item_latents` VALUES (14064, 68, 7, 52, 4);

-- Time Hammer Slow animation.
DELETE FROM `item_mods` WHERE `itemId` = 17083 AND `modId` = 499;
INSERT INTO `item_mods` VALUES (17083, 499, 18);

-- Minuet and Titanis Earring latents.
DELETE FROM `item_latents` WHERE `itemId` = 14764 AND `modId` = 25;
INSERT INTO `item_latents` VALUES (14764, 25, 3, 13, 198);
DELETE FROM `item_latents` WHERE `itemId` = 14765 AND `modId` = 27;
INSERT INTO `item_latents` VALUES (14765, 27, 4, 13, 197);

-- Lilith's Rod additional effect.
DELETE FROM `item_mods` WHERE `itemId` = 17072 AND `modId` IN (431, 499, 500, 501, 950);
INSERT INTO `item_mods` VALUES (17072, 431, 6);
INSERT INTO `item_mods` VALUES (17072, 499, 22);
INSERT INTO `item_mods` VALUES (17072, 500, 25);
INSERT INTO `item_mods` VALUES (17072, 501, 25);
INSERT INTO `item_mods` VALUES (17072, 950, 8);

-- Raifu additional effect.
DELETE FROM `item_mods` WHERE `itemId` = 18210 AND `modId` IN (431, 499, 500, 501, 950);
INSERT INTO `item_mods` VALUES (18210, 431, 1);
INSERT INTO `item_mods` VALUES (18210, 499, 5);
INSERT INTO `item_mods` VALUES (18210, 500, 20);
INSERT INTO `item_mods` VALUES (18210, 501, 25);
INSERT INTO `item_mods` VALUES (18210, 950, 5);
