-----------------------------------
-- King of The North
-- Horlais Peak KSNM99, Themis Orb
-- Inspired by The Blood-bathed Crown
-- !additem 1553
-----------------------------------
local horlaisID = zones[xi.zone.HORLAIS_PEAK]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.HORLAIS_PEAK,
    battlefieldId    = xi.battlefield.id.KING_OF_THE_NORTH,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(30),
    index            = 21,
    menuName         = 'King of The North',
    entryName        = 'King of The North',
    entryNpc         = 'BC_Entrance',
    exitNpc          = 'Burning_Circle',
    requiredItems    = { xi.item.THEMIS_ORB },
    armouryCrates    =
    {
        horlaisID.mob.ARMSMASTER_DEKBUK + 6,
        horlaisID.mob.ARMSMASTER_DEKBUK + 13,
        horlaisID.mob.ARMSMASTER_DEKBUK + 20,
    },
})

content.groups =
{
    {
        mobIds =
        {
            {
                horlaisID.mob.FROSTSCAR_HROZDAG,
                horlaisID.mob.SIEGE_SNIPER,
                horlaisID.mob.SIEGE_SNIPER + 1,
                horlaisID.mob.BLACKGUARD,
                horlaisID.mob.BLACKGUARD + 1,
            },

            {
                horlaisID.mob.FROSTSCAR_HROZDAG + 1,
                horlaisID.mob.SIEGE_SNIPER + 2,
                horlaisID.mob.SIEGE_SNIPER + 3,
                horlaisID.mob.BLACKGUARD + 2,
                horlaisID.mob.BLACKGUARD + 3,
            },

            {
                horlaisID.mob.FROSTSCAR_HROZDAG + 2,
                horlaisID.mob.SIEGE_SNIPER + 4,
                horlaisID.mob.SIEGE_SNIPER + 5,
                horlaisID.mob.BLACKGUARD + 4,
                horlaisID.mob.BLACKGUARD + 5,
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
        { itemId = xi.item.SUPREMACY_EARRING, weight = 4000 },
        { itemId = xi.item.GNADBHODS_HELM,     weight = 4000 },
        { itemId = xi.item.NONE,               weight = 2000 },
    },

    {
        { itemId = xi.item.NIMUES_TIGHTS, weight = 3000 },
        { itemId = xi.item.RULER,         weight = 3000 },
        { itemId = xi.item.FENIAN_RING,    weight = 3000 },
        { itemId = xi.item.NONE,           weight = 1000 },
    },
})

return content:register()
