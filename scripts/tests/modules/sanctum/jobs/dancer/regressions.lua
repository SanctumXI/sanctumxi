describe('Sanctum Dancer regressions', function()
    local player
    local target
    local ability
    local action

    local function makeEntity(id)
        local entity =
        {
            id = id, tp = 3000, hp = 1, maxHP = 3000, job = xi.job.DNC,
            mods = {}, merits = {}, effects = {}, facing = true, animation = 1,
        }

        local getters =
        {
            getID = 'id', getTP = 'tp', getHP = 'hp', getMaxHP = 'maxHP',
            getMainJob = 'job', getAnimation = 'animation', isFacing = 'facing',
        }

        for method, field in pairs(getters) do
            entity[method] = function(self)
                return self[field]
            end
        end

        function entity:getMod(mod)
            return self.mods[mod] or 0
        end

        function entity:addMod(mod, value)
            self.mods[mod] = self:getMod(mod) + value
        end

        function entity:delMod(mod, value)
            self:addMod(mod, -value)
        end

        function entity:getMerit(merit)
            return self.merits[merit] or 0
        end

        function entity:hasStatusEffect(effect)
            return self.effects[effect] ~= nil
        end

        function entity:getStatusEffect(effect)
            return self.effects[effect]
        end

        function entity:delStatusEffect(effect)
            self.effects[effect] = nil
        end

        function entity:addStatusEffect(effectId, params)
            local effect = { power = params.power or 0, subPower = params.subPower or 0, mods = {}, duration = params.duration }

            function effect:getPower()
                return self.power
            end

            function effect:setPower(value)
                self.power = value
            end

            function effect:getSubPower()
                return self.subPower
            end

            function effect:setSubPower(value)
                self.subPower = value
            end

            function effect:addMod(mod, value)
                self.mods[mod] = (self.mods[mod] or 0) + value
            end

            function effect:setIcon(value)
                self.icon = value
            end

            function effect:setDuration(value)
                self.duration = value
            end

            self.effects[effectId] = effect
            return true
        end

        function entity:delTP(value)
            self.tp = self.tp - value
        end

        function entity:addTP(value)
            self.tp = self.tp + value
        end

        function entity:getStat(stat)
            return 90
        end

        function entity:restoreHP(value)
            self.hp = self.hp + value
        end

        function entity:wakeUp()
        end

        function entity:updateEnmityFromCure(healed, amount)
        end

        function entity:healingWaltz()
            return xi.effect.NONE
        end

        function entity:getJobPointLevel(category)
            return 0
        end

        function entity:getEquipID(slot)
            return 0
        end

        function entity:getWeaponSkillType(slot)
            return xi.skill.DAGGER
        end

        function entity:getObjType()
            return xi.objType.PC
        end

        function entity:hasTrait(trait)
            return self.warSubjob == true
        end

        function entity:isPC()
            return true
        end

        return entity
    end

    before_each(function()
        player = makeEntity(100001)
        target = makeEntity(100002)
        ability = { id = xi.jobAbility.CURING_WALTZ, recast = 15 }

        function ability:getID()
            return self.id
        end

        function ability:getRecast()
            return self.recast
        end

        function ability:setRecast(value)
            self.recast = value
        end

        function ability:setPostActionCleanupEffect(value)
            self.cleanup = value
        end

        function ability:setMsg(value)
            self.message = value
        end

        action = {}

        function action:getPrimaryTargetID()
            return target.id
        end

        function action:setAnimation(id, value)
        end

        function action:info(id, value)
        end
    end)

    local sambaCosts =
    {
        haste_samba = 400, drain_samba = 200, drain_samba_ii = 300,
        drain_samba_iii = 400, aspir_samba = 200, aspir_samba_ii = 400,
    }

    for name, cost in pairs(sambaCosts) do
        it(name .. ' checks and consumes its configured TP cost', function()
            local samba = xi.actions.abilities[name]
            player.tp = cost - 1
            assert(samba.onAbilityCheck(player, player, ability) == xi.msg.basic.NOT_ENOUGH_TP)
            player.tp = cost
            assert(samba.onAbilityCheck(player, player, ability) == 0)
            samba.onUseAbility(player, player, ability)
            assert(player.tp == 0)
        end)

        it(name .. ' is free under Trance but still blocked by Fan Dance', function()
            local samba = xi.actions.abilities[name]
            player.tp = 0
            player:addStatusEffect(xi.effect.TRANCE, {})
            assert(samba.onAbilityCheck(player, player, ability) == 0)
            samba.onUseAbility(player, player, ability)
            assert(player.tp == 0)
            player:addStatusEffect(xi.effect.FAN_DANCE, {})
            assert(samba.onAbilityCheck(player, player, ability) == xi.msg.basic.UNABLE_TO_USE_JA2)
        end)
    end

    it('uses caster merits for Healing Waltz and the correct recast multiplier at every rank', function()
        player:addStatusEffect(xi.effect.FAN_DANCE, {})
        for rank = 1, 5 do
            player.merits[xi.merit.FAN_DANCE] = rank * 5
            ability.recast = 15
            assert(xi.actions.abilities.healing_waltz.onAbilityCheck(player, target, ability) == 0)
            assert(math.abs(ability.recast - 15 * (1 - (rank - 1) * 0.05)) < 0.0001)
            assert(ability.cleanup == xi.effect.CONTRADANCE)
        end
    end)

    it('caps Healing Waltz recast and schedules Contradance cleanup during Trance', function()
        player.tp = 0
        player:addStatusEffect(xi.effect.TRANCE, {})
        assert(xi.actions.abilities.healing_waltz.onAbilityCheck(player, target, ability) == 0)
        assert(ability.recast == 6)
        assert(ability.cleanup == xi.effect.CONTRADANCE)
    end)

    it('clamps negative Waltz recasts and costs to zero', function()
        player.tp = 0
        player.mods[xi.mod.WALTZ_DELAY] = -30
        player.mods[xi.mod.WALTZ_COST] = 100
        assert(xi.job_utils.dancer.checkWaltzAbility(player, target, ability) == 0)
        assert(ability.recast == 0)
        xi.job_utils.dancer.useWaltzAbility(player, target, ability, action)
        assert(player.tp == 0)
    end)

    it('rejects dead Waltz targets and Saber Dance even with Trance', function()
        player:addStatusEffect(xi.effect.TRANCE, {})
        target.hp = 0
        assert(xi.job_utils.dancer.checkWaltzAbility(player, target, ability) == xi.msg.basic.CANNOT_ON_THAT_TARG)
        target.hp = 1
        player:addStatusEffect(xi.effect.SABER_DANCE, {})
        assert(xi.actions.abilities.healing_waltz.onAbilityCheck(player, target, ability) == xi.msg.basic.UNABLE_TO_USE_JA2)
    end)

    it('charges Healing Waltz once for a multi-target Contradance', function()
        player:addStatusEffect(xi.effect.CONTRADANCE, {})
        xi.actions.abilities.healing_waltz.onUseAbility(player, target, ability, action)
        xi.actions.abilities.healing_waltz.onUseAbility(player, player, ability, action)
        assert(player.tp == 2800)
    end)

    it('keeps the main-job Waltz formula and divides only subjob stat scaling by three', function()
        assert(xi.job_utils.dancer.useWaltzAbility(player, target, ability, action) == 105 * xi.settings.main.CURE_POWER)
        player.job = xi.job.WAR
        assert(xi.job_utils.dancer.useWaltzAbility(player, target, ability, action) == 75 * xi.settings.main.CURE_POWER)
    end)

    it('charges Divine Waltz only on the first target', function()
        ability.id = xi.jobAbility.DIVINE_WALTZ
        xi.job_utils.dancer.useWaltzAbility(player, target, ability, action)
        xi.job_utils.dancer.useWaltzAbility(player, player, ability, action)
        assert(player.tp == 2600)
    end)

    it('honors Step TP reduction and retains the combat requirement', function()
        player.mods[xi.mod.STEP_TP_CONSUMED] = -40
        player.tp = 59
        assert(xi.job_utils.dancer.checkStepAbility(player, target, ability) == xi.msg.basic.NOT_ENOUGH_TP)
        player.tp = 60
        assert(xi.job_utils.dancer.checkStepAbility(player, target, ability) == 0)
        player.animation = 0
        assert(xi.job_utils.dancer.checkStepAbility(player, target, ability) == xi.msg.basic.REQUIRES_COMBAT)
    end)

    it('includes Step Accuracy merits without leaving a modifier behind', function()
        ability.id = xi.jobAbility.QUICKSTEP
        player.merits[xi.merit.STEP_ACCURACY] = 15
        player.mods[xi.mod.STEP_ACCURACY] = 8
        stub('xi.combat.physicalHitRate.getPhysicalHitRate', function(attacker, defender, accuracy)
            assert(accuracy == 33)
            return 1
        end)

        xi.job_utils.dancer.useStepAbility(player, target, ability, action, xi.effect.LETHARGIC_DAZE_1)
        assert(player:getMod(xi.mod.STEP_ACCURACY) == 8)
        assert(player:getStatusEffect(xi.effect.FINISHING_MOVE_1):getPower() == 2)
        assert(player.tp == 2900)
    end)

    it('restores Step Accuracy even if the wrapped calculation errors', function()
        ability.id = xi.jobAbility.QUICKSTEP
        player.merits[xi.merit.STEP_ACCURACY] = 15
        stub('xi.combat.physicalHitRate.getPhysicalHitRate', function()
            error('Deliberate test failure')
        end)

        assert(not pcall(xi.job_utils.dancer.useStepAbility, player, target, ability, action, xi.effect.LETHARGIC_DAZE_1))
        assert(player:getMod(xi.mod.STEP_ACCURACY) == 0)
    end)

    it('preserves finishing moves beyond the five Reverse Flourish consumes', function()
        player.tp = 0
        player.merits[xi.merit.REVERSE_FLOURISH_EFFECT] = 15
        player:addStatusEffect(xi.effect.FINISHING_MOVE_1, { power = 9 })
        assert(xi.job_utils.dancer.useReverseFlourishAbility(player, target, ability, action) == 750)
        assert(player.tp == 750)
        assert(player:getStatusEffect(xi.effect.FINISHING_MOVE_1):getPower() == 4)
    end)

    it('keeps Wild Flourish guaranteed to land without an accuracy roll', function()
        ability.id = xi.jobAbility.WILD_FLOURISH
        player:addStatusEffect(xi.effect.FINISHING_MOVE_1, { power = 2 })
        stub('xi.combat.physicalHitRate.getPhysicalHitRate', function()
            error('Wild Flourish must not roll accuracy')
        end)

        xi.job_utils.dancer.useWildFlourishAbility(player, target, ability, action)
        assert(target:hasStatusEffect(xi.effect.CHAINBOUND))
        assert(not player:hasStatusEffect(xi.effect.FINISHING_MOVE_1))
        assert(ability.message ~= xi.msg.basic.JA_MISS)
    end)

    it('does not award Closed Position accuracy from behind the enemy', function()
        player.merits[xi.merit.CLOSED_POSITION] = 15
        local frontAccuracy = xi.combat.physicalHitRate.getHitRateModifiers(player, target, false, false)
        target.facing = false
        local rearAccuracy = xi.combat.physicalHitRate.getHitRateModifiers(player, target, false, false)
        assert(frontAccuracy - rearAccuracy == 15)
    end)

    for _, damageMultiplier in ipairs({ 0, 0.5 }) do
        it('applies Violent Flourish damage reduction before Phalanx and Stoneskin: ' .. damageMultiplier, function()
            player:addStatusEffect(xi.effect.FINISHING_MOVE_1, { power = 2 })

            function player:getWeaponDmg()
                return 100
            end

            function player:getWeaponDamageType(slot)
                return 1
            end

            function target:physicalDmgTaken(damage, damageType)
                assert(damage == 100)
                assert(damageType == 1)
                return damage * damageMultiplier
            end

            function target:takeDamage(damage, attacker, attackType, damageType)
                self.damageTaken = damage
            end

            function target:updateEnmityFromDamage(attacker, damage)
                assert(damage == self.damageTaken)
            end

            function action:recordDamage(defender, attackType, damage)
                assert(damage == defender.damageTaken)
            end

            stub('xi.combat.physicalHitRate.getPhysicalHitRate', 1)
            stub('xi.data.levelCorrection.isLevelCorrectedZone', false)
            stub('xi.combat.physical.calculateMeleeStatFactor', 0)
            stub('xi.combat.physical.calculateMeleePDIF', 1)
            stub('utils.handlePhalanx', function(defender, damage)
                return math.max(0, damage - 10)
            end)

            stub('utils.handleStoneskin', function(defender, damage)
                return math.max(0, damage - 5)
            end)

            stub('xi.combat.magicHitRate.calculateResistRate', 1)
            stub('xi.data.statusEffect.isTargetImmune', false)
            stub('xi.data.statusEffect.isTargetResistant', false)
            stub('xi.data.statusEffect.isEffectNullified', false)
            stub('xi.data.statusEffect.isResistRateSuccessfull', true)
            local damage = xi.job_utils.dancer.useViolentFlourishAbility(player, target, ability, action)
            assert(damage == math.max(0, 100 * damageMultiplier - 15))
            assert(target.damageTaken == damage)
            assert(player:getStatusEffect(xi.effect.FINISHING_MOVE_1):getPower() == 1)
        end)
    end

    it('consumes a finishing move on a missed Violent Flourish without dealing damage', function()
        player:addStatusEffect(xi.effect.FINISHING_MOVE_1, { power = 1 })
        stub('xi.combat.physicalHitRate.getPhysicalHitRate', -1)
        assert(xi.job_utils.dancer.useViolentFlourishAbility(player, target, ability, action) == 0)
        assert(ability.message == xi.msg.basic.JA_MISS)
        assert(not player:hasStatusEffect(xi.effect.FINISHING_MOVE_1))
    end)

    it('stores Saber Dance floor and its exact applied modifiers on the effect', function()
        player.merits[xi.merit.SABER_DANCE] = 25
        player.warSubjob = true
        xi.actions.abilities.saber_dance.onUseAbility(player, player, ability)
        local effect = player:getStatusEffect(xi.effect.SABER_DANCE)
        local effectScripts = xi.effects
        effectScripts.saber_dance.onEffectGain(player, effect)
        assert(effect:getPower() == 50)
        assert(effect:getSubPower() == 22)
        for _ = 1, 20 do
            effectScripts.saber_dance.onEffectTick(player, effect)
        end

        assert(effect:getPower() == 22)
        assert(effect.mods[xi.mod.DOUBLE_ATTACK] == 12)
        assert(effect.mods[xi.mod.SAMBA_PDURATION] == 20)
        assert(player:getMod(xi.mod.DOUBLE_ATTACK) == 0)
    end)

    it('stores the full merit-scaled Fan Dance enmity on its effect', function()
        player.merits[xi.merit.FAN_DANCE] = 25
        player:addStatusEffect(xi.effect.HASTE_SAMBA, {})
        player:addStatusEffect(xi.effect.SABER_DANCE, {})
        xi.actions.abilities.fan_dance.onUseAbility(player, player, ability)
        local effect = player:getStatusEffect(xi.effect.FAN_DANCE)
        local effectScripts = xi.effects
        effectScripts.fan_dance.onEffectGain(player, effect)
        assert(effect:getPower() == 9500)
        assert(effect:getSubPower() == 40)
        assert(effect.mods[xi.mod.ENMITY] == 40)
        assert(not player:hasStatusEffect(xi.effect.HASTE_SAMBA))
        assert(not player:hasStatusEffect(xi.effect.SABER_DANCE))
    end)

    it('applies Chocobo Jig II movement and duration to each recipient', function()
        player.mods[xi.mod.JIG_DURATION] = 100
        target:addStatusEffect(xi.effect.WEIGHT, {})
        xi.actions.abilities.chocobo_jig.onUseAbility(player, target, ability)
        assert(not target:hasStatusEffect(xi.effect.WEIGHT))
        local effect = target:getStatusEffect(xi.effect.QUICKENING)
        assert(effect:getPower() == 10)
        assert(effect.duration == 180)
        assert(not player:hasStatusEffect(xi.effect.QUICKENING))
    end)

    it('resets Fan Dance to its original merit-scaled strength when recast', function()
        for rank = 1, 5 do
            player.merits[xi.merit.FAN_DANCE] = rank * 5
            player:addStatusEffect(xi.effect.FAN_DANCE, { power = 2000, subPower = 15 + rank * 5 })
            xi.actions.abilities.fan_dance.onUseAbility(player, player, ability)
            local effect = player:getStatusEffect(xi.effect.FAN_DANCE)
            assert(effect:getPower() == 7000 + rank * 500)
            assert(effect:getSubPower() == 15 + rank * 5)
            assert(effect.duration == 300)
        end
    end)
end)
