-----------------------------------
-- xi.effect.SLEEP_I
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    -- Immunobreak reset.
    target:setMod(xi.mod.SLEEP_IMMUNOBREAK, 0)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    if effect:getTier() >= 4 then
        local bioEffect = target:getStatusEffect(xi.effect.BIO)
        if bioEffect and bioEffect:getTier() >= 11 then
            target:delStatusEffect(xi.effect.BIO)
        end
    end
end

return effectObject
