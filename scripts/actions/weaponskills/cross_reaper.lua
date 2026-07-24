-----------------------------------
-- Cross Reaper
-- Scythe weapon skill
-- Skill level: 225
-- Delivers a two-hit attack. Damage varies with TP.
-- Modifiers: STR:30%  MND:30%
-- 100%TP     200%TP     300%TP
-- 2.0         2.25    2.5
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 2
    params.ftpMod = { 2.0, 2.25, 2.5 }
    -- wscs are in % so 0.2=20%
    params.str_wsc = 0.3 params.mnd_wsc = 0.3

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 2.0, 4.0, 7.0 }
        params.str_wsc = 0.6 params.mnd_wsc = 0.6
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 and xi.wsEffect.set(player, xi.wsEffect.CROSS_REAPER_MB, 30, 60) then
        xi.wsEffect.message(player, 'Your next magic burst will deal 30% more damage!')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
