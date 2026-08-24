-----------------------------------
-- WotG-free Dancer artifact quest 1
-- Moves The Unfinished Waltz encounter from Grauberg [S] to Valkurm Dunes.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('wotg_free_dancer_artifact_quest_1')
-----------------------------------

local migratoryHippogryphId = 17199662
local hippogryphCreditRange = 100

local reflectionText =
{
    12345,
    12346,
    12347,
}

local function engageHippogryph(player)
    local hippogryph = GetMobByID(migratoryHippogryphId)

    if not hippogryph then
        return false
    end

    if not hippogryph:isSpawned() then
        hippogryph = SpawnMob(migratoryHippogryphId)
    end

    if hippogryph then
        hippogryph:setMobMod(xi.mobMod.EXP_BONUS, -100)
        hippogryph:updateEnmity(player)
        return true
    end

    return false
end

local function grantHippogryphCredit(quest, mob, player)
    if not player then
        return
    end

    for _, member in ipairs(player:getParty()) do
        if
            member:getZoneID() == mob:getZoneID() and
            member:checkDistance(mob) <= hippogryphCreditRange and
            member:getQuestStatus(
                xi.questLog.JEUNO,
                xi.quest.id.jeuno.THE_UNFINISHED_WALTZ) == xi.questStatus.QUEST_ACCEPTED and
            quest:getVar(member, 'Prog') == 1 and
            quest:getVar(member, 'HippoEvent') == 1
        then
            quest:setVar(member, 'HippoEvent', 2)
        end
    end
end

m:addOverride('xi.server.onServerStart', function()
    super()

    xi.module.modifyInteractionEntry('scripts/quests/jeuno/DNC_AF1_The_Unfinished_Waltz', function(quest)
        quest.sections =
        {
            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_AVAILABLE and
                        player:getMainJob() == xi.job.DNC and
                        player:getMainLvl() >= xi.settings.main.AF1_QUEST_LEVEL
                end,

                [xi.zone.UPPER_JEUNO] =
                {
                    ['Laila'] = quest:progressEvent(10129),

                    onEventFinish =
                    {
                        [10129] = function(player, csid, option, npc)
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
                            if player:seenKeyItem(xi.ki.THE_ESSENCE_OF_DANCE) then
                                return quest:progressEvent(10133)
                            else
                                return quest:progressEvent(10130)
                            end
                        end,
                    },

                    ['Rhea_Myuliah'] =
                    {
                        onTrigger = function(player, npc)
                            if quest:getVar(player, 'Prog') == 0 then
                                return quest:progressEvent(10131)
                            else
                                return quest:progressEvent(10132)
                            end
                        end,
                    },

                    onEventFinish =
                    {
                        [10131] = function(player, csid, option, npc)
                            quest:setVar(player, 'Prog', 1)
                        end,

                        [10133] = function(player, csid, option, npc)
                            if quest:complete(player) then
                                -- Set mustZone and Timer for "The Road to Divadom" quest.
                                player:setCharVar('Quest[3][97]Timer', VanadielUniqueDay() + 1)
                                player:setLocalVar('Quest[3][97]mustZone', 1)
                            end
                        end,
                    },
                },

                [xi.zone.VALKURM_DUNES] =
                {
                    ['DNC_AF1_QM'] =
                    {
                        onTrigger = function(player, npc)
                            if
                                player:hasKeyItem(xi.ki.THE_ESSENCE_OF_DANCE) or
                                quest:getVar(player, 'Prog') ~= 1
                            then
                                return quest:noAction()
                            end

                            local hippoEvent = quest:getVar(player, 'HippoEvent')

                            if hippoEvent == 0 then
                                if engageHippogryph(player) then
                                    quest:setVar(player, 'HippoEvent', 1)
                                end
                            elseif hippoEvent == 1 then
                                -- Re-engage an existing party spawn, or replace one lost after a wipe.
                                engageHippogryph(player)
                            elseif hippoEvent == 2 then
                                for _, textId in ipairs(reflectionText) do
                                    player:messageSpecial(textId)
                                end

                                npcUtil.giveKeyItem(player, xi.ki.THE_ESSENCE_OF_DANCE)
                                quest:setVar(player, 'HippoEvent', 3)
                            end

                            return quest:noAction()
                        end,
                    },

                    ['Migratory_Hippogryph'] =
                    {
                        onMobDeath = function(mob, player, optParams)
                            grantHippogryphCredit(quest, mob, player)
                        end,
                    },
                },
            },

            {
                check = function(player, status, vars)
                    return status == xi.questStatus.QUEST_COMPLETED and
                        not player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_ROAD_TO_DIVADOM)
                end,

                [xi.zone.UPPER_JEUNO] =
                {
                    ['Laila']        = quest:event(10134):replaceDefault(),
                    ['Rhea_Myuliah'] = quest:event(10135):replaceDefault(),
                },
            },
        }
    end)
end)

return m
