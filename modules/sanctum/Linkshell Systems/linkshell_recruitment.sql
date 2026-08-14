-- Sanctum companion linkshell recruitment profiles and applications.
-- Keep in sync with the dashboard project's deploy/linkshell_recruitment.sql.

CREATE TABLE IF NOT EXISTS `linkshell_recruitment_profiles`
(
    `linkshell_id`       int unsigned NOT NULL,
    `is_visible`        tinyint(1) unsigned NOT NULL DEFAULT 0,
    `headline`          varchar(120) NOT NULL DEFAULT '',
    `description`       text NOT NULL,
    `playstyle`         varchar(160) NOT NULL DEFAULT '',
    `schedule`          varchar(160) NOT NULL DEFAULT '',
    `requirements`      text NOT NULL,
    `contact`           varchar(240) NOT NULL DEFAULT '',
    `updated_by_charid` int unsigned NOT NULL,
    `updated_at`        datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                      ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`linkshell_id`),
    KEY `idx_linkshell_recruitment_visible_time` (`is_visible`, `updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `linkshell_recruitment_applications`
(
    `id`                   bigint unsigned NOT NULL AUTO_INCREMENT,
    `linkshell_id`         int unsigned NOT NULL,
    `applicant_account_id` int unsigned NOT NULL,
    `applicant_charid`     int unsigned NOT NULL,
    `applicant_name`       varchar(15) NOT NULL,
    `application_message`  text NOT NULL,
    `status`               varchar(24) NOT NULL DEFAULT 'pending',
    `active_slot`          tinyint(1) unsigned NULL DEFAULT 1,
    `applied_at`           datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `decided_at`           datetime(6) NULL,
    `decided_by_charid`    int unsigned NULL,
    `decision_note`        varchar(1000) NOT NULL DEFAULT '',
    `pearl_delivered_at`   datetime(6) NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_linkshell_recruitment_active`
        (`linkshell_id`, `applicant_charid`, `active_slot`),
    KEY `idx_linkshell_recruitment_inbox`
        (`linkshell_id`, `status`, `applied_at`),
    KEY `idx_linkshell_recruitment_applicant`
        (`applicant_charid`, `applied_at`),
    CONSTRAINT `chk_linkshell_recruitment_status`
        CHECK (`status` IN ('pending', 'approved', 'rejected', 'joined', 'withdrawn')),
    CONSTRAINT `chk_linkshell_recruitment_active_slot`
        CHECK (`active_slot` IS NULL OR `active_slot` = 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
