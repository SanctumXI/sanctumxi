-- Double Palm Shield has a row, an enum entry and a C++ id but no ability script,
-- so it burned its recast and did nothing. Pull the row until it is written.
DELETE FROM `abilities`
WHERE `abilityId` = 971;
