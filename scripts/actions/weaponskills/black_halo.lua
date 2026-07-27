-----------------------------------
-- Black Halo
-- Club weapon skill
-- Skill level: 230
-- In order to obtain Black Halo, the quest Orastery Woes must be completed.
-- Delivers a two-hit attack. Damage varies with TP.
-- Will stack with Sneak Attack.
-- Aligned with the Shadow Gorget, Thunder Gorget & Breeze Gorget.
-- Aligned with the Shadow Belt, Thunder Belt & Breeze Belt.
-- Element: None
-- Modifiers: STR:30%  MND:50%
-- 100%TP    200%TP    300%TP
-- 1.50      2.50      3.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 2
    params.ftpMod = { 1.5, 2.5, 3 }
    params.str_wsc = 0.4
    params.mnd_wsc = 0.5

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 3.0, 7.25, 9.75 }
        params.mnd_wsc = 0.7
    end

    if player:getMainJob() == xi.job.PLD then
        params.vit_wsc = 0.5
        params.str_wsc = 0.0
        params.mnd_wsc = 0.5
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 then
        target:addStatusEffect(xi.effect.MAGIC_EVASION_DOWN, { power = 10, duration = 45, origin = player })
    end

    local mainJob = player:getMainJob()
    local effect
    local power
    local duration
    local message

    if mainJob == xi.job.PLD then
        effect   = xi.wsEffect.BLACK_HALO_BASH
        power    = 25
        duration = 60
        message  = 'Your next Shield Bash is empowered.'
    elseif mainJob == xi.job.MNK or mainJob == xi.job.WAR then
        effect   = xi.wsEffect.BLACK_HALO_CRIT
        power    = 15
        duration = 45 + math.floor((tp - 1000) / 100) * 3
        message  = 'Black Halo increased your melee critical hit damage!'
    elseif
        mainJob == xi.job.WHM or
        mainJob == xi.job.GEO or
        mainJob == xi.job.BLU or
        mainJob == xi.job.BLM or
        mainJob == xi.job.SCH or
        mainJob == xi.job.SMN
    then
        effect   = xi.wsEffect.BLACK_HALO_MP
        power    = 3
        duration = 45 + math.floor((tp - 1000) / 100) * 3
        message  = 'Black Halo empowered your melee hits to restore MP!'
    end

    if effect then
        if xi.wsEffect.set(player, effect, power, duration) then
            xi.wsEffect.message(player, message)
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
