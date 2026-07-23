-----------------------------------
-- Manafont (Automaton)
-- TODO: Implement JP Bonuses
-----------------------------------
---@type TAbilityAutomaton
local abilityObject = {}

abilityObject.onAutomatonAbilityCheck = function(target, automaton, skill)
    return 0
end

abilityObject.onAutomatonAbility = function(target, automaton, skill, master, action)
    skill:setMsg(xi.mobskills.mobBuffMove(automaton, xi.effect.MANAFONT, 1, 0, 60))

    return xi.effect.MANAFONT
end

return abilityObject
