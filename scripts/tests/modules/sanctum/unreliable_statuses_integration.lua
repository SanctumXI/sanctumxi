describe('UnreliableStatuses Sleep engine integration', function()
    local player
    local mob

    before_each(function()
        player = xi.test.world:spawnPlayer({ job = xi.job.BLM, level = 99, zone = xi.zone.QUFIM_ISLAND })
        mob = player.entities:moveTo(17293357)
        mob:respawn()
        mob.assert:isAlive()

        stub('math.randomInt', function(low, high)
            if low == 1 and high == 100 then
                return 8
            end

            return low
        end)
    end)

    it('resolves the data mapping, warns on the first check, and expires the real effect', function()
        mob:setMod(xi.mod.SLEEP_IMMUNOBREAK, 7)
        mob:addStatusEffect(xi.effect.SLEEP_I, { power = 1, duration = 60, origin = player, tier = 1 })
        assert(mob:getMod(xi.mod.SLEEP_IMMUNOBREAK) == 0)
        assert(mob:getLocalVar('UnreliableStatuses:SleepToken') > 0, 'Sleep handler/module did not load')

        xi.test.world:skipTime(11)
        assert(mob:getStatusEffect(xi.effect.SLEEP_I):getTimeRemaining() > 4000)
        xi.test.world:skipTime(2)
        local remaining = mob:getStatusEffect(xi.effect.SLEEP_I):getTimeRemaining()
        assert(remaining > 3000 and remaining <= 4000)
        xi.test.world:skipTime(3)
        mob.assert:hasEffect(xi.effect.SLEEP_I)
        xi.test.world:skipTime(2)
        mob.assert.no:hasEffect(xi.effect.SLEEP_I)
        assert(mob:getLocalVar('UnreliableStatuses:SleepToken') == 0)

        mob:addStatusEffect(xi.effect.SLEEP_I, { power = 1, duration = 60, origin = player, tier = 1 })
        mob.assert:hasEffect(xi.effect.SLEEP_I)
    end)

    it('invalidates the old timer when the engine overwrites Sleep with Sleep II', function()
        mob:addStatusEffect(xi.effect.SLEEP_I, { power = 1, duration = 60, origin = player, tier = 1 })
        local oldToken = mob:getLocalVar('UnreliableStatuses:SleepToken')
        xi.test.world:skipTime(6)
        mob:addStatusEffect(xi.effect.SLEEP_I, { power = 2, duration = 90, origin = player, tier = 2 })
        assert(mob:getLocalVar('UnreliableStatuses:SleepToken') > oldToken)

        xi.test.world:skipTime(7)
        assert(mob:getStatusEffect(xi.effect.SLEEP_I):getTimeRemaining() > 80000)
        xi.test.world:skipTime(6)
        assert(mob:getStatusEffect(xi.effect.SLEEP_I):getTimeRemaining() <= 4000)
        xi.test.world:skipTime(5)
        mob.assert.no:hasEffect(xi.effect.SLEEP_I)
    end)

    it('does not shorten enemy Sleep inflicted on a player', function()
        player:addStatusEffect(xi.effect.SLEEP_I, { power = 1, duration = 60, origin = mob, tier = 1 })
        xi.test.world:skipTime(13)
        assert(player:getStatusEffect(xi.effect.SLEEP_I):getTimeRemaining() > 45000)
        assert(player:getLocalVar('UnreliableStatuses:SleepToken') == 0)
    end)
end)
