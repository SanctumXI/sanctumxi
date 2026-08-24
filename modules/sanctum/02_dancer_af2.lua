-----------------------------------
-- Sanctum: Dancer AF2
-- Replaces The Road to Divadom's WotG route with an Ifrit's Cauldron trial.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('sanctum_dancer_af2')
-----------------------------------

local cauldronReflectionText =
{
    11613,
    11614,
}

m:addOverride('xi.server.onServerStart', function()
    super()

    xi.module.modifyInteractionEntry('scripts/quests/jeuno/DNC_AF2_The_Road_to_Divadom', function(quest)
        quest.sections =
        {
            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_AVAILABLE and
                        player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_UNFINISHED_WALTZ) and
                        player:getMainJob() == xi.job.DNC and
                        player:getMainLvl() >= xi.settings.main.AF2_QUEST_LEVEL and
                        not quest:getMustZone(player) and
                        quest:getVar(player, 'Timer') <= VanadielUniqueDay()
                end,

                [xi.zone.UPPER_JEUNO] =
                {
                    ['Laila'] = quest:progressEvent(10136),

                    onEventFinish =
                    {
                        [10136] = function(player, csid, option, npc)
                            quest:begin(player)
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
                        onTrigger = function(player, npc)
                            if quest:getVar(player, 'Prog') == 0 then
                                return quest:progressEvent(10137)
                            else
                                return quest:progressEvent(10170)
                            end
                        end,
                    },

                    onEventFinish =
                    {
                        [10170] = function(player, csid, option, npc)
                            local tightsItemID = xi.item.DANCERS_TIGHTS_F - player:getGender()

                            if npcUtil.giveItem(player, tightsItemID) then
                                quest:complete(player)

                                player:setCharVar('Quest[3][98]Timer', VanadielUniqueDay() + 1)
                                player:setLocalVar('Quest[3][98]mustZone', 1)
                                player:setCharVar('HQuest[DncArtifact]Prog', 1)
                            end
                        end,
                    },
                },

                [xi.zone.IFRITS_CAULDRON] =
                {
                    ['qm4'] =
                    {
                        onTrigger = function(player, npc)
                            if quest:getVar(player, 'Prog') == 0 then
                                for _, textId in ipairs(cauldronReflectionText) do
                                    player:messageSpecial(textId)
                                end

                                quest:setVar(player, 'Prog', 1)
                                return quest:noAction()
                            end
                        end,
                    },
                },
            },

            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_COMPLETED and
                        not player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.COMEBACK_QUEEN)
                end,

                [xi.zone.UPPER_JEUNO] =
                {
                    ['Laila'] = quest:event(10140):replaceDefault(),
                },
            },
        }
    end)
end)

return m
