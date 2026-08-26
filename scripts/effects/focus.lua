-----------------------------------
-- xi.effect.FOCUS
-- Note: Glanzfaust bonus is implemented as a latent effect while wearing the equipment and having the effect
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local bonusPower = effect:getPower()
    local monkLevel = utils.getActiveJobLevel(target, xi.job.MNK)

    -- Accuracy
    effect:addMod(xi.mod.ACC, (monkLevel +1) + bonusPower)

    -- Critical Hit Rate
    effect:addMod(xi.mod.CRITHITRATE, math.floor(monkLevel +1) * 0.2)

    -- Sanctum Custom: Focus grants haste at level 40+
    if monkLevel >= 40 then
        effect:addMod(xi.mod.HASTE_ABILITY, 500) -- 500 = 5%
    end
        -- Sanctum Custom: Focus lowers defense
    effect:addMod(xi.mod.DEFP, -15)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject