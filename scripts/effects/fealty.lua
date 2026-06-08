-----------------------------------
-- xi.effect.FEALTY
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)

    local power = target:getMerit(xi.merit.FEALTY) - 15
        effect:addMod(xi.mod.DMGMAGIC_II, -(power * 100))

end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
