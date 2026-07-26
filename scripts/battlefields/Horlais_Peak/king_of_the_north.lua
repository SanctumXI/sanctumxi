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
    requiredItems    = { xi.item.THEMIS_ORB, wearMessage = horlaisID.text.A_CRACK_HAS_FORMED, wornMessage = horlaisID.text.ORB_IS_CRACKED },
})

content:addEssentialMobs({ 'Bloodcrown_Brradhod', 'Brradhods_Fletcher', 'Brradhods_Donzel' })

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
