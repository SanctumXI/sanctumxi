SET @apply_steel_conquest_changes = NOT EXISTS (
    SELECT 1
    FROM `server_variables`
    WHERE `name` = 'steel_conquest_changes_v1'
);

UPDATE `conquest_system` AS `current`
JOIN (
    SELECT 0 AS `region_id`, 0 AS `region_control`, 1 AS `region_control_prev`, 5000 AS `sandoria_influence`, 0 AS `bastok_influence`, 0 AS `windurst_influence`, 0 AS `beastmen_influence`
    UNION ALL SELECT 1, 0, 1, 2600, 2400, 0, 0
    UNION ALL SELECT 2, 0, 1, 3000, 0, 0, 2000
    UNION ALL SELECT 3, 1, 1, 0, 5000, 0, 0
    UNION ALL SELECT 4, 1, 0, 0, 3000, 0, 2000
    UNION ALL SELECT 5, 2, 0, 0, 0, 5000, 0
    UNION ALL SELECT 6, 2, 0, 0, 0, 2700, 2300
    UNION ALL SELECT 7, 2, 0, 0, 0, 2600, 2400
    UNION ALL SELECT 8, 3, 0, 1500, 0, 0, 3500
    UNION ALL SELECT 9, 3, 3, 0, 0, 0, 5000
    UNION ALL SELECT 10, 3, 3, 0, 0, 0, 5000
    UNION ALL SELECT 11, 3, 3, 0, 0, 0, 5000
    UNION ALL SELECT 12, 3, 3, 0, 0, 0, 5000
    UNION ALL SELECT 13, 3, 3, 0, 0, 0, 5000
    UNION ALL SELECT 14, 2, 3, 0, 0, 2600, 2400
    UNION ALL SELECT 15, 3, 3, 0, 0, 0, 5000
    UNION ALL SELECT 16, 3, 3, 0, 0, 0, 5000
    UNION ALL SELECT 17, 3, 3, 0, 1500, 0, 3500
    UNION ALL SELECT 18, 3, 3, 0, 0, 0, 5000
) AS `seed` ON `seed`.`region_id` = `current`.`region_id`
SET
    `current`.`region_control` = `seed`.`region_control`,
    `current`.`region_control_prev` = `seed`.`region_control_prev`,
    `current`.`sandoria_influence` = `seed`.`sandoria_influence`,
    `current`.`bastok_influence` = `seed`.`bastok_influence`,
    `current`.`windurst_influence` = `seed`.`windurst_influence`,
    `current`.`beastmen_influence` = `seed`.`beastmen_influence`
WHERE @apply_steel_conquest_changes = 1;

INSERT INTO `server_variables` (`name`, `value`, `expiry`)
SELECT 'steel_conquest_changes_v1', 1, 0
FROM DUAL
WHERE @apply_steel_conquest_changes = 1;
