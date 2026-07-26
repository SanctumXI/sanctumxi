-----------------------------------
-- Ride the Lightning
-- Qu'Bia Arena KSNM99, Themis Orb
-- !additem 1553
-----------------------------------
local qubiaID = zones[xi.zone.QUBIA_ARENA]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.QUBIA_ARENA,
    battlefieldId    = xi.battlefield.id.RIDE_THE_LIGHTNING,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(30),
    index            = 22,
    menuName         = 'Ride the Lightning',
    entryName        = 'Ride the Lightning',
    entryNpc         = 'BC_Entrance',
    exitNpc          = 'Burning_Circle',
    requiredItems    = { xi.item.THEMIS_ORB, wearMessage = qubiaID.text.A_CRACK_HAS_FORMED, wornMessage = qubiaID.text.ORB_IS_CRACKED },
    armouryCrates    =
    {
        qubiaID.mob.GHUL_I_BEABAN + 2,
        qubiaID.mob.GHUL_I_BEABAN + 5,
        qubiaID.mob.GHUL_I_BEABAN + 8,
    },
})

content:addEssentialMobs({ 'Ixion' })

content.loot = xi.battlefield.addKSNM99LootGroups({
    {
        { itemId = xi.item.GIL, weight = 10000, amount = 32000 },
    },

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
})

return content:register()
