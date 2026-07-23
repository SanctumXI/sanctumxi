-----------------------------------
-- Bone Crusher
-- Description: Delivers a threefold attack. Additional Effect: Stun.
-----------------------------------
---@type TAbilityAutomaton
local abilityObject = {}

abilityObject.onAutomatonAbilityCheck = function(target, automaton, skill)
    local master = automaton:getMaster()

    if not master then
        return
    end

    return master:countEffect(xi.effect.LIGHT_MANEUVER)
end

abilityObject.onAutomatonAbility = function(target, automaton, skill, master, action)
    local params = {}

    params.baseDamage     = automaton:getWeaponDmg()
    params.numHits        = utils.clamp(3 + xi.automaton.getExtraHits(automaton, 3), 1, 8)
    params.fTP            = { 1.5, 1.5, 1.5 }
    params.vit_wSC        = 0.60
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = params.numHits

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.fTP = { 2.66, 2.66, 2.66 }

        if target:isUndead() then
            params.fTP = { 3.66, 3.66, 3.66 }
        end
    else
        if target:isUndead() then
            params.fTP = { 2.5, 2.5, 2.5 }
        end
    end

    xi.automaton.applyFlameHolder(automaton, params.fTP)

    local info = xi.mobskills.mobPhysicalMove(automaton, target, skill, action, params)

    if xi.mobskills.processDamage(automaton, target, skill, action, info) then
        target:takeDamage(info.damage, automaton, info.attackType, info.damageType)

        local chance = 0.033 * skill:getTP()
        if
            info.damage > 0 and
            not target:hasStatusEffect(xi.effect.STUN) and
            chance >= math.randomFloat(0, 1) * 100
        then
            xi.mobskills.mobStatusEffectMove(automaton, target, xi.effect.STUN, 1, 0, 4)
        end
    end

    return info.damage
end

return abilityObject
