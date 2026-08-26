-----------------------------------
-- LQS Example: Custom Teleporter
-----------------------------------

return LQS.teleporter({
    name = "Sus Bastard",
    zone = "Northern_San_dOria",
    pos  = { 116.462, -0.199, -8.590, 163 },
    look = LQS.look({
        race = xi.race.HUME_M,
        face = LQS.face.A4,
        body = 16,
        legs = 14,
        feet = 12,
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
            name     = "Bastok Mines",
            lockText = "Rank 3 Required",
            pos      = { 89.570, 0.623, -71.851, 127, 234 },
            costs    = { gil = 500 },
            level    = 10,
            check = function(player)
                return player:getRank(player:getNation()) >= 3
            end,
        },

    },

    noDestinations  = "You haven't met the requirements for any destinations yet.",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})
