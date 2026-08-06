-- Complete custom spell lists referenced by the Sanctum mob pools.
DELETE FROM `mob_spell_lists`
WHERE `spell_list_id` BETWEEN 1000 AND 1005;

INSERT INTO `mob_spell_lists` VALUES ('RoHyu_Blackanvil_KSNM',1000,112,37,255); -- flash (37~255)
INSERT INTO `mob_spell_lists` VALUES ('RoHyu_Blackanvil_KSNM',1000,34,55,255);  -- diaga_ii (55~255)
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,246,1,255); -- drain_ii
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,270,1,255); -- absorb_int
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,275,1,255); -- absorb_tp
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,248,1,255); -- aspir_ii
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,157,1,255); -- aero_iv
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,186,1,255); -- aeroga_iii
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,314,1,255); -- enaero_ii
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,231,1,255); -- bio_ii
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,276,1,255); -- blind_ii
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,80,1,255);  -- paralyze_ii
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,79,1,255);  -- slow_ii
INSERT INTO `mob_spell_lists` VALUES ('Tzee_Xicus_Hierophant_KSNM',1001,132,1,255); -- shellra_iii
INSERT INTO `mob_spell_lists` VALUES ('Divine_Reproach_KSNM',1002,156,1,255); -- aero_iii
INSERT INTO `mob_spell_lists` VALUES ('Divine_Reproach_KSNM',1002,185,1,255); -- aeroga_ii
INSERT INTO `mob_spell_lists` VALUES ('Divine_Reproach_KSNM',1002,53,1,255);  -- blink
INSERT INTO `mob_spell_lists` VALUES ('Divine_Reproach_KSNM',1002,237,1,255); -- choke
INSERT INTO `mob_spell_lists` VALUES ('Divine_Reproach_KSNM',1002,574,1,255); -- feather_barrier
INSERT INTO `mob_spell_lists` VALUES ('Divine_Reproach_KSNM',1002,57,1,255);  -- haste
INSERT INTO `mob_spell_lists` VALUES ('Divine_Reproach_KSNM',1002,208,1,255); -- tornado
INSERT INTO `mob_spell_lists` VALUES ('Divine_Reproach_KSNM',1002,647,1,255); -- zephyr_mantle
INSERT INTO `mob_spell_lists` VALUES ('HM_Simurgh',1003,4,1,255);   -- Cure IV (1~255)
INSERT INTO `mob_spell_lists` VALUES ('HM_Simurgh',1003,53,1,255);  -- Blink (1~255)
INSERT INTO `mob_spell_lists` VALUES ('HM_Simurgh',1003,156,1,255); -- Aero III (1~255)
INSERT INTO `mob_spell_lists` VALUES ('HM_Simurgh',1003,185,1,255); -- Aeroga II (1~255)
INSERT INTO `mob_spell_lists` VALUES ('HM_Simurgh',1003,208,1,255); -- Tornado (1~255)
INSERT INTO `mob_spell_lists` VALUES ('HM_Simurgh',1003,376,1,255); -- Horde Lullaby (1~255)
INSERT INTO `mob_spell_lists` VALUES ('HM_Simurgh',1003,423,1,255); -- Massacre Elegy (1~255)
INSERT INTO `mob_spell_lists` VALUES ('HM_Simurgh',1003,462,1,255); -- Magic Finale (1~255)
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Earthshaper_KSNM',1004,210,1,255); -- Quake
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Earthshaper_KSNM',1004,162,1,255); -- Stone IV
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Earthshaper_KSNM',1004,161,1,255); -- Stone III
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Earthshaper_KSNM',1004,190,1,255); -- Stonega II
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Earthshaper_KSNM',1004,191,1,255); -- Stonega III
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,15,1,255);  -- Paralyna
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,16,1,255);  -- Blindna
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,56,1,255);  -- Slow
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,132,1,255); -- Shellra III
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,110,1,255); -- Regen II
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,4,1,255);   -- Cure IV
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,5,1,255);   -- Cure V
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,54,1,255);  -- Stoneskin
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,29,1,255);  -- Banish II
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,8,1,255);   -- Curaga II
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,95,1,255);  -- Esuna
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,98,1,255);  -- Repose
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,30,1,255);  -- Banish III
INSERT INTO `mob_spell_lists` VALUES ('Quadav_Liturgist_KSNM',1005,39,1,255);  -- Banishga II
