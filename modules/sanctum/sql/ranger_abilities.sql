-- Double Shot is a Sanctum level 70 ability and must not depend on Abyssea content.
UPDATE `abilities`
SET `content_tag` = NULL
WHERE `abilityId` = 257 AND `name` = 'double_shot';
