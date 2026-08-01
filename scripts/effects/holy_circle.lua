-----------------------------------
-- xi.effect.HOLY_CIRCLE
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local divineSkill = target:getSkillLevel(xi.skill.DIVINE_MAGIC)
    local power = math.floor((divineSkill / 20) + 5)

    target:addMod(xi.mod.UNDEAD_KILLER, effect:getPower())
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
