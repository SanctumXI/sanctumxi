-----------------------------------
-- The Ravening Worm
-- Chamber of Oracles KSNM99, Themis Orb
-- !additem 1553
-----------------------------------
local chamberOfOraclesID = zones[xi.zone.CHAMBER_OF_ORACLES]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.CHAMBER_OF_ORACLES,
    battlefieldId    = xi.battlefield.id.THE_RAVENING_WORM,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(30),
    index            = 10,
    menuName         = 'The Ravening Worm',
    entryName        = 'The Ravening Worm',
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

content:addEssentialMobs({ 'Zepwell_Worm' })

content.loot = xi.battlefield.addKSNM99LootGroups({
    {
        { itemId = xi.item.GIL, weight = 10000, amount = 32000 },
    },
})

return content:register()
