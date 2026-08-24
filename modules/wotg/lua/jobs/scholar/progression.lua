-----------------------------------
-- WotG-free Scholar progression
-- Moves the Scholar unlock and artifact quests to accessible locations.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('wotg_free_scholar_progression')
-----------------------------------

local windurstWatersText =
{
    YOU_CAN_NOW_BECOME_A_SCHOLAR = 17393,
}

m:addOverride('xi.server.onServerStart', function()
    super()

    xi.module.modifyInteractionEntry('scripts/quests/crystalWar/A_Little_Knowledge', function(quest)
        quest.sections =
        {
            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_AVAILABLE and
                        player:getMainLvl() >= xi.settings.main.ADVANCED_JOB_LEVEL
                end,

                [xi.zone.WINDURST_WATERS] =
                {
                    ['Erlene'] = quest:progressEvent(10, 1),

                    onEventFinish =
                    {
                        [10] = function(player, csid, option, npc)
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
                            if npcUtil.tradeMatches(trade, { { xi.item.SHEET_OF_VELLUM, 12 } }) then
                                return quest:progressEvent(12)
                            end
                        end,

                        onTrigger = quest:event(11),
                    },

                    onEventFinish =
                    {
                        [12] = function(player, csid, option, npc)
                            if quest:complete(player) then
                                player:tradeComplete()
                                player:unlockJob(xi.job.SCH)
                                player:addSpell(xi.magic.spell.EMBRAVA, { silentLog = true })
                                player:addSpell(xi.magic.spell.KAUSTRA, { silentLog = true })
                                player:messageSpecial(windurstWatersText.YOU_CAN_NOW_BECOME_A_SCHOLAR)
                            end
                        end,
                    },
                },
            },

            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_COMPLETED and
                        player:getQuestStatus(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.ON_SABBATICAL) ~= xi.questStatus.QUEST_COMPLETED
                end,

                [xi.zone.WINDURST_WATERS] =
                {
                    ['Erlene'] = quest:event(16):replaceDefault(),
                },
            },
        }
    end)

    xi.module.modifyInteractionEntry('scripts/quests/crystalWar/SCH_AF1_On_Sabbatical', function(quest)
        quest.sections =
        {
            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_AVAILABLE and
                        player:getMainJob() == xi.job.SCH and
                        player:getMainLvl() >= xi.settings.main.AF1_QUEST_LEVEL
                end,

                [xi.zone.WINDURST_WATERS] =
                {
                    ['Erlene'] = quest:progressEvent(13),

                    onEventFinish =
                    {
                        [13] = function(player, csid, option, npc)
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
                            if npcUtil.tradeMatches(trade, { { xi.item.HEAT_ROD, 1 } }) then
                                return quest:progressEvent(15)
                            end
                        end,

                        onTrigger = quest:event(14),
                    },

                    onEventFinish =
                    {
                        [15] = function(player, csid, option, npc)
                            if quest:complete(player) then
                                player:tradeComplete()
                                xi.quest.setVar(player, xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.ON_SABBATICAL, 'Timer', VanadielUniqueDay() + 1)
                                xi.quest.setMustZone(player, xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.ON_SABBATICAL)
                            end
                        end,
                    },
                },
            },

            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_COMPLETED and
                        player:getQuestStatus(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.DOWNWARD_HELIX) ~= xi.questStatus.QUEST_COMPLETED and
                        player:getQuestStatus(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.SEEING_BLOOD_RED) ~= xi.questStatus.QUEST_COMPLETED
                end,

                [xi.zone.WINDURST_WATERS] =
                {
                    ['Erlene'] = quest:event(17):replaceDefault(),
                },
            },
        }
    end)

    xi.module.modifyInteractionEntry('scripts/quests/crystalWar/SCH_AF2_Downward_Helix', function(quest)
        local onSabbaticalQuest = xi.quest.id.crystalWar.ON_SABBATICAL

        quest.reward.itemParams = { fromTrade = true }
        quest.sections =
        {
            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_AVAILABLE and
                        player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, onSabbaticalQuest) and
                        xi.quest.getVar(player, xi.questLog.CRYSTAL_WAR, onSabbaticalQuest, 'Timer') <= VanadielUniqueDay() and
                        not xi.quest.getMustZone(player, xi.questLog.CRYSTAL_WAR, onSabbaticalQuest) and
                        player:getMainJob() == xi.job.SCH and
                        player:getMainLvl() >= xi.settings.main.AF2_QUEST_LEVEL
                end,

                [xi.zone.WINDURST_WATERS] =
                {
                    ['Erlene'] = quest:progressEvent(22),

                    onEventFinish =
                    {
                        [22] = function(player, csid, option, npc)
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
                            if
                                npcUtil.tradeMatches(trade,
                                {
                                    { xi.item.CHUNK_OF_LIGHT_ORE, 1 },
                                    { xi.item.CHUNK_OF_DARK_ORE, 1 },
                                })
                            then
                                return quest:progressEvent(24)
                            end
                        end,

                        onTrigger = quest:progressEvent(23),
                    },

                    onEventFinish =
                    {
                        [24] = function(player, csid, option, npc)
                            if quest:complete(player) then
                                player:tradeComplete()
                                xi.quest.setVar(player, xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.DOWNWARD_HELIX, 'Timer', VanadielUniqueDay() + 1)
                                xi.quest.setMustZone(player, xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.DOWNWARD_HELIX)
                            end
                        end,
                    },
                },
            },

            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_COMPLETED and
                        player:getQuestStatus(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.SEEING_BLOOD_RED) ~= xi.questStatus.QUEST_COMPLETED
                end,

                [xi.zone.WINDURST_WATERS] =
                {
                    ['Erlene'] = quest:event(25):replaceDefault(),
                },
            },
        }
    end)
end)

return m
