-----------------------------------
-- Ability: Chakra
-- Cures certain status effects and restores a small amount of HP to user.
-- Obtained: Monk Level 35
-- Recast Time: 5:00
-- Duration: Instant
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    -- Chakra must remain usable through Paralyze and cleanse it when activated.
    -- The core also exempts Chakra from the paralysis interruption roll.
    player:delStatusEffect(xi.effect.PARALYSIS)

    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    return xi.job_utils.monk.useChakra(player, target, ability)
end

return abilityObject
