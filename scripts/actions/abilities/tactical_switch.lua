-----------------------------------
-- Ability: Tactical Switch
-- Description: Swaps TP of master and automaton.
-- Obtained: PUP Level 75 MERIT
-- Recast Time: 00:05:00
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    local meritReduction = player:getMerit(xi.merit.TACTICAL_SWITCH)
    ability:setRecast(ability:getRecast() - meritReduction)
end

abilityObject.onUseAbility = function(player, target, ability, action)
    return xi.job_utils.puppetmaster.onAbilityUseTacticalSwitch(player, target, ability, action)
end

return abilityObject
