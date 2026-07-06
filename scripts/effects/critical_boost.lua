-----------------------------------
-- xi.effect.CRITICAL_BOOST
-- DAT Error, CUSTOM EFFECT
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.CRITHITRATE, effect:getPower())
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
