-- Complete custom skill lists referenced by the Sanctum mob pools.
DELETE FROM `mob_skill_lists`
WHERE `skill_list_id` BETWEEN 31000 AND 31001;

INSERT INTO `mob_skill_lists` VALUES ('Heavy_Is_the_Shell',31000,611);  -- Ore Toss
INSERT INTO `mob_skill_lists` VALUES ('Heavy_Is_the_Shell',31000,2204); -- Ore Lob
INSERT INTO `mob_skill_lists` VALUES ('Heavy_Is_the_Shell',31000,2266); -- Shell Charge
INSERT INTO `mob_skill_lists` VALUES ('Heavy_Is_the_Shell',31000,2267); -- Skull Smash
INSERT INTO `mob_skill_lists` VALUES ('Dark_Ixion_KSNM',31001,2333); -- di_glow, to telegraph next mobskill
