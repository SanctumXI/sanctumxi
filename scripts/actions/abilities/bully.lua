-----------------------------------
-- Ability: Bully
-- Raises critical hit rate for party 5%
-- Obtained: Thief Level 50
-- Recast Time: 5:00
-- Duration: 2:00
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    return xi.job_utils.thief.useBully(player, target, ability)
end

return abilityObject
