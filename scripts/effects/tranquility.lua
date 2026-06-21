-----------------------------------
-- xi.effect.TRANQUILITY
-----------------------------------
---@type TEffect
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local power = target:getMerit(xi.merit.TRANQUILITY) / 5

    target:addMod(xi.mod.CURE_POTENCY, power)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.CURE_POTENCY, effect:getPower())
end

return effectObject