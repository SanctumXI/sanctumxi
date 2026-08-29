-- The internal item_basic name remains caliber_ring because it selects the Lua item script.
-- A client DAT patch is still required to replace Caliber Ring in the inventory UI.
UPDATE `item_basic`
SET `sortname` = 'sanctum_ring'
WHERE `itemid` = 26164;

UPDATE `item_equipment`
SET `name` = 'sanctum_ring'
WHERE `itemid` = 26164;

UPDATE `item_usable`
SET
    `name` = 'sanctum_ring',
    `maxCharges` = 2
WHERE `itemid` = 26164;

UPDATE `char_inventory`
SET `extra` = CONCAT(SUBSTRING(`extra`, 1, 1), 0x02, SUBSTRING(`extra`, 3))
WHERE
    `itemId` = 26164 AND
    OCTET_LENGTH(`extra`) >= 2 AND
    ORD(SUBSTRING(`extra`, 2, 1)) > 2;
