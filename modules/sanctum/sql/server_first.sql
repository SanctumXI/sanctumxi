-- Server First archive.
--
-- Run this with dbtool before turning ServerFirst.lua on. Nothing here ever
-- gets updated or deleted. The full roster and every relic/mythic award are
-- meant to stay on the books.

CREATE TABLE IF NOT EXISTS `server_first_events` (
    `event_key`         varchar(96)  NOT NULL,
    `category`          varchar(255) NOT NULL,
    `subject`           varchar(255) NOT NULL,
    `credit_type`       varchar(255) NOT NULL,
    `credit_name`       varchar(255) NOT NULL,
    `zone_id`           smallint unsigned NOT NULL DEFAULT 0,
    `announced_message` varchar(511) NOT NULL,
    `occurred_at`       int unsigned NOT NULL,
    PRIMARY KEY (`event_key`),
    KEY `server_first_events_occurred_at_idx` (`occurred_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `server_first_participants` (
    `event_key`      varchar(96)  NOT NULL,
    `charid`         int unsigned NOT NULL,
    `charname`       varchar(255) NOT NULL,
    `linkshell_name` varchar(255) DEFAULT NULL,
    `is_leader`      tinyint(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`event_key`, `charid`),
    KEY `server_first_participants_charid_idx` (`charid`),
    CONSTRAINT `server_first_participants_event_fk`
        FOREIGN KEY (`event_key`) REFERENCES `server_first_events` (`event_key`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `server_legendary_weapons` (
    `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
    `charid`      int unsigned NOT NULL,
    `charname`    varchar(255) NOT NULL,
    `weapon_id`   smallint unsigned NOT NULL,
    `weapon_name` varchar(255) NOT NULL,
    `weapon_kind` varchar(255) NOT NULL,
    `zone_id`     smallint unsigned NOT NULL DEFAULT 0,
    `awarded_at`  int unsigned NOT NULL,
    PRIMARY KEY (`id`),
    KEY `server_legendary_weapons_charid_idx` (`charid`),
    KEY `server_legendary_weapons_awarded_at_idx` (`awarded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
