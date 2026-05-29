---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local power = effect:getPower()
    local Level = target:getMainLvl()

    -- WAR-only custom bonuses
    if target:getMainJob() == xi.job.WAR then
        effect:addMod(xi.mod.PARRY, Level / 2)
        effect:addMod(xi.mod.EVA, Level / 2)
        effect:addMod(xi.mod.SHIELD, Level / 2)
        effect:addMod(xi.mod.VIT, Level / 4)
        effect:addMod(xi.mod.ATTP, -15)
        effect:addMod(xi.mod.DEFP, power)
    else
        effect:addMod(xi.mod.ATTP, -25)
        effect:addMod(xi.mod.DEFP, 25)
    end
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject