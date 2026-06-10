-----------------------------------
-- xi.effect.HOLY_CIRCLE
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.UNDEAD_KILLER, effect:getPower())

    effect:addMod(xi.mod.ENSPELL, xi.element.LIGHT)
    effect:addMod(xi.mod.ENSPELL_DMG, 15)
    effect:addMod(xi.mod.ACC, 10)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.UNDEAD_KILLER, effect:getPower())
end

return effectObject
