-----------------------------------
-- xi.effect.BLUNT_TRAUMA
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local power = effect:getPower()

    effect:addMod(xi.mod.IMPACT_SDT, power)
    effect:addMod(xi.mod.HTH_SDT, power)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
