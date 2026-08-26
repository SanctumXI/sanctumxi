describe('UnreliableStatuses Sleep timers', function()
    local now
    local entities
    local players
    local hooks
    local player
    local mob
    local rolls
    local rollCount

    local function removeEffect(target, effectId)
        local effect = target.effects[effectId]
        if effect then
            target.effects[effectId] = nil
            hooks[effectId].onEffectLose(target, effect)
            effect.valid = false
        end
    end

    local function makeEntity(id, kind)
        local entity =
        {
            id         = id,
            kind       = kind,
            zoneId     = 1,
            allegiance = kind == 'mob' and xi.allegiance.MOB or xi.allegiance.PLAYER,
            vars       = {},
            effects    = {},
            timers     = {},
            messages   = {},
            animations = {},
            mods       = {},
            spawned    = true,
            dead       = false,
            distance   = 0,
            name       = 'Goblin_Weaver',
            packetName = '',
        }

        function entity:getID()
            return self.id
        end

        function entity:isPC()
            return self.kind == 'player'
        end

        function entity:isMob()
            return self.kind == 'mob'
        end

        function entity:isPet()
            return self.kind == 'pet'
        end

        function entity:isSpawned()
            return self.spawned
        end

        function entity:isDead()
            return self.dead
        end

        function entity:getMaster()
            return self.master
        end

        function entity:getZoneID()
            return self.zoneId
        end

        function entity:getInstance()
            return self.instance
        end

        function entity:getAllegiance()
            return self.allegiance
        end

        function entity:getName()
            return self.name
        end

        function entity:getPacketName()
            return self.packetName
        end

        function entity:getLocalVar(key)
            return self.vars[key] or 0
        end

        function entity:setLocalVar(key, value)
            self.vars[key] = value
        end

        function entity:setMod(key, value)
            self.mods[key] = value
        end

        function entity:getStatusEffect(effectId)
            return self.effects[effectId]
        end

        function entity:delStatusEffect(effectId)
            removeEffect(self, effectId)
        end

        function entity:checkDistance(target)
            return self.distance
        end

        function entity:getZone()
            local zonePlayers = {}
            for _, candidate in pairs(players) do
                if candidate.zoneId == self.zoneId then
                    table.insert(zonePlayers, candidate)
                end
            end

            return
            {
                getPlayers = function()
                    return zonePlayers
                end,
            }
        end

        function entity:timer(delay, callback)
            assert(delay > 0)
            table.insert(self.timers, { due = now + delay, callback = callback })
        end

        function entity:weaknessTrigger(level)
            table.insert(self.animations, { time = now, level = level })
        end

        function entity:printToPlayer(message, channel)
            table.insert(self.messages, { time = now, message = message, channel = channel })
        end

        entities[id] = entity
        if entity:isPC() then
            players[id] = entity
        end

        return entity
    end

    local function applySleep(target, options)
        options = options or {}
        for _, effectId in ipairs({ xi.effect.SLEEP_I, xi.effect.SLEEP_II, xi.effect.LULLABY }) do
            removeEffect(target, effectId)
        end

        local effect =
        {
            valid    = true,
            start    = now,
            duration = options.duration or 60000,
            originId = options.originId or player.id,
            tier     = options.tier or 1,
            power    = options.power or 1,
            effectId = options.effectId or xi.effect.SLEEP_I,
        }

        function effect:getDuration()
            assert(self.valid)
            return self.duration
        end

        function effect:getOriginID()
            assert(self.valid)
            return self.originId
        end

        function effect:getTier()
            assert(self.valid)
            return self.tier
        end

        function effect:getPower()
            assert(self.valid)
            return self.power
        end

        function effect:getEffectType()
            assert(self.valid)
            return self.effectId
        end

        function effect:setDuration(duration)
            assert(self.valid)
            self.duration = duration
        end

        function effect:getTimeRemaining()
            assert(self.valid, 'A callback accessed a deleted effect')
            return math.max(0, self.start + self.duration - now)
        end

        target.effects[effect.effectId] = effect
        hooks[effect.effectId].onEffectGain(target, effect)
        return effect
    end

    local function tick()
        -- Match the map loop: expiration precedes entity timer callbacks.
        for _, entity in pairs(entities) do
            for effectId, effect in pairs(entity.effects) do
                if effect.duration ~= 0 and effect.start + effect.duration <= now then
                    removeEffect(entity, effectId)
                end
            end
        end

        for _, entity in pairs(entities) do
            local index = 1
            while index <= #entity.timers do
                local timer = entity.timers[index]
                if timer.due <= now then
                    table.remove(entity.timers, index)
                    timer.callback(entity)
                else
                    index = index + 1
                end
            end
        end
    end

    local function advance(milliseconds)
        local finish = now + milliseconds
        while now < finish do
            local nextTime = finish
            for _, entity in pairs(entities) do
                for _, timer in ipairs(entity.timers) do
                    nextTime = math.min(nextTime, timer.due)
                end

                for _, effect in pairs(entity.effects) do
                    if effect.duration > 0 then
                        nextTime = math.min(nextTime, effect.start + effect.duration)
                    end
                end
            end

            assert(nextTime > now, 'Timer failed to advance')
            now = nextTime
            tick()
        end
    end

    before_each(function()
        now       = 0
        entities  = {}
        players   = {}
        rolls     = {}
        rollCount = 0

        local sleepHooks   = dofile('scripts/effects/sleep.lua')
        local lullabyHooks = dofile('scripts/effects/lullaby.lua')
        local module       = dofile('modules/sanctum/Buffs and Debuffs/UnreliableStatuses.lua')
        for _, override in ipairs(module.overrides) do
            local scriptName, callback = override.name:match('xi%.effects%.(%w+)%.(%w+)')
            local base = scriptName == 'sleep' and sleepHooks or lullabyHooks
            applyOverride(base, callback, override.func, override.name, '')
        end

        hooks =
        {
            [xi.effect.SLEEP_I]  = sleepHooks,
            [xi.effect.SLEEP_II] = sleepHooks,
            [xi.effect.LULLABY]  = lullabyHooks,
            [xi.effect.BIO] =
            {
                onEffectLose = function()
                end,
            },
        }

        player = makeEntity(1, 'player')
        mob    = makeEntity(2, 'mob')

        stub('GetPlayerByID', function(id)
            return players[id]
        end)

        stub('GetEntityByID', function(id, instance, quiet)
            assert(quiet, 'Missing origins should not spam the server log')
            return entities[id]
        end)

        stub('math.randomInt', function(low, high)
            assert(low == 1 and high == 100)
            rollCount = rollCount + 1
            return table.remove(rolls, 1) or 100
        end)
    end)

    it('includes roll 8, warns at 12 seconds, and wakes four seconds later', function()
        rolls = { 8 }
        local effect = applySleep(mob)
        advance(11999)
        assert(rollCount == 0 and #mob.animations == 0)
        advance(1)
        assert(rollCount == 1 and effect:getTimeRemaining() == 4000)
        assert(effect:getDuration() == 16000)
        assert(#mob.animations == 1 and mob.animations[1].level == 1)
        assert(#player.messages == 1)
        assert(player.messages[1].message == 'Goblin Weaver begins to stir!')
        assert(player.messages[1].channel == xi.msg.channel.SYSTEM_3)
        advance(3999)
        assert(mob:getStatusEffect(xi.effect.SLEEP_I))
        advance(1)
        assert(not mob:getStatusEffect(xi.effect.SLEEP_I))
        advance(60000)
        assert(rollCount == 1 and #mob.animations == 1)
    end)

    it('excludes roll 9 and gives another chance twelve seconds later', function()
        rolls = { 9, 8 }
        local effect = applySleep(mob)
        advance(12000)
        assert(effect:getDuration() == 60000 and #mob.animations == 0)
        advance(12000)
        assert(rollCount == 2 and effect:getTimeRemaining() == 4000)
        assert(mob.animations[1].time == 24000)
    end)

    for _, duration in ipairs({ 15000, 30000, 45000, 60000, 90000, 120000 }) do
        it(string.format('warns once before natural expiration of a %d ms Sleep', duration), function()
            local effect = applySleep(mob, { duration = duration })
            advance(duration - 4000)
            assert(#mob.animations == 1 and #player.messages == 1)
            assert(mob.animations[1].time == duration - 4000)
            assert(effect:getDuration() == duration)
            assert(rollCount == math.floor((duration - 4001) / 12000))
            advance(4000)
            assert(not mob:getStatusEffect(xi.effect.SLEEP_I))
        end)
    end

    it('warns immediately for a short effect without extending it', function()
        applySleep(mob, { duration = 1000 })
        assert(#mob.animations == 1)
        advance(1000)
        assert(not mob:getStatusEffect(xi.effect.SLEEP_I))
        assert(rollCount == 0)
    end)

    it('rolls independently for multiple sleeping enemies', function()
        local other = makeEntity(3, 'mob')
        applySleep(mob)
        applySleep(other)
        rolls = { 8, 9 }
        advance(12000)
        assert(rollCount == 2)
        assert(#mob.animations + #other.animations == 1)
        advance(4000)
        local survivors = (mob:getStatusEffect(xi.effect.SLEEP_I) and 1 or 0) +
            (other:getStatusEffect(xi.effect.SLEEP_I) and 1 or 0)
        assert(survivors == 1)
    end)

    it('invalidates a removed application before its pending check runs', function()
        applySleep(mob)
        advance(6000)
        removeEffect(mob, xi.effect.SLEEP_I)
        local replacement = applySleep(mob)
        advance(6000)
        assert(rollCount == 0 and replacement:getTimeRemaining() == 54000)
        rolls = { 8 }
        advance(6000)
        assert(rollCount == 1 and replacement:getTimeRemaining() == 4000)
    end)

    it('does not let a pending wake remove a replacement Sleep II', function()
        rolls = { 8 }
        applySleep(mob)
        advance(13000)
        local replacement = applySleep(mob, { tier = 2, power = 2, duration = 90000 })
        advance(3000)
        assert(mob:getStatusEffect(xi.effect.SLEEP_I) == replacement)
        assert(replacement:getTimeRemaining() == 87000)
        assert(#mob.animations == 1)
    end)

    it('allows immediate removal during a warning and re-sleep after wake', function()
        rolls = { 8 }
        applySleep(mob)
        advance(12000)
        removeEffect(mob, xi.effect.SLEEP_I)
        assert(not mob:getStatusEffect(xi.effect.SLEEP_I))
        local replacement = applySleep(mob)
        advance(4000)
        assert(replacement:getTimeRemaining() == 56000)
        assert(#mob.animations == 1)
    end)

    it('does not reuse a token when respawn clears local variables', function()
        applySleep(mob)
        advance(6000)
        removeEffect(mob, xi.effect.SLEEP_I)
        mob.vars = {}
        local replacement = applySleep(mob)
        advance(6000)
        assert(rollCount == 0 and replacement:getTimeRemaining() == 54000)
    end)

    it('includes player pets as sources', function()
        local pet = makeEntity(3, 'pet')
        pet.master = player
        rolls = { 8 }
        local effect = applySleep(mob, { originId = pet.id })
        advance(12000)
        assert(effect:getTimeRemaining() == 4000 and #mob.animations == 1)
    end)

    it('leaves players and pets as targets unchanged', function()
        local pet = makeEntity(3, 'pet')
        applySleep(player, { originId = mob.id })
        applySleep(pet)
        advance(60000)
        assert(rollCount == 0 and #player.animations == 0 and #pet.animations == 0)
        assert(#player.messages == 0)
    end)

    it('leaves enemy-applied, self-applied, and unknown-source Sleep unchanged', function()
        local enemy = makeEntity(3, 'mob')
        local npc = makeEntity(4, 'npc')
        for _, originId in ipairs({ enemy.id, mob.id, npc.id, 0, 999 }) do
            local effect = applySleep(mob, { originId = originId })
            advance(16000)
            assert(effect:getDuration() == 60000)
        end

        assert(rollCount == 0 and #mob.animations == 0)
    end)

    it('excludes allied mobs and sources outside the target instance', function()
        mob.allegiance = xi.allegiance.PLAYER
        applySleep(mob)
        advance(16000)
        mob.allegiance = xi.allegiance.MOB
        player.instance = {}
        applySleep(mob)
        advance(16000)
        player.instance = nil
        player.zoneId = 2
        applySleep(mob)
        advance(16000)
        assert(rollCount == 0 and #mob.animations == 0)
    end)

    it('preserves Nightmare, sentinel sleeps, permanent effects, and explicit exemptions', function()
        for _, options in ipairs({ { tier = 4 }, { power = 255 }, { duration = 0 } }) do
            applySleep(mob, options)
            advance(16000)
        end

        mob:setLocalVar('UnreliableStatuses:Exempt', 1)
        applySleep(mob)
        advance(16000)
        assert(rollCount == 0 and #mob.animations == 0)
    end)

    it('keeps existing immunobreak reset and Nightmare Bio cleanup', function()
        mob.mods[xi.mod.SLEEP_IMMUNOBREAK] = 7
        applySleep(mob, { tier = 4 })
        assert(mob.mods[xi.mod.SLEEP_IMMUNOBREAK] == 0)
        mob.effects[xi.effect.BIO] =
        {
            getTier = function()
                return 11
            end,
        }
        removeEffect(mob, xi.effect.SLEEP_I)
        assert(not mob:getStatusEffect(xi.effect.BIO))
    end)

    it('limits named text to nearby players in the same instance', function()
        local nearby = makeEntity(3, 'player')
        local distant = makeEntity(4, 'player')
        local otherInstance = makeEntity(5, 'player')
        local otherZone = makeEntity(6, 'player')
        nearby.distance = 50
        distant.distance = 51
        otherInstance.instance = {}
        otherZone.zoneId = 2
        mob.packetName = 'Restless Goblin'
        applySleep(mob, { duration = 4000 })
        assert(#player.messages == 1 and #nearby.messages == 1)
        assert(player.messages[1].message == 'Restless Goblin begins to stir!')
        assert(#distant.messages == 0 and #otherInstance.messages == 0 and #otherZone.messages == 0)
    end)

    it('stops checks on death, despawn, or a new encounter exemption', function()
        applySleep(mob)
        mob.dead = true
        advance(12000)
        mob.dead = false
        applySleep(mob)
        mob.spawned = false
        advance(12000)
        mob.spawned = true
        applySleep(mob)
        mob:setLocalVar('UnreliableStatuses:Exempt', 1)
        advance(12000)
        assert(rollCount == 0 and #mob.animations == 0)
    end)

    for _, effectId in ipairs({ xi.effect.SLEEP_II, xi.effect.LULLABY }) do
        it(string.format('handles legacy sleep effect %d', effectId), function()
            rolls = { 8 }
            local effect = applySleep(mob, { effectId = effectId })
            advance(12000)
            assert(effect:getTimeRemaining() == 4000)
            advance(4000)
            assert(not mob:getStatusEffect(effectId))
        end)
    end

    it('does not perform catch-up rolls after a stalled update', function()
        applySleep(mob)
        now = 30000
        tick()
        assert(rollCount == 1 and #mob.timers == 1)
        advance(11999)
        assert(rollCount == 1)
        advance(1)
        assert(rollCount == 2)
    end)

    it('never extends natural expiry when a warning callback is late', function()
        local effect = applySleep(mob)
        now = 58000
        tick()
        assert(effect:getDuration() == 60000 and #mob.animations == 1)
        assert(rollCount == 0)
        advance(2000)
        assert(not mob:getStatusEffect(xi.effect.SLEEP_I))
    end)

    it('does not warn for an effect that expired before a delayed callback', function()
        applySleep(mob)
        now = 60000
        tick()
        assert(#mob.animations == 0 and rollCount == 0)
    end)

    it('re-evaluates an extended duration without adding an extra early roll', function()
        local effect = applySleep(mob)
        advance(54000)
        effect:setDuration(90000)
        advance(2000)
        assert(rollCount == 4 and #mob.animations == 0)
        advance(30000)
        assert(rollCount == 7 and #mob.animations == 1)
        assert(mob.animations[1].time == 86000)
        assert(effect:getDuration() == 90000)
    end)
end)
