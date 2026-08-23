-----------------------------------
-- Ability: Light Shot
-- Consumes a Light Card to enhance light-based debuffs. Additional effect: Light-based Sleep
-- Dia Effect: Defense Down Effect +5% and DoT + 1
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    --ranged weapon/ammo: You do not have an appropriate ranged weapon equipped.
    --no card: <name> cannot perform that action.
    if
        player:getWeaponSkillType(xi.slot.RANGED) ~= xi.skill.MARKSMANSHIP or
        player:getWeaponSkillType(xi.slot.AMMO) ~= xi.skill.MARKSMANSHIP
    then
        return 216, 0
    end

    if
        player:hasItem(xi.item.LIGHT_CARD, 0) or
        player:hasItem(xi.item.TRUMP_CARD, 0)
    then
        return 0, 0
    else
        return 71, 0
    end
end

abilityObject.onUseAbility = function(player, target, ability, action)
    action:setRecast(math.max(0, action:getRecast() - player:getMod(xi.mod.QUICK_DRAW_RECAST)))
    local duration = 60
    local bonusAcc = player:getStat(xi.mod.AGI) / 2 + player:getMerit(xi.merit.QUICK_DRAW_ACCURACY) + player:getMod(xi.mod.QUICK_DRAW_MACC)
    local resist   = xi.combat.magicHitRate.calculateResistRate(player, target, 0, 0, 0, xi.element.LIGHT, 0, 0, bonusAcc)

    target:updateClaim(player)

    if resist < 0.5 then
        ability:setMsg(xi.msg.basic.JA_MISS_2) -- resist message
        return xi.effect.SLEEP_I
    end

    duration = duration * resist

    local effects = {}

    local dia = target:getStatusEffect(xi.effect.DIA)

    if dia ~= nil then
        table.insert(effects, dia)
    end

    local threnody = target:getStatusEffect(xi.effect.THRENODY)

    if threnody ~= nil and threnody:getSubPower() == xi.mod.DARK_MEVA then
        table.insert(effects, threnody)
    end

    if #effects > 0 then
        local effect         = effects[math.randomInt(1, #effects)]
        local effectDuration = effect:getDuration() / 1000
        local startTime      = effect:getStartTime()
        local tick           = effect:getTick() / 1000
        local power          = effect:getPower()
        local subpower       = effect:getSubPower()
        local tier           = effect:getTier()
        local effectId       = effect:getEffectType()
        local subId          = effect:getSubType()
        local originId       = effect:getOriginID()

        if effectId == xi.effect.DIA then
            power    = power + 1
            subpower = subpower + 5
        else
            power = power * 1.5
        end

        target:delStatusEffectSilent(effectId)
        target:addStatusEffect(effectId, { power = power, duration = effectDuration, origin = player, tick = tick, subType = subId, subPower = subpower, tier = tier })

        local newEffect = target:getStatusEffect(effectId)
        if newEffect then
            newEffect:setStartTime(startTime)
            newEffect:setOriginID(originId)
        end
    end

    if target:addStatusEffect(xi.effect.SLEEP_I, { power = 1, duration = duration, origin = player, subPower = xi.element.LIGHT }) then
        ability:setMsg(xi.msg.basic.JA_ENFEEB_IS)
    else
        ability:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
    end

    local _ = player:delItem(xi.item.LIGHT_CARD, 1) or player:delItem(xi.item.TRUMP_CARD, 1)
    return xi.effect.SLEEP_I
end

return abilityObject
