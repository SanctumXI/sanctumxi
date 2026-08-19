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
    name = "Sly Bastard",
    zone = "Tavnazian_Safehold",
    pos  = { -14.631, -9.961, -0.855, 238 }, -- !pos -14.631 -9.961 -0.855 26
    look = LQS.look({
        race = xi.race.HUME_M,
        face = LQS.face.A2,
        body = 11,
        legs = 19,
        feet = 22,
    }),

    -- Greeting shown when NPC is triggered
    greeting = "Tell me where you want to go",

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
            name     = "Lower Jeuno",
            lockText = "Complete 'A Chocobo's Wounds'",
            pos      = { -35.059, 0.000, -48.293, 214, 245 }, -- !pos -35.059 0.000 -48.293 245
            costs    = { gil = 1000 },
            level    = 20,
            check = function(player)
                return player:hasCompletedQuest(
                    xi.questLog.JEUNO,
                    xi.quest.id.jeuno.CHOCOBOS_WOUNDS
                )
            end
        },

        {
            name     = "Port Windurst",
            lockText = "Rank 3 Required",
            pos      = { 197.209, -12.000, 222.625, 65, 240 }, -- !pos 197.209 -12.000 222.625 240
            costs    = { gil = 500 },
            level    = 10,
            check = function(player)
                return player:getRank(player:getNation()) >= 3
            end
        },

        {
            name     = "Bastok Mines",
            lockText = "Rank 3 Required",
            pos      = { 89.570, 0.623, -71.851, 127, 234 }, -- !pos 89.570 0.623 -71.851 234
            costs    = { gil = 500 },
            level    = 10,
            check = function(player)
                return player:getRank(player:getNation()) >= 3
            end
        },

        {
            name     = "Northern San d'Oria",
            lockText = "Rank 3 Required",
            pos      = { 111.108, -0.199, -8.846, 222, 231 }, -- !pos 111.108 -0.199 -8.846 231
            costs    = { gil = 500 },
            level    = 10,
            check = function(player)
                return player:getRank(player:getNation()) >= 3
            end
        },

    },

    -- Messages
    noDestinations  = "You haven't met the requirements for any destinations yet.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})
