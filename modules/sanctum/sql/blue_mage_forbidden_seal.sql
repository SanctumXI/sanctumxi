INSERT INTO `abilities`
    (`abilityId`, `name`, `job`, `level`, `validTarget`, `recastTime`, `recastId`,
     `message1`, `message2`, `animation`, `animationTime`, `castTime`, `actionType`,
     `range`, `isAOE`, `radius`, `CE`, `VE`, `meritModID`, `addType`, `content_tag`)
VALUES
    (338, 'unbridled_wisdom', 16, 10, 1, 600, 82, 100, 0, 286, 2000, 0, 6,
     0.0, 0, 0, 0, 0, 0, 0, 'TOAU')
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `job` = VALUES(`job`),
    `level` = VALUES(`level`),
    `validTarget` = VALUES(`validTarget`),
    `recastTime` = VALUES(`recastTime`),
    `recastId` = VALUES(`recastId`),
    `message1` = VALUES(`message1`),
    `message2` = VALUES(`message2`),
    `animation` = VALUES(`animation`),
    `animationTime` = VALUES(`animationTime`),
    `castTime` = VALUES(`castTime`),
    `actionType` = VALUES(`actionType`),
    `range` = VALUES(`range`),
    `isAOE` = VALUES(`isAOE`),
    `radius` = VALUES(`radius`),
    `CE` = VALUES(`CE`),
    `VE` = VALUES(`VE`),
    `meritModID` = VALUES(`meritModID`),
    `addType` = VALUES(`addType`),
    `content_tag` = VALUES(`content_tag`);
