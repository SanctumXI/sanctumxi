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
    name = "Stupid Bastard",
    zone = "Mhaura",
    pos  = { 5.756, -4.119, 84.868, 152 }, -- !pos 5.756 -4.119 84.868 249
    look = LQS.look({
        race = xi.race.HUME_M,
        face = LQS.face.A5,
        body = 4,
        legs = 12,
        feet = 11,
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
            name     = "Selbina",
            lockText = "Sub Job required",
            pos      = { 17.981, -14.559, 99.830, 64, 248 },
            costs    = { gil = 500 },
            level    = 10,
            check = function(player)
                return
                    player:hasCompletedQuest(
                        xi.questLog.OTHER_AREAS,
                        xi.quest.id.otherAreas.THE_OLD_LADY
                    ) or
                    player:hasCompletedQuest(
                        xi.questLog.OTHER_AREAS,
                        xi.quest.id.otherAreas.ELDER_MEMORIES
                    )
            end,
        },


    },

    -- Messages
    noDestinations  = "You haven't met the requirements for any destinations yet.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})
