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
    name = "Portaru-Ruru",
    zone = "Lower_Jeuno",
    pos  = { -39.147, -1.000, -15.505, 17 }, -- !pos -39.147 -1.000 -15.505 245
    look = LQS.look({
        race = xi.race.TARU_M,
        face = LQS.face.A5,
        body = 17,
        legs = 22,
        feet = 18,
    }),

    -- Greeting shown when NPC is triggered
    greeting = "Tell me where you want to go",

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
            name     = "Whitegate",
            lockText = "Complete 'Land of Sacred Serpents'",
            pos      = { -91.938, 0.000, -72.111, 254, 50 }, -- !pos -91.938 0.000 -72.111 50
            costs    = { gil = 2000 },
            level    = 20,
            check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.TOAU, xi.mission.id.toau.LAND_OF_SACRED_SERPENTS)
            end,
        },

        {
            name     = "Tavnazian Safehold",
            lockText = "Complete 'The Mothercrystals'",
            pos      = { 0.015, -21.876, 2.125, 67, 26 }, -- !pos 0.015 -21.876 2.125 26
            costs    = { gil = 1500 },
            check = function(player)
                return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.THE_MOTHERCRYSTALS)
            end,
        },

        {
            name     = "Rabao",
            lockText = "Fame 4 Required",
            pos      = { -0.622, 0.000, -75.861, 191, 247 }, -- !pos -0.622 0.000 -75.861 247,
            costs    = { gil = 1000 },
            level    = 30,
            check = function(player)
                return player:getFameLevel(xi.fameArea.SELBINA_RABAO) >= 4
            end,
        },

        {
            name     = "Norg",
            lockText = "Fame 4 Required",
            pos      = { -19.724, 0.172, -55.122, 191, 252 }, -- !pos -19.724 0.172 -55.122 252,
            costs    = { gil = 1000 },
            level    = 30,
            check = function(player)
                return player:getFameLevel(xi.fameArea.NORG) >= 4
            end,
        },

        {
            name     = "Khazam",
            lockText = "Kazham Airship Pass Required",
            pos      = { -28.059, -4.000, -32.657, 62, 250 }, -- !pos -28.059 -4.000 -32.657 250
            costs    = { gil = 1000 },
            level    = 30,
            check = function(player)
                return player:hasKeyItem(xi.ki.AIRSHIP_PASS_FOR_KAZHAM)
            end,
        },
    },

    -- Messages
    noDestinations  = "You haven't met the requirements for any destinations yet.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})
