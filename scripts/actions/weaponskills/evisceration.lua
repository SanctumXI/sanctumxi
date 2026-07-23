-----------------------------------
-- Evisceration
-- Dagger weapon skill
-- Skill level: 230
-- In order to obtain Evisceration, the quest Cloak and Dagger must be completed.
-- Delivers a fivefold attack. Chance of params.critical hit varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Shadow Gorget, Soil Gorget & Light Gorget.
-- Aligned with the Shadow Belt, Soil Belt & Light Belt.
-- Element: None
-- Modifiers: DEX:30%
-- 100%TP    200%TP    300%TP
-- 1.00      1.00      1.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 5
    params.ftpMod = { 1.15, 1.15, 1.15 }
    params.dex_wsc = 0.5
    params.critVaries = { 0.20, 0.35, 0.55 }

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.multiHitfTP = true
        params.ftpMod = { 1.25, 1.25, 1.25 }
        params.crit200 = 0.25
        params.dex_wsc = 0.5
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    local critBonus = utils.clamp(10 + math.floor((tp - 1000) * 15 / 2000), 10, 25)
    if xi.wsEffect.set(player, xi.wsEffect.EVISCERATION_CRIT, critBonus, 60) then
        xi.wsEffect.message(player, string.format('Your next Dagger weaponskill gains +%i%% critical hit rate.', critBonus))
    else
        xi.wsEffect.message(player, 'An empowered effect is already active.')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
