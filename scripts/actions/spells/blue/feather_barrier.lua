-----------------------------------
-- Spell: Feather Barrier
-- Enhances evasion
-- Spell cost: 25 MP
-- Monster Type: Birds
-- Spell Type: Magical (Wind)
-- Blue Magic Points: 2
-- Stat Bonus: None
-- Level: 56
-- Casting Time: 4 seconds
-- Recast Time: 60 seconds
-- Duration: 180 Seconds
-----------------------------------
-- Combos: Resist Gravity
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local power = 20
    local duration = xi.spells.blue.calculateDurationWithDiffusion(caster, 180)

    if not target:addStatusEffect(xi.effect.EVASION_BOOST, { power = power, duration = duration, origin = caster }) then
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    end

    return xi.effect.EVASION_BOOST
end

return spellObject
