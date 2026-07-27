-----------------------------------
-- Heavy Is the Shell
-- Waughroon Shrine KSNM99, Themis Orb
-- Inspired by The Buried God
-- !additem 1553
-----------------------------------
local waughroonID = zones[xi.zone.WAUGHROON_SHRINE]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.WAUGHROON_SHRINE,
    battlefieldId    = xi.battlefield.id.HEAVY_IS_THE_SHELL,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(30),
    index            = 22,
    menuName         = 'Heavy Is the Shell',
    entryName        = 'Heavy Is the Shell',
    entryNpc         = 'BC_Entrance',
    exitNpc          = 'Burning_Circle',
    requiredItems    = { xi.item.THEMIS_ORB },
    armouryCrates    =
    {
        waughroonID.mob.YOBHU_HIDEOUSMASK + 6,
        waughroonID.mob.YOBHU_HIDEOUSMASK + 13,
        waughroonID.mob.YOBHU_HIDEOUSMASK + 20,
    },
})

content.groups =
{
    {
        mobIds =
        {
            {
                waughroonID.mob.ROHYU_BLACKANVIL,
                waughroonID.mob.QUADAV_EARTHSHAPER,
                waughroonID.mob.QUADAV_EARTHSHAPER + 1,
                waughroonID.mob.QUADAV_LITURGIST,
                waughroonID.mob.QUADAV_LITURGIST + 1,
            },

            {
                waughroonID.mob.ROHYU_BLACKANVIL + 1,
                waughroonID.mob.QUADAV_EARTHSHAPER + 2,
                waughroonID.mob.QUADAV_EARTHSHAPER + 3,
                waughroonID.mob.QUADAV_LITURGIST + 2,
                waughroonID.mob.QUADAV_LITURGIST + 3,
            },

            {
                waughroonID.mob.ROHYU_BLACKANVIL + 2,
                waughroonID.mob.QUADAV_EARTHSHAPER + 4,
                waughroonID.mob.QUADAV_EARTHSHAPER + 5,
                waughroonID.mob.QUADAV_LITURGIST + 4,
                waughroonID.mob.QUADAV_LITURGIST + 5,
            },
        },

        superlink = true,
        isParty   = true,
        allDeath  = utils.bind(content.handleAllMonstersDefeated, content),
    },
}

content.loot = xi.battlefield.addKSNM99LootGroups({
    {
        { itemId = xi.item.GIL, weight = 10000, amount = 32000 },
    },

    {
        { itemId = xi.item.PARAMOUNT_EARRING, weight = 4000 },
        { itemId = xi.item.ZHAGOS_BARBUT,     weight = 4000 },
        { itemId = xi.item.NONE,              weight = 2000 },
    },

    {
        { itemId = xi.item.HEADSMANS_RING,  weight = 3000 },
        { itemId = xi.item.SEISMIC_AXE,     weight = 3000 },
        { itemId = xi.item.STONE_MUFFLERS,  weight = 3000 },
        { itemId = xi.item.NONE,            weight = 1000 },
    },
})

return content:register()
