-----------------------------------
-- Spell: Warm-Up
-- Enhances accuracy and gain regen
-- Spell cost: 59 MP
-- Monster Type: Beastmen
-- Spell Type: Magical (Earth)
-- Blue Magic Points: 4
-- Stat Bonus: DEX+1
-- Level: 68
-- Casting Time: 3 seconds
-- Recast Time: 56 seconds
-- Duration: 180 seconds
-----------------------------------
-- Combos: Clear Mind
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local duration = xi.spells.blue.calculateDurationWithDiffusion(caster, 180)
    local returnEffect = xi.effect.ACCURACY_BOOST

    local actionOne = target:addStatusEffect(xi.effect.ACCURACY_BOOST, { power = 15, duration = duration, origin = caster })
    local actionTwo = target:addStatusEffect(xi.effect.REGEN, { power = 5, duration = duration, origin = caster })

    if not actionOne and not actionTwo then -- both statuses fail to apply
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    elseif not actionOne and actionTwo then -- accuracy fails, but regen applies
        returnEffect = xi.effect.REGEN
    elseif actionOne and not actionTwo then -- regen fails, but accuracy applies
        returnEffect = xi.effect.ACCURACY_BOOST
    end

    return returnEffect
end

return spellObject
