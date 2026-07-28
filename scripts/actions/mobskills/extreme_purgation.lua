-----------------------------------
-- Extreme Purgation
-- Family: Sandworm
-- Description: Deals Wind damage to enemies within an area of effect.
--              Drains all buffs and debuffs from targets, transferring them to the user.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

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

        -- Drain every dispelable/waltzable/erasable effect (buff or debuff) from the
        -- target onto the mob -- same approach as Contagion Transfer (Deadly Moa
        -- family). Uses copyStatusEffect rather than rebuilding addStatusEffect's
        -- params table by hand: getDuration()/getTick() return milliseconds, but
        -- addStatusEffect's duration/tick fields are read as seconds (and duration
        -- was the original full length, not what's left) -- passing them through
        -- directly was inflating both by ~1000x on the mob's copy.
        local availableEffects = {}
        for _, effect in pairs(target:getStatusEffects()) do
            local flags = effect:getEffectFlags()
            if bit.band(flags, bit.bor(xi.effectFlag.DISPELABLE, xi.effectFlag.WALTZABLE, xi.effectFlag.ERASABLE)) ~= 0 then
                table.insert(availableEffects, effect:getEffectType())
            end
        end

        for _, effectId in ipairs(availableEffects) do
            local statusEffect = target:getStatusEffect(effectId)

            if statusEffect then
                mob:copyStatusEffect(statusEffect)
                target:delStatusEffectSilent(effectId)
            end
        end
    end

    return info.damage
end

return mobskillObject
