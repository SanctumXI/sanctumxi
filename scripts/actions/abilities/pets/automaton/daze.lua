-----------------------------------
-- Daze
-- Description: Delivers a single attack. Damage varies with TP. Additional Effect: Stun.
-----------------------------------
---@type TAbilityAutomaton
local abilityObject = {}

abilityObject.onAutomatonAbilityCheck = function(target, automaton, skill)
    local master = automaton:getMaster()

    if not master then
        return
    end

    return master:countEffect(xi.effect.THUNDER_MANEUVER)
end

abilityObject.onAutomatonAbility = function(target, automaton, skill, master, action)
    local params = {}

    params.baseDamage       = xi.automaton.getRangedBaseDamage(automaton)
    params.numHits          = 1
    params.fTP              = { 5.0, 5.5, 6.0 }
    params.dex_wSC          = 0.60
    params.accuracyModifier = { 150, 150, 150 }
    params.attackType       = xi.attackType.RANGED
    params.damageType       = xi.damageType.PIERCING
    params.shadowBehavior   = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.skipParry        = true
    params.skipGuard        = true
    params.skipBlock        = true

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.fTP     = { 6.0, 8.5, 11.0 }
    end

    xi.automaton.applyFlameHolder(automaton, params.fTP)

    if damage > 0 then
        local chance = 0.033 * skill:getTP()
        if
            not target:hasStatusEffect(xi.effect.STUN) and
            chance >= math.randomFloat(0, 1) * 100
        then
            target:addStatusEffect(xi.effect.STUN, { power = 1, duration = 4, origin = automaton })
        end
    end

    return info.damage
end

return abilityObject
