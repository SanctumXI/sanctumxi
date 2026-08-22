INSERT INTO `traits`
    (`traitid`, `name`, `job`, `level`, `rank`, `modifier`, `value`, `content_tag`, `meritid`)
VALUES
    (140, 'predator', 9, 20, 1, 0, 0, NULL, 0)
ON DUPLICATE KEY UPDATE
    `name`        = VALUES(`name`),
    `value`       = VALUES(`value`),
    `content_tag` = VALUES(`content_tag`),
    `meritid`     = VALUES(`meritid`);
