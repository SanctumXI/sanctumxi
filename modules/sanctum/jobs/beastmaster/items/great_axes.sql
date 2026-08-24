-- Give Beastmaster access to every Great Axe that Dark Knight can equip.
UPDATE `item_equipment` AS `equipment`
INNER JOIN `item_weapon` AS `weapon`
    ON `weapon`.`itemId` = `equipment`.`itemId`
SET `equipment`.`jobs` = `equipment`.`jobs` | 256
WHERE `weapon`.`skill` = 6
  AND (`equipment`.`jobs` & 128) <> 0;

-- Give Beastmaster the same Great Axe weapon-skill access as Dark Knight.
UPDATE `weapon_skills`
SET `jobs` = INSERT(`jobs`, 9, 1, SUBSTRING(`jobs`, 8, 1))
WHERE `type` = 6
  AND ORD(SUBSTRING(`jobs`, 8, 1)) > 0;

-- Also give Beastmaster access to the Warrior-only Great Axe weapon skills
UPDATE `weapon_skills`
SET `jobs` = INSERT(`jobs`, 9, 1, SUBSTRING(`jobs`, 1, 1))
WHERE `weaponskillid` IN (86, 90);
