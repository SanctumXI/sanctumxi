CREATE TABLE IF NOT EXISTS `linkshell_bank_audit`
(
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `linkshell_id` INT UNSIGNED NOT NULL,
    `actor_charid` INT UNSIGNED NOT NULL,
    `actor_name` VARCHAR(15) NOT NULL,
    `operation` VARCHAR(20) NOT NULL,
    `source_container` TINYINT UNSIGNED NOT NULL,
    `source_slot` TINYINT UNSIGNED NOT NULL,
    `destination_container` TINYINT UNSIGNED NOT NULL,
    `destination_slot` TINYINT UNSIGNED NOT NULL,
    `itemId` SMALLINT UNSIGNED NOT NULL,
    `quantity` INT UNSIGNED NOT NULL,
    `signature` VARCHAR(20) NOT NULL DEFAULT '',
    `extra` BLOB(24) NOT NULL,
    `created_at` TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    PRIMARY KEY (`id`),
    KEY `idx_linkshell_bank_audit_ls_time` (`linkshell_id`, `created_at`),
    KEY `idx_linkshell_bank_audit_actor` (`actor_charid`, `created_at`),
    KEY `idx_linkshell_bank_audit_item` (`itemId`, `created_at`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci;
