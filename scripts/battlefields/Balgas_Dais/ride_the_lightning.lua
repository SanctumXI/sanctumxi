-----------------------------------
-- Ride the Lightning
-- Balga's Dais KSNM99, Themis Orb
-- !additem 1553
-----------------------------------
local balgasID = zones[xi.zone.BALGAS_DAIS]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.BALGAS_DAIS,
    battlefieldId    = xi.battlefield.id.RIDE_THE_LIGHTNING,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(30),
    index            = 22,
    menuName         = 'Ride the Lightning',
    entryName        = 'Ride the Lightning',
    entryNpc         = 'BC_Entrance',
    exitNpc          = 'Burning_Circle',
    requiredItems    = { xi.item.THEMIS_ORB, wearMessage = balgasID.text.A_CRACK_HAS_FORMED, wornMessage = balgasID.text.ORB_IS_CRACKED },
    armouryCrates    =
    {
        balgasID.mob.WYRM + 1,
        balgasID.mob.WYRM + 3,
        balgasID.mob.WYRM + 5,
    },
})

content:addEssentialMobs({ 'Ixion' })

content.loot =
{
    {
        { itemId = xi.item.DARK_IXION_HORN, weight = 10000 },
    },

    {
        { itemId = xi.item.DARK_IXION_TAIL, weight = 10000 },
    },

    {
        { itemId = xi.item.AZOTH, weight = 2400 },
        { itemId = xi.item.NONE,  weight = 7600 },
    },

    {
        { itemId = xi.item.IXION_CAPE, weight = 2400 },
        { itemId = xi.item.NONE,       weight = 7600 },
    },

    {
        { itemId = xi.item.IXION_CLOAK, weight = 2400 },
        { itemId = xi.item.NONE,        weight = 7600 },
    },
}

return content:register()
