-----------------------------------
-- Three's a Crowd
-- Sacrificial Chamber KSNM99, Themis Orb
-- !additem 1553
-----------------------------------
local sacrificialChamberID = zones[xi.zone.SACRIFICIAL_CHAMBER]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.SACRIFICIAL_CHAMBER,
    battlefieldId    = xi.battlefield.id.THREES_A_CROWD,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(30),
    index            = 5,
    menuName         = 'Three\'s a Crowd',
    entryName        = 'Three\'s a Crowd',
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
