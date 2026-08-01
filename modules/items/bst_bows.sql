-- Give Beastmaster access to every Archery weapon that Warrior can equip.
-- Native Archery weapon-skill permissions are intentionally unchanged.
UPDATE `item_equipment` AS `equipment`
INNER JOIN `item_weapon` AS `weapon`
    ON `weapon`.`itemId` = `equipment`.`itemId`
SET `equipment`.`jobs` = `equipment`.`jobs` | 256
WHERE `weapon`.`skill` = 25
  AND (`equipment`.`jobs` & 1) <> 0;
