-- Sanctum merit definitions. These complete rows are module-owned.
DELETE FROM `merits`
WHERE `meritid` IN
(
    68,386,448,450,452,518,576,704,706,708,
    710,768,770,774,834,898,900,902,904,964,
    966,968,1024,1026,1028,1030,1032,1090,1094,1154,
    1156,1158,1160,1162,1164,1216,1218,1220,1222,1282,
    1344,1346,1352,1412,1414,1416,1472,1474,1476,1478,
    1480,1600,1602,2054,2118,2184,2262,2370,2432,2436,
    2438,2496,2500,2560,2564,2632,2634,2694,2754,2834,
    2838,3008,3076,3138,3140,3142
);

INSERT INTO `merits` VALUES (68,'max_merits',10,1,1048575,9,0);
INSERT INTO `merits` VALUES (386,'retaliation_damage',5,5,1,6,5);
INSERT INTO `merits` VALUES (448,'focus_recast',5,12,2,6,6);
INSERT INTO `merits` VALUES (450,'iron_guard_effect',5,5,2,6,6);
INSERT INTO `merits` VALUES (452,'chakra_recast',5,12,2,6,6);
INSERT INTO `merits` VALUES (518,'banish_effect',5,3,4,6,7);
INSERT INTO `merits` VALUES (576,'elemental_seal_recast',5,30,8,6,8);
INSERT INTO `merits` VALUES (704,'flee_recast',5,12,32,6,10);
INSERT INTO `merits` VALUES (706,'hide_recast',5,12,32,6,10);
INSERT INTO `merits` VALUES (708,'sata_recast',5,2,32,6,10);
INSERT INTO `merits` VALUES (710,'bully_recast',5,10,32,6,10);
INSERT INTO `merits` VALUES (768,'majesty_recast',5,12,64,6,11);
INSERT INTO `merits` VALUES (770,'challenge',5,3,64,6,11);
INSERT INTO `merits` VALUES (774,'shield_chance',5,1,64,6,11);
INSERT INTO `merits` VALUES (834,'nether_void',5,10,128,6,12);
INSERT INTO `merits` VALUES (898,'reward_recast',5,10,256,6,13);
INSERT INTO `merits` VALUES (900,'pet_boost',5,3,256,6,13);
INSERT INTO `merits` VALUES (902,'sic_recast',5,3,256,3,13);
INSERT INTO `merits` VALUES (904,'tame_recast',5,60,256,6,13);
INSERT INTO `merits` VALUES (964,'minne_effect',5,4,512,6,14);
INSERT INTO `merits` VALUES (966,'minuet_effect',5,3,512,6,14);
INSERT INTO `merits` VALUES (968,'madrigal_effect',5,2,512,6,14);
INSERT INTO `merits` VALUES (1024,'scavenge_effect',5,7,1024,6,15);
INSERT INTO `merits` VALUES (1026,'velocity_shot_effect',5,1,1024,6,15);
INSERT INTO `merits` VALUES (1028,'barrage_effect',5,4,1024,6,15);
INSERT INTO `merits` VALUES (1030,'double_shot_effect',5,1,1024,6,15);
INSERT INTO `merits` VALUES (1032,'rapid_shot_rate',5,2,1024,6,15);
INSERT INTO `merits` VALUES (1090,'sekkanoki_recast',5,12,2048,6,16);
INSERT INTO `merits` VALUES (1094,'meditate_recast',5,8,2048,6,16);
INSERT INTO `merits` VALUES (1154,'ninjutsu_effect',5,2,4096,6,17);
INSERT INTO `merits` VALUES (1156,'hojo_effect',5,10,4096,6,17);
INSERT INTO `merits` VALUES (1158,'jubaku_effect',5,10,4096,6,17);
INSERT INTO `merits` VALUES (1160,'kurayami_effect',5,10,4096,6,17);
INSERT INTO `merits` VALUES (1162,'dokumori_effect',5,10,4096,6,17);
INSERT INTO `merits` VALUES (1164,'dual_wield_bonus',5,1,4096,6,17);
INSERT INTO `merits` VALUES (1216,'conserve_tp_chance',5,2,8192,6,18);
INSERT INTO `merits` VALUES (1218,'jump_recast',5,3,8192,6,18);
INSERT INTO `merits` VALUES (1220,'wyvern_boost',5,3,8192,6,18);
INSERT INTO `merits` VALUES (1222,'wyvern_hp',5,50,8192,6,18);
INSERT INTO `merits` VALUES (1282,'avatar_physical_attack',5,1,16384,6,19);
INSERT INTO `merits` VALUES (1344,'affinity_recast',5,6,32768,6,20);
INSERT INTO `merits` VALUES (1346,'conserve_mp_effect',5,3,32768,6,20);
INSERT INTO `merits` VALUES (1352,'magical_accuracy',5,3,32768,6,20);
INSERT INTO `merits` VALUES (1412,'quick_draw_accuracy',5,3,65536,6,21);
INSERT INTO `merits` VALUES (1414,'random_deal_recast',5,60,65536,6,21);
INSERT INTO `merits` VALUES (1416,'rapid_shot_rate2',5,2,65536,6,21);
INSERT INTO `merits` VALUES (1472,'martial_arts_effect',5,5,131072,6,22);
INSERT INTO `merits` VALUES (1474,'caster_protocol',5,1,131072,6,22);
INSERT INTO `merits` VALUES (1476,'defender_protocol',5,1,131072,6,22);
INSERT INTO `merits` VALUES (1478,'medic_protocol',5,1,131072,6,22);
INSERT INTO `merits` VALUES (1480,'striker_protocol',5,1,131072,6,22);
INSERT INTO `merits` VALUES (1600,'grimoire_recast',5,4,524288,6,24);
INSERT INTO `merits` VALUES (1602,'modus_veritas_effect',5,1,524288,6,24);
INSERT INTO `merits` VALUES (2054,'aggressive_aim',5,5,1,7,31);
INSERT INTO `merits` VALUES (2118,'penance',5,36,2,7,32);
INSERT INTO `merits` VALUES (2184,'animus_solace',5,5,4,7,33);
INSERT INTO `merits` VALUES (2262,'aspir_absorption_amount',5,5,8,7,34);
INSERT INTO `merits` VALUES (2370,'feint',5,15,32,7,36);
INSERT INTO `merits` VALUES (2432,'fealty',5,15,64,7,37);
INSERT INTO `merits` VALUES (2436,'iron_will',5,20,64,7,37);
INSERT INTO `merits` VALUES (2438,'guardian',5,20,64,7,37);
INSERT INTO `merits` VALUES (2496,'dark_seal',5,30,128,7,38);
INSERT INTO `merits` VALUES (2500,'blood_discipline',5,10,128,7,38);
INSERT INTO `merits` VALUES (2560,'run_wild',5,30,256,7,39);
INSERT INTO `merits` VALUES (2564,'beast_affinity',5,1,256,7,39);
INSERT INTO `merits` VALUES (2632,'marcato',5,3,512,7,40);
INSERT INTO `merits` VALUES (2634,'eloquence',5,6,512,7,40);
INSERT INTO `merits` VALUES (2694,'vision',5,3,1024,7,41);
INSERT INTO `merits` VALUES (2754,'blade_bash',5,1,2048,7,42);
INSERT INTO `merits` VALUES (2834,'innin_effect',5,2,4096,7,43);
INSERT INTO `merits` VALUES (2838,'nin_magic_attack',5,5,4096,7,43);
INSERT INTO `merits` VALUES (3008,'convergence',5,10,32768,7,46);
INSERT INTO `merits` VALUES (3076,'winning_streak',5,24,65536,7,47);
INSERT INTO `merits` VALUES (3138,'tactical_switch',5,10,131072,7,48);
INSERT INTO `merits` VALUES (3140,'repair_maintain',5,3,131072,7,48);
INSERT INTO `merits` VALUES (3142,'overclocking',5,12,131072,7,48);

