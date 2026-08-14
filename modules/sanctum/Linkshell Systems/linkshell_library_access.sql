CREATE TABLE IF NOT EXISTS `linkshell_library_access`
(
    `linkshell_id` INT UNSIGNED NOT NULL,
    `purchased_by` INT UNSIGNED NOT NULL,
    `price` INT UNSIGNED NOT NULL,
    `purchased_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`linkshell_id`),
    UNIQUE KEY `uq_linkshell_library_access_buyer` (`purchased_by`),
    CONSTRAINT `fk_linkshell_library_access_linkshell`
        FOREIGN KEY (`linkshell_id`) REFERENCES `linkshells` (`linkshellid`)
        ON UPDATE CASCADE ON DELETE CASCADE
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci;
