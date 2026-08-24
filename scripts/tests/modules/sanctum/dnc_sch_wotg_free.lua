describe('Sanctum WotG-free Dancer and Scholar quests', function()
    it('grants persistent Hippogryph kill credit to nearby eligible party members', function()
        local player = xi.test.world:spawnPlayer(
        {
            zone  = xi.zone.VALKURM_DUNES,
            job   = xi.job.DNC,
            level = 99,
        })
        local partyMember = xi.test.world:spawnPlayer(
        {
            zone  = xi.zone.VALKURM_DUNES,
            job   = xi.job.DNC,
            level = 99,
        })
        local stranger = xi.test.world:spawnPlayer(
        {
            zone  = xi.zone.VALKURM_DUNES,
            job   = xi.job.DNC,
            level = 99,
        })
        local questId    = xi.quest.id.jeuno.THE_UNFINISHED_WALTZ
        local questPrefix = Quest.getVarPrefix(xi.questLog.JEUNO, questId)

        player.actions:inviteToParty(partyMember)
        partyMember.actions:acceptPartyInvite()

        for _, member in ipairs({ player, partyMember, stranger }) do
            member:addQuest(xi.questLog.JEUNO, questId)
            member:setCharVar(questPrefix .. 'Prog', 1)
            member:setCharVar(questPrefix .. 'HippoEvent', 1)
            member.entities:moveTo(17199662)
        end

        local hippogryph = GetMobByID(17199662)
        assert(hippogryph)

        InteractionGlobal.onMobDeath(hippogryph, player, {}, function()
        end)

        assert(player:getCharVar(questPrefix .. 'HippoEvent') == 2)
        assert(partyMember:getCharVar(questPrefix .. 'HippoEvent') == 2)
        assert(stranger:getCharVar(questPrefix .. 'HippoEvent') == 1)
    end)
end)
