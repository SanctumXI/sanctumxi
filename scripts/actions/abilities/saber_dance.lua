-----------------------------------
-- Ability: Saber Dance
-- Increases Double Attack rate but renders Waltz unusable. Double Attack rate gradually decreases.
-- Obtained: Dancer Level 75 Merit Group 2
-- Recast Time: 3 minutes
-- Duration: 5 minutes
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    local rank = player:getMerit(xi.merit.SABER_DANCE) / 5
    local startDA = 35 + 3 * rank
    local floorDA = 12 + 2 * rank

    player:addStatusEffect(xi.effect.SABER_DANCE, { power = startDA, subPower, floorDA, duration = 300, origin = player, tick = 3 })
end

return abilityObject
