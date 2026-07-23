-----------------------------------
-- Mighty Strikes (Automaton)
-- TODO: Implement JP Bonuses
-----------------------------------
---@type TAbilityAutomaton
local abilityObject = {}

abilityObject.onAutomatonAbilityCheck = function(target, automaton, skill)
    return 0
end

abilityObject.onAutomatonAbility = function(target, automaton, skill, master, action)
    skill:setMsg(xi.mobskills.mobBuffMove(automaton, xi.effect.MIGHTY_STRIKES, 1, 0, 45))

    return xi.effect.MIGHTY_STRIKES
end

return abilityObject
