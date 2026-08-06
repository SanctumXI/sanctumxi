-- Sanctum Blue Magic set costs, traits, and skillchains. These complete rows are module-owned.
DELETE FROM `blue_spell_list`
WHERE (`spellid`,`mob_skill_id`) IN
(
    (535,1646),
    (588,497),
    (596,329),
    (622,665),
    (633,1745),
    (644,1963)
);

INSERT INTO `blue_spell_list` VALUES (535,1646,2,14,1,0,0,0,NULL); -- Cold Wave
INSERT INTO `blue_spell_list` VALUES (588,497,1,4,1,0,0,0,NULL); -- Lowing
INSERT INTO `blue_spell_list` VALUES (596,329,1,0,1,3,0,0,NULL); -- Pinecone Bomb
INSERT INTO `blue_spell_list` VALUES (622,665,1,11,1,7,0,0,NULL); -- Grand Slam
INSERT INTO `blue_spell_list` VALUES (633,1745,3,21,1,0,0,0,NULL); -- Enervation
INSERT INTO `blue_spell_list` VALUES (644,1963,5,4,1,0,0,0,NULL); -- Mind Blast

