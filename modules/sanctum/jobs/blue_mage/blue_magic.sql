-- Blue Magic job levels are stored in the BLU byte of the jobs binary field.
UPDATE `spell_list`
SET `jobs` = 0x00000000000000000000000000000025000000000000
WHERE `spellid` = 530; -- Refueling: 37

UPDATE `spell_list`
SET `jobs` = 0x00000000000000000000000000000023000000000000
WHERE `spellid` = 636; -- Warm-Up: 35

UPDATE `spell_list`
SET
    `jobs`        = 0x00000000000000000000000000000018000000000000,
    `content_tag` = 'TOAU'
WHERE `spellid` = 678; -- Dream Flower: 24

-- Keep Soporific's set-point and trait data for existing characters, but remove
-- its learnable monster-skill mapping.
UPDATE `blue_spell_list`
SET `mob_skill_id` = 0
WHERE `spellid` = 598;
