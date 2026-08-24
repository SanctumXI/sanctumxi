-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: club
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_club')

-----------------------------------
-- Source: scripts/actions/weaponskills/black_halo.lua
-----------------------------------
do
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
    m:addOverride('xi.actions.weaponskills.black_halo.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
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
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/brainshaker.lua
-----------------------------------
do
    -----------------------------------
    -- Brainshaker
    -- Club weapon skill
    -- Skill level: 70
    -- Stuns enemy. Duration of stun varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Aqua Gorget.
    -- Aligned with the Aqua Belt.
    -- Element: None
    -- Modifiers: STR:30%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.brainshaker.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1, 1, 1 }
        params.str_wsc = 0.3

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
        local lvl = player:getSkillLevel(11)
        local enpower = lvl / 15
        target:addStatusEffect(xi.effect.SHOCK, { power = enpower, duration = 60, origin = player })

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/judgment.lua
-----------------------------------
do
    -----------------------------------
    -- Judgment
    -- Club weapon skill
    -- Were you looking for Judgment Key?
    -- Skill level: 200
    -- Delivers a single-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Thunder Gorget.
    -- Aligned with the Thunder Belt.
    -- Element: None
    -- Modifiers: STR:32%  MND:32%
    -- 100%TP    200%TP    300%TP
    -- 2.00      2.50      4.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.judgment.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 2.25, 2.75, 3.75 }
        params.str_wsc = 0.35 params.mnd_wsc = 0.35

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 3.5, 8.75, 12.0 }
            params.str_wsc = 0.5 params.mnd_wsc = 0.5
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if xi.wsEffect.set(player, xi.wsEffect.JUDGMENT_HOLY_DMG, 25, 60) then
            xi.wsEffect.message(player, 'Your next Holy or Banish spell will deal 25% more damage.')
        else
            xi.wsEffect.message(player, 'An empowered effect is already active.')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/moonlight.lua
-----------------------------------
do
    -----------------------------------
    -- Moonlight
    -----------------------------------
    local function applyMoonlightEffects(player, member)
        if not member:isDead() and member:checkDistance(player) <= 6 then
            member:addStatusEffect(xi.effect.REFRESH, { power = 1, duration = 45, origin = player })
        end
    end

    m:addOverride('xi.actions.weaponskills.moonlight.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local lvl       = player:getSkillLevel(xi.skill.CLUB)
        local damage    = lvl / 7
        local damagemod = damage * ((50 + (tp * 0.12)) / 160)
        damagemod = damagemod * xi.settings.main.WEAPON_SKILL_POWER

        applyMoonlightEffects(player, player)

        for _, member in pairs(player:getPartyWithTrusts()) do
            if member:getID() ~= player:getID() then
                applyMoonlightEffects(player, member)
            end
        end

        return 1, 0, false, damagemod
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/seraph_strike.lua
-----------------------------------
do
    -----------------------------------
    -- Seraph Strike
    -- Club weapon skill
    -- Skill level: 40
    -- Deals light elemental damage to enemy. Damage varies with TP.
    -- Aligned with the Thunder Gorget.
    -- Aligned with the Thunder Belt.
    -- Element: None
    -- Modifiers: STR:40%  MND:40%
    -- 100%TP    200%TP    300%TP
    -- 2.125     3.675      6.125
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.seraph_strike.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 2.0, 3.0 }
        params.str_wsc = 0.3 params.mnd_wsc = 0.3
        params.ele = xi.element.LIGHT
        params.skill = xi.skill.CLUB
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 2.125, 3.675, 6.125 }
            params.str_wsc = 0.4 params.mnd_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.LIGHT })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/shining_strike.lua
-----------------------------------
do
    -----------------------------------
    -- Shining Strike
    -- Club weapon skill
    -- Skill level: 5
    -- Deals light elemental damage to enemy. Damage varies with TP.
    -- Aligned with the Thunder Gorget.
    -- Aligned with the Thunder Belt.
    -- Element: None
    -- Modifiers: STR:40%  MND:40%
    -- 100%TP    200%TP    300%TP
    -- 1.625       3       4.625
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.shining_strike.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 1.75, 2.5 }
        params.str_wsc = 0.2 params.mnd_wsc = 0.2
        params.ele = xi.element.LIGHT
        params.skill = xi.skill.CLUB
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.625, 3.0, 4.625 }
            params.str_wsc = 0.4 params.mnd_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/skullbreaker.lua
-----------------------------------
do
    -----------------------------------
    -- Skullbreaker
    -- Club weapon skill
    -- Skill level: 150
    -- Lowers enemy's INT. Chance of lowering INT varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Snow Gorget & Aqua Gorget.
    -- Aligned with the Snow Belt & Aqua Belt.
    -- Element: None
    -- Modifiers: STR:100%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.skullbreaker.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params   = {}
        params.numHits = 1
        params.ftpMod  = { 1.25, 1.5, 1.75 }
        params.str_wsc = 0.5

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 1
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            target:addStatusEffect(xi.effect.DEFENSE_DOWN, { power = 10, duration = 60, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/starlight.lua
-----------------------------------
do
    -----------------------------------
    -- Starlight
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.starlight.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local lvl = player:getSkillLevel(11) -- get club skill
        local damage = (lvl / 5.5)
        local damagemod = damage * ((50 + (tp * 0.12)) / 150)
        damagemod = damagemod * xi.settings.main.WEAPON_SKILL_POWER
        player:addStatusEffect(xi.effect.REFRESH, { power = 1, duration = 60, origin = player })
        return 1, 0, false, damagemod
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/true_strike.lua
-----------------------------------
do
    -----------------------------------
    -- True Strike
    -- Club weapon skill
    -- Skill level: 175
    -- Deals params.critical damage. params.accuracy varies with TP.
    -- 100% Critical Hit Rate. Has a substantial accuracy penalty at 100TP. http://www.bg-wiki.com/bg/True_Strike
    -- Will stack with Sneak Attack.
    -- Aligned with the Breeze Gorget & Thunder Gorget.
    -- Aligned with the Breeze Belt & Thunder Belt.
    -- Element: None
    -- Modifiers: STR:100%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.00      1.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.true_strike.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.25, 1.25, 1.25 }
        params.str_wsc = 0.5
        params.critVaries = { 1.0, 1.0, 1.0 }
        -- params.accVaries = { -50, -50, -50 } -- TODO: verify exact number. Not used on Sanctum
        params.atkVaries  = { 2.0, 2.0, 2.0 }

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 1.0
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
