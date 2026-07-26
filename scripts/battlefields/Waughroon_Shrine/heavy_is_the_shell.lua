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
    requiredItems    = { xi.item.THEMIS_ORB, wearMessage = waughroonID.text.A_CRACK_HAS_FORMED, wornMessage = waughroonID.text.ORB_IS_CRACKED },
})

content:addEssentialMobs({ 'ZaDha_Adamantking', 'ZaDhas_Biographer', 'ZaDhas_Minister' })

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
