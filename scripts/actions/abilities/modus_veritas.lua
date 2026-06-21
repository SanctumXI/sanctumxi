-----------------------------------
-- Ability: Modus Veritas
-- Removes helix effect for elemental burst damage.
-- Obtained: Scholar Level 65
-- Recast Time: 3:00
-- Duration: Instant
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    local helix = target:getStatusEffect(xi.effect.HELIX)

    if helix == nil then
        ability:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        return 0
    end

    local mvPower = helix:getSubPower()
    local element = helix:getSubType()

    -- Prevent stacking / abuse.
    if mvPower > 0 then
        ability:setMsg(xi.msg.basic.JA_MISS)
        return 0
    end

    local skill   = xi.skill.ELEMENTAL_MAGIC
    local resist  = xi.combat.magicHitRate.calculateResistRate(
        player,
        target,
        0,
        skill,
        0,
        element,
        0,
        0,
        0
    )

    if resist < 0.25 then
        ability:setMsg(xi.msg.basic.JA_MISS)
        return 0
    end

    local tickMs       = helix:getTick()
    local remainingMs  = helix:getTimeRemaining()
    local remainingTicks = math.max(1, math.ceil(remainingMs / tickMs))
    local mvMerits = player:getMerit(xi.merit.MODUS_VERITAS_EFFECT)

    local damage = helix:getPower() * remainingTicks
    damage = damage * (1 + (0.05 * mvMerits))

    -- Optional JP bonus from original Modus Veritas effect.
    damage = damage + (3 * player:getJobPointLevel(xi.jp.MODUS_VERITAS_EFFECT))

    damage = math.floor(damage * resist)

    target:takeDamage(damage, player, xi.attackType.MAGICAL, element)
    target:updateEnmityFromDamage(player, damage)

    target:delStatusEffect(xi.effect.HELIX)

    ability:setMsg(xi.msg.basic.JA_DAMAGE)
    return damage
end
return abilityObject
