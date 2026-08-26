-----------------------------------
-- Sanctum Dancer adjustments
-----------------------------------
require('modules/module_utils')
-----------------------------------

xi.module.ensureTable('xi.effects.saber_dance')
xi.module.ensureTable('xi.effects.fan_dance')
xi.module.ensureTable('xi.effects.drain_daze')
xi.module.ensureTable('xi.effects.aspir_daze')

local m = Module:new('sanctum_dancer')

local waltzAbilities =
{
    [xi.jobAbility.CURING_WALTZ    ] = { 200, 0.25,  60 },
    [xi.jobAbility.CURING_WALTZ_II ] = { 350, 0.50, 130 },
    [xi.jobAbility.CURING_WALTZ_III] = { 500, 0.75, 270 },
    [xi.jobAbility.CURING_WALTZ_IV ] = { 650, 1.00, 450 },
    [xi.jobAbility.CURING_WALTZ_V  ] = { 800, 1.25, 600 },
    [xi.jobAbility.DIVINE_WALTZ    ] = { 400, 0.25,  60 },
    [xi.jobAbility.DIVINE_WALTZ_II ] = { 800, 0.75, 270 },
}

local function overrideSambaCost(abilityName, currentCost, newCost)
    local abilityPath = 'xi.actions.abilities.' .. abilityName

    m:addOverride(abilityPath .. '.onAbilityCheck', function(player, target, ability)
        if player:hasStatusEffect(xi.effect.FAN_DANCE) then
            return xi.msg.basic.UNABLE_TO_USE_JA2, 0
        elseif
            not player:hasStatusEffect(xi.effect.TRANCE) and
            player:getTP() < newCost
        then
            return xi.msg.basic.NOT_ENOUGH_TP, 0
        end

        return 0, 0
    end)

    m:addOverride(abilityPath .. '.onUseAbility', function(player, target, ability)
        local result = super(player, target, ability)

        if not player:hasStatusEffect(xi.effect.TRANCE) then
            player:delTP(newCost - currentCost)
        end

        return result
    end)
end

overrideSambaCost('haste_samba', 350, 400)
overrideSambaCost('drain_samba', 100, 200)
overrideSambaCost('drain_samba_ii', 250, 300)
overrideSambaCost('aspir_samba', 100, 200)
overrideSambaCost('aspir_samba_ii', 250, 400)

local function checkWaltz(player, target, ability, baseCost)
    local cost = math.max(0, baseCost - player:getMod(xi.mod.WALTZ_COST) * 10)

    if target:getHP() == 0 then
        return xi.msg.basic.CANNOT_ON_THAT_TARG, 0
    elseif player:hasStatusEffect(xi.effect.SABER_DANCE) then
        return xi.msg.basic.UNABLE_TO_USE_JA2, 0
    elseif player:hasStatusEffect(xi.effect.TRANCE) then
        ability:setRecast(math.min(ability:getRecast(), 6))
    elseif player:getTP() < cost then
        return xi.msg.basic.NOT_ENOUGH_TP, 0
    else
        local recast = math.max(0, ability:getRecast() + player:getMod(xi.mod.WALTZ_DELAY))
        local merits = player:getMerit(xi.merit.FAN_DANCE)

        if player:hasStatusEffect(xi.effect.FAN_DANCE) and merits > 5 then
            recast = recast * (105 - merits) / 100
        end

        ability:setRecast(recast)
    end

    ability:setPostActionCleanupEffect(xi.effect.CONTRADANCE)

    return 0, 0
end

m:addOverride('xi.job_utils.dancer.checkWaltzAbility', function(player, target, ability)
    return checkWaltz(player, target, ability, waltzAbilities[ability:getID()][1])
end)

m:addOverride('xi.job_utils.dancer.useWaltzAbility', function(player, target, ability, action)
    local abilityId      = ability:getID()
    local waltzInfo      = waltzAbilities[abilityId]
    local waltzCost      = math.max(0, waltzInfo[1] - player:getMod(xi.mod.WALTZ_COST) * 10)
    local statMultiplier = waltzInfo[2]

    if
        not player:hasStatusEffect(xi.effect.TRANCE) and
        action:getPrimaryTargetID() == target:getID()
    then
        player:delTP(waltzCost)
    end

    if player:getMainJob() ~= xi.job.DNC then
        statMultiplier = statMultiplier / 3
    end

    local amtCured = (target:getStat(xi.mod.VIT) + player:getStat(xi.mod.CHR)) * statMultiplier + waltzInfo[3]
    amtCured       = math.floor(amtCured * (1 + math.min(50, player:getMod(xi.mod.WALTZ_POTENCY)) / 100))

    if player:hasStatusEffect(xi.effect.CONTRADANCE) then
        amtCured = amtCured * 2
    end

    amtCured = amtCured * xi.settings.main.CURE_POWER
    amtCured = math.min(amtCured, target:getMaxHP() - target:getHP())

    target:restoreHP(amtCured)
    target:wakeUp()
    player:updateEnmityFromCure(target, amtCured)

    return amtCured
end)

