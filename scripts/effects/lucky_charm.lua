-----------------------------------
-- xi.effect.LUCKY_CHARM
-- Sanctum: critical hit rate granted by the Ladybug jug pet.
-- Runtime definition lives in modules/sanctum/data/status_effects.yaml.
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
