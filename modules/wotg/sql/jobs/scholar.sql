-- Move Erlene from The Eldieme Necropolis [S] to Windurst Waters.
-- The new actor ID is beyond Windurst Waters' current retail entity-name table.
INSERT INTO `npc_list`
    (`npcid`, `name`, `polutils_name`, `pos_rot`, `pos_x`, `pos_y`, `pos_z`, `flag`, `speed`, `speedsub`,
     `animation`, `animationsub`, `namevis`, `status`, `entityFlags`, `look`, `name_prefix`, `content_tag`, `widescan`)
VALUES
    (17752608, 'Erlene', 'Erlene', 64, -57.5238, -5.5000, 104.9193, 20, 40, 40,
     0, 0, 0, 0, 25, 0x01000F02D610D620D630D640D650006000700000, 32, 'WOTG', 1)
ON DUPLICATE KEY UPDATE
    `name`          = VALUES(`name`),
    `polutils_name` = VALUES(`polutils_name`),
    `pos_rot`       = VALUES(`pos_rot`),
    `pos_x`         = VALUES(`pos_x`),
    `pos_y`         = VALUES(`pos_y`),
    `pos_z`         = VALUES(`pos_z`),
    `flag`          = VALUES(`flag`),
    `speed`         = VALUES(`speed`),
    `speedsub`      = VALUES(`speedsub`),
    `animation`     = VALUES(`animation`),
    `animationsub`  = VALUES(`animationsub`),
    `namevis`       = VALUES(`namevis`),
    `status`        = VALUES(`status`),
    `entityFlags`   = VALUES(`entityFlags`),
    `look`          = VALUES(`look`),
    `name_prefix`   = VALUES(`name_prefix`),
    `content_tag`   = VALUES(`content_tag`),
    `widescan`      = VALUES(`widescan`);

UPDATE `npc_list`
SET `status` = 2
WHERE `npcid` = 17494732;
