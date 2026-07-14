CREATE TABLE IF NOT EXISTS linkshell_treasury
(
    linkshell_id INT UNSIGNED NOT NULL,
    item_id      SMALLINT UNSIGNED NOT NULL,
    quantity     INT UNSIGNED NOT NULL DEFAULT 0,

    PRIMARY KEY (linkshell_id, item_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4;