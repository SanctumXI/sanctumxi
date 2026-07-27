-----------------------------------
-- Seraph Strike
-- Club weapon skill
-- Skill level: 40
-- Deals light elemental damage to enemy. Damage varies with TP.
-- Aligned with the Thunder Gorget.
-- Aligned with the Thunder Belt.
-- Element: None
-- Modifiers: STR:40%  MND:40%
-- 100%TP    200%TP    300%TP
-- 2.125     3.675      6.125
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.ftpMod = { 1.0, 2.0, 3.0 }
    params.str_wsc = 0.3 params.mnd_wsc = 0.3
    params.ele = xi.element.LIGHT
    params.skill = xi.skill.CLUB
    params.includemab = true

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 2.125, 3.675, 6.125 }
        params.str_wsc = 0.4 params.mnd_wsc = 0.4
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

    if damage > 0 then
        target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.LIGHT })
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
