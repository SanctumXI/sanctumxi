-----------------------------------
-- Spell: Healing Breeze
-- Restores HP for party members within area of effect
-- Spell cost: 60 MP
-- Monster Type: Beasts
-- Spell Type: Magical (Wind)
-- Blue Magic Points: 4
-- Stat Bonus: CHR+2, HP+10
-- Level: 16
-- Casting Time: 4.5 seconds
-- Recast Time: 20 seconds
-----------------------------------
-- Combos: Auto Regen
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local params = {}
    params.minCure = 80
    params.divisor0 = 1
    params.constant0 = 20
    params.powerThreshold1 = 150
    params.divisor1 = 2.049
    params.constant1 = 58.4
    params.powerThreshold2 = 400
    params.divisor2 = 6.383
    params.constant2 = 124.667

    return xi.spells.blue.useCuringSpell(caster, target, spell, params)
end

return spellObject
