DELETE FROM `npc_list`
WHERE `npcid` = 17776912 AND `name` = 'Outpost_Liaison';

INSERT INTO `npc_list`
(
    `npcid`, `name`, `polutils_name`, `pos_rot`, `pos_x`, `pos_y`, `pos_z`,
    `flag`, `speed`, `speedsub`, `animation`, `animationsub`, `namevis`,
    `status`, `entityFlags`, `look`, `name_prefix`, `content_tag`, `widescan`
)
VALUES
(
    17781073, 'Outpost_Liaison', 'Outpost Liaison', 8, -60.104, 6.000, -75.708,
    0, 40, 40, 0, 1, 0,
    0, 27, 0x0000870500000000000000000000000000000000, 32, NULL, 1
)
ON DUPLICATE KEY UPDATE
    `name`           = VALUES(`name`),
    `polutils_name`  = VALUES(`polutils_name`),
    `pos_rot`        = VALUES(`pos_rot`),
    `pos_x`          = VALUES(`pos_x`),
    `pos_y`          = VALUES(`pos_y`),
    `pos_z`          = VALUES(`pos_z`),
    `flag`           = VALUES(`flag`),
    `speed`          = VALUES(`speed`),
    `speedsub`       = VALUES(`speedsub`),
    `animation`      = VALUES(`animation`),
    `animationsub`   = VALUES(`animationsub`),
    `namevis`        = VALUES(`namevis`),
    `status`         = VALUES(`status`),
    `entityFlags`    = VALUES(`entityFlags`),
    `look`           = VALUES(`look`),
    `name_prefix`    = VALUES(`name_prefix`),
    `content_tag`    = VALUES(`content_tag`),
    `widescan`       = VALUES(`widescan`);
