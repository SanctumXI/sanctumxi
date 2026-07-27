-----------------------------------
-- Blade Ei
-- Katana weapon skill
-- Skill Level: 175
-- Delivers a dark elemental attack. Damage varies with TP.
-- Aligned with the Shadow Gorget.
-- Aligned with the Shadow Belt.
-- Element: Dark
-- Modifiers: STR:30%  INT:30%
-- 100%TP    200%TP    300%TP
-- 1.00      1.50      2.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.ftpMod = { 1.5, 2.0, 2.5 }
    params.str_wsc = 0.35 params.int_wsc = 0.35
    params.ele = xi.element.DARK
    params.skill = xi.skill.KATANA
    params.includemab = true

    -- to do ignore shadow and blink https://www.bg-wiki.com/ffxi/Blade:_Ei
    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.str_wsc = 0.4 params.int_wsc = 0.4
        params.ftpMod = { 1.0, 3.0, 5.0 }
    end

    local damage, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

    if damage > 0 then
        target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.DARK })
    end

    return tpHits, extraHits, false, damage
end

return weaponskillObject
