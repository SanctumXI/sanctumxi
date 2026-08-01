-----------------------------------
-- xi.effect.ARCANE_CIRCLE
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
        local darkSkill = target:getSkillLevel(xi.skill.DARK_MAGIC)
    local power = math.floor((darkSkill / 20) + 5)

       effect:addMod(xi.mod.ARCANA_KILLER, effect:getPower())
    -- Sanctum Custom effect (Disabled)
    -- effect:addMod(xi.mod.ENSPELL, xi.element.DARK)
    -- effect:addMod(xi.mod.ENSPELL_DMG, power)
    -- effect:addMod(xi.mod.ATTP, 5)
 
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
