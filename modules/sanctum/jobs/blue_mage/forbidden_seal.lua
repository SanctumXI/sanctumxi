-----------------------------------
-- Sanctum Blue Mage Forbidden Seal
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_forbidden_seal')

xi.effect.FORBIDDEN_SEAL     = 514
xi.jobAbility.FORBIDDEN_SEAL = xi.jobAbility.UNBRIDLED_WISDOM

m:addOverride('xi.actions.abilities.unbridled_wisdom.onAbilityCheck', function(player, target, ability)
    if player:hasStatusEffect(xi.effect.FORBIDDEN_SEAL) then
        return xi.msg.basic.EFFECT_ALREADY_ACTIVE, 0
    end

    return 0, 0
end)

m:addOverride('xi.actions.abilities.unbridled_wisdom.onUseAbility', function(player, target, ability, action)
    player:addStatusEffect(xi.effect.FORBIDDEN_SEAL,
    {
        power    = 1,
        duration = 60,
        origin   = player,
        icon     = xi.effect.UNBRIDLED_WISDOM,
    })

    return xi.effect.UNBRIDLED_WISDOM
end)

m:addOverride('xi.effects.unbridled_wisdom.onEffectGain', function(target, effect)
    if effect:getEffectType() ~= xi.effect.FORBIDDEN_SEAL then
        super(target, effect)
    end
end)

m:addOverride('xi.effects.unbridled_wisdom.onEffectLose', function(target, effect)
    if effect:getEffectType() ~= xi.effect.FORBIDDEN_SEAL then
        super(target, effect)
    end
end)

return m
