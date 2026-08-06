-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: staff
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_ws_staff')

-----------------------------------
-- Source: scripts/actions/weaponskills/full_swing.lua
-----------------------------------
do
    -----------------------------------
    -- Full Swing
    -- Staff weapon skill
    -- Skill Level: 200
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Flame Gorget & Thunder Gorget.
    -- Aligned with the Flame Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      3.00      5.00
    -- Sanctum custom: Empowers the next Staff weaponskill with 15% more damage
    -- for up to 60 seconds.
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.full_swing.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.5, 3.5, 5.0 }
        params.str_wsc = 0.6
        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
    
        if xi.wsEffect.set(player, xi.wsEffect.FULL_SWING_DAMAGE, 15, 60) then
            xi.wsEffect.message(player, 'Your next Staff weaponskill will deal 15% more damage!')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end
    
        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/heavy_swing.lua
-----------------------------------
do
    -----------------------------------
    -- Heavy Swing
    -- Staff weapon skill
    -- Skill Level: 5
    -- Deacription:Delivers a single-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Thunder Gorget.
    -- Aligned with the Thunder Belt.
    -- Element: None
    -- Modifiers: STR:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.25      2.25
    -- Sanctum custom: Grants 2 HP/tick Regen for 30 seconds.
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.heavy_swing.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.0, 1.25, 2.25 }
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
-- Source: scripts/actions/weaponskills/retribution.lua
-----------------------------------
do
    -----------------------------------
    -- Retribution
    -- Staff weapon skill
    -- Skill Level: 230
    -- Delivers a single-hit attack. Damage varies with TP.
    -- In order to obtain Retribution, the quest Blood and Glory must be completed.
    -- Despite the appearance of throwing the staff, this is not a long-range Weapon Skill like Mistral Axe.
    -- The range only extends the usual 1 yalm beyond meleeing range.
    -- Will stack with Sneak Attack.
    -- Aligned with the Shadow Gorget, Soil Gorget & Aqua Gorget.
    -- Aligned with the Shadow Belt, Soil Belt & Aqua Belt.
    -- Element: None
    -- Modifiers: STR:30%  MND:50%
    -- 100%TP    200%TP    300%TP
    -- 2.00      2.50      3.00
    -- Sanctum custom: Gains up to 20 base damage from current enmity and prevents
    -- enmity loss from taking damage for 45/75/105 seconds based on TP.
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.retribution.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params     = {}
        params.numHits   = 1
        params.ftpMod    = { 2.0, 2.5, 3.0 }
        params.atkVaries = { 1.5, 1.5, 1.5 } -- https://w.atwiki.jp/studiogobli/pages/93.html
        params.str_wsc   = 0.3
        params.mnd_wsc   = 0.5
    
        if target:getObjType() == xi.objType.MOB then
            local totalEnmity = target:getCE(player) + target:getVE(player)
    
            params.bonusWSmods = math.min(20, math.floor(totalEnmity / 1000))
        end
    
        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
        local duration = 45 + math.floor((tp - 1000) / 100) * 3
    
        local empowered = xi.wsEffect.applyMod(
            player,
            xi.mod.ENMITY_LOSS_REDUCTION,
            1000,
            duration,
            'Retribution prevents enmity loss when taking damage!'
        )
    
        if not empowered then
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end
    
        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/rock_crusher.lua
-----------------------------------
do
    -----------------------------------
    -- Rock Crusher
    -- Staff weapon skill
    -- Skill Level: 40
    -- Delivers an earth elemental attack. Damage varies with TP.
    -- Aligned with the Thunder Gorget.
    -- Aligned with the Thunder Belt.
    -- Element: Earth
    -- Modifiers: STR:40%  INT:40%
    -- 100%TP    200%TP    300%TP
    -- 1.00      2.00      2.50
    -- Sanctum custom: Inflicts Weight for 45 seconds.
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.rock_crusher.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 2.0, 2.5 }
        params.str_wsc = 0.2 params.int_wsc = 0.2
        params.ele = xi.element.EARTH
        params.skill = xi.skill.STAFF
        params.includemab = true
        params.dStat = xi.mod.INT
    
        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.int_wsc = 0.4
        end
    
        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)
    
        if damage > 0 then
            target:addStatusEffect(xi.effect.WEIGHT, { power = 25, duration = 45, origin = player })
        end
    
        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/shell_crusher.lua
-----------------------------------
do
    -----------------------------------
    -- Shell Crusher
    -- Staff weapon skill
    -- Skill Level: 175
    -- Lowers target's defense.
    -- Will stack with Sneak Attack.
    -- Aligned with the Breeze Gorget.
    -- Aligned with the Breeze Belt.
    -- Element: None
    -- Modifiers: STR:100%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -- Sanctum custom: Ignores 30%/40%/50% defense and lowers defense by 15%
    -- for 45 seconds.
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.shell_crusher.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1.15, 1.35, 1.5 }
        params.str_wsc = 0.4
        params.ignoredDefense = { 0.25, 0.35, 0.5 }
    
        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 1
        end
    
        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
    
        if damage > 0 then
            target:addStatusEffect(xi.effect.DEFENSE_DOWN, { power = 15, duration = 45, origin = player })
        end
    
        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/spirit_taker.lua
