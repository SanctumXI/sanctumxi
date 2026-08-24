-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: great sword
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_great_sword')

-----------------------------------
-- Source: scripts/actions/weaponskills/crescent_moon.lua
-----------------------------------
do
    -----------------------------------
    -- Crescent Moon
    -- Great Sword weapon skill
    -- Skill level: 175
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Modifiers: STR:35%
    -- 100%TP     200%TP     300%TP
    -- 1.0         1.75    2.5
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.crescent_moon.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.0, 1.75, 2.5 }
        -- wscs are in % so 0.2=20%
        params.str_wsc = 0.35

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.5, 1.75, 2.75 }
            params.str_wsc = 0.8
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.MAGIC_ACC_DOWN, { power = 10, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/frostbite.lua
-----------------------------------
do
    -----------------------------------
    -- Frostbite
    -- Great Sword weapon skill
    -- Skill Level: 70
    -- Delivers an ice elemental attack. Damage varies with TP.
    -- Aligned with the Snow Gorget.
    -- Aligned with the Snow Belt.
    -- Element: Ice
    -- Modifiers: STR:20%  INT:20%
    -- 100%TP    200%TP    300%TP
    -- 1.00      2.00      2.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.frostbite.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 2.0, 2.5 }
        params.str_wsc = 0.2 params.int_wsc = 0.2
        params.ele = xi.element.ICE
        params.skill = xi.skill.GREAT_SWORD
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.int_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.ICE })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/ground_strike.lua
-----------------------------------
do
    -----------------------------------
    -- Ground Strike
    -- Great Sword weapon skill
    -- Skill level: 250 QUESTED
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Modifiers: STR:50% INT:50%
    -- 100%TP     200%TP     300%TP
    -- 1.5         1.75    3.0
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.ground_strike.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.75, 2.25, 2.50 }
        params.str_wsc = 0.5
        params.int_wsc = 0.2
        params.atkVaries = { 1.75, 1.75, 1.75 }

        if player:getMainJob() == xi.job.DRK then
            params.str_wsc = 1.0
            params.int_wsc = 0.0
            params.atkVaries = { 1.85, 1.85, 1.85 }
        end

        if player:getMainJob() == xi.job.PLD then
            params.str_wsc = 0.6
            params.vit_wsc = 0.6
            params.atkVaries = { 1.25, 1.25, 1.25 }
        end

        if player:getMainJob() == xi.job.WAR then
            params.str_wsc = 0.7
            params.vit_wsc = 0.3
            params.atkVaries = { 1.75, 1.75, 1.75 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        local effect
        local power
        local message

        if player:getMainJob() == xi.job.DRK then
            effect  = xi.wsEffect.GROUND_STRIKE_BASH
            power   = 25
            message = 'Your next Weapon Bash is empowered.'
        elseif player:getMainJob() == xi.job.WAR then
            effect  = xi.wsEffect.GROUND_STRIKE_DA
            power   = 100
            message = 'Your next attack will strike twice.'
        elseif player:getMainJob() == xi.job.PLD then
            effect  = xi.wsEffect.GROUND_STRIKE_HOLY
            power   = 50
            message = 'Your next Holy spell will cost half MP.'
        end

        if effect then
            if xi.wsEffect.set(player, effect, power, 60) then
                xi.wsEffect.message(player, message)
            else
                xi.wsEffect.message(player, 'An empowered effect is already active.')
            end
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/hard_slash.lua
-----------------------------------
do
    -----------------------------------
    -- Hard Slash
    -- Great Sword weapon skill
    -- Skill level: 5
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Modifiers: STR:30%
    -- 100%TP     200%TP     300%TP
    -- 1.5         1.75        2.0
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.hard_slash.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.5, 1.75, 2.0 }
        -- wscs are in % so 0.2=20%
        params.str_wsc = 0.3

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 1.0
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/sickle_moon.lua
-----------------------------------
do
    -----------------------------------
    -- Sickle Moon
    -- Great Sword weapon skill
    -- Skill level: 200
    -- Delivers a two-hit attack. Damage varies with TP.
    -- Modifiers: STR:40%  AGI:40%
    -- 100%TP     200%TP     300%TP
    -- 1.5         2        2.75
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.sickle_moon.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.5, 2.0, 2.75 }
        -- wscs are in % so 0.2=20%
        params.str_wsc = 0.2 params.agi_wsc = 0.2

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.agi_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if xi.wsEffect.set(player, xi.wsEffect.SICKLE_MOON_DRAIN, 1, 45) then
            xi.wsEffect.message(player, 'Your melee hits will restore 1% of your maximum HP!')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/spinning_slash.lua
-----------------------------------
do
    -----------------------------------
    -- Spinning Slash
    -- Great Sword weapon skill
    -- Skill level: 225
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Modifiers: STR:30%  INT:30%
    -- 100%TP     200%TP     300%TP
    -- 2.5         3        3.5
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.spinning_slash.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.5, 3.0, 3.5 }
        -- wscs are in % so 0.2=20%
        params.str_wsc = 0.4 params.int_wsc = 0.3
        params.atkVaries = { 1.5, 1.5, 1.5 }

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
