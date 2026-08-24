-----------------------------------
-- Seeing Blood-red
-----------------------------------
-- !addquest 7 34
-- Erlene : !pos -57.5238 -5.5000 104.9193 238
-----------------------------------

local downwardHelixQuest = xi.quest.id.crystalWar.DOWNWARD_HELIX
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.SEEING_BLOOD_RED)

quest.reward =
{
    item       = xi.item.SCHOLARS_MORTARBOARD,
    itemParams = { fromTrade = true },
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, downwardHelixQuest) and
                xi.quest.getVar(player, xi.questLog.CRYSTAL_WAR, downwardHelixQuest, 'Timer') <= VanadielUniqueDay() and
                not xi.quest.getMustZone(player, xi.questLog.CRYSTAL_WAR, downwardHelixQuest) and
                player:getMainJob() == xi.job.SCH and
                player:getMainLvl() >= xi.settings.main.AF3_QUEST_LEVEL
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Erlene'] = quest:progressEvent(18),

            onEventFinish =
            {
                [18] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Erlene'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeMatches(trade, { { xi.item.INTELLIGENCE_POTION, 1 } }) then
                        return quest:progressEvent(20)
                    end
                end,

                onTrigger = quest:progressEvent(19),
            },

            onEventFinish =
            {
                [20] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:tradeComplete()
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Erlene'] = quest:event(21):replaceDefault(),
        },
    },
}

return quest
