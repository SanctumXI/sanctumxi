-----------------------------------
-- Spell: Sub-zero Smash
-- Additional Effect: Paralysis. Damage varies with TP
-- Spell cost: 146 MP
-- Monster Type: Aquans
-- Spell Type: Physical (Ice)
-- Blue Magic Points: 4
-- Stat Bonus: HP+10 VIT+3
-- Level: 72
-- Casting Time: 3 seconds
-- Recast Time: 35 seconds
-- Skillchain Element(s): Fragmentation
-- Combos: Fast Cast
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local params = {}
    params.ecosystem  = xi.ecosystem.AQUAN
    params.tpmod      = xi.spells.blue.tpMod.DAMAGE
    params.attackType = xi.attackType.PHYSICAL
    params.damageType = xi.damageType.ICE
    params.scattr     = xi.skillchainType.FRAGMENTATION
    params.attribute  = xi.mod.INT
    params.skillType  = xi.skill.BLUE_MAGIC
    params.numhits    = 1
    params.multiplier = 2.0
    params.tp150      = 2.0
    params.tp300      = 2.0
    params.azuretp    = 2.0
    params.duppercap  = 72
    params.str_wsc    = 0.0
    params.dex_wsc    = 0.2
    params.vit_wsc    = 0.0
    params.agi_wsc    = 0.2
    params.int_wsc    = 0.3
    params.mnd_wsc    = 0.0
    params.chr_wsc    = 0.0

    -- Handle damage.
    local damage = xi.spells.blue.usePhysicalSpell(caster, target, spell, params)

    if damage <= 0 then
        return damage
    end

    -- Handle status effects.
    local effectTable =
    {
        [1] = { xi.effect.PARALYSIS, 15, 0, 90 },
    }

    xi.spells.blue.applyBlueAdditionalEffect(caster, target, params, effectTable)

    return damage
end

return spellObject
