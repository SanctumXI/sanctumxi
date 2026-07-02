-----------------------------------
-- Keen Edge
-- Great Axe weapon skill
-- Skill level: 150
-- Delivers a single hit attack. Chance of params.critical varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Shadow Gorget.
-- Aligned with the Shadow Belt.
-- Element: None
-- Modifiers: STR:35%
-- 100%TP    200%TP    300%TP
-- 1.00      1.00      1.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 2
    params.ftpMod = { 1.0, 1.0, 1.0 }
    params.str_wsc = 0.6
    params.critVaries = { 0.5, 0.75, 1.0 }

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.str_wsc = 1.0
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    -- Add critical hit buff after WS for 30 seconds
    player:addStatusEffect(xi.effect.BLOOD_RAGE, { power = 15, duration = 45, origin = player })

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
