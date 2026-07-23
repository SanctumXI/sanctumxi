-----------------------------------
-- Invincible (Automaton)
-- TODO: Implement JP Bonuses
-----------------------------------
---@type TAbilityAutomaton
local abilityObject = {}

abilityObject.onAutomatonAbilityCheck = function(target, automaton, skill)
    return 0
end

abilityObject.onAutomatonAbility = function(target, automaton, skill, master, action)
    skill:setMsg(xi.mobskills.mobBuffMove(automaton, xi.effect.INVINCIBLE, 1, 0, 30))

    local currentTarget = automaton:getTarget()
    if currentTarget then
        currentTarget:addEnmity(automaton, 0, 7200)
    end

    return xi.effect.INVINCIBLE
end

return abilityObject
