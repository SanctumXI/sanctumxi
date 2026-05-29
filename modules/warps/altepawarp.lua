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
    name = "Sandy Bastard",
    zone = "Western_Altepa_Desert",
    pos  = { -29.146, 12.199, 132.642, 30 }, -- !pos -29.146 12.199 132.642 125
    look = LQS.look({
        race = xi.race.TARU_M,
        face = LQS.face.A2,
        body = 21,
        legs = 19,
        feet = 10,
    }),

    -- Greeting shown when NPC is triggered
    greeting = "This gate is a real bastard but I found a sneaky way in. For 5000 gil I'll send you through.",

    -- Menu customization
    menuTitle    = "Be a sneaky bastard?",
    itemsPerPage = 1,

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
            name  = "Absolutely!",
            pos   = { -20.035, 12.199, 139.569, 192, 125 }, -- !pos -20.035 12.199 139.569 125
            costs = { gil = 5000},
            level = 1,
        },

    },

    -- Messages
    noDestinations  = "You really don't have access?",
    insufficientGil = "What do you think I'm running? A Charity?",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "You must be one of those purists. Begone!",
})
