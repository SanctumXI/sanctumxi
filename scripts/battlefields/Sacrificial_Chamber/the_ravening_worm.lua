-----------------------------------
-- The Ravening Worm
-- Sacrificial Chamber KSNM99, Themis Orb
-- !additem 1553
-----------------------------------
local sacrificialChamberID = zones[xi.zone.SACRIFICIAL_CHAMBER]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.SACRIFICIAL_CHAMBER,
    battlefieldId    = xi.battlefield.id.THE_RAVENING_WORM,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(15),
    index            = 7,
    entryNpc         = '_4j0',
    exitNpcs         = { '_4j2', '_4j3', '_4j4' },
    requiredItems    = { xi.item.THEMIS_ORB },
    armouryCrates    =
    {
        sacrificialChamberID.mob.QULL_THE_FALLSTOPPER + 4,
        sacrificialChamberID.mob.QULL_THE_FALLSTOPPER + 10,
        sacrificialChamberID.mob.QULL_THE_FALLSTOPPER + 16,
    },
})

content:addEssentialMobs({ 'Rancorwurm' })

content.loot = xi.battlefield.addKSNM99LootGroups({
    {
        { itemId = xi.item.GIL, weight = 10000, amount = 32000 },
    },
})

return content:register()
