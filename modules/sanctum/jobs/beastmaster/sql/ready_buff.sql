UPDATE `abilities`
SET `meritModID` = 0
WHERE `abilityId` IN (72, 251);

UPDATE `abilities_charges`
SET
    `chargeTime` = 30,
    `meritModID` = 0
WHERE
    `recastId` = 102 AND
    `job` = 9 AND
    `level` = 25;
