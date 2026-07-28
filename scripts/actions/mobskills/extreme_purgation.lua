-----------------------------------
-- Extreme Purgation
-- Family: Sandworm
-- Description: Deals Wind damage to enemies within an area of effect.
--              Drains all buffs and debuffs from targets, transferring them to the user.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

-- Common buffs and debuffs eligible to be drained from the target and applied to the mob.
local transferableEffects =
{
    xi.effect.HASTE, xi.effect.BLINK, xi.effect.STONESKIN, xi.effect.AQUAVEIL, xi.effect.PROTECT,
    xi.effect.SHELL, xi.effect.REGEN, xi.effect.REFRESH, xi.effect.PHALANX,
    xi.effect.FLASH, xi.effect.BLINDNESS, xi.effect.ELEGY, xi.effect.REQUIEM, xi.effect.PARALYSIS,
    xi.effect.POISON, xi.effect.CURSE_I, xi.effect.CURSE_II, xi.effect.DISEASE, xi.effect.PLAGUE,
    xi.effect.WEIGHT, xi.effect.BIND, xi.effect.BIO, xi.effect.DIA, xi.effect.BURN, xi.effect.FROST,
    xi.effect.CHOKE, xi.effect.RASP, xi.effect.SHOCK, xi.effect.DROWN, xi.effect.STR_DOWN,
    xi.effect.DEX_DOWN, xi.effect.VIT_DOWN, xi.effect.AGI_DOWN, xi.effect.INT_DOWN, xi.effect.MND_DOWN,
    xi.effect.CHR_DOWN, xi.effect.ADDLE, xi.effect.SLOW, xi.effect.ACCURACY_DOWN, xi.effect.ATTACK_DOWN,
    xi.effect.EVASION_DOWN, xi.effect.DEFENSE_DOWN, xi.effect.MAGIC_ACC_DOWN, xi.effect.MAGIC_ATK_DOWN,
    xi.effect.MAGIC_EVASION_DOWN, xi.effect.MAGIC_DEF_DOWN,
}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 3.0, 3.0, 3.0 }
    params.element         = xi.element.WIND
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WIND
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        for _, effectId in ipairs(transferableEffects) do
            local statusEffect = target:getStatusEffect(effectId)

            if statusEffect then
                mob:addStatusEffect(effectId, { power = statusEffect:getPower(), duration = statusEffect:getDuration(), origin = mob, tick = statusEffect:getTick() })
                target:delStatusEffectSilent(effectId)
            end
        end
    end

    return info.damage
end

return mobskillObject
