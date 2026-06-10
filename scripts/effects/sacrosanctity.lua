-----------------------------------
-- xi.effect.SACROSANCTITY
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.MDEF, 50)
    target:addMod(xi.mod.REGAIN, 15)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.MDEF, 50)
    target:delMod(xi.mod.REGAIN, 15)
end

return effectObject
