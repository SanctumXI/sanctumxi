-----------------------------------
-- xi.effect.SUBLIMATION_COMPLETE
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:delStatusEffect(xi.effect.REFRESH)

    local merits = target:getMerit(xi.merit.SUBLIMATION_EFFECT) / 10
    local bonus    = merits * 2

    effect:addMod(xi.mod.MATT, bonus)
    effect:addMod(xi.mod.CURE_POTENCY_II, bonus)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)

end

return effectObject