-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: axe
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_axe')

-----------------------------------
-- Source: scripts/actions/weaponskills/avalanche_axe.lua
-----------------------------------
do
    -----------------------------------
    -- Avalanche Axe
    -- Axe weapon skill
    -- Skill level: 100
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Soil Gorget & Thunder Gorget.
    -- Aligned with the Soil Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR:30%
    -- 100%TP    200%TP    300%TP
    -- 1.50      2.00      2.50
    -----------------------------------
    local effectPowerVar = 'Sanctum_AvalancheAxeCritPower'
    local effectTokenVar = 'Sanctum_AvalancheAxeCritToken'

    local function applyCritRateDown(target)
        local power    = 5
        local oldPower = target:getLocalVar(effectPowerVar)
        local token    = target:getLocalVar(effectTokenVar) + 1

        if oldPower ~= 0 then
            target:delMod(xi.mod.CRITHITRATE, -oldPower)
        end

        target:addMod(xi.mod.CRITHITRATE, -power)
        target:setLocalVar(effectPowerVar, power)
        target:setLocalVar(effectTokenVar, token)

        target:timer(45000, function(targetArg)
            if targetArg and targetArg:getLocalVar(effectTokenVar) == token then
                targetArg:delMod(xi.mod.CRITHITRATE, -power)
                targetArg:setLocalVar(effectPowerVar, 0)
                targetArg:setLocalVar(effectTokenVar, 0)
            end
        end)
    end

    m:addOverride('xi.actions.weaponskills.avalanche_axe.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.5, 2, 2.5 }
        params.str_wsc = 0.35

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            applyCritRateDown(target)
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/calamity.lua
-----------------------------------
do
    -----------------------------------
    -- Calamity
    -- Axe weapon skill
    -- Skill level: 200 (Beastmasters and Warriors only.)
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Soil Gorget & Thunder Gorget.
    -- Aligned with the Soil Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR:32%  VIT:32%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.50      4.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.calamity.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.0, 2.5, 4.0 }
        params.str_wsc = 0.35 params.vit_wsc = 0.35

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 2.5, 6.5, 10.375 }
            params.str_wsc = 0.5 params.vit_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if xi.wsEffect.set(player, xi.wsEffect.CALAMITY_AXE_CRIT, 1, 60) then
            xi.wsEffect.message(player, 'The first hit of your next Axe weaponskill will be a critical hit.')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/decimation.lua
-----------------------------------
do
    -----------------------------------
    -- Decimation
    -- Axe weapon skill
    -- Skill level: 240
    -- In order to obtain Decimation, the quest Axe the Competition must be completed.
    -- Delivers a three-hit attack. params.accuracy varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Flame Gorget, Light Gorget & Aqua Gorget.
    -- Aligned with the Flame Belt, Light Belt & Aqua Belt.
    -- Element: None
    -- Modifiers: STR:50%
    -- 100%TP    200%TP    300%TP
    -- 1.25      1.25      1.25
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.decimation.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 3
        params.ftpMod = { 1.75, 2.0, 2.25 }
        params.str_wsc = 0.6
        params.accVaries = { 15, 30, 60 } -- TODO: verify exact number

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.75, 1.75, 1.75 }
            params.multiHitfTP = true
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        local duration = 45 + math.floor((tp - 1000) / 100) * 3
        if not xi.wsEffect.applyMod(player, xi.mod.DOUBLE_ATTACK, 5, duration, 'Decimation increased your double attack rate!') then
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/gale_axe.lua
-----------------------------------
do
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
    m:addOverride('xi.actions.weaponskills.gale_axe.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
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
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/mistral_axe.lua
-----------------------------------
do
    -----------------------------------
    -- Mistral Axe
    -- Axe weapon skill
    -- Skill level: 225 (Beastmasters and Warriors only.)
    -- Delivers a single-hit ranged attack at a maximum distance of 15.7'. Damage varies with TP.
    -- Despite being able to be used from a distance it is considered a melee attack and can be stacked with Sneak Attack and/or Trick Attack
    -- Aligned with the Flame Gorget & Light Gorget.
    -- Aligned with the Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers: STR:50%
    -- 100%TP    200%TP    300%TP
    -- 2.50      3.00      3.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.mistral_axe.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.5, 3.0, 3.75 }
        params.str_wsc = 0.55

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 4.0, 10.5, 13.625 }
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.EVASION_DOWN, { power = 25, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/raging_axe.lua
-----------------------------------
do
    -----------------------------------
    -- Raging Axe
    -- Axe weapon skill
    -- Skill level: 5
    -- Delivers a two-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- When stacked with Sneak Attack, both hits have a 100% chance of landing, though it is unclear if they both params.crit.
    -- Aligned with the Breeze Gorget & Thunder Gorget.
    -- Aligned with the Breeze Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR:60%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.50      2.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.raging_axe.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.0, 1.5, 2.0 }
        params.str_wsc = 0.3

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/rampage.lua
-----------------------------------
do
    -----------------------------------
    -- Rampage
    -- Axe weapon skill
    -- Skill level: 175
    -- Delivers a five-hit attack. Chance of params.critical varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Soil Gorget.
    -- Aligned with the Soil Belt.
    -- Element: None
    -- Modifiers: STR:50%
    -- 100%TP    200%TP    300%TP
    --   1         1         1
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.rampage.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 5
        params.ftpMod = { 0.5, 0.5, 0.5 }
        params.str_wsc = 0.3
        params.critVaries = { 0.10, 0.25, 0.50 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.0, 1.0, 1.0 }
            params.str_wsc = 0.5
            params.critVaries = { 0.0, 0.20, 0.40 }
            params.multiHitfTP = true
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/smash_axe.lua
-----------------------------------
do
    -----------------------------------
    -- Smash Axe
    -- Axe weapon skill
    -- Skill level: 40
    -- Stuns enemy. Duration of stun varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Snow Gorget & Aqua Gorget.
    -- Aligned with the Snow Belt & Aqua Belt.
    -- Element: None
    -- Modifiers: STR:100%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.smash_axe.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1, 1, 1 }
        params.str_wsc = 0.4

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 1
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        -- Handle status effect
        local effectId      = xi.effect.STUN
        local actionElement = xi.element.THUNDER
        local power         = 1
        local duration      = math.floor(tp / 500 * applyResistanceAddEffect(player, target, actionElement, 0))
        xi.weaponskills.handleWeaponskillEffect(player, target, effectId, actionElement, damage, power, duration)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/spinning_axe.lua
-----------------------------------
do
    -----------------------------------
    -- Spinning Axe
    -- Axe weapon skill
    -- Skill level: 150
    -- Single-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Flame Gorget, Soil Gorget & Thunder Gorget.
    -- Aligned with the Flame Belt, Soil Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR:60%
    -- 100%TP    200%TP    300%TP
    -- 2.00      2.50      3.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.spinning_axe.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.0, 2.5, 3.0 }
        params.str_wsc = 0.4

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.6
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addEnmity(player, 300, 1000)
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
