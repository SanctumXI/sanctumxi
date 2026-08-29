-- Slot 1216 is conserve_tp_chance here, not Ancient Circle Recast. Nothing should
-- shorten Ancient Circle.
UPDATE `abilities`
SET `meritModID` = 0
WHERE `abilityId` = 65;
