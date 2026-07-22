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
    params.ftpMod = { 1.5, 1.75, 2.0 }
    params.str_wsc = 1.0
    params.dex_wsc = .5
    params.ignoredDefense = { 0.25, 0.35, 0.45 }

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.str_wsc = 1.0 -- http://wiki.ffo.jp/html/2421.html
        params.multiHitfTP = true
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    -- Handle status effect
    local effectId      = xi.effect.DEFENSE_DOWN
    local actionElement = xi.element.FIRE
    local power         = 25
    local duration      = math.floor((120 + 6 * tp / 100) * applyResistanceAddEffect(player, target, actionElement, 0))
    xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

    -- Sanctum Combo: Exploding Palm empowers Chakra
    if xi.wsEffect.set(player, xi.wsEffect.CHAKRA_BOOST, 100, 30) then
        xi.wsEffect.message(player, 'Your next Chakra is empowered.')
    else
        xi.wsEffect.message(player, 'An empowered effect is already active.')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
