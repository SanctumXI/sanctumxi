-----------------------------------
-- Sunburst
-- Staff weapon skill
-- Skill Level: 150
-- Deals light or darkness elemental damage. Damage varies with TP.
-- Aligned with the Shadow Gorget & Aqua Gorget.
-- Aligned with the Shadow Belt & Aqua Belt.
-- Element: Light/Dark
-- Modifiers: :    STR:40% MND:40%
-- 100%TP    200%TP    300%TP
-- 1.00      2.50      4.00
-- Sanctum custom: Restores party HP equal to Staff skill / 3 and grants
-- 3 HP/tick Regen for 45 seconds.
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

local function applySunburstEffects(player, member, healPower)
    if member:isDead() then
        return
    end

    local hpRestored = member:addHP(healPower)

    member:addStatusEffect(xi.effect.REGEN, { power = 3, duration = 45, origin = player })

    if hpRestored > 0 then
        member:messageBasic(xi.msg.basic.RECOVERS_HP, 0, hpRestored)
    end
end

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.ftpMod = { 1.0, 2.5, 4.0 }
    params.str_wsc = 0.4
    params.mnd_wsc = 0.4
    params.skill = xi.skill.STAFF
    params.includemab = true
    params.dStat = xi.mod.INT
    -- 50/50 shot of being light or dark
    params.ele = xi.element.LIGHT
    if math.randomInt(1, 100) <= 50 then
        params.ele = xi.element.DARK
    end

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.str_wsc = 0.4 params.mnd_wsc = 0.4
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)
    local healPower = math.max(1, math.floor(player:getSkillLevel(xi.skill.STAFF) / 3))

    applySunburstEffects(player, player, healPower)

    for _, member in pairs(player:getPartyWithTrusts()) do
        if member:getID() ~= player:getID() then
            applySunburstEffects(player, member, healPower)
        end
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
