import mariadb


def migration_name():
    return "Expanding Linkshell Mog Locker into the three-tab Linkshell Bank"


def _table_exists(cur, table):
    cur.execute(
        "SELECT 1 FROM information_schema.TABLES "
        "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? LIMIT 1",
        (table,),
    )
    return cur.fetchone() is not None


def _column_exists(cur, table, column):
    cur.execute(
        "SELECT 1 FROM information_schema.COLUMNS "
        "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? "
        "LIMIT 1",
        (table, column),
    )
    return cur.fetchone() is not None


def _column_is_not_null(cur, table, column):
    cur.execute(
        "SELECT IS_NULLABLE FROM information_schema.COLUMNS "
        "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? "
        "LIMIT 1",
        (table, column),
    )
    row = cur.fetchone()
    return row is not None and row[0] == "NO"


def _primary_columns(cur, table):
    cur.execute(f"SHOW INDEX FROM `{table}` WHERE Key_name = 'PRIMARY'")
    return [row[4] for row in cur.fetchall()]


def _table_engine(cur, table):
    cur.execute(
        "SELECT ENGINE FROM information_schema.TABLES "
        "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?",
        (table,),
    )
    row = cur.fetchone()
    return row[0] if row else None


def _constraint_exists(cur, constraint):
    cur.execute(
        "SELECT 1 FROM information_schema.TABLE_CONSTRAINTS "
        "WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = ? LIMIT 1",
        (constraint,),
    )
    return cur.fetchone() is not None


def check_preconditions(cur):
    return


def needs_to_run(cur):
    if not _table_exists(cur, "linkshell_moglocker"):
        return True

    required_columns = ("container_id", "revision")
    if any(
        not _column_exists(cur, "linkshell_moglocker", column)
        for column in required_columns
    ):
        return True

    if not _column_is_not_null(
        cur, "linkshell_moglocker", "signature"
    ) or not _column_is_not_null(cur, "linkshell_moglocker", "extra"):
        return True

    if _table_engine(cur, "linkshell_moglocker") != "InnoDB":
        return True

    if _primary_columns(cur, "linkshell_moglocker") != [
        "linkshell_id",
        "container_id",
        "slot",
    ]:
        return True

    if not _table_exists(cur, "linkshell_bank_audit"):
        return True

    if not _table_exists(cur, "linkshell_bank_quarantine"):
        return True

    required_constraints = (
        "fk_linkshell_bank_linkshell",
        "chk_linkshell_bank_container",
        "chk_linkshell_bank_slot",
        "chk_linkshell_bank_quantity",
        "chk_linkshell_bank_extra",
        "chk_linkshell_bank_revision",
    )
    return any(not _constraint_exists(cur, name) for name in required_constraints)


def _create_support_tables(cur):
    cur.execute("""
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
        COLLATE=utf8mb4_general_ci
        """)
    cur.execute("""
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
        COLLATE=utf8mb4_general_ci
        """)


def _create_items_table(cur):
    cur.execute("""
        CREATE TABLE `linkshell_moglocker`
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
        COLLATE=utf8mb4_general_ci
        """)


