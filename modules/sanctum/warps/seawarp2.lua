-----------------------------------
-- LQS Example: Custom Teleporter
-----------------------------------
-- This example demonstrates the LQS.teleporter() function
-- for creating custom teleporter NPCs with full control over:
-- - Custom destinations with coordinates or teleport IDs
-- - Custom costs (gil, cp, or free)
-- - Custom requirements (level, key items, etc.)
-- - Pre-teleport effects (buffs, reraise, etc.)
-----------------------------------

return LQS.teleporter({
    name = "Slimy Bastard",
    zone = "Aht_Urhgan_Whitegate",
    pos  = { -90.465, 0.000, -90.309, 217 }, -- !pos -90.465 0.000 -90.309 50
    look = LQS.look({
        race = xi.race.GALKA,
        face = LQS.face.A3,
        body = 17,
        legs = 9,
        feet = 4,
    }),

    -- Greeting shown when NPC is triggered
    greeting = "So you want to travel the seas?",

    -- Menu customization
    menuTitle    = "Choose Your Destination",
    itemsPerPage = 4,

    -- Teleport settings
    teleportDelay = 1500,

    -- Pre-teleport effects (optional)
    -- Can use LQS.signetEffect() for standard Signet, or custom effects:
    -- preTeleportEffects = {
    --     LQS.signetEffect(), -- Standard Signet with rank-based duration
    --    {
    --        effect   = xi.effect.RERAISE,
    --        power    = 1,
    --         duration = 7200, -- 2 hours
    --     },
    -- },

    -- Teleport animation (optional)
    animation = { actionID = 6, animID = 600 },

    -- Custom destinations
    destinations = {
        -- Using direct coordinates (cross-zone)
        {
            name      = "Al'Taieu - South",
            lockText = "Sea Access Required",
            pos   = { 0.032, -0.038, -546.619, 191, 33 }, -- !pos 0.032 -0.038 -546.619 33
            costs = { gil = 2000 },
            check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.GARDEN_OF_ANTIQUITY)
            end,
        },

        {
            name      = "Al'Taieu - West",
            lockText = "Sea Access Required",
            pos = { -597.191, -1.056, -316.257, 10, 33 }, -- !pos -597.191 -1.056 -316.257 33
            costs    = { gil = 2000 },
            check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.GARDEN_OF_ANTIQUITY)
            end,
        },

        {
            name      = "Al'Taieu - East",
            lockText = "Sea Access Required",
            pos   = { 566.169, -2.040, -187.122, 9, 33 }, -- !pos 566.169 -2.040 -187.122 33
            costs = { gil = 2000},
             check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.GARDEN_OF_ANTIQUITY)
            end,
        },

    },

    -- Messages
    noDestinations  = "You must unlock Sea access to use my services.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})
