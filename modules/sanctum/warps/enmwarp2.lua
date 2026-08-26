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
    name = "ENM Expert",
    zone = "Aht_Urhgan_Whitegate",
    pos  = { -69.590, 0.000, -102.286, 157 }, -- !pos -69.590 0.000 -102.286 50
    look = LQS.look({
        race = xi.race.GALKA,
        face = LQS.face.A3,
        body = 11,
        legs = 12,
        feet = 13,
    }),

    -- Greeting shown when NPC is triggered
    greeting = "I know all the secrets to help with ENMs",

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
            name  = "Jakaka - Mountain Climb",
            lockText = "Complete The Road Forks",
            pos   = { 398.413, 20.747, -24.520, 126, 7 }, -- !pos 398.413 20.747 -24.520 7
            costs = { gil = 1500 },
             check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.THE_ROAD_FORKS)
            end,
        },

    },

    -- Messages
    noDestinations  = "You haven't met the requirements for any destinations yet.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",

})

