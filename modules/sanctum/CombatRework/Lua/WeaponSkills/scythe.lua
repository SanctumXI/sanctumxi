-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: scythe
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_scythe')

-----------------------------------
-- Source: scripts/actions/weaponskills/catastrophe.lua
-----------------------------------
do
    -----------------------------------
    -- Catastrophe
    -- Scythe weapon skill
    -- Skill Level: N/A
    -- Drain target's HP. Bec de Faucon/Apocalypse: Additional effect: Haste
    -- This weapon skill is available with the stage 5 relic Scythe Apocalypse or within Dynamis with the stage 4 Bec de Faucon.
    -- Also available without Aftermath effects with the Crisis Scythe. After 13 weapon skills have been used successfully, gives one "charge" of Catastrophe.
    -- Aligned with the Shadow Gorget & Soil Gorget.
    -- Aligned with the Shadow Belt & Soil Belt.
    -- Element: None
    -- Modifiers: INT:40%  AGI:40%
    -- 100%TP    200%TP    300%TP
    -- 2.75      2.75      2.75
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.catastrophe.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        local targetHP = target:getHP()
        params.numHits = 2
        params.ftpMod = { 2.75, 2.75, 2.75 }
        params.str_wsc = 0.6 params.dex_wsc = 0.2

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.agi_wsc = 0.0 params.int_wsc = 0.4
        end

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.RELIC)

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle HP Drain
        if not target:isUndead() then
            local drain = math.floor(damage * math.randomInt(30, 70) / 100) -- TODO: JP Wiki States 50% Heal but all current proof i have shows 30-70%

            drain = utils.clamp(drain, 0, targetHP)

            player:addHP(drain)
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/cross_reaper.lua
-----------------------------------
do
    -----------------------------------
    -- Cross Reaper
    -- Scythe weapon skill
    -- Skill level: 225
    -- Delivers a two-hit attack. Damage varies with TP.
    -- Modifiers: STR:30%  MND:30%
    -- 100%TP     200%TP     300%TP
    -- 2.0         2.25    2.5
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.cross_reaper.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 2.0, 2.25, 2.5 }
        -- wscs are in % so 0.2=20%
        params.str_wsc = 0.3 params.mnd_wsc = 0.3

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 2.0, 4.0, 7.0 }
            params.str_wsc = 0.6 params.mnd_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if
            damage > 0 and
            xi.wsEffect.set(player, xi.wsEffect.CROSS_REAPER_MB, 30, 60)
        then
            xi.wsEffect.message(player, 'Your next magic burst will deal 30% more damage!')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/dark_harvest.lua
-----------------------------------
do
    -----------------------------------
    -- Dark Harvest
    -- Scythe weapon skill
    -- Skill Level: 30
    -- Delivers a dark elemental attack. Damage varies with TP.
    -- Aligned with the Aqua Gorget.
    -- Aligned with the Aqua Belt.
    -- Element: Dark
    -- Modifiers: STR:20%  INT:20%
    -- 100%TP    200%TP    300%TP
    -- 1.00      2.00      2.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.dark_harvest.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 2.0, 2.5 }
        params.str_wsc = 0.2 params.int_wsc = 0.2
        params.ele = xi.element.DARK
        params.skill = xi.skill.SCYTHE
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.int_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            local mpRestored = player:addMP(math.floor(damage / 4))

            if mpRestored > 0 then
                player:timer(500, function(playerArg)
                    playerArg:messageBasic(xi.msg.basic.RECOVERS_MP, 0, mpRestored)
                end)
            end
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/nightmare_scythe.lua
-----------------------------------
do
    -----------------------------------
    -- Nightmare Scythe
    -- Scythe weapon skill
    -- Skill Level: 100
    -- Blinds enemy. Duration of effect varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Shadow Gorget & Soil Gorget.
    -- Aligned with the Shadow Belt & Soil Belt.
    -- Element: None
    -- Modifiers: STR:60%  MND:60%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.nightmare_scythe.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1.25, 1.25, 1.25 }
        params.str_wsc = 0.3
        params.mnd_wsc = 0.3

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
            params.mnd_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.BLINDNESS
        local actionElement = xi.element.DARK
        local power         = 20
        local duration      = math.floor(6 * tp / 100 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/shadow_of_death.lua
-----------------------------------
do
    -----------------------------------
    -- Shadow of Death
    -- Scythe weapon skill
    -- Skill Level: 70
    -- Delivers a dark elemental attack. Damage varies with TP.
    -- Aligned with the Snow Gorget & Aqua Gorget.
    -- Aligned with the Snow Belt & Aqua Belt.
    -- Element: Dark
    -- Modifiers: STR:40%  INT:40%
    -- 100%TP    200%TP    300%TP
    -- 1.00      2.50      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.shadow_of_death.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.25, 2.5, 3.0 }
        params.str_wsc = 0.3 params.int_wsc = 0.3
        params.ele = xi.element.DARK
        params.skill = xi.skill.SCYTHE
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.int_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 20, duration = 45, origin = player, subPower = xi.element.DARK })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/slice.lua
-----------------------------------
do
    -----------------------------------
    -- Slice
    -- Scythe weapon skill
    -- Skill level: 5
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Modifiers: STR:100%
    -- 100%TP     200%TP     300%TP
    -- 1.50     1.75    2.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.slice.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.5, 1.75, 2.0 }
        -- wscs are in % so 0.2=20%
        params.str_wsc = 0.35

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 1.0
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/spiral_hell.lua
-----------------------------------
do
    -----------------------------------
    -- Spiral Hell
    -- Scythe weapon skill
    -- Skill level: 240 QUESTED
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Modifiers: STR:50%  INT:50%
    -- 100%TP     200%TP     300%TP
    -- 1.375     2.75     4.75
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.spiral_hell.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 2.0, 2.75, 3.5 }
        -- wscs are in % so 0.2=20%
        params.str_wsc = 0.8 params.int_wsc = 0.2

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
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/vorpal_scythe.lua
-----------------------------------
do
    -----------------------------------
    -- Vorpal Scythe
    -- Scythe weapon skill
    -- Skill level: 150
    -- Delivers a single-hit attack. params.crit varies with TP.
    -- Modifiers: STR:100%
    -- 100%TP     200%TP     300%TP
    -- 1.0         1.0        1.0
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.vorpal_scythe.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.25, 1.25, 1.25 }
        -- wscs are in % so 0.2=20%
        params.str_wsc = 0.5
        params.critVaries = { 0.3, 0.6, 0.9 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 1.0
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.DEFENSE_DOWN, { power = 5, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
