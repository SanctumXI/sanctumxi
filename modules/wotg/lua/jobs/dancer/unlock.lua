-----------------------------------
-- WotG-free Dancer unlock
-- Replaces the WotG-dependent Lakeside Minuet route with a Snow Lily trial.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('wotg_free_dancer_unlock')
-----------------------------------

m:addOverride('xi.server.onServerStart', function()
    super()

    xi.module.modifyInteractionEntry('scripts/quests/jeuno/Lakeside_Minuet', function(quest)
        local upperJeunoID = zones[xi.zone.UPPER_JEUNO]

        quest.sections =
        {
            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_AVAILABLE and
                        player:getMainLvl() >= xi.settings.main.ADVANCED_JOB_LEVEL
                end,

                [xi.zone.UPPER_JEUNO] =
                {
                    ['Laila'] = quest:progressEvent(10111),

                    onEventFinish =
                    {
                        [10111] = function(player, csid, option, npc)
                            if option == 1 then
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

                [xi.zone.UPPER_JEUNO] =
                {
                    ['Laila'] =
                    {
                        onTrade = function(player, npc, trade)
                            if npcUtil.tradeMatches(trade, xi.item.SNOW_LILY) then
                                return quest:progressEvent(10118)
                            end
                        end,

                        onTrigger = quest:progressEvent(10112),
                    },

                    onEventFinish =
                    {
                        [10118] = function(player, csid, option, npc)
                            if quest:complete(player) then
                                player:tradeComplete()
                                player:unlockJob(xi.job.DNC)
                                player:messageSpecial(upperJeunoID.text.UNLOCK_DANCER)

                                if player:hasKeyItem(xi.ki.STARDUST_PEBBLE) then
                                    player:delKeyItem(xi.ki.STARDUST_PEBBLE)
                                end

                                npcUtil.giveKeyItem(player, xi.ki.JOB_GESTURE_DANCER)
                                player:needToZone(true)
                            end
                        end,
                    },
                },
            },

            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_COMPLETED and
                        not player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_UNFINISHED_WALTZ)
                end,

                [xi.zone.UPPER_JEUNO] =
                {
                    ['Laila']        = quest:event(10119):replaceDefault(),
                    ['Rhea_Myuliah'] = quest:event(10126):replaceDefault(),
                },
            },
        }
    end)
end)

return m
