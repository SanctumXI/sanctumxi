-----------------------------------
-- xi.effect.IRON_GUARD
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.ADDITIVE_GUARD, 25)

    -- Iron Guard Merits reduce your enmity loss
    local merit = target:getMerit(xi.merit.IRON_GUARD_EFFECT)
    if merit > 0 then
        effect:addMod(xi.mod.ENMITY_LOSS_REDUCTION, merit)
    end
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