m:addOverride('xi.actions.abilities.healing_waltz.onAbilityCheck', function(player, target, ability)
    return checkWaltz(player, target, ability, 200)
end)

m:addOverride('xi.actions.abilities.healing_waltz.onUseAbility', function(player, target, ability, action)
    if
        not player:hasStatusEffect(xi.effect.TRANCE) and
        action:getPrimaryTargetID() == target:getID()
    then
        player:delTP(math.max(0, 200 - player:getMod(xi.mod.WALTZ_COST) * 10))
    end

    local effect = target:healingWaltz()
    ability:setMsg(effect == xi.effect.NONE and xi.msg.basic.NO_EFFECT or xi.msg.basic.JA_REMOVE_EFFECT)

    return effect
end)

m:addOverride('xi.job_utils.dancer.checkStepAbility', function(player, target, ability)
    if player:getAnimation() ~= 1 then
        return xi.msg.basic.REQUIRES_COMBAT, 0
    elseif
        not player:hasStatusEffect(xi.effect.TRANCE) and
        player:getTP() < math.max(0, 100 + player:getMod(xi.mod.STEP_TP_CONSUMED))
    then
        return xi.msg.basic.NOT_ENOUGH_TP, 0
    end

    return 0, 0
end)

m:addOverride('xi.job_utils.dancer.useStepAbility', function(player, target, ability, action, stepEffect)
    local accuracy = player:getMerit(xi.merit.STEP_ACCURACY)
    player:addMod(xi.mod.STEP_ACCURACY, accuracy)

    local success, result = pcall(super, player, target, ability, action, stepEffect)
    player:delMod(xi.mod.STEP_ACCURACY, accuracy)

    if not success then
        error(result)
    end

    return result
end)

m:addOverride('xi.job_utils.dancer.useReverseFlourishAbility', function(player, target, ability, action)
    local remainingMoves = math.max(0, player:getStatusEffect(xi.effect.FINISHING_MOVE_1):getPower() - 5)
    local result         = super(player, target, ability, action)

    if remainingMoves > 0 then
        local icon = remainingMoves <= 5 and xi.effect.FINISHING_MOVE_1 + remainingMoves - 1 or xi.effect.FINISHING_MOVE_6
        player:addStatusEffect(xi.effect.FINISHING_MOVE_1, { power = remainingMoves, duration = 7200, origin = player, icon = icon })
    end

    return result
end)

m:addOverride('xi.job_utils.dancer.useViolentFlourishAbility', function(player, target, ability, action)
    local finishingEffect = player:getStatusEffect(xi.effect.FINISHING_MOVE_1)
    local remainingMoves  = finishingEffect:getPower() - 1
    local hitRate         = xi.combat.physicalHitRate.getPhysicalHitRate(player, target, 100, xi.attackAnimation.RIGHT_ATTACK, false)

    if remainingMoves == 0 then
        player:delStatusEffect(xi.effect.FINISHING_MOVE_1)
    else
        finishingEffect:setPower(remainingMoves)
        finishingEffect:setIcon(remainingMoves <= 5 and xi.effect.FINISHING_MOVE_1 + remainingMoves - 1 or xi.effect.FINISHING_MOVE_6)
        finishingEffect:setDuration(7200000)
    end

    if
        math.randomFloat(0, 1) > hitRate and
        not (player:hasStatusEffect(xi.effect.SNEAK_ATTACK) and player:isBehind(target))
    then
        ability:setMsg(xi.msg.basic.JA_MISS)
        action:info(target:getID(), 3)
        return 0
    end

    local weaponType   = player:getWeaponSkillType(xi.slot.MAIN)
    local weaponDamage = player:getWeaponDmg()
    local damageType   = player:getWeaponDamageType(xi.slot.MAIN)

    if weaponType == xi.skill.HAND_TO_HAND then
        weaponDamage = weaponDamage + player:getSkillLevel(xi.skill.HAND_TO_HAND) * 0.11
    end

    local levelCorrection = xi.data.levelCorrection.isLevelCorrectedZone(player)
    local baseDamage      = weaponDamage + xi.combat.physical.calculateMeleeStatFactor(player, target)
    local pdif            = xi.combat.physical.calculateMeleePDIF(player, target, weaponType, 1, false, levelCorrection, false, 0, false, xi.slot.MAIN, false)
    local damage          = target:physicalDmgTaken(baseDamage * pdif, damageType)

    damage = utils.handlePhalanx(target, damage)
    damage = utils.handleStoneskin(target, damage)
    target:takeDamage(damage, player, xi.attackType.PHYSICAL, damageType)
    target:updateEnmityFromDamage(player, damage)
    action:recordDamage(target, xi.attackType.PHYSICAL, damage)

    local bonusMacc  = player:getMod(xi.mod.VFLOURISH_MACC)
    local resistRate = xi.combat.magicHitRate.calculateResistRate(player, target, 0, 0, xi.skillRank.A_PLUS, xi.element.THUNDER, xi.mod.INT, xi.effect.STUN, bonusMacc)

    if
        not xi.data.statusEffect.isTargetImmune(target, xi.effect.STUN, xi.element.THUNDER) and
        not xi.data.statusEffect.isTargetResistant(player, target, xi.effect.STUN) and
        not xi.data.statusEffect.isEffectNullified(target, xi.effect.STUN, 0) and
        xi.data.statusEffect.isResistRateSuccessfull(xi.effect.STUN, resistRate, 0)
    then
        target:addStatusEffect(xi.effect.STUN, { power = 1, duration = 2, origin = player })
    else
        ability:setMsg(xi.msg.basic.JA_DAMAGE)
    end

    local animations = { [0] = 25, 25, 26, 24, 29, 26, 28, 28, 30, 27, 32, 27, 23 }
    action:setAnimation(target:getID(), animations[weaponType] or 0)
    action:info(target:getID(), 7)

    return damage
end)

m:addOverride('xi.combat.physicalHitRate.getHitRateModifiers', function(attacker, target, isWeaponskill, isRanged)
    local accuracy, evasion = super(attacker, target, isWeaponskill, isRanged)

    if
        not isRanged and
        attacker:isPC() and
        attacker:isFacing(target) and
        not target:isFacing(attacker)
    then
        accuracy = accuracy - attacker:getMerit(xi.merit.CLOSED_POSITION)
    end

    return accuracy, evasion
end)

m:addOverride('xi.actions.abilities.saber_dance.onUseAbility', function(player, target, ability)
    local rank    = player:getMerit(xi.merit.SABER_DANCE) / 5
    local startDA = 35 + 3 * rank
    local floorDA = 12 + 2 * rank

    player:addStatusEffect(xi.effect.SABER_DANCE, { power = startDA, subPower = floorDA, duration = 300, origin = player, tick = 3 })

    return xi.effect.SABER_DANCE
end)

m:addOverride('xi.effects.saber_dance.onEffectGain', function(target, effect)
    local merits = target:getMerit(xi.merit.SABER_DANCE)

    if effect:getSubPower() == 0 then
        effect:setSubPower(12 + 2 * merits / 5)
    end

    effect:addMod(xi.mod.SAMBA_PDURATION, math.max(0, merits - 5))

    if target:hasTrait(xi.trait.DOUBLE_ATTACK) then
        effect:addMod(xi.mod.DOUBLE_ATTACK, -10)
    end

    effect:addMod(xi.mod.DOUBLE_ATTACK, effect:getPower())
    target:delStatusEffect(xi.effect.FAN_DANCE)
end)

m:addOverride('xi.effects.saber_dance.onEffectTick', function(target, effect)
    local power    = effect:getPower()
    local newPower = math.max(effect:getSubPower(), power - 3)

    if newPower < power then
        effect:addMod(xi.mod.DOUBLE_ATTACK, newPower - power)
        effect:setPower(newPower)
    end
end)

m:addOverride('xi.effects.saber_dance.onEffectLose', function(target, effect)
end)

m:addOverride('xi.actions.abilities.fan_dance.onUseAbility', function(player, target, ability)
    local merits = player:getMerit(xi.merit.FAN_DANCE)

    player:addStatusEffect(xi.effect.FAN_DANCE, { power = 7000 + merits * 100, subPower = 15 + merits, duration = 300, origin = player })

    return xi.effect.FAN_DANCE
end)

m:addOverride('xi.effects.fan_dance.onEffectGain', function(target, effect)
    if effect:getSubPower() == 0 then
        effect:setSubPower(15 + target:getMerit(xi.merit.FAN_DANCE))
    end

    target:delStatusEffect(xi.effect.HASTE_SAMBA)
    target:delStatusEffect(xi.effect.ASPIR_SAMBA)
    target:delStatusEffect(xi.effect.DRAIN_SAMBA)
    target:delStatusEffect(xi.effect.SABER_DANCE)
    effect:addMod(xi.mod.ENMITY, effect:getSubPower())
end)

m:addOverride('xi.effects.fan_dance.onEffectLose', function(target, effect)
end)

m:addOverride('xi.effects.drain_daze.onEffectGain', function(target, effect)
    effect:addMod(xi.mod.ATTP, -10)
end)

m:addOverride('xi.effects.drain_daze.onEffectLose', function(target, effect)
end)

m:addOverride('xi.effects.aspir_daze.onEffectGain', function(target, effect)
    effect:addMod(xi.mod.MATT, -10)
end)

m:addOverride('xi.actions.abilities.chocobo_jig.onUseAbility', function(player, target, ability)
    local baseDuration       = 120 + player:getJobPointLevel(xi.jp.JIG_DURATION)
    local durationMultiplier = 1 + utils.clamp(player:getMod(xi.mod.JIG_DURATION), 0, 50) / 100
    local finalDuration      = math.floor(baseDuration * durationMultiplier)

    if target:hasStatusEffect(xi.effect.WEIGHT) then
        target:delStatusEffect(xi.effect.WEIGHT)
    end

    target:addStatusEffect(xi.effect.QUICKENING, { power = 10, duration = finalDuration, origin = player })

    return xi.effect.QUICKENING
end)

return m
