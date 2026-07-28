-----------------------------------
-- Three's a Crowd
-- Chamber of Oracles KSNM99, Themis Orb
-- !additem 1553
-----------------------------------
local chamberOfOraclesID = zones[xi.zone.CHAMBER_OF_ORACLES]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.CHAMBER_OF_ORACLES,
    battlefieldId    = xi.battlefield.id.THREES_A_CROWD,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(30),
    index            = 11,
    entryNpc         = 'SC_Entrance',
    exitNpc          = 'Shimmering_Circle',
    requiredItems    = { xi.item.THEMIS_ORB },
    armouryCrates    =
    {
        chamberOfOraclesID.mob.PURSON + 1,
        chamberOfOraclesID.mob.PURSON + 3,
        chamberOfOraclesID.mob.PURSON + 5,
    },
})

content:addEssentialMobs({ 'Typhon' })

content.loot = xi.battlefield.addKSNM99LootGroups({
    {
        { itemId = xi.item.GIL, weight = 10000, amount = 32000 },
    },

    {
        { itemId = xi.item.HYDRA_SCALE,         weight = 3500 },
        { itemId = xi.item.HYDRA_FANG,          weight = 3500 },
        { itemId = xi.item.CHUNK_OF_HYDRA_MEAT, weight = 3000 },
    },

    {
        { itemId = xi.item.BERSERKERS_TORQUE, weight = 2400 },
        { itemId = xi.item.NONE,              weight = 7600 },
    },

    {
        { itemId = xi.item.SIRIUS_AXE, weight = 2400 },
        { itemId = xi.item.NONE,       weight = 7600 },
    },
})

return content:register()
