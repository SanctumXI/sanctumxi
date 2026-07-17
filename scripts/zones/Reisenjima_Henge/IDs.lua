-----------------------------------
-- Area: Reisenjima_Henge
-----------------------------------
zones = zones or {}

zones[xi.zone.REISENJIMA_HENGE] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        ITEMS_OBTAINED                = 6400, -- You obtain <number> <item>!
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
    },
    mob =
    {
        HARD_MODE_ROC         = 17973581,
        HARD_MODE_SIMURGH     = 17973582,
        HARD_MODE_KING_ARTHRO = 17973583,
        HARD_MODE_KNIGHT_CRABS =
        {
            17973585,
            17973586,
            17973587,
            17973588,
            17973589,
            17973590,
        },
    },
    npc =
    {
        HARD_MODE_HNM_QM = 17973584,
    },
}

return zones[xi.zone.REISENJIMA_HENGE]
