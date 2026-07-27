-----------------------------------
-- Ability: Dark Seal
-- Description: Enhances the accuracy of your next dark magic spell.
-- Obtained: Dark Knight Level 75
-- Recast Time: 00:05:00
-- Duration: 30 seconds.
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    -- The first merit unlocks Dark Seal; merits 2–5 reduce recast by 30 seconds each.
    local meritReduction = math.max(0, player:getMerit(xi.merit.DARK_SEAL) - 30)
    ability:setRecast(math.max(0, ability:getRecast() - meritReduction))
    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability, action)
    return xi.job_utils.dark_knight.useDarkSeal(player, target, ability, action) 
end

return abilityObject
