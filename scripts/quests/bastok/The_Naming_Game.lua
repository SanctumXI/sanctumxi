-----------------------------------
-- The Naming Game
-----------------------------------
-- Log ID: 1, Quest ID: 81
-- Raibaht : !gotoid 17748012
-----------------------------------

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.THE_NAMING_GAME)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.BASTOK,
    gil      = 3600,
    title    = xi.title.HYPER_ULTRA_SONIC_ADVENTURER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.TEAK_ME_TO_THE_STARS) and
                player:getFameLevel(xi.fameArea.BASTOK) >= 5
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] = quest:progressEvent(869),

            onEventFinish =
            {
                [869] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status >= xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeMatches(trade, { { xi.item.CHUNK_OF_ORDRYNITE, 1 } }) then
                        return quest:progressEvent(870)
                    end
                end,
            },

            onEventFinish =
            {
                [870] = function(player, csid, option, npc)
                    if player:getQuestStatus(quest.areaId, quest.questId) == xi.questStatus.QUEST_ACCEPTED then
                        quest:complete(player)
                    end

                    player:tradeComplete()
                end,
            },
        },
    },
}

return quest
