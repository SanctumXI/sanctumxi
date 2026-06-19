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

abilityObject.onUseAbility = function(player, target, ability)
    local pet = player:getPet()

    if pet == nil then
    return
end

    local playerTP = player:getTP()
    local petTP = pet:getTP()

    player:setTP(petTP)
    pet:setTP(playerTP)

end

return abilityObject
