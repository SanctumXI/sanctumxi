-----------------------------------
-- xi.effect.RETALIATION
-- Allows you to counterattack but reduces movement speed.
-- Unlike counter, grants TP like a regular melee attack.
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect, player)
    local boost = target:getMerit(xi.merit.RETALIATION_DAMAGE)
    effect:addMod(xi.mod.MOVE_SPEED_WEIGHT_PENALTY, 8)
    effect:addMod(xi.mod.RETALIATION, boost)

end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)

end

return effectObject
