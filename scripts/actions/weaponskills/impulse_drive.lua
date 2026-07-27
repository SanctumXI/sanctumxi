-----------------------------------
-- Impulse Drive
-- Polearm weapon skill
-- Skill Level: 240
-- Delivers a two-hit attack. Damage varies with TP.
-- In order to obtain Impulse Drive, the quest Methods Create Madness must be completed.
-- Will stack with Sneak Attack.
-- Aligned with the Shadow Gorget, Soil Gorget & Snow Gorget.
-- Aligned with the Shadow Belt, Soil Belt & Snow Belt.
-- Element: None
-- Modifiers: STR:50%
-- 100%TP    200%TP    300%TP
-- 1.00      1.50      2.50
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 2
    params.ftpMod = { 1.75, 2.0, 2.25 }
    params.str_wsc = 0.5
    params.ignoredDefense = { 0.25, 0.25, 0.25 }

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 1.0, 3.0, 5.5 }
        params.str_wsc = 1.0
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if xi.wsEffect.set(player, xi.wsEffect.IMPULSE_DRIVE_DAMAGE, 25, 60) then
        xi.wsEffect.message(player, 'Your next weaponskill used above 1500 TP will deal 25% more damage!')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