-----------------------------------
do
    -----------------------------------
    -- Spirit Taker
    -- Staff weapon skill
    -- Skill Level: 215
    -- Deals Light elemental damage and converts the damage dealt to own MP. Damage varies with TP.
    -- It is a magical weapon skill and cannot miss.
    -- Element: Light
    -- Modifiers: INT:50%  MND:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.50      2.00
    -----------------------------------
    local echoEligibleJobs =
    {
        [xi.job.BLM] = true,
        [xi.job.WHM] = true,
        [xi.job.SCH] = true,
        [xi.job.PLD] = true,
    }
    
    local directDamageSkills =
    {
        [xi.skill.ELEMENTAL_MAGIC] = true,
        [xi.skill.DARK_MAGIC]      = true,
        [xi.skill.DIVINE_MAGIC]    = true,
    }
    
    local echoListenerName      = 'SPIRIT_TAKER_ECHO'
    local instantListenerName   = 'SPIRIT_TAKER_ECHO_INSTANT'
    local echoCastingVar        = 'SpiritTakerEchoCasting'
    
    local function addSpiritTakerEchoListener(player)
        player:removeListener(echoListenerName)
    
        player:addListener('MAGIC_USE', echoListenerName, function(caster, target, spell, action)
            -- An echoed spell cannot trigger another echo.
            if caster:getLocalVar(echoCastingVar) == 1 then
                caster:setLocalVar(echoCastingVar, 0)
                caster:removeListener(echoListenerName)
                return
            end
    
            if not xi.wsEffect.has(caster, xi.wsEffect.SPIRIT_TAKER_ECHO) then
                caster:removeListener(echoListenerName)
                return
            end
    
            if
                target:getAllegiance() == caster:getAllegiance() or
                not directDamageSkills[spell:getSkillType()]
            then
                return
            end
    
            xi.wsEffect.consume(caster)
    
            if math.randomInt(1, 100) <= 10 then
                local spellId = spell:getID()
    
                caster:setLocalVar(echoCastingVar, 1)
    
                xi.wsEffect.message(caster, 'Spirit Taker echoed your spell!')
    
                -- Queue the echo after the original spell has fully resolved.
                caster:timer(3000, function(echoCaster)
                    if echoCaster:getLocalVar(echoCastingVar) == 1 then
                        -- Only the echoed spell is instant and free; do not affect intervening casts.
                        echoCaster:addMod(xi.mod.QUICK_MAGIC, 100)
                        echoCaster:removeListener(instantListenerName)
                        echoCaster:addListener('MAGIC_START', instantListenerName, function(instantCaster, echoTarget, echoSpell, echoAction)
                            instantCaster:delMod(xi.mod.QUICK_MAGIC, 100)
                            echoSpell:setMPCost(0)
                            instantCaster:removeListener(instantListenerName)
                        end)
    
                        echoCaster:castSpell(spellId, target)
                    end
                end)
    
                -- Clean up if the echoed cast cannot start (for example, if its recast is unavailable).
                caster:timer(5000, function(echoCaster)
                    if echoCaster:getLocalVar(echoCastingVar) == 1 then
                        echoCaster:setLocalVar(echoCastingVar, 0)
                        echoCaster:delMod(xi.mod.QUICK_MAGIC, 100)
                        echoCaster:removeListener(instantListenerName)
                        echoCaster:removeListener(echoListenerName)
                    end
                end)
            else
                caster:removeListener(echoListenerName)
            end
        end)
    end
    
    m:addOverride('xi.actions.weaponskills.spirit_taker.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.0, 1.5, 2.0 }
        params.int_wsc = 0.5 params.mnd_wsc = 0.5
        params.ele = xi.element.LIGHT
        params.skill = xi.skill.STAFF
        params.includemab = true
    
        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)
        player:addMP(math.max(0, damage))
    
        if player:getMainJob() == xi.job.SMN then
            -- 45 seconds at 1000 TP, scaling to 105 seconds at 3000 TP.
            local duration = 45 + math.floor((math.min(tp, 3000) - 1000) / 100) * 3
    
            xi.wsEffect.set(player, xi.wsEffect.SPIRIT_TAKER_SMN_PET_DAMAGE, 5, duration)
            xi.wsEffect.message(player, 'Empowered: Your avatar\'s Blood Pact damage is increased by 5%.')
        elseif echoEligibleJobs[player:getMainJob()] then
            xi.wsEffect.set(player, xi.wsEffect.SPIRIT_TAKER_ECHO, 1, 60)
            addSpiritTakerEchoListener(player)
            xi.wsEffect.message(player, 'Your next direct-damage spell may echo.')
        end
    
        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/starburst.lua
-----------------------------------
do
    -----------------------------------
    -- Starburst
    -- Staff weapon skill
    -- Skill Level: 100
    -- Deals light or darkness elemental damage. Damage varies with TP.
    -- Aligned with the Shadow Gorget & Aqua Gorget.
    -- Aligned with the Shadow Belt & Aqua Belt.
    -- Element: Light/Dark (Random)
    -- Modifiers: :    STR:40% MND:40%
    -- 100%TP    200%TP    300%TP
    -- 1.00      2.00      2.50
    -- Sanctum custom: Inflicts Flash for 5 seconds.
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.starburst.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.25, 2.0, 2.5 }
        params.skill = xi.skill.STAFF
        params.includemab = true
        params.str_wsc = 0.2 params.mnd_wsc = 0.2
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
    
        if damage > 0 then
            target:addStatusEffect(xi.effect.FLASH, { power = 100, duration = 6, origin = player })
        end
    
        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/sunburst.lua
-----------------------------------
do
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
    
    m:addOverride('xi.actions.weaponskills.sunburst.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
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
    end)
end

return m
