-- Sanctum companion/in-game friends system.
-- Relationships are stored once per unordered character pair. Personal notes,
-- favorites, and login-notification choices remain private to their owner.

CREATE TABLE IF NOT EXISTS `sanctum_friendships` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `character_low_id` int(10) unsigned NOT NULL,
  `character_high_id` int(10) unsigned NOT NULL,
  `requested_by_charid` int(10) unsigned NOT NULL,
  `status` enum('pending','accepted') NOT NULL DEFAULT 'pending',
  `requested_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `accepted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sanctum_friend_pair` (`character_low_id`,`character_high_id`),
  KEY `idx_sanctum_friends_high_status` (`character_high_id`,`status`),
  KEY `idx_sanctum_friends_requester_status` (`requested_by_charid`,`status`),
  CONSTRAINT `chk_sanctum_friend_pair_order` CHECK (`character_low_id` < `character_high_id`),
  CONSTRAINT `chk_sanctum_friend_requester` CHECK (`requested_by_charid` IN (`character_low_id`,`character_high_id`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `sanctum_friend_preferences` (
  `owner_charid` int(10) unsigned NOT NULL,
  `friend_charid` int(10) unsigned NOT NULL,
  `is_favorite` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `notify_on_login` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `private_note` varchar(240) NOT NULL DEFAULT '',
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`owner_charid`,`friend_charid`),
  KEY `idx_sanctum_friend_preferences_friend` (`friend_charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

