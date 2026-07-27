-----------------------------------
-- Shell Crusher
-- Staff weapon skill
-- Skill Level: 175
-- Lowers target's defense.
-- Will stack with Sneak Attack.
-- Aligned with the Breeze Gorget.
-- Aligned with the Breeze Belt.
-- Element: None
-- Modifiers: STR:100%
-- 100%TP    200%TP    300%TP
-- 1.00      1.00      1.00
-- Sanctum custom: Ignores 30%/40%/50% defense and lowers defense by 15%
-- for 45 seconds.
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params   = {}
    params.numHits = 1
    params.ftpMod  = { 1.15, 1.35, 1.5 }
    params.str_wsc = 0.4
    params.ignoredDefense = { 0.25, 0.35, 0.5 }

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.str_wsc = 1
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 then
        target:addStatusEffect(xi.effect.DEFENSE_DOWN, { power = 15, duration = 45, origin = player })
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
