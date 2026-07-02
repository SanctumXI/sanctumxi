-----------------------------------
-- Spell: Memento Mori
-- Enhances magic attack
-- Spell cost: 50 MP
-- Monster Type: Undead
-- Spell Type: Magical (Ice)
-- Blue Magic Points: 4
-- Stat Bonus: INT+1
-- Level: 62
-- Casting Time: 3 seconds
-- Recast Time: 1 minute
-----------------------------------
-- Combos: Magic Attack Bonus
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local power = 30
    local duration = xi.spells.blue.calculateDurationWithDiffusion(caster, 10)

    if not target:addStatusEffect(xi.effect.MAGIC_ATK_BOOST, { power = power, duration = duration, origin = caster }) then
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    end

    return xi.effect.MAGIC_ATK_BOOST
end

return spellObject
