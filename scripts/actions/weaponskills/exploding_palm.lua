-----------------------------------
-- Exploding Palm (Formerly Spinning Attack)
-- Hand-to-Hand weapon skill
-- Skill Level: 150
-- Delivers an area attack. Radius varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Flame Gorget & Thunder Gorget.
-- Aligned with the Flame Belt & Thunder Belt.
-- Element: None
-- Modifiers: STR: 35%
-- 100%TP    200%TP    300%TP
-- 1.00      1.00      1.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

-- TODO: Radius 5y at 2334 TP
weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 1
    params.ftpMod = { 1.5, 1.7, 1.9 }
    params.str_wsc = .75
    params.dex_wsc = .5
    params.ignoredDefense = { 0.25, 0.35, 0.45 }

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.str_wsc = 1.0 -- http://wiki.ffo.jp/html/2421.html
        params.multiHitfTP = true
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 then
        target:addStatusEffect(xi.effect.MAGIC_DEF_DOWN, { power = 5, duration = 45, origin = player })
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
