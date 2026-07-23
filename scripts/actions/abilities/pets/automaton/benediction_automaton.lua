-----------------------------------
-- Benediction (Automaton)
-- TODO: Implement JP Bonuses
-----------------------------------
---@type TAbilityAutomaton
local abilityObject = {}

local function isPartyTarget(automaton, target)
    if target:getID() == automaton:getID() then
        return true
    end

    local master = automaton:getMaster()
    if not master then
        return false
    end

    for _, partyMember in ipairs(master:getPartyWithTrusts()) do
        if partyMember:getID() == target:getID() then
            return true
        end
    end

    return false
end

abilityObject.onAutomatonAbilityCheck = function(target, automaton, skill)
    return 0
end

abilityObject.onAutomatonAbility = function(target, automaton, skill, master, action)
    -- Player-aligned pet AoE target finding includes every nearby allied player.
    -- Benediction should only affect the automaton and its master's party.
    if not isPartyTarget(automaton, target) then
        return 0
    end

    target:eraseAllStatusEffect()

    local maxHeal = target:getMaxHP() - target:getHP()

    target:addHP(maxHeal)
    target:wakeUp()

    skill:setMsg(xi.msg.basic.SELF_HEAL)

    return maxHeal
end

return abilityObject
