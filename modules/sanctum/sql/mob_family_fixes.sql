-- Sanctum: thematic corrections to shared family and resistance rows.
-- Separate from bst_jug_pets.sql because none of these are pet balance; they
-- apply to wild mobs of the type and were found auditing the wider table.

-- Skeletons were backwards on both elements they care about. Every row in the
-- Skeleton superfamily had them weak to dark and only mildly weak to light,
-- so Drain landed harder on a skeleton than Banish did. Undead are dark
-- aligned: they now resist dark and take extra from light.
--
-- All four rows are used exclusively by superfamily 178, so nothing outside
-- the skeletons moves. Draugar stay one step hardier than common skeletons,
-- which is the gap the original rows already had.

UPDATE `mob_resistances`
   SET `light_res_rank` = -3,
       `dark_res_rank`  =  3
 WHERE `resist_id` IN (
     227, -- Skeleton, 155 pools
     292  -- Skeleton - Velionis - ZNM Tier 1, 1 pool
 ); -- both were light -2 / dark -3

UPDATE `mob_resistances`
   SET `light_res_rank` = -2,
       `dark_res_rank`  =  4
 WHERE `resist_id` IN (
     88, -- Draugar - Vanquished_Einherjar, 4 pools
     89  -- Draugar, 32 pools
 ); -- both were light -1 / dark -2

-- The rest of the undead that were inverted the same way: resisting light and
-- taking extra from dark. Every row below is used only by its own superfamily,
-- so each change is contained. Magnitudes keep each family's character rather
-- than flattening them all to one number.

-- Vampyr, Strigoi. Burn in sunlight, made of night: the strongest swing here.
UPDATE `mob_resistances`
   SET `light_res_rank` = -3,
       `dark_res_rank`  =  4
 WHERE `resist_id` IN (
     252, -- Vampyr, 4 pools
     284, -- Vampyr, 3 pools
     309  -- Vampyre - Nosferatu - ZNM Tier 3, 8 pools
 ); -- all were light +1 / dark -1

-- Dullahan, Infernal Knight. Headless knights, hardier than common undead.
UPDATE `mob_resistances`
   SET `light_res_rank` = -3,
       `dark_res_rank`  =  4
 WHERE `resist_id` = 447; -- Dullahan, 4 pools, was light +3 / dark -2

UPDATE `mob_resistances`
   SET `light_res_rank` = -2,
       `dark_res_rank`  =  3
 WHERE `resist_id` IN (
     86,  -- Doomed, 33 pools, was light +2 / dark -2
     522, -- Jnun, 2 pools, was light +2 / dark -2
     472, -- Naraka, 12 pools, was light +2 / dark 0
     73   -- Corpselights, 18 pools, was light +2 / dark -1
 );

-- Dvergr Skull already resisted dark; it only needed the light half turned
-- round, and it stays the toughest of the corpselights.
UPDATE `mob_resistances`
   SET `light_res_rank` = -2,
       `dark_res_rank`  =  4
 WHERE `resist_id` = 91; -- Dvergr_Skull, 2 pools, was light +6 / dark +2

-- Colibri and Toucalibri had agility rank E, the worst of any bird in the
-- game. They are hummingbirds. Rank A puts them where their model already
-- suggests; their mental ranks are already A across the board, which suits a
-- family built around mimicry and stealing buffs.
UPDATE `mob_family_system` SET `AGI` = 1 WHERE `familyID` IN (
    179, -- Colibri
    180  -- Toucalibri
); -- both were 5

-- The five pools left unresolved by the generated pass below. All sit in
-- family 0, which does not exist in mob_family_system, so neither a family
-- nor an ecosystem sibling could supply a value.
UPDATE `mob_pools`
   SET `modelSize`       = 1,
       `modelHitboxSize` = 20
 WHERE `poolid` = 6031; -- Katashiro, the Evil Weapon standard

