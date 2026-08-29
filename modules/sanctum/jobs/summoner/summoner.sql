UPDATE `abilities`
SET `level` = 255
WHERE `abilityId` = 385 AND `name` = 'apogee' AND `job` = 15;

UPDATE `skill_ranks`
SET `smn` = 1
WHERE `skillid` = 38 AND `name` = 'summoning';

UPDATE `abilities`
SET `level` = CASE `abilityId`
    WHEN 553 THEN 55
    WHEN 618 THEN 60
    WHEN 569 THEN 65
END
WHERE `job` = 15 AND `abilityId` IN (553, 618, 569);

-- Bit 4 is NO_TP_COST in CPetSkillState. Clear it only for level-75 SMN pacts.
UPDATE `pet_skills`
SET `pet_skill_flag` = `pet_skill_flag` & ~4,
    `pet_prepare_time` = 500
WHERE (`pet_skill_flag` & 192) <> 0
  AND `pet_skill_id` NOT IN (668, 669, 671)
  AND `pet_skill_id` IN
  (
      SELECT `abilityId` FROM `abilities` WHERE `job` = 15 AND `level` <= 75
  );

-- Preserve saved spell knowledge, but remove player casting eligibility.
UPDATE `spell_list`
SET `jobs` = UNHEX(REPEAT('00', 22))
WHERE (`spellid` = 306 AND `name` = 'alexander')
   OR (`spellid` = 847 AND `name` = 'atomos');

-- Also hide these actions from Diabolos's overly broad pet-command range.
UPDATE `abilities`
SET `level` = 255
WHERE (`abilityId` = 668 AND `name` = 'deconstruction')
   OR (`abilityId` = 669 AND `name` = 'chronoshift')
   OR (`abilityId` = 671 AND `name` = 'perfect_defense');

UPDATE `mob_spell_lists`
SET `min_level` = 48
WHERE `spell_list_id` = 210 AND `spell_id` = 57;

UPDATE `mob_spell_lists`
SET `min_level` = 63
WHERE `spell_list_id` = 210 AND `spell_id` = 46;

UPDATE `mob_spell_lists`
SET `min_level` = 10
WHERE `spell_list_id` = 210 AND `spell_id` = 48;
