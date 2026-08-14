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
