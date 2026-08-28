describe('Sanctum Stoneskin refresh', function()
    local now
    local caster
    local target
    local spell
    local stoneskin
    local effectHooks

    local function makeEntity(id)
        local entity = { id = id, effects = {}, mods = {}, mnd = 100, skill = 300 }

        function entity:getID()
            return self.id
        end

        function entity:getMainLvl()
            return 75
        end

        function entity:getMainJob()
            return xi.job.WHM
        end

        function entity:isPet()
            return false
        end

        function entity:getSkillLevel(skill)
            return self.skill
        end

        function entity:getStat(stat)
            return self.mnd
        end

        function entity:getJobPointLevel(category)
            return 0
        end

        function entity:getMod(mod)
            return self.mods[mod] or 0
        end

        function entity:setMod(mod, value)
            self.mods[mod] = value
        end

        function entity:getStatusEffect(effectId)
            return self.effects[effectId]
        end

        function entity:hasStatusEffect(effectId)
            return self.effects[effectId] ~= nil
        end

        function entity:delStatusEffectSilent(effectId)
            local effect = self.effects[effectId]
            if effect then
                if effectId == xi.effect.STONESKIN then
                    effectHooks.onEffectLose(self, effect)
                end

                self.effects[effectId] = nil
            end
        end

        function entity:addStatusEffect(effectId, params)
            local existing = self.effects[effectId]
            local tier = params.tier or 0
            -- Match the engine's tier_higher rule, not a permissive table replacement.
            if
                effectId == xi.effect.STONESKIN and
                existing and
                (tier == 0 or existing.tier == 0 or tier <= existing.tier)
            then
                return false
            end

            self:delStatusEffectSilent(effectId)
            local effect =
            {
                power = params.power or 0, tier = tier, origin = params.origin,
                duration = params.duration * 1000, start = now,
            }

            function effect:getPower()
                return self.power
            end

            function effect:getTier()
                return self.tier
            end

            function effect:getTimeRemaining()
                return math.max(0, self.start + self.duration - now)
            end

            self.effects[effectId] = effect
            if effectId == xi.effect.STONESKIN then
                effectHooks.onEffectGain(self, effect)
            end

            return true
        end

        return entity
    end

    before_each(function()
        now = 0
        caster = makeEntity(1)
        target = makeEntity(2)
        effectHooks = dofile('scripts/effects/stoneskin.lua')
        stoneskin = dofile('scripts/actions/spells/white/stoneskin.lua')
        local module = dofile('modules/sanctum/MiscFixes/Lua/spells_and_abilities.lua')
        for _, override in ipairs(module.overrides) do
            if override.name == 'xi.actions.spells.white.stoneskin.onSpellCast' then
                applyOverride(stoneskin, 'onSpellCast', override.func, override.name, '')
            end
        end

        spell = {}

        function spell:getID()
            return xi.magic.spell.STONESKIN
        end

        function spell:getSpellGroup()
            return xi.magic.spellGroup.WHITE
        end

        function spell:getSkillType()
            return xi.skill.ENHANCING_MAGIC
        end

        function spell:setMsg(message)
            self.message = message
        end
    end)

    local function cast(recipient)
        local result = stoneskin.onSpellCast(caster, recipient, spell)
        assert(result == xi.effect.STONESKIN, 'Stoneskin returned no effect')
        assert(spell.message == xi.msg.basic.MAGIC_GAIN_EFFECT)
        return recipient:getStatusEffect(xi.effect.STONESKIN)
    end

    it('applies a fresh shield normally', function()
        local effect = cast(caster)
        assert(effect:getPower() > 0)
        assert(caster:getMod(xi.mod.STONESKIN) == effect:getPower())
        assert(effect:getTimeRemaining() == 300000)
    end)

    it('refreshes an equal-strength shield and resets its duration', function()
        local previous = cast(caster)
        now = 120000
        local effect = cast(caster)
        assert(effect ~= previous)
        assert(effect:getPower() == previous:getPower())
        assert(effect:getTimeRemaining() == 300000)
    end)

    it('refills absorbed damage even when the stored effect power is unchanged', function()
        local previous = cast(caster)
        caster:setMod(xi.mod.STONESKIN, 1)
        now = 120000
        local effect = cast(caster)
        assert(effect:getPower() == previous:getPower())
        assert(caster:getMod(xi.mod.STONESKIN) == effect:getPower())
        assert(effect:getTimeRemaining() == 300000)
    end)

    it('uses the new spell potency even when it is weaker', function()
        local previous = cast(caster)
        caster.skill = 30
        caster.mnd = 20
        local effect = cast(caster)
        assert(effect:getPower() < previous:getPower())
        assert(caster:getMod(xi.mod.STONESKIN) == effect:getPower())
    end)

    it('still replaces a weaker shield with a stronger spell', function()
        caster.skill = 30
        caster.mnd = 20
        local previous = cast(caster)
        caster.skill = 300
        caster.mnd = 100
        local effect = cast(caster)
        assert(effect:getPower() > previous:getPower())
    end)

    it('refreshes the recipient without removing the caster shield', function()
        local own = cast(caster)
        local previous = cast(target)
        now = 120000
        local effect = cast(target)
        assert(effect ~= previous)
        assert(effect.origin == caster)
        assert(effect:getTimeRemaining() == 300000)
        assert(caster:getStatusEffect(xi.effect.STONESKIN) == own)
        assert(own:getTimeRemaining() == 180000)
    end)

    it('recalculates duration bonuses when refreshing', function()
        cast(caster)
        caster:setMod(xi.mod.ENH_MAGIC_DURATION, 50)
        now = 120000
        assert(cast(caster):getTimeRemaining() == 450000)
    end)

    it('does not stack absorption across repeated refreshes', function()
        local power = cast(caster):getPower()
        for _ = 1, 3 do
            now = now + 30000
            cast(caster)
            assert(caster:getMod(xi.mod.STONESKIN) == power)
        end
    end)

    for _, tier in ipairs({ 0, 2, 3, 4, 5 }) do
        it('preserves the existing non-spell tier ' .. tier .. ' shield', function()
            target:addStatusEffect(xi.effect.STONESKIN, { power = 1, duration = 900, origin = target, tier = tier })
            local previous = target:getStatusEffect(xi.effect.STONESKIN)
            now = 120000
            assert(stoneskin.onSpellCast(caster, target, spell) == xi.effect.NONE)
            assert(spell.message == xi.msg.basic.MAGIC_NO_EFFECT)
            assert(target:getStatusEffect(xi.effect.STONESKIN) == previous)
            assert(target:getMod(xi.mod.STONESKIN) == 1)
            assert(previous:getTimeRemaining() == 780000)
        end)
    end
end)
