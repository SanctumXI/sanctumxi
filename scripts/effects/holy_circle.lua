-----------------------------------
-- xi.effect.HOLY_CIRCLE
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local divineSkill = target:getSkillLevel(xi.skill.DIVINE_MAGIC)
    local power = math.floor((divineSkill / 20) + 5)
    local jpValue = target:getJobPointLevel(xi.jp.HOLY_CIRCLE_EFFECT) -- Only affects damage received.

    target:addMod(xi.mod.UNDEAD_KILLER, effect:getPower())
    effect:addMod(xi.mod.UNDEAD_DMG_MULTIPLIER, effect:getPower())
    effect:addMod(xi.mod.UNDEAD_RES_MULTIPLIER, effect:getPower() + jpValue)

    -- Sanctum Custom effect (Disabled)
    -- effect:addMod(xi.mod.ENSPELL, xi.element.LIGHT)
    -- effect:addMod(xi.mod.ENSPELL_DMG, power)
    -- effect:addMod(xi.mod.ACC, 10)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.UNDEAD_KILLER, effect:getPower())
end

return effectObject
