-----------------------------------
-- Wing and a Prayer
-- Balga's Dais KSNM99, Themis Orb
-- Inspired by A Malicious Manifest
-- !additem 1553
-----------------------------------
local balgasID = zones[xi.zone.BALGAS_DAIS]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.BALGAS_DAIS,
    battlefieldId    = xi.battlefield.id.WING_AND_A_PRAYER,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(30),
    index            = 22,
    menuName         = 'Wing and a Prayer',
    entryName        = 'Wing and a Prayer',
    entryNpc         = 'BC_Entrance',
    exitNpc          = 'Burning_Circle',
    requiredItems    = { xi.item.THEMIS_ORB, wearMessage = balgasID.text.A_CRACK_HAS_FORMED, wornMessage = balgasID.text.ORB_IS_CRACKED },
})

content:addEssentialMobs({ 'Tzee_Xicu_the_Manifest', 'Tzee_Xicus_Elemental' })

content.loot = xi.battlefield.addKSNM99LootGroups({
    {
        { itemId = xi.item.GIL, weight = 10000, amount = 32000 },
    },

    {
        { itemId = xi.item.BRILLIANT_EARRING,     weight = 4000 },
        { itemId = xi.item.REE_HABALOS_HEADGEAR,  weight = 4000 },
        { itemId = xi.item.NONE,                  weight = 2000 },
    },

    {
        { itemId = xi.item.DIVERTERS_RING,   weight = 3000 },
        { itemId = xi.item.KOSCHEI_CRACKOWS, weight = 3000 },
        { itemId = xi.item.PRESTER,           weight = 3000 },
        { itemId = xi.item.NONE,              weight = 1000 },
    },
})

return content:register()
