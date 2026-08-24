describe('Retired job-specific limit-break quests', function()
    it('tracks all five retired quest routes', function()
        local removedLimitBreaks = xi.sanctum.removedJobLimitBreaks
        local seenJobs          = {}

        assert(#removedLimitBreaks == 5)

        for _, limitBreak in ipairs(removedLimitBreaks) do
            assert(not seenJobs[limitBreak.job])
            seenJobs[limitBreak.job] = true
        end

        assert(seenJobs[xi.job.BLU])
        assert(seenJobs[xi.job.COR])
        assert(seenJobs[xi.job.PUP])
        assert(seenJobs[xi.job.DNC])
        assert(seenJobs[xi.job.SCH])
    end)

    it('does not begin Breaking the Bonds of Fate at the old quest marker', function()
        local player = xi.test.world:spawnPlayer(
        {
            zone  = xi.zone.ARRAPAGO_REEF,
            job   = xi.job.COR,
            level = 70,
        })

        player:addQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.AGAINST_ALL_ODDS)
        player:completeQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.AGAINST_ALL_ODDS)

        player.entities:gotoAndTrigger('qm6')
        player.events:expectNotInEvent()
        assert(player:getQuestStatus(
            xi.questLog.AHT_URHGAN,
            xi.quest.id.ahtUrhgan.BREAKING_THE_BONDS_OF_FATE) == xi.questStatus.QUEST_AVAILABLE)
    end)
end)
