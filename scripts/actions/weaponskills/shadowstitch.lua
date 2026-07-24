-----------------------------------
-- Shadowstitch
-- Dagger weapon skill
-- Skill level: 70
-- Binds target. Chance of binding varies with TP.
-- Does stack with Sneak Attack.
-- Aligned with the Aqua Gorget.
-- Aligned with the Aqua Belt.
-- Element: None
-- Modifiers: CHR:100%
-- 100%TP    200%TP    300%TP
-- 1.00      1.00      1.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params   = {}
    params.numHits = 1
    params.ftpMod  = { 1, 1, 1 }
    params.chr_wsc = 0.3

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.chr_wsc = 1
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    -- Handle status effect
    local procChance = 25 + tp / 40

    if math.randomInt(1, 100) <= procChance then
        local effectId      = xi.effect.BIND
        local actionElement = xi.element.ICE
        local power         = 1
        local resistance    = applyResistanceAddEffect(player, target, actionElement, 0)
        local duration      = math.floor((15 + 15 * tp / 1000) * resistance)
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
