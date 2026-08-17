-----------------------------------
-- Sky Warp NPC
-----------------------------------

return LQS.teleporter({
    name = "Smiley Bastard",
    zone = "Aht_Urhgan_Whitegate",
    pos  = { -80.655, 0.000, -77.590, 130 },
    look = LQS.look({
        race = xi.race.HUME_M,
        face = LQS.face.A4,
        body = 10,
        legs = 19,
        feet = 3,
    }),

    greeting = "The sky is the limit...",

    menuTitle    = "Choose Your Destination",
    itemsPerPage = 4,

    teleportDelay = 1500,

    animation = { actionID = 6, animID = 600 },

    destinations = {
        {
            name     = "Ru'Aun Gardens - Main",
            lockText = "Sky Access Required",
            pos   = { -1.383, -54.040, -607.075, 191, 130 },
            costs = { gil = 2000 },
            check = function(player)
                return player:hasCompletedMission(
                    xi.mission.log_id.ZILART,
                    xi.mission.id.zilart.THE_GATE_OF_THE_GODS
                )
            end,
        },

        {
            name     = "Seiryu Island",
            lockText = "Sky Access Required",
            pos   = { 421.342, -8.000, -136.988, 140, 130 },
            costs = { gil = 2000 },
            check = function(player)
                return player:hasCompletedMission(
                    xi.mission.log_id.ZILART,
                    xi.mission.id.zilart.THE_GATE_OF_THE_GODS
                )
            end,
        },

        {
            name     = "Genbu Island",
            lockText = "Sky Access Required",
            pos   = { 258.725, -8.000, 356.263, 90, 130 },
            costs = { gil = 2000 },
            check = function(player)
                return player:hasCompletedMission(
                    xi.mission.log_id.ZILART,
                    xi.mission.id.zilart.THE_GATE_OF_THE_GODS
                )
            end,
        },

        {
            name     = "Byakko Island",
            lockText = "Sky Access Required",
            pos   = { -258.677, -8.000, 356.137, 38, 130 },
            costs = { gil = 2000 },
            check = function(player)
                return player:hasCompletedMission(
                    xi.mission.log_id.ZILART,
                    xi.mission.id.zilart.THE_GATE_OF_THE_GODS
                )
            end,
        },

        {
            name     = "Suzaku Island",
            lockText = "Sky Access Required",
            pos   = { -420.856, -8.000, -136.667, 240, 130 },
            costs = { gil = 2000 },
            check = function(player)
                return player:hasCompletedMission(
                    xi.mission.log_id.ZILART,
                    xi.mission.id.zilart.THE_GATE_OF_THE_GODS
                )
            end,
        },
    },

    noDestinations  = "You must unlock sky to get my assistance",
    insufficientGil = "You don't have enough Gil for this journey.",
    insufficientCP  = "You don't have enough conquest points for this journey.",
    cancelled       = "Perhaps another time. Safe travels!",
})