-- Complete Sanctum definitions for skills enabled by the custom KSNM lists.
DELETE FROM `mob_skills`
WHERE `mob_skill_id` IN (2204,2266,2267);

INSERT INTO `mob_skills` VALUES (2204,355,'ore_lob',2,8.0,15.0,2000,1500,4,0,0,0,0,0,0);
INSERT INTO `mob_skills` VALUES (2266,2012,'shell_charge',0,0.0,7.0,2000,1500,4,0,0,7,0,0,0);
INSERT INTO `mob_skills` VALUES (2267,2009,'skull_smash',0,0.0,7.0,2000,1500,4,0,0,0,0,0,0);
