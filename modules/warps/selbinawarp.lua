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
    name = "Stinky Bastard",
    zone = "Selbina",
    pos  = { 14.543, -14.559, 59.413, 220, 248 }, -- !pos 14.543 -14.559 59.413 248
    look = LQS.look({
        race = xi.race.HUME_M,
        face = LQS.face.A3,
        body = 8,
        legs = 14,
        feet = 10,
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
            name  = "Lower Jeuno",
            pos   = { -35.059, 0.000, -48.293, 214, 245 }, -- !pos -35.059 0.000 -48.293 245
            costs = { gil = 1000 },
            level = 20,
              check = function(player)
                return player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.CHOCOBOS_WOUNDS)
            end,
        },

        {
            name     = "Northern San d'Oria",
            pos = { 111.108, -0.199, -8.846, 222, 231 }, -- !pos 111.108 -0.199 -8.846 231
            costs    = { gil = 500 },
            level    = 10,
        },

        {
            name  = "Bastok Mines",
            pos   = { 89.570, 0.623, -71.851, 127, 234}, -- !pos 89.570 0.623 -71.851 234,
            costs = { gil = 500 },
            level = 10,
        },
        {
            name  = "Port Windurst",
            pos   = { 197.209, -12.000, 222.625, 65, 240 }, -- !pos 197.209 -12.000 222.625 240,
            costs = { gil = 500}, 
            level = 10,
        },

        {
            name     = "Mhaura",
            pos = { 0.003, -4.000, 117.971, 65, 249 }, -- !pos 0.003 -4.000 117.971 249
            costs    = { gil = 500 },
            level    = 10,
        },

        {
            name  = "Rabao",
            pos   = { -0.622, 0.000, -75.861, 191, 247}, -- !pos -0.622 0.000 -75.861 247,
            costs = { gil = 750},
            level = 30,
        },

              {
            name  = "Norg",
            pos   = { -19.724, 0.172, -55.122, 191, 252 }, -- !pos -19.724 0.172 -55.122 252,
            costs = { gil = 750 },
            level = 30,
        },
         {
            name  = "Khazam",
            pos   = { -28.059, -4.000, -32.657, 62, 250 }, -- !pos -28.059 -4.000 -32.657 250
            costs = { gil = 750 },
            level = 30,
        },
         {
            name  = "Nashmau",
            pos   = { 0.117, 0.000, -31.918, 190, 53 }, -- !pos 0.117 0.000 -31.918 53
            costs = { gil = 750 },
            level = 50,
        },
    },

    -- Messages
    noDestinations  = "You haven't met the requirements for any destinations yet.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})
