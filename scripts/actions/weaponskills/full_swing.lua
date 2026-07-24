-----------------------------------
-- Full Swing
-- Staff weapon skill
-- Skill Level: 200
-- Delivers a single-hit attack. Damage varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Flame Gorget & Thunder Gorget.
-- Aligned with the Flame Belt & Thunder Belt.
-- Element: None
-- Modifiers: STR:50%
-- 100%TP    200%TP    300%TP
-- 1.00      3.00      5.00
-- Sanctum custom: Empowers the next Staff weaponskill with 15% more damage
-- for up to 60 seconds.
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 1
    params.ftpMod = { 1.0, 3.0, 5.0 }
    params.str_wsc = 0.5
    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if xi.wsEffect.set(player, xi.wsEffect.FULL_SWING_DAMAGE, 15, 60) then
        xi.wsEffect.message(player, 'Your next Staff weaponskill will deal 15% more damage!')
    else
        xi.wsEffect.message(player, 'An empowered effect is already active.')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
