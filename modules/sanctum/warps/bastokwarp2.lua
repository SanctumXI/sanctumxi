-----------------------------------
-- LQS Example: Custom Teleporter
-----------------------------------

return LQS.teleporter({
    name = "Dirty Bastard",
    zone = "Bastok_Mines",
    pos  = { 82.008, 0.000, -63.713, 94 }, -- !pos 82.008 0.000 -63.713 234
    look = LQS.look({
        race = xi.race.HUME_M,
        face = LQS.face.A2,
        body = 13,
        legs = 16,
        feet = 10,
    }),

    greeting = "Tell me where you want to go",

    menuTitle    = "Choose Your Destination",
    itemsPerPage = 4,

    teleportDelay = 1500,

    animation = { actionID = 6, animID = 600 },

    destinations =
    {
        {
            name     = "Lower Jeuno",
            lockText = "Complete 'A Chocobo's Wounds'",
            pos      = { -35.059, 0.000, -48.293, 214, 245 },
            costs    = { gil = 1000 },
            level    = 10,
            check = function(player)
                return player:hasCompletedQuest(
                    xi.questLog.JEUNO,
                    xi.quest.id.jeuno.CHOCOBOS_WOUNDS
                )
            end,
        },

        {
            name     = "Northern San d'Oria",
            lockText = "Rank 3 Required",
            pos      = { 111.108, -0.199, -8.846, 222, 231 },
            costs    = { gil = 500 },
            level    = 10,
            check = function(player)
                return player:getRank(player:getNation()) >= 3
            end,
        },

        {
            name     = "Port Windurst",
            lockText = "Rank 3 Required",
            pos      = { 197.209, -12.000, 222.625, 65, 240 },
            costs    = { gil = 500 },
            level    = 10,
            check = function(player)
                return player:getRank(player:getNation()) >= 3
            end,
        },

        {
            name     = "Mhaura",
            lockText = "Sub Job required",
            pos      = { 0.003, -4.000, 117.971, 65, 249 },
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

        {
            name     = "Rabao",
            lockText = "Fame 4 Required",
            pos      = { -0.622, 0.000, -75.861, 191, 247 },
            costs    = { gil = 750 },
            level    = 30,
            check = function(player)
                return player:getFameLevel(xi.fameArea.SELBINA_RABAO) >= 4
            end,
        },

        {
            name     = "Norg",
            lockText = "Fame 4 Required",
            pos      = { -19.724, 0.172, -55.122, 191, 252 },
            costs    = { gil = 750 },
            level    = 30,
            check = function(player)
                return player:getFameLevel(xi.fameArea.NORG) >= 4
            end,
        },

        {
            name     = "Kazham",
            lockText = "Kazham Airship Pass Required",
            pos      = { -28.059, -4.000, -32.657, 62, 250 },
            costs    = { gil = 750 },
            level    = 30,
            check = function(player)
                return player:hasKeyItem(xi.ki.AIRSHIP_PASS_FOR_KAZHAM)
            end,
        },
    },

    noDestinations  = "You haven't met the requirements for any destinations yet.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})
