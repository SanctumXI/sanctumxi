-- Give Beastmaster access to every bow that Warrior can equip.
UPDATE `item_equipment` AS `equipment`
INNER JOIN `item_weapon` AS `weapon`
    ON `weapon`.`itemId` = `equipment`.`itemId`
SET `equipment`.`jobs` = `equipment`.`jobs` | 256
WHERE `weapon`.`skill` = 25
  AND (`equipment`.`jobs` & 1) <> 0;