UPDATE `mob_pools`
   SET `modelSize`       = 1,
       `modelHitboxSize` = 15
 WHERE `poolid` IN (
     6032, -- Nii Aquu
     6033, -- Reikuu
     6034, -- Zhuu Buxu the Silent
     6035  -- Gessho
 ); -- the Yagudo standard

-- ---------------------------------------------------------------------------
-- Generated: model sizes for pools that shipped with NULL.
--
-- A NULL modelHitboxSize leaves the mob a zero hitbox, and melee range is
-- hitbox + 2 + the target's hitbox, so those mobs reach less far than every
-- sibling of the same type. Four jug pets hit this during the BST pass.
--
-- Values are the most common size/hitbox pair among non-NULL pools of the same
-- family, falling back to the ecosystem's most common pair. Regenerate rather
-- than hand-edit this block.
-- ---------------------------------------------------------------------------

UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 12 WHERE `poolid` IN (37, 131, 159, 215, 223, 264, 275, 282, 298, 432, 494, 598, 599, 635, 725, 728, 807, 809, 810, 860, 873, 896, 1128, 1200, 1259, 1315, 1316, 1349, 1372, 1400, 1490, 1527, 1545, 1604, 1651, 1702, 1706, 1861, 1959, 1968);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 12 WHERE `poolid` IN (1969, 1972, 1973, 1977, 1979, 1980, 1981, 2048, 2071, 2074, 2103, 2175, 2182, 2258, 2259, 2260, 2261, 2299, 2325, 2339, 2344, 2348, 2355, 2357, 2427, 2583, 2601, 2604, 2609, 2676, 2713, 2714, 2715, 2925, 2949, 3067, 3142, 3146, 3150, 3197);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 12 WHERE `poolid` IN (3228, 3229, 3230, 3250, 3253, 3255, 3283, 3285, 3288, 3352, 3353, 3366, 3389, 3391, 3401, 3402, 3404, 3408, 3546, 3560, 3593, 3596, 3750, 3751, 3762, 3797, 3823, 3826, 3978, 3986, 4085, 4187, 4200, 4206, 4263, 4283, 4305, 4336, 4340, 4345);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 12 WHERE `poolid` IN (4346, 4348, 4381, 4527, 4565, 4619, 4685, 4729, 5474, 5475, 5500, 5507, 5511, 5536, 5601, 5635, 5636, 5651, 5652, 5681, 5683, 5723, 5724, 5761, 5776, 5787, 5800, 5814, 5866, 5876, 5953, 5954, 5956, 5957, 6004, 6008, 6083, 6101, 6110, 6115);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 12 WHERE `poolid` IN (6123, 6125, 6126, 6127, 6128, 6129, 6341, 6392, 6587, 6744, 6751, 6969, 7013, 7071, 7091);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 15 WHERE `poolid` IN (14, 16, 377, 401, 456, 516, 517, 518, 542, 543, 590, 632, 753, 929, 1022, 1066, 1067, 1068, 1069, 1096, 1147, 1168, 1215, 1317, 1484, 1485, 1610, 1611, 1612, 1615, 1627, 1724, 1725, 1726, 1729, 1749, 1777, 1779, 1780, 1781);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 15 WHERE `poolid` IN (1782, 1783, 1784, 1856, 1857, 1858, 1859, 1865, 1878, 1879, 1880, 1881, 1882, 1883, 1884, 1940, 1986, 2017, 2150, 2151, 2152, 2153, 2199, 2252, 2279, 2285, 2307, 2308, 2383, 2636, 2637, 2638, 2639, 2640, 2641, 2642, 2670, 2683, 2778, 2779);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 15 WHERE `poolid` IN (2780, 2814, 2815, 2897, 2915, 2917, 2926, 2928, 2999, 3002, 3018, 3025, 3035, 3038, 3273, 3275, 3337, 3385, 3386, 3392, 3421, 3491, 3703, 3715, 3716, 3717, 3857, 3887, 3888, 3889, 3890, 3891, 3892, 3893, 3993, 4208, 4209, 4409, 4414, 4419);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 15 WHERE `poolid` IN (4422, 4434, 4435, 4449, 4451, 4472, 4494, 4495, 4496, 4499, 4510, 4512, 4520, 4597, 4832, 4942, 5346, 5420, 5554, 5557, 5766, 5774, 5785, 5815, 5827, 5847, 6060, 6062, 6063, 6068, 6088, 6098, 6099, 6144, 6320, 6680, 6681, 6972, 6974, 6978);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 15 WHERE `poolid` IN (6979, 7009, 7036, 7037, 7560, 7561, 7562, 7563, 7564, 30001);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 17 WHERE `poolid` IN (12, 84, 110, 311, 359, 600, 601, 602, 718, 806, 808, 866, 960, 1070, 1158, 1805, 1824, 1937, 1938, 2177, 2179, 2291, 2359, 2403, 2810, 2839, 3166, 4075, 4078, 4465, 4469, 4514, 4676, 4680, 5213, 5215, 5498, 5513, 5514, 5515);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 17 WHERE `poolid` IN (5516, 5529, 5533, 5535, 5550, 5576, 5614, 5653, 5755, 5807, 5809, 5810, 5812, 6005, 6006, 6007, 6133, 6134, 6135, 6143, 6150, 6167, 6689, 6695, 6729, 6778, 6823, 6997);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 24 WHERE `poolid` IN (53, 224, 376, 1179, 1370, 1392, 1423, 1436, 1455, 2190, 2244, 2504, 2791, 2816, 2954, 3066, 3241, 3737, 3820, 3970, 4185, 4189, 4313, 5359, 5552, 5696, 5732, 6058, 6112, 6118, 6119, 6121, 6124, 6410, 6730, 6762, 6763, 7066, 7067);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 13 WHERE `poolid` IN (540, 677, 778, 779, 780, 781, 782, 949, 1001, 1032, 1860, 1869, 1895, 1896, 1897, 2081, 2137, 2474, 2824, 2825, 2826, 2827, 3195, 3310, 3351, 3416, 3439, 4002, 4539, 4540, 4541, 5797, 6114, 6743, 7040);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 8 WHERE `poolid` IN (320, 802, 803, 1026, 1227, 1250, 1279, 1307, 1319, 2566, 3926, 4721, 5506, 5606, 5607, 5608, 5615, 5684, 5685, 6514, 7031, 7032);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 30 WHERE `poolid` IN (95, 1177, 1523, 1529, 1533, 1541, 1551, 1560, 1575, 1581, 1596, 1598, 1761, 2012, 2160, 3203, 3332, 4096, 4664, 6485);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 10 WHERE `poolid` IN (402, 403, 1180, 1964, 2212, 2454, 2682, 2781, 3301, 3466, 4007, 4237, 4268, 6102, 6172, 7095, 7096, 7097, 7098);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 15 WHERE `poolid` IN (101, 278, 1152, 1153, 1156, 1395, 1847, 2284, 3076, 3149, 3971, 4674, 5811, 6136, 6690, 6691, 6990);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 20 WHERE `poolid` IN (579, 580, 581, 612, 613, 821, 822, 823, 1592, 3383, 3840, 4259, 4491, 4629, 4686, 7004);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 13 WHERE `poolid` IN (620, 649, 794, 824, 879, 2206, 2503, 2722, 3615, 3987, 4093, 4122, 5199, 5212, 6772);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 27 WHERE `poolid` IN (69, 891, 1603, 2216, 2939, 2955, 3663, 3988, 4114, 4118, 4188, 4260, 4492, 6942);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 11 WHERE `poolid` IN (418, 461, 618, 1591, 1617, 2270, 2385, 2506, 3772, 4076, 4094, 6396, 6397, 6788);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 25 WHERE `poolid` IN (629, 1222, 1424, 1594, 1854, 2127, 2391, 3086, 3307, 3390, 5362, 5363, 5510, 5788);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 20 WHERE `poolid` IN (727, 1764, 2730, 2880, 3331, 4713, 5503, 5504, 5675, 5760, 5783, 6592, 6594);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 8 WHERE `poolid` IN (973, 1297, 2591, 2592, 2593, 2594, 2595, 2596, 3065, 4654, 5495, 5497);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 8 WHERE `poolid` IN (2066, 2067, 4071, 4211, 4213, 4454, 4860, 5216, 5808, 6145, 6688, 7566);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 35 WHERE `poolid` IN (544, 2139, 2278, 2952, 3861, 6117, 6120, 6122, 7065, 7068);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 6 WHERE `poolid` IN (1428, 3182, 3184, 3186, 3187, 4295, 4947, 5509, 5686, 5687);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 37 WHERE `poolid` IN (903, 2117, 3176, 3434, 3517, 3837, 4497, 5136, 6599);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 11 WHERE `poolid` IN (1750, 2899, 2900, 2901, 2902, 3954, 6825, 6988, 6991);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 20 WHERE `poolid` IN (261, 4231, 4232, 4233, 4234, 5310, 5795, 5798);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 16 WHERE `poolid` IN (373, 1590, 1829, 2087, 2539, 3666, 4608, 5214);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 10 WHERE `poolid` IN (939, 1727, 3151, 3280, 3651, 6303, 6304, 6822);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 18 WHERE `poolid` IN (550, 1121, 1228, 2540, 3144, 3308, 4617);
UPDATE `mob_pools` SET `modelSize` = 3, `modelHitboxSize` = 35 WHERE `poolid` IN (4665, 4667, 5315, 5603, 5604, 5781, 5784);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 25 WHERE `poolid` IN (365, 2434, 2435, 3302, 3595, 4737);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 34 WHERE `poolid` IN (2322, 5610, 5801, 5802, 5804, 5805);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 45 WHERE `poolid` IN (4489, 5502, 5789, 5791, 5792, 5794);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 11 WHERE `poolid` IN (312, 1477, 1593, 3147, 6337);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 36 WHERE `poolid` IN (526, 1327, 2554, 3096, 6860);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 14 WHERE `poolid` IN (969, 970, 971, 972, 3441);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 3 WHERE `poolid` IN (4485, 5813, 6147, 6693, 6694);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 12 WHERE `poolid` IN (5200, 5201, 5314, 5508, 6967);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 9 WHERE `poolid` IN (616, 1254, 3053, 4108);
UPDATE `mob_pools` SET `modelSize` = 1, `modelHitboxSize` = 32 WHERE `poolid` IN (549, 2861, 6349);
UPDATE `mob_pools` SET `modelSize` = 3, `modelHitboxSize` = 41 WHERE `poolid` IN (5777, 5778, 5782);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 27 WHERE `poolid` IN (3629, 4712);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 28 WHERE `poolid` IN (4663, 4666);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 34 WHERE `poolid` IN (5790, 5793);
UPDATE `mob_pools` SET `modelSize` = 3, `modelHitboxSize` = 25 WHERE `poolid` IN (5796, 5799);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 29 WHERE `poolid` IN (5803, 5806);
UPDATE `mob_pools` SET `modelSize` = 3, `modelHitboxSize` = 15 WHERE `poolid` IN (1155);
UPDATE `mob_pools` SET `modelSize` = 3, `modelHitboxSize` = 63 WHERE `poolid` IN (4475);
UPDATE `mob_pools` SET `modelSize` = 3, `modelHitboxSize` = 47 WHERE `poolid` IN (5700);
UPDATE `mob_pools` SET `modelSize` = 0, `modelHitboxSize` = 17 WHERE `poolid` IN (5779);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 32 WHERE `poolid` IN (5780);
UPDATE `mob_pools` SET `modelSize` = 2, `modelHitboxSize` = 22 WHERE `poolid` IN (6964);
