-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: polearm
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_polearm')

-----------------------------------
-- Source: scripts/actions/weaponskills/double_thrust.lua
-----------------------------------
do
    -----------------------------------
    -- Double Thrust
    -- Polearm weapon skill
    -- Skill Level: 5
    -- Delivers a two-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Light Gorget.
    -- Aligned with the Light Belt.
    -- Element: None
    -- Modifiers: STR:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.50      2.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.double_thrust.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.0, 1.5, 2.0 }
        params.str_wsc = 0.3

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.dex_wsc = 0.3
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/geirskogul.lua
-----------------------------------
do
    -----------------------------------
    -- Geirskogul
    -- Polearm weapon skill
    -- Skill Level: N/A
    -- Gae Assail/Gungnir: Shock Spikes.
    -- This weapon skill is only available with the stage 5 relic Polearm Gungnir, within Dynamis with the stage 4 Gae Assail, or by activating the latent effect on the Skogul Lance.
    -- Aligned with the Light Gorget, Aqua Gorget & Snow Gorget.
    -- Aligned with the Light Belt, Aqua Belt & Snow Belt.
    -- Element: None
    -- Modifiers: AGI:60%
    -- 100%TP    200%TP    300%TP
    -- 3.00      3.00      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.geirskogul.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.5, 3.0, 3.5 }
        params.str_wsc = 0.6

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.dex_wsc = 0.8 params.agi_wsc = 0.0
        end

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.RELIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/impulse_drive.lua
-----------------------------------
do
    -----------------------------------
    -- Impulse Drive
    -- Polearm weapon skill
    -- Skill Level: 240
    -- Delivers a two-hit attack. Damage varies with TP.
    -- In order to obtain Impulse Drive, the quest Methods Create Madness must be completed.
    -- Will stack with Sneak Attack.
    -- Aligned with the Shadow Gorget, Soil Gorget & Snow Gorget.
    -- Aligned with the Shadow Belt, Soil Belt & Snow Belt.
    -- Element: None
    -- Modifiers: STR:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.50      2.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.impulse_drive.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.75, 2.0, 2.25 }
        params.str_wsc = 0.5
        params.ignoredDefense = { 0.25, 0.25, 0.25 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.0, 3.0, 5.5 }
            params.str_wsc = 1.0
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if xi.wsEffect.set(player, xi.wsEffect.IMPULSE_DRIVE_DAMAGE, 25, 60) then
            xi.wsEffect.message(player, 'Your next weaponskill used above 1500 TP will deal 25% more damage!')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/raiden_thrust.lua
-----------------------------------
do
    -----------------------------------
    -- Raiden Thrust
    -- Polearm weapon skill
    -- Skill Level: 70
    -- Deals lightning elemental damage to enemy. Damage varies with TP.
    -- Aligned with the Light Gorget & Thunder Gorget.
    -- Aligned with the Light Belt & Thunder Belt.
    -- Element: Lightning
    -- Modifiers: STR:40%  INT:40%
    -- 100%TP    200%TP    300%TP
    -- 1.00      2.00      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.raiden_thrust.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 2.0, 3.0 }
        params.str_wsc = 0.3 params.int_wsc = 0.3
        params.ele = xi.element.THUNDER
        params.skill = xi.skill.POLEARM
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.int_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.PARALYSIS, { power = 15, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/skewer.lua
-----------------------------------
do
    -----------------------------------
    -- Skewer
    -- Polearm weapon skill
    -- Skill Level: 200
    -- Delivers a three-hit attack. Chance of params.critical hit varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Light Gorget & Thunder Gorget.
    -- Aligned with the Light Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.skewer.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 3
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.str_wsc = 0.4
        params.critVaries = { 0.1, 0.3, 0.5 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.MAGIC_EVASION_DOWN, { power = 5, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/thunder_thrust.lua
-----------------------------------
do
    -----------------------------------
    -- Thunder Thrust
    -- Polearm weapon skill
    -- Skill Level: 30
    -- Deals lightning elemental damage to enemy. Damage varies with TP.
    -- Aligned with the Light Gorget & Thunder Gorget.
    -- Aligned with the Light Belt & Thunder Belt.
    -- Element: Lightning
    -- Modifiers: STR:40%  INT:40%
    -- 100%TP    200%TP    300%TP
    -- 1.50      2.00      2.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.thunder_thrust.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.5, 2.0, 2.5 }
        params.str_wsc = 0.2 params.int_wsc = 0.2
        params.ele = xi.element.THUNDER
        params.skill = xi.skill.POLEARM
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.int_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.THUNDER })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/vorpal_thrust.lua
-----------------------------------
do
    -----------------------------------
    -- Vorpal Thrust
    -- Polearm weapon skill
    -- Skill Level: 175
    -- Delivers a single-hit attack. Chance of params.critical varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Aqua Gorget & Light Gorget.
    -- Aligned with the Aqua Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:50%  AGI:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.vorpal_thrust.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.0, 1.0, 1.0 }
        params.str_wsc = 0.2 params.agi_wsc = 0.2
        params.critVaries = { 0.3, 0.6, 0.9 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.5 params.agi_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            local polearmSkill = player:getSkillLevel(xi.skill.POLEARM)
            local strDownPower = math.min(25, 5 + math.floor(polearmSkill / 15))

            target:addStatusEffect(xi.effect.STR_DOWN, { power = strDownPower, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/wheeling_thrust.lua
-----------------------------------
do
    -----------------------------------
    -- Wheeling Thrust
    -- Polearm weapon skill
    -- Skill Level: 225
    -- Ignores enemy's defense. Amount ignored varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:80%
    -- 100%TP    200%TP    300%TP
    -- 1.75      1.75      1.75
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.wheeling_thrust.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.75, 2.0, 2.25 }
        params.str_wsc = 0.5
        -- Defense ignored is 50%, 75%, 100% (50% at 100 TP is accurate, other values are guesses)
        params.ignoredDefense = { 0.5, 0.75, 1.0 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.8
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if xi.wsEffect.set(player, xi.wsEffect.WHEELING_THRUST_JUMP, 100, 60) then
            xi.wsEffect.message(player, 'Your next Jump or High Jump will grant an additional 100 TP!')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
