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
