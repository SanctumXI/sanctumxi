-----------------------------------
-- xi.effect.STEALTH_SHOT
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
local sbPower = (target:getMerit(xi.merit.STEALTH_SHOT) / 10) * 3

    effect:addMod(xi.mod.ENMITY, -target:getMerit(xi.merit.STEALTH_SHOT))
    effect:addMod(xi.mod.SUBTLE_BLOW, sbPower)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
