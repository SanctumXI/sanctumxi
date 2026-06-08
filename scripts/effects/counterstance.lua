-----------------------------------
-- xi.effect.COUNTERSTANCE
-- Custom effects for Sanctum
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    if target:isMob() and target:getFamily() == 59 then -- Bugbear Family
        effect:addMod(xi.mod.ATTP, 15)
    end

        -- Custom penalty: Attack delay +15%
    effect:addMod(xi.mod.DELAYP, 15)
    effect:addMod(xi.mod.ENMITY_LOSS_REDUCTION, 25)
    effect:addMod(xi.mod.COUNTER, effect:getPower())

    -- Lv. 60+ bonus: Defense +10%
    local level = target:getMainLvl()
    if level >= 60 then
        effect:addMod(xi.mod.DEFENSE_BOOST, 10)
    end
    
    -- Lv. 75+ bonus: Counter rate +5
    if level >= 75 then
        effect:addMod(xi.mod.COUNTER, 5)
    end

end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject