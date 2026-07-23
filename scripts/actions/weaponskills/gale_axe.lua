-----------------------------------
-- Gale Axe
-- Axe weapon skill
-- Skill level: 70
-- Deals wind elemental damage. Chokes target. Chance of choking varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Breeze Gorget.
-- Aligned with the Breeze Belt.
-- Element: Wind
-- Modifiers: STR:30%
-- 100%TP    200%TP    300%TP
-- 1.00      1.00      1.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params   = {}
    params.numHits = 1
    params.ftpMod  = { 1.0, 1.25, 1.5 }
    params.str_wsc = 0.4

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.str_wsc = 1.0
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 then
        local axeSkill     = player:getSkillLevel(xi.skill.AXE)
        local vitDownPower = math.min(25, 5 + math.floor(axeSkill / 15))

        target:addStatusEffect(xi.effect.VIT_DOWN, { power = vitDownPower, duration = 45, origin = player })
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
