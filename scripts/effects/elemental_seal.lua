-----------------------------------
-- xi.effect.ELEMENTAL_SEAL
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    -- Overwrites
    target:delStatusEffectSilent(xi.effect.DARK_SEAL)
    target:delStatusEffectSilent(xi.effect.DIVINE_EMBLEM)
    target:delStatusEffectSilent(xi.effect.DIVINE_SEAL)

    -- Sanctum Custom: Elemental Seal grants MAB by BLM level
    local blmLevel = utils.getActiveJobLevel(target, xi.job.BLM)

    if blmLevel >= 75 then
        effect:addMod(xi.mod.MATT, 10)
    elseif blmLevel >= 50 then
        effect:addMod(xi.mod.MATT, 5)
    end
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject