-- Steady Wing is available only when Dragoon is the character's main job.
UPDATE `abilities` SET `addType` = `addType` | 4 WHERE `abilityId` = 295;

-- Natural weapon skills introduced at 290 skill or later are out of era.
UPDATE `weapon_skills`
SET `jobs` = 0x00000000000000000000000000000000000000000000
WHERE `skilllevel` >= 290;

-- Fulminous Fury and No Quarter are centered AoEs, like Self-Destruct.
UPDATE `mob_skills` SET `mob_skill_aoe` = 1 WHERE `mob_skill_id` IN (3657, 3658);

-- Notorious Bombs do not randomly select Self-Destruct. NMs with scripted
-- Self-Destruct conditions can still explicitly select it from their Lua.
DELETE FROM `mob_skill_lists` WHERE `skill_list_id` = 31002;
INSERT INTO `mob_skill_lists` VALUES ('Sanctum_Bomb_NM', 31002, 510);

UPDATE `mob_pools`
SET `skill_list_id` = 31002
WHERE
    `familyid` = 46 AND
    (`mobType` & 2) != 0 AND
    `skill_list_id` = 56;
