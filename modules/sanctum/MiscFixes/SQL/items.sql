-- Wyvern Skulls do not stack.
UPDATE `item_basic` SET `stackSize` = 1 WHERE `itemid` = 905;

-- Tiny Goldfish have been removed from all fishing pools.
DELETE FROM `fishing_group` WHERE `fishid` = 4310;
DELETE FROM `fishing_bait_affinity` WHERE `fishid` = 4310;

DELETE FROM `item_mods`
WHERE `itemId` = 13692 AND `modId` IN (946, 947);

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
