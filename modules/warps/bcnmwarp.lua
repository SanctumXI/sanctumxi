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
    name = "Strange Bastard",
    zone = "Port_Jeuno",
    pos  = { -58.592, 0.000, 10.301, 42 }, -- !pos -58.592 0.000 10.301 246
    look = LQS.look({
        race = xi.race.ELVAAN_M,
        face = LQS.face.A2,
        body = 16,
        legs = 9,
        feet = 4,
    }),

    -- Greeting shown when NPC is triggered
    greeting = "Time to burn some orbs?",

    -- Menu customization
    menuTitle    = "Which battlefield would you like to warp to?",
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
            name  = "Balga's Dais",
            pos   = { 299.935, -124.083, 368.510, 62, 146 }, -- !pos 299.935 -124.083 368.510 146
            costs = { gil = 2000},
            level = 10,
        },

        {
            name     = "Horlais Peak",
            pos = { -522.801, 159.800, -209.811, 1, 139 }, -- !pos -522.801 159.800 -209.811 139 
            costs    = { gil = 2000},
            level    = 10,
        },

        {
            name  = "Waughroon Shrine",
            pos   = { -361.434, 104.245, -259.996, 0, 144 }, -- !pos -361.434 104.245 -259.996 144
            costs = { gil = 2000}, 
            level = 10,
        },

        {
            name  = "Qu'Bia Arena",
            pos   = { -241.046, -24.250, 19.991, 0, 206 }, -- !pos -241.046 -24.250 19.991 206
            costs = { gil = 2000},
            level = 10,
        },

        {
            name  = "Chamber of Oracles",
            pos   = { -219.976, -0.700, -10.945, 191, 168 }, -- !pos -219.976 -0.700 -10.945 168
            costs = { gil = 2000},
            level = 10,
        },

        {
            name  = "Sacrificial Chamber",
            pos   = { 314.816, -0.068, 339.668, 129, 163 }, -- !pos 314.816 -0.068 339.668 163
            costs = { gil = 2000},
            level = 10,
        },
    },

    -- Messages
    noDestinations  = "You haven't met the requirements for any destinations yet.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})
