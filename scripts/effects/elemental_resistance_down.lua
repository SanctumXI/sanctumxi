-----------------------------------
-- xi.effect.ELEMENTAL_RESISTANCE_DOWN
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    if effect:getSubPower() == xi.element.ICE then
        target:addMod(xi.mod.ICE_MEVA, -effect:getPower())
        return
    end

    target:addMod(xi.mod.FIRE_MEVA, -effect:getPower())
    target:addMod(xi.mod.ICE_MEVA, -effect:getPower())
    target:addMod(xi.mod.WIND_MEVA, -effect:getPower())
    target:addMod(xi.mod.EARTH_MEVA, -effect:getPower())
    target:addMod(xi.mod.THUNDER_MEVA, -effect:getPower())
    target:addMod(xi.mod.WATER_MEVA, -effect:getPower())
    target:addMod(xi.mod.LIGHT_MEVA, -effect:getPower())
    target:addMod(xi.mod.DARK_MEVA, -effect:getPower())
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    if effect:getSubPower() == xi.element.ICE then
        target:delMod(xi.mod.ICE_MEVA, -effect:getPower())
        return
    end

    target:delMod(xi.mod.FIRE_MEVA, -effect:getPower())
    target:delMod(xi.mod.ICE_MEVA, -effect:getPower())
    target:delMod(xi.mod.WIND_MEVA, -effect:getPower())
    target:delMod(xi.mod.EARTH_MEVA, -effect:getPower())
    target:delMod(xi.mod.THUNDER_MEVA, -effect:getPower())
    target:delMod(xi.mod.WATER_MEVA, -effect:getPower())
    target:delMod(xi.mod.LIGHT_MEVA, -effect:getPower())
    target:delMod(xi.mod.DARK_MEVA, -effect:getPower())
end

return effectObject
