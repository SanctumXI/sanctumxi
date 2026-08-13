CREATE TABLE IF NOT EXISTS `linkshell_moglocker`
(
    `linkshell_id` INT UNSIGNED NOT NULL,
    `container_id` TINYINT UNSIGNED NOT NULL DEFAULT 4,
    `slot` TINYINT UNSIGNED NOT NULL,
    `itemId` SMALLINT UNSIGNED NOT NULL,
    `quantity` INT UNSIGNED NOT NULL DEFAULT 1,
    `signature` VARCHAR(20) NOT NULL DEFAULT '',
    `extra` BLOB(24) NOT NULL,
    `revision` BIGINT UNSIGNED NOT NULL DEFAULT 1,

    PRIMARY KEY (`linkshell_id`, `container_id`, `slot`),
    KEY `idx_linkshell_bank_item` (`linkshell_id`, `itemId`),
    CONSTRAINT `fk_linkshell_bank_linkshell`
        FOREIGN KEY (`linkshell_id`) REFERENCES `linkshells` (`linkshellid`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `chk_linkshell_bank_container`
        CHECK (`container_id` IN (1, 4, 9)),
    CONSTRAINT `chk_linkshell_bank_slot`
        CHECK (`slot` BETWEEN 1 AND 80),
    CONSTRAINT `chk_linkshell_bank_quantity`
        CHECK (`quantity` > 0),
    CONSTRAINT `chk_linkshell_bank_extra`
        CHECK (OCTET_LENGTH(`extra`) = 24),
    CONSTRAINT `chk_linkshell_bank_revision`
        CHECK (`revision` > 0)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci;
