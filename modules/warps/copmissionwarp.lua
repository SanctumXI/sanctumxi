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
    name = "Short Bastard",
    zone = "Tavnazian_Safehold",
    pos  = { -15.136, -9.991, 2.836, 6 }, -- !pos -15.136 -9.991 2.836 26
    look = LQS.look({
        race = xi.race.TARU_M,
        face = LQS.face.A3,
        body = 26,
        legs = 5,
        feet = 18,
    }),

    -- Greeting shown when NPC is triggered
    greeting = "These shortcuts should help. Check back often for more help.",

    -- Menu customization
    menuTitle    = "Choose Your Destination",
    itemsPerPage = 5,

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
            name  = "Monarch Linn A01",
            pos   = { -507.800, -8.500, -387.011, 217, 30 }, -- !pos -507.800 -8.500 -387.011 30
            costs = { gil = 2000 },
             check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.AN_ETERNAL_MELODY)
            end,
        },

        {
            name     = "Monarch Linn B01",
            pos = { -534.188, -20.500, 503.554, 94, 29 }, -- !pos -534.188 -20.500 503.554 29
            costs    = { gil = 2000 },
            check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.AN_ETERNAL_MELODY)
            end,
        },

        {
            name  = "Mine Shaft [#2716]",
            pos   = { -68.192, -120.000, -580.105, 255, 13 }, -- !pos -68.192 -120.000 -580.105 13
            costs = { gil = 2000}, 
            check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.DESIRES_OF_EMPTINESS)
            end,
        },

        {
            name  = "Purgonorgo Isle",
            pos   = { -398.710, -3.038, -418.172, 65, 4 }, -- !pos -398.710 -3.038 -418.172 4
            costs = { gil = 2000 },
            check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.DESIRES_OF_EMPTINESS)
            end,
        },

        {
            name  = "Cid's Lab",
            pos   = { -21.936, -10.000, -1.623, 254, 237 }, -- !pos -21.936 -10.000 -1.623 237
            costs = { gil = 2000},
            level = 1,
        },

    },

    -- Messages
    noDestinations  = "You must progress further in Chains of Promathia to use my services.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})
