-- Sanctum Blue Magic stat modifiers. Complete current rows and retired keys are module-owned.
DELETE FROM `blue_spell_mods`
WHERE (`spellId`,`modid`) IN
(
    (513,13),
    (519,11),
    (519,14),
    (522,2),
    (522,5),
    (522,12),
    (531,12),
    (533,8),
    (535,12),
    (540,8),
    (540,12),
    (540,13),
    (541,2),
    (541,5),
    (541,8),
    (542,2),
    (542,5),
    (543,8),
    (543,12),
    (557,2),
    (557,5),
    (557,14),
    (563,11),
    (563,12),
    (564,2),
    (564,5),
    (565,2),
    (565,14),
    (570,2),
    (570,5),
    (573,11),
    (582,11),
    (582,14),
    (585,2),
    (588,2),
    (588,10),
    (589,9),
    (589,13),
    (598,2),
    (598,5),
    (598,13),
    (599,2),
    (599,5),
    (605,2),
    (605,5),
    (605,12),
    (611,12),
    (617,2),
    (617,5),
    (617,10),
    (617,12),
    (622,10),
    (622,12),
    (632,10),
    (636,9),
    (636,10),
    (638,2),
    (638,5),
    (638,11),
    (638,14),
    (642,2),
    (642,5),
    (645,2),
    (645,5),
    (645,14),
    (646,5),
    (648,5),
    (648,12),
    (653,9),
    (653,11)
);

INSERT INTO `blue_spell_mods` VALUES (513,13,3); -- MND+3

INSERT INTO `blue_spell_mods` VALUES (519,11,2); -- AGI+1

INSERT INTO `blue_spell_mods` VALUES (522,5,10); -- MP+10
INSERT INTO `blue_spell_mods` VALUES (522,12,1); -- INT+1

INSERT INTO `blue_spell_mods` VALUES (531,12,2); -- INT+2

INSERT INTO `blue_spell_mods` VALUES (533,8,3); -- STR+3

INSERT INTO `blue_spell_mods` VALUES (535,12,1); -- INT+1

INSERT INTO `blue_spell_mods` VALUES (540,8,2); -- STR+2

INSERT INTO `blue_spell_mods` VALUES (541,2,-15); -- HP-15
INSERT INTO `blue_spell_mods` VALUES (541,8,1); -- STR+1

INSERT INTO `blue_spell_mods` VALUES (542,2,-10); -- HP-10
INSERT INTO `blue_spell_mods` VALUES (542,5,10); -- MP+10

INSERT INTO `blue_spell_mods` VALUES (543,8,1); -- STR+1

INSERT INTO `blue_spell_mods` VALUES (557,14,2); -- CHA+2

INSERT INTO `blue_spell_mods` VALUES (563,12,3); -- INT+2

INSERT INTO `blue_spell_mods` VALUES (564,2,10); -- HP+10

INSERT INTO `blue_spell_mods` VALUES (565,14,3); -- CHR+3

INSERT INTO `blue_spell_mods` VALUES (570,2,-10); -- HP-10

INSERT INTO `blue_spell_mods` VALUES (573,11,3); -- AGI+3

INSERT INTO `blue_spell_mods` VALUES (582,14,2); -- CHA+2

INSERT INTO `blue_spell_mods` VALUES (585,2,10); -- HP+10

INSERT INTO `blue_spell_mods` VALUES (588,10,2); -- VIT+2

INSERT INTO `blue_spell_mods` VALUES (589,13,1); -- MND+1

INSERT INTO `blue_spell_mods` VALUES (598,13,2); -- MND+2

INSERT INTO `blue_spell_mods` VALUES (599,2,-10); -- HP-10
INSERT INTO `blue_spell_mods` VALUES (599,5,10); -- MP+10

INSERT INTO `blue_spell_mods` VALUES (605,12,2); -- INT+2

INSERT INTO `blue_spell_mods` VALUES (611,12,2); -- INT+2

INSERT INTO `blue_spell_mods` VALUES (617,12,3); -- INT+3

INSERT INTO `blue_spell_mods` VALUES (622,10,1); -- VIT+1

INSERT INTO `blue_spell_mods` VALUES (632,10,2); -- VIT+2

INSERT INTO `blue_spell_mods` VALUES (636,9,1); -- DEX+1

INSERT INTO `blue_spell_mods` VALUES (638,5,5); -- MP+5,
INSERT INTO `blue_spell_mods` VALUES (638,11,2); -- AGI+2

INSERT INTO `blue_spell_mods` VALUES (642,5,10); -- MP+10

INSERT INTO `blue_spell_mods` VALUES (645,2,10); -- HP+10
INSERT INTO `blue_spell_mods` VALUES (645,14,3); -- CHR+3

INSERT INTO `blue_spell_mods` VALUES (646,5,10); -- MP+10

INSERT INTO `blue_spell_mods` VALUES (648,12,2); -- INT+2

INSERT INTO `blue_spell_mods` VALUES (653,9,3); -- DEX+3

