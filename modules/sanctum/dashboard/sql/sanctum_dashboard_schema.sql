-- Sanctum XI Dashboard server schema.
-- This file is safe to run repeatedly on MariaDB and replaces the former
-- per-feature dashboard SQL files.

CREATE TABLE IF NOT EXISTS `sanctum_dashboard_schema_versions`
(
    `version`     int unsigned NOT NULL,
    `description` varchar(160) NOT NULL,
    `applied_at`  datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_library_access`
(
    `linkshell_id` int unsigned NOT NULL,
    `purchased_by` int unsigned NOT NULL,
    `price`        int unsigned NOT NULL,
    `purchased_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`linkshell_id`),
    UNIQUE KEY `uq_linkshell_library_access_buyer` (`purchased_by`),
    CONSTRAINT `fk_linkshell_library_access_linkshell`
        FOREIGN KEY (`linkshell_id`) REFERENCES `linkshells` (`linkshellid`)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_moglocker`
(
    `linkshell_id` int unsigned NOT NULL,
    `container_id` tinyint unsigned NOT NULL DEFAULT 4,
    `slot`         tinyint unsigned NOT NULL,
    `itemId`       smallint unsigned NOT NULL,
    `quantity`     int unsigned NOT NULL DEFAULT 1,
    `signature`    varchar(20) NOT NULL DEFAULT '',
    `extra`        blob(24) NOT NULL,
    `revision`     bigint unsigned NOT NULL DEFAULT 1,
    PRIMARY KEY (`linkshell_id`, `container_id`, `slot`),
    KEY `idx_linkshell_bank_item` (`linkshell_id`, `itemId`),
    CONSTRAINT `fk_linkshell_bank_linkshell`
        FOREIGN KEY (`linkshell_id`) REFERENCES `linkshells` (`linkshellid`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `chk_linkshell_bank_container` CHECK (`container_id` IN (1, 4, 9)),
    CONSTRAINT `chk_linkshell_bank_slot` CHECK (`slot` BETWEEN 1 AND 80),
    CONSTRAINT `chk_linkshell_bank_quantity` CHECK (`quantity` > 0),
    CONSTRAINT `chk_linkshell_bank_extra` CHECK (OCTET_LENGTH(`extra`) = 24),
    CONSTRAINT `chk_linkshell_bank_revision` CHECK (`revision` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_treasury`
