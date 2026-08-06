-- Sanctum owns these complete zone/group definitions.
DELETE FROM `mob_groups`
WHERE (`zoneid`, `groupid`) IN
(
    (139,52), (139,59), (139,60),
    (144,61), (144,70), (144,71),
    (146,64), (146,71),
    (163,32), (168,31), (206,78),
    (292,79), (292,80), (292,81), (292,82), (292,83)
);

INSERT INTO `mob_groups` VALUES (52,9005,139,'Frostscar_Hrozdag',0,128,0,30000,0,0,NULL);
INSERT INTO `mob_groups` VALUES (59,9006,139,'Siege_Sniper',0,128,0,8000,0,0,NULL);
INSERT INTO `mob_groups` VALUES (60,9007,139,'Blackguard',0,128,0,10000,0,0,NULL);
INSERT INTO `mob_groups` VALUES (61,9004,144,'RoHyu_Blackanvil',0,128,0,30000,500,0,NULL);
INSERT INTO `mob_groups` VALUES (70,9008,144,'Quadav_Earthshaper',0,128,0,20000,10000,0,NULL);
INSERT INTO `mob_groups` VALUES (71,9009,144,'Quadav_Liturgist',0,128,0,12000,10000,0,NULL);
INSERT INTO `mob_groups` VALUES (64,9010,146,'Tzee_Xicus_Hierophant',0,128,0,30000,20000,0,NULL);
INSERT INTO `mob_groups` VALUES (71,9011,146,'Divine_Reproach',0,128,0,8000,10000,0,NULL);
INSERT INTO `mob_groups` VALUES (32,9013,163,'Rancorwurm',0,128,0,55000,0,0,NULL);
INSERT INTO `mob_groups` VALUES (31,9012,168,'Typhon',0,128,0,60000,0,0,NULL);
INSERT INTO `mob_groups` VALUES (78,9014,206,'Ixion',0,128,0,65000,0,0,NULL);
INSERT INTO `mob_groups` VALUES (79,9000,292,'HM_Roc',0,128,2112,28500,0,0,NULL); -- Normal Roc loot (Sauromugue Champaign)
INSERT INTO `mob_groups` VALUES (80,9001,292,'HM_Simurgh',0,128,2255,51000,0,0,NULL); -- Normal Simurgh loot (Rolanberry Fields)
INSERT INTO `mob_groups` VALUES (81,9002,292,'HM_King_Arthro',0,128,1449,70000,7500,0,NULL); -- Normal King Arthro loot (Jugner Forest)
INSERT INTO `mob_groups` VALUES (82,9003,292,'HM_Knight_Crab',0,128,0,4500,0,0,NULL);
INSERT INTO `mob_groups` VALUES (83,9015,292,'HM_Simurgh_Aspect',0,128,0,7500,0,0,NULL);
