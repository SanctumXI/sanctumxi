-- Reuse Valkurm Dunes' dormant qm entity as The Unfinished Waltz ???.
UPDATE `npc_list`
SET
    `name` = 'DNC_AF1_QM',
    `polutils_name` = '???',
    `pos_rot` = 127,
    `pos_x` = -720.000,
    `pos_y` = -8.000,
    `pos_z` = 170.000,
    `flag` = 1,
    `status` = 0,
    `entityFlags` = 3,
    `widescan` = 0
WHERE `npcid` = 17199777;

-- Migratory Hippogryph: quest-only level 45 spawn at Valkurm's secret beach.
INSERT INTO `mob_groups`
    (`groupid`, `poolid`, `zoneid`, `name`, `respawntime`, `spawntype`, `dropid`, `HP`, `MP`, `allegiance`, `content_tag`)
VALUES
    (74, 2654, 103, 'Migratory_Hippogryph', 0, 128, 0, 2000, 0, 0, NULL)
ON DUPLICATE KEY UPDATE
    `poolid` = VALUES(`poolid`),
    `name` = VALUES(`name`),
    `respawntime` = VALUES(`respawntime`),
    `spawntype` = VALUES(`spawntype`),
    `dropid` = VALUES(`dropid`),
    `HP` = VALUES(`HP`),
    `MP` = VALUES(`MP`),
    `allegiance` = VALUES(`allegiance`),
    `content_tag` = VALUES(`content_tag`);

INSERT INTO `mob_spawn_points`
    (`mobid`, `spawnslotid`, `mobname`, `polutils_name`, `groupid`, `minLevel`, `maxLevel`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`)
VALUES
    (17199662, 0, 'Migratory_Hippogryph', 'Migratory Hippogryph', 74, 45, 45, -696.000, -8.000, 172.000, 78)
ON DUPLICATE KEY UPDATE
    `mobname` = VALUES(`mobname`),
    `polutils_name` = VALUES(`polutils_name`),
    `groupid` = VALUES(`groupid`),
    `minLevel` = VALUES(`minLevel`),
    `maxLevel` = VALUES(`maxLevel`),
    `pos_x` = VALUES(`pos_x`),
    `pos_y` = VALUES(`pos_y`),
    `pos_z` = VALUES(`pos_z`),
    `pos_rot` = VALUES(`pos_rot`);
