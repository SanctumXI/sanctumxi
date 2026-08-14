CREATE TABLE IF NOT EXISTS `linkshell_bank_quarantine`
(
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `linkshell_id` INT UNSIGNED NOT NULL,
    `container_id` TINYINT UNSIGNED NOT NULL,
    `slot` TINYINT UNSIGNED NOT NULL,
    `itemId` SMALLINT UNSIGNED NOT NULL,
    `quantity` INT UNSIGNED NOT NULL,
    `signature` VARCHAR(20) NOT NULL DEFAULT '',
    `extra` BLOB(24) NULL,
    `revision` BIGINT UNSIGNED NOT NULL DEFAULT 1,
    `reason` VARCHAR(64) NOT NULL,
    `quarantined_at` TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    PRIMARY KEY (`id`),
    KEY `idx_linkshell_bank_quarantine_ls` (`linkshell_id`, `quarantined_at`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci;