def migrate(cur, db):
    try:
        _create_support_tables(cur)

        if not _table_exists(cur, "linkshell_moglocker"):
            _create_items_table(cur)
            db.commit()
            return

        if not _column_exists(cur, "linkshell_moglocker", "container_id"):
            cur.execute(
                "ALTER TABLE `linkshell_moglocker` "
                "ADD COLUMN `container_id` TINYINT UNSIGNED NOT NULL DEFAULT 4 AFTER `linkshell_id`"
            )

        if not _column_exists(cur, "linkshell_moglocker", "revision"):
            cur.execute(
                "ALTER TABLE `linkshell_moglocker` "
                "ADD COLUMN `revision` BIGINT UNSIGNED NOT NULL DEFAULT 1 AFTER `extra`"
            )

        if _table_engine(cur, "linkshell_moglocker") != "InnoDB":
            cur.execute("ALTER TABLE `linkshell_moglocker` ENGINE=InnoDB")

        cur.execute(
            "UPDATE `linkshell_moglocker` "
            "SET `signature` = '' WHERE `signature` IS NULL"
        )
        cur.execute(
            "ALTER TABLE `linkshell_moglocker` "
            "MODIFY COLUMN `signature` VARCHAR(20) NOT NULL DEFAULT ''"
        )

        primary_columns = _primary_columns(cur, "linkshell_moglocker")
        if primary_columns != ["linkshell_id", "container_id", "slot"]:
            cur.execute(
                "ALTER TABLE `linkshell_moglocker` "
                "DROP PRIMARY KEY, "
                "ADD PRIMARY KEY (`linkshell_id`, `container_id`, `slot`)"
            )

        cur.execute("""
            INSERT INTO `linkshell_bank_quarantine`
                (`linkshell_id`, `container_id`, `slot`, `itemId`, `quantity`,
                 `signature`, `extra`, `revision`, `reason`)
            SELECT
                bank.`linkshell_id`,
                bank.`container_id`,
                bank.`slot`,
                bank.`itemId`,
                bank.`quantity`,
                bank.`signature`,
                bank.`extra`,
                bank.`revision`,
                CASE
                    WHEN shell.`linkshellid` IS NULL THEN 'missing linkshell'
                    WHEN bank.`container_id` NOT IN (1, 4, 9) THEN 'invalid container'
                    WHEN bank.`slot` NOT BETWEEN 1 AND 80 THEN 'invalid slot'
                    WHEN item.`itemid` IS NULL THEN 'invalid item id'
                    WHEN item.`type` IN (32, 128) THEN 'prohibited item type'
                    WHEN (item.`flags` & 16384) <> 0 THEN 'exclusive item'
                    WHEN bank.`quantity` = 0 THEN 'zero quantity'
                    WHEN bank.`quantity` > item.`stackSize` THEN 'quantity exceeds stack size'
                    WHEN bank.`extra` IS NOT NULL AND OCTET_LENGTH(bank.`extra`) <> 24 THEN 'invalid extra length'
                    WHEN bank.`revision` = 0 THEN 'invalid revision'
                    ELSE 'invalid row'
                END
            FROM `linkshell_moglocker` AS bank
            LEFT JOIN `linkshells` AS shell
                ON shell.`linkshellid` = bank.`linkshell_id`
            LEFT JOIN `item_basic` AS item
                ON item.`itemid` = bank.`itemId`
            WHERE
                shell.`linkshellid` IS NULL OR
                bank.`container_id` NOT IN (1, 4, 9) OR
                bank.`slot` NOT BETWEEN 1 AND 80 OR
                item.`itemid` IS NULL OR
                item.`type` IN (32, 128) OR
                (item.`flags` & 16384) <> 0 OR
                bank.`quantity` = 0 OR
                bank.`quantity` > item.`stackSize` OR
                (bank.`extra` IS NOT NULL AND OCTET_LENGTH(bank.`extra`) <> 24) OR
                bank.`revision` = 0
            """)
        cur.execute("""
            DELETE bank
            FROM `linkshell_moglocker` AS bank
            LEFT JOIN `linkshells` AS shell
                ON shell.`linkshellid` = bank.`linkshell_id`
            LEFT JOIN `item_basic` AS item
                ON item.`itemid` = bank.`itemId`
            WHERE
                shell.`linkshellid` IS NULL OR
                bank.`container_id` NOT IN (1, 4, 9) OR
                bank.`slot` NOT BETWEEN 1 AND 80 OR
                item.`itemid` IS NULL OR
                item.`type` IN (32, 128) OR
                (item.`flags` & 16384) <> 0 OR
                bank.`quantity` = 0 OR
                bank.`quantity` > item.`stackSize` OR
                (bank.`extra` IS NOT NULL AND OCTET_LENGTH(bank.`extra`) <> 24) OR
                bank.`revision` = 0
            """)

        cur.execute(
            "UPDATE `linkshell_moglocker` "
            "SET `extra` = UNHEX(REPEAT('00', 24)) WHERE `extra` IS NULL"
        )
        cur.execute(
            "ALTER TABLE `linkshell_moglocker` "
            "MODIFY COLUMN `extra` BLOB(24) NOT NULL"
        )

        cur.execute(
            "SHOW INDEX FROM `linkshell_moglocker` "
            "WHERE Key_name = 'idx_linkshell_bank_item'"
        )
        if cur.fetchone() is None:
            cur.execute(
                "ALTER TABLE `linkshell_moglocker` "
                "ADD KEY `idx_linkshell_bank_item` (`linkshell_id`, `itemId`)"
            )

        constraints = {
            "fk_linkshell_bank_linkshell": (
                "ALTER TABLE `linkshell_moglocker` "
                "ADD CONSTRAINT `fk_linkshell_bank_linkshell` "
                "FOREIGN KEY (`linkshell_id`) REFERENCES `linkshells` (`linkshellid`) "
                "ON UPDATE CASCADE ON DELETE RESTRICT"
            ),
            "chk_linkshell_bank_container": (
                "ALTER TABLE `linkshell_moglocker` "
                "ADD CONSTRAINT `chk_linkshell_bank_container` "
                "CHECK (`container_id` IN (1, 4, 9))"
            ),
            "chk_linkshell_bank_slot": (
                "ALTER TABLE `linkshell_moglocker` "
                "ADD CONSTRAINT `chk_linkshell_bank_slot` "
                "CHECK (`slot` BETWEEN 1 AND 80)"
            ),
            "chk_linkshell_bank_quantity": (
                "ALTER TABLE `linkshell_moglocker` "
                "ADD CONSTRAINT `chk_linkshell_bank_quantity` "
                "CHECK (`quantity` > 0)"
            ),
            "chk_linkshell_bank_extra": (
                "ALTER TABLE `linkshell_moglocker` "
                "ADD CONSTRAINT `chk_linkshell_bank_extra` "
                "CHECK (OCTET_LENGTH(`extra`) = 24)"
            ),
            "chk_linkshell_bank_revision": (
                "ALTER TABLE `linkshell_moglocker` "
                "ADD CONSTRAINT `chk_linkshell_bank_revision` "
                "CHECK (`revision` > 0)"
            ),
        }
        for name, statement in constraints.items():
            if not _constraint_exists(cur, name):
                cur.execute(statement)

        db.commit()
    except mariadb.Error as err:
        db.rollback()
        print(f"Something went wrong: {err}")
        raise
