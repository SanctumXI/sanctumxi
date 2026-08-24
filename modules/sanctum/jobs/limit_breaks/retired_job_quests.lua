-----------------------------------
-- Retired job-specific level-break quests
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_retired_job_limit_break_quests')

-- Keep the quest IDs intact for character-data compatibility. DNC and SCH do
-- not have executable quest resources in this branch, but are listed here so
-- the replacement Maat implementation has one authoritative set of retired
-- routes.
local removedLimitBreaks =
{
    {
        name          = 'Achieving True Power',
        job           = xi.job.PUP,
        questArea     = xi.questLog.BASTOK,
        questId       = xi.quest.id.bastok.ACHIEVING_TRUE_POWER,
        questResource = 'scripts/quests/bastok/PUP_LB_Achieving_True_Power',
    },
    {
        name          = 'A Furious Finale',
        job           = xi.job.DNC,
        questArea     = xi.questLog.JEUNO,
        questId       = xi.quest.id.jeuno.A_FURIOUS_FINALE,
    },
    {
        name          = 'Breaking the Bonds of Fate',
        job           = xi.job.COR,
        questArea     = xi.questLog.AHT_URHGAN,
        questId       = xi.quest.id.ahtUrhgan.BREAKING_THE_BONDS_OF_FATE,
        questResource = 'scripts/quests/ahtUrhgan/COR_LB_Breaking_the_Bonds_of_Fate',
    },
    {
        name          = 'Survival of the Wisest',
        job           = xi.job.SCH,
        questArea     = xi.questLog.OTHER_AREAS,
        questId       = xi.quest.id.otherAreas.SURVIVAL_OF_THE_WISEST,
    },
    {
        name          = 'The Beast Within',
        job           = xi.job.BLU,
        questArea     = xi.questLog.AHT_URHGAN,
        questId       = xi.quest.id.ahtUrhgan.THE_BEAST_WITHIN,
        questResource = 'scripts/quests/ahtUrhgan/BLU_LB_The_Beast_Within',
    },
}

xi.sanctum = xi.sanctum or {}
xi.sanctum.removedJobLimitBreaks = removedLimitBreaks

local function disableQuest(resource)
    xi.module.modifyInteractionEntry(resource, function(quest)
        for _, section in ipairs(quest.sections) do
            section.check = function()
                return false
            end
        end
    end)
end

m:addOverride('xi.server.onServerStart', function()
    super()

    for _, limitBreak in ipairs(removedLimitBreaks) do
        if limitBreak.questResource then
            disableQuest(limitBreak.questResource)
        end
    end
end)

return m
