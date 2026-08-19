-- Restore the Whitegate slot that previously hosted the Linkshell Concierge.
INSERT INTO `npc_list`
(
    `npcid`, `name`, `polutils_name`, `pos_rot`, `pos_x`, `pos_y`, `pos_z`,
    `flag`, `speed`, `speedsub`, `animation`, `animationsub`, `namevis`,
    `status`, `entityFlags`, `look`, `name_prefix`, `content_tag`, `widescan`
)
VALUES
(
    16982537, 'blank', '', 0, 0.000, 0.000, 0.000,
    0, 40, 40, 0, 0, 0,
    2, 27, 0x0000CD0700000000000000000000000000000000, 32, 'TOAU', 1
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

INSERT INTO `npc_list`
(
    `npcid`, `name`, `polutils_name`, `pos_rot`, `pos_x`, `pos_y`, `pos_z`,
    `flag`, `speed`, `speedsub`, `animation`, `animationsub`, `namevis`,
    `status`, `entityFlags`, `look`, `name_prefix`, `content_tag`, `widescan`
)
VALUES
(
    17781074, 'Linkshell_Concierge', 'Linkshell Concierge', 189, 24.731, -0.100, -13.316,
    21, 40, 40, 0, 1, 0,
    0, 27, 0x01000F017710862000305E405E50006000700000, 32, NULL, 1
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
