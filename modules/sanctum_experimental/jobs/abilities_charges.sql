-- Sanctum job ability charge progression. These complete rows are module-owned.
DELETE FROM `abilities_charges`
WHERE (`recastId`,`job`,`level`) IN
(
    (102,9,25)
);

INSERT INTO `abilities_charges` VALUES (102,9,25,3,45,902);

