-----------------------------------
-- xi.effect.COUNTERSTANCE
-- Custom effects for Sanctum
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    if target:isMob() and target:getFamily() == xi.mobSpecies.BUGBEAR then -- Bugbear Family
        effect:addMod(xi.mod.ATTP, 15)
    end

        -- Custom penalty: Attack delay +20%
    effect:addMod(xi.mod.DELAYP, 20)
    effect:addMod(xi.mod.ENMITY_LOSS_REDUCTION, 30)
    effect:addMod(xi.mod.COUNTER, effect:getPower())

end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject