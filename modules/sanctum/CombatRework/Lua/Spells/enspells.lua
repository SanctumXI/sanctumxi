-----------------------------------
-- Sanctum combat rework: enspell base damage
-- Source: scripts/globals/spells/enhancing_spell.lua
--
-- The stock script mixes two eras. Below 401 skill it uses the 75-era curve, then
-- jumps to the retail-modern one, so a single point of skill at 400 doubles the
-- damage. We are a 75-cap server, so keep the era curve and nothing else.
--
-- 20 base damage at the 300 skill cap. Weapon delay scaling in
-- battleutils::CalculateEnspellDamage takes that up to 30 on the slowest weapons.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combatrework_enspells')

local function isEnspellEffect(effectId)
    return
        (effectId >= xi.effect.ENFIRE and effectId <= xi.effect.ENWATER) or
        (effectId >= xi.effect.ENFIRE_II and effectId <= xi.effect.ENWATER_II) or
        effectId == xi.effect.AUSPICE
end

m:addOverride('xi.spells.enhancing.calculateEnhancingBasePower', function(caster, target, spell, spellId, spellEffect)
    if not isEnspellEffect(spellEffect) then
        return super(caster, target, spell, spellId, spellEffect)
    end

    local skillLevel = caster:getSkillLevel(spell:getSkillType())

    if skillLevel > 200 then
        return math.floor(skillLevel / 20) + 5
    end

    return math.floor(skillLevel * 6 / 100) + 3
end)

return m
