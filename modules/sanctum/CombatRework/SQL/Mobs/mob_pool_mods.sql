-- Sanctum owns the complete modifier sets for these custom pools.
DELETE FROM `mob_pool_mods`
WHERE `poolid` BETWEEN 9000 AND 9015;

INSERT INTO `mob_pool_mods` VALUES (9004,3,100,1); -- MP_BASE: 100
INSERT INTO `mob_pool_mods` VALUES (9004,38,1,1); -- Ro'Hyu Blackanvil: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9005,38,1,1); -- Frostscar Hrozdag: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9006,38,1,1); -- Siege Sniper: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9007,38,1,1); -- Blackguard: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9008,38,1,1); -- Quadav Earthshaper: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9009,38,1,1); -- Quadav Liturgist: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9010,38,1,1); -- Tzee Xicu's Hierophant: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9011,38,1,1); -- Divine Reproach: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9012,38,1,1); -- Typhon: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9013,38,1,1); -- Rancorwurm: NO_DROPS
INSERT INTO `mob_pool_mods` VALUES (9014,38,1,1); -- Ixion: NO_DROPS
