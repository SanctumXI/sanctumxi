-----------------------------------
-- Spiral Hell
-- Scythe weapon skill
-- Skill level: 240 QUESTED
-- Delivers a single-hit attack. Damage varies with TP.
-- Modifiers: STR:50%  INT:50%
-- 100%TP     200%TP     300%TP
-- 1.375     2.75     4.75
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 2
    params.ftpMod = { 2.0, 2.75, 3.5 }
    -- wscs are in % so 0.2=20%
    params.str_wsc = 0.5 params.int_wsc = 0.5

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 1.375, 2.75, 4.75 }
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

    if damage > 0 then
        local mainJob = player:getMainJob()

        if mainJob == xi.job.DRK or mainJob == xi.job.BLM then
            if xi.wsEffect.set(player, xi.wsEffect.SPIRAL_HELL_ABSORB, 15, 60) then
                xi.wsEffect.message(player, 'Your next Drain, Aspir, or Absorb spell gains potency and accuracy!')
            end
        else
            local duration = 45 + math.floor((tp - 1000) / 100) * 3

            if xi.wsEffect.set(player, xi.wsEffect.SPIRAL_HELL_CRIT, 5, duration) then
                xi.wsEffect.message(player, 'Critical hit damage increased. Every fifth attack will automatically critical!')
            end
        end
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
