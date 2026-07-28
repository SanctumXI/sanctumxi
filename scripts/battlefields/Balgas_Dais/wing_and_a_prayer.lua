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
    index            = 28,
    menuName         = 'Wing and a Prayer',
    entryName        = 'Wing and a Prayer',
    entryNpc         = 'BC_Entrance',
    exitNpc          = 'Burning_Circle',
    requiredItems    = { xi.item.THEMIS_ORB },
    armouryCrates    =
    {
        balgasID.mob.VOO_TOLU_THE_GHOSTFIST + 6,
        balgasID.mob.VOO_TOLU_THE_GHOSTFIST + 13,
        balgasID.mob.VOO_TOLU_THE_GHOSTFIST + 20,
    },
})

content.groups =
{
    {
        mobIds =
        {
            {
                balgasID.mob.TZEE_XICUS_HIEROPHANT,
                balgasID.mob.DIVINE_REPROACH,
                balgasID.mob.DIVINE_REPROACH + 1,
                balgasID.mob.DIVINE_REPROACH + 2,
                balgasID.mob.DIVINE_REPROACH + 3,
            },

            {
                balgasID.mob.TZEE_XICUS_HIEROPHANT + 1,
                balgasID.mob.DIVINE_REPROACH + 4,
                balgasID.mob.DIVINE_REPROACH + 5,
                balgasID.mob.DIVINE_REPROACH + 6,
                balgasID.mob.DIVINE_REPROACH + 7,
            },

            {
                balgasID.mob.TZEE_XICUS_HIEROPHANT + 2,
                balgasID.mob.DIVINE_REPROACH + 8,
                balgasID.mob.DIVINE_REPROACH + 9,
                balgasID.mob.DIVINE_REPROACH + 10,
                balgasID.mob.DIVINE_REPROACH + 11,
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