(
    `linkshell_id` int unsigned NOT NULL,
    `item_id`      smallint unsigned NOT NULL,
    `quantity`     int unsigned NOT NULL DEFAULT 0,
    PRIMARY KEY (`linkshell_id`, `item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_bank_audit`
(
    `id`                    bigint unsigned NOT NULL AUTO_INCREMENT,
    `linkshell_id`          int unsigned NOT NULL,
    `actor_charid`          int unsigned NOT NULL,
    `actor_name`            varchar(15) NOT NULL,
    `operation`             varchar(20) NOT NULL,
    `source_container`      tinyint unsigned NOT NULL,
    `source_slot`           tinyint unsigned NOT NULL,
    `destination_container` tinyint unsigned NOT NULL,
    `destination_slot`      tinyint unsigned NOT NULL,
    `itemId`                smallint unsigned NOT NULL,
    `quantity`              int unsigned NOT NULL,
    `signature`             varchar(20) NOT NULL DEFAULT '',
    `extra`                 blob(24) NOT NULL,
    `created_at`            timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`id`),
    KEY `idx_linkshell_bank_audit_ls_time` (`linkshell_id`, `created_at`),
    KEY `idx_linkshell_bank_audit_actor` (`actor_charid`, `created_at`),
    KEY `idx_linkshell_bank_audit_item` (`itemId`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_bank_quarantine`
(
    `id`             bigint unsigned NOT NULL AUTO_INCREMENT,
    `linkshell_id`   int unsigned NOT NULL,
    `container_id`   tinyint unsigned NOT NULL,
    `slot`           tinyint unsigned NOT NULL,
    `itemId`         smallint unsigned NOT NULL,
    `quantity`       int unsigned NOT NULL,
    `signature`      varchar(20) NOT NULL DEFAULT '',
    `extra`          blob(24) NULL,
    `revision`       bigint unsigned NOT NULL DEFAULT 1,
    `reason`         varchar(64) NOT NULL,
    `quarantined_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`id`),
    KEY `idx_linkshell_bank_quarantine_ls` (`linkshell_id`, `quarantined_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_management_audit`
(
    `id`                       bigint unsigned NOT NULL AUTO_INCREMENT,
    `linkshell_id`             int unsigned NOT NULL,
    `authenticated_account_id` int unsigned NOT NULL,
    `actor_charid`             int unsigned NOT NULL,
    `actor_name`               varchar(15) NOT NULL,
    `target_charid`            int unsigned NOT NULL,
    `target_name`              varchar(15) NOT NULL,
    `action`                   varchar(32) NOT NULL,
    `details`                  varchar(512) NOT NULL DEFAULT '',
    `created_at`               timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_linkshell_management_ls_time` (`linkshell_id`, `created_at`),
    KEY `idx_linkshell_management_actor_time` (`actor_charid`, `created_at`),
    KEY `idx_linkshell_management_target_time` (`target_charid`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_message_commands`
(
    `id`                       bigint unsigned NOT NULL AUTO_INCREMENT,
    `linkshell_id`             int unsigned NOT NULL,
    `authenticated_account_id` int unsigned NOT NULL,
    `actor_charid`             int unsigned NOT NULL,
    `actor_name`               varchar(15) NOT NULL,
    `message`                  blob NOT NULL,
    `expected_message`         blob NULL,
    `expected_messagetime`     int unsigned NOT NULL DEFAULT 0,
    `status`                   varchar(16) NOT NULL DEFAULT 'pending',
    `claim_token`              varchar(96) NULL,
    `failure_reason`           varchar(255) NOT NULL DEFAULT '',
    `requested_at`             timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `claimed_at`               timestamp(6) NULL DEFAULT NULL,
    `completed_at`             timestamp(6) NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_linkshell_message_pending` (`status`, `id`),
    KEY `idx_linkshell_message_shell_time` (`linkshell_id`, `requested_at`),
    KEY `idx_linkshell_message_claim` (`claim_token`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_recruitment_profiles`
(
    `linkshell_id`       int unsigned NOT NULL,
    `is_visible`         tinyint(1) unsigned NOT NULL DEFAULT 0,
    `headline`           varchar(120) NOT NULL DEFAULT '',
    `description`        text NOT NULL,
    `playstyle`          varchar(160) NOT NULL DEFAULT '',
    `schedule`           varchar(160) NOT NULL DEFAULT '',
    `requirements`       text NOT NULL,
    `contact`            varchar(240) NOT NULL DEFAULT '',
    `updated_by_charid`  int unsigned NOT NULL,
    `updated_at`         datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                      ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`linkshell_id`),
    KEY `idx_linkshell_recruitment_visible_time` (`is_visible`, `updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_recruitment_applications`
(
    `id`                         bigint unsigned NOT NULL AUTO_INCREMENT,
    `linkshell_id`               int unsigned NOT NULL,
    `applicant_account_id`       int unsigned NOT NULL,
    `applicant_charid`           int unsigned NOT NULL,
    `applicant_name`             varchar(15) NOT NULL,
    `application_message`        text NOT NULL,
    `status`                     varchar(24) NOT NULL DEFAULT 'pending',
    `active_slot`                tinyint(1) unsigned NULL DEFAULT 1,
    `applied_at`                 datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `decided_at`                 datetime(6) NULL,
    `decided_by_charid`          int unsigned NULL,
    `decision_note`              varchar(1000) NOT NULL DEFAULT '',
    `pearl_delivered_at`         datetime(6) NULL,
    `pearl_claim_expires_at`     datetime(6) NULL,
    `pearl_online_notified_at`   datetime(6) NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_linkshell_recruitment_active`
        (`linkshell_id`, `applicant_charid`, `active_slot`),
    KEY `idx_linkshell_recruitment_inbox`
        (`linkshell_id`, `status`, `applied_at`),
    KEY `idx_linkshell_recruitment_applicant`
        (`applicant_charid`, `applied_at`),
    KEY `idx_linkshell_recruitment_notification`
        (`status`, `pearl_online_notified_at`, `decided_at`),
    CONSTRAINT `chk_linkshell_recruitment_status`
        CHECK (`status` IN ('pending', 'approved', 'rejected', 'joined', 'withdrawn')),
    CONSTRAINT `chk_linkshell_recruitment_active_slot`
        CHECK (`active_slot` IS NULL OR `active_slot` = 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `linkshell_recruitment_applications`
    ADD COLUMN IF NOT EXISTS `pearl_claim_expires_at` datetime(6) NULL
    AFTER `pearl_delivered_at`;

ALTER TABLE `linkshell_recruitment_applications`
    ADD COLUMN IF NOT EXISTS `pearl_online_notified_at` datetime(6) NULL
    AFTER `pearl_claim_expires_at`;

ALTER TABLE `linkshell_recruitment_applications`
    ADD INDEX IF NOT EXISTS `idx_linkshell_recruitment_notification`
    (`status`, `pearl_online_notified_at`, `decided_at`);

CREATE TABLE IF NOT EXISTS `sanctum_friendships`
(
    `id`                    bigint unsigned NOT NULL AUTO_INCREMENT,
    `character_low_id`      int unsigned NOT NULL,
    `character_high_id`     int unsigned NOT NULL,
    `requested_by_charid`   int unsigned NOT NULL,
    `status`                enum('pending','accepted') NOT NULL DEFAULT 'pending',
    `requested_at`          datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `accepted_at`           datetime(6) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_sanctum_friend_pair` (`character_low_id`, `character_high_id`),
    KEY `idx_sanctum_friends_high_status` (`character_high_id`, `status`),
    KEY `idx_sanctum_friends_requester_status` (`requested_by_charid`, `status`),
    CONSTRAINT `chk_sanctum_friend_pair_order` CHECK (`character_low_id` < `character_high_id`),
    CONSTRAINT `chk_sanctum_friend_requester`
        CHECK (`requested_by_charid` IN (`character_low_id`, `character_high_id`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `sanctum_friend_preferences`
(
    `owner_charid`    int unsigned NOT NULL,
    `friend_charid`   int unsigned NOT NULL,
    `is_favorite`     tinyint(1) unsigned NOT NULL DEFAULT 0,
    `notify_on_login` tinyint(1) unsigned NOT NULL DEFAULT 1,
    `private_note`    varchar(240) NOT NULL DEFAULT '',
    `updated_at`      datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                  ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`owner_charid`, `friend_charid`),
    KEY `idx_sanctum_friend_preferences_friend` (`friend_charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `sanctum_yells`
(
    `id`            bigint unsigned NOT NULL AUTO_INCREMENT,
    `sender_charid` int unsigned DEFAULT NULL,
    `sender_name`   varchar(15) NOT NULL,
    `zone_id`       smallint unsigned DEFAULT NULL,
    `message`       varchar(512) NOT NULL,
    `sent_at`       datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`id`),
    KEY `idx_sanctum_yells_sent` (`sent_at`, `id`),
    KEY `idx_sanctum_yells_sender` (`sender_charid`, `sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `sanctum_crafter_profiles`
(
    `charid`           int unsigned NOT NULL,
    `is_visible`       tinyint(1) unsigned NOT NULL DEFAULT 0,
    `accepts_requests` tinyint(1) unsigned NOT NULL DEFAULT 1,
    `availability`     varchar(40) NOT NULL DEFAULT 'Available',
    `note`             varchar(240) NOT NULL DEFAULT '',
    `updated_at`       datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                   ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`charid`),
    KEY `idx_sanctum_crafter_visible` (`is_visible`, `accepts_requests`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `sanctum_craft_requests`
(
    `id`               bigint unsigned NOT NULL AUTO_INCREMENT,
    `requester_charid` int unsigned NOT NULL,
    `crafter_charid`   int unsigned NOT NULL,
    `craft_skill_id`   smallint unsigned NOT NULL,
    `item_name`        varchar(120) NOT NULL,
    `quantity`         int unsigned NOT NULL DEFAULT 1,
    `message`          varchar(500) NOT NULL DEFAULT '',
    `status`           enum('pending','accepted','declined','cancelled','expired')
                       NOT NULL DEFAULT 'pending',
    `created_at`       datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `expires_at`       datetime(6) NOT NULL,
    `responded_at`     datetime(6) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_sanctum_craft_incoming` (`crafter_charid`, `status`, `created_at`),
    KEY `idx_sanctum_craft_sent` (`requester_charid`, `status`, `created_at`),
    KEY `idx_sanctum_craft_expiry` (`status`, `expires_at`),
    CONSTRAINT `chk_sanctum_craft_distinct_players`
        CHECK (`requester_charid` <> `crafter_charid`),
    CONSTRAINT `chk_sanctum_craft_quantity` CHECK (`quantity` BETWEEN 1 AND 9999),
    CONSTRAINT `chk_sanctum_craft_skill` CHECK (`craft_skill_id` BETWEEN 48 AND 57)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `sanctum_dashboard_schema_versions` (`version`, `description`)
VALUES (1, 'Consolidated dashboard baseline')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);
