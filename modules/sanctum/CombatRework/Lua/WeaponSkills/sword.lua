-----------------------------------
-- Sanctum custom weapon skills
-- Weapon type: sword
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_combat_weaponskills_sword')

-----------------------------------
-- Source: scripts/actions/weaponskills/atonement.lua
-----------------------------------
do
    -----------------------------------
    -- Atonement
    -- TODO: This needs to be reworked, as this weapon skill does damage based on current enmity, not based on stat modifiers. http://wiki.ffxiclopedia.org/wiki/Atonement    http://www.bg-wiki.com/bg/Atonement
    -- Sword weapon skill
    -- Skill Level: N/A
    -- Delivers a Twofold attack. Enmity varies with TP. Burtgang: Aftermath effect varies with TP.
    -- Available only after completing the Unlocking a Myth (Paladin) quest.
    -- Aligned with the Aqua Gorget, Flame Gorget & Light Gorget.
    -- Aligned with the Aqua Belt, Flame Belt & Light Belt.
    -- Element: None
    -- Modifiers (old): damage varies with enmity
    -- 100%TP    200%TP    300%TP
    -- 0.09      0.11      0.20   -CE
    -- 0.11      0.14      0.25   -VE
    -- Modifiers (new): enmity from damage varies with TP
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.5       2.0
    -- Modifiers (non-mob, wrong): STR:40% VIT:50%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.25      1.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.atonement.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits    = 2
        params.ftpMod     = { 1, 1.25, 1.5 }
        params.str_wsc    = 0.4
        params.vit_wsc    = 0.5
        params.enmityMult = 1

        -- Apply aftermath
        xi.aftermath.addStatusEffect(player, tp, xi.slot.MAIN, xi.aftermath.type.MYTHIC)

        local attack =
        {
            ['type'] = xi.attackType.BREATH,
            ['slot'] = xi.slot.MAIN,
            ['weaponType'] = player:getWeaponSkillType(xi.slot.MAIN),
            ['damageType'] = xi.damageType.ELEMENTAL
        }
        local calcParams =
        {
            wsID            = wsID,
            criticalHit     = false,
            hitsLanded      = 1,
            tpHitsLanded    = 0,
            extraHitsLanded = 0,
            shadowsAbsorbed = 0,
            bonusTP         = 0
        }

        local damage = 0

        -- Calculate damage caps (item level and level based)
        local levelUsed       = player:getAverageItemLevel() > 99 and player:getAverageItemLevel() or player:getMainLvl()
        -- local hitDamageCap    = (levelUsed + 14) * 5 -- iLvl 119 -> 665
        local globalDamageCap = levelUsed * 10       -- iLvl 119 -> 1190

        -- If the target isn't a mob,theres no enmity to calculate with.
        if target:getObjType() ~= xi.objType.MOB then
            params.ftpMod = { 1, 1.5, 2 }

            damage, calcParams.criticalHit, calcParams.tpHitsLanded, calcParams.extraHitsLanded = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)
            return calcParams.tpHitsLanded, calcParams.extraHitsLanded, calcParams.criticalHit, damage
        end

        -- Calculate damage based on target's CE and VE, clamped to the global damage cap.
        damage = utils.clamp((target:getCE(player) + target:getVE(player)) / 6, 0, globalDamageCap)

        -- TP affects enmity multiplier, 1.0 at 1k, 1.5 at 2k, 2.0 at 3k. Gorget/Belt adds 100 tp each.
        params.enmityMult = params.enmityMult + (tp + xi.combat.physical.calculateFTPBonus(player) * 1000 - 1000) / 2000
        params.enmityMult = utils.clamp(params.enmityMult, 1, 2) -- necessary because of Gorget/Belt bonus

        damage = math.floor(damage * xi.combat.damage.calculateDamageAdjustment(target, false, false, false, true))
        damage = math.floor(damage * xi.spells.damage.calculateAbsorption(target, xi.element.NONE, false))
        damage = math.floor(damage * xi.spells.damage.calculateNullification(target, xi.element.NONE, false, true))
        damage = math.floor(target:handleSevereDamage(damage, false))

        if player:getMod(xi.mod.WEAPONSKILL_DAMAGE_BASE + wsID) > 0 then
            damage = damage * (100 + player:getMod(xi.mod.WEAPONSKILL_DAMAGE_BASE + wsID)) / 100
        end

        calcParams.finalDmg = damage

        if damage > 0 then
            if player:getOffhandDmg() > 0 then
                calcParams.tpHitsLanded = 2
            else
                calcParams.tpHitsLanded = 1
            end

            -- Atonement always yields the a TP return of a 2 hit WS (unless it does 0 damage), because if one hit lands, both hits do.
            calcParams.extraHitsLanded = 1
        end

        damage = xi.weaponskills.takeWeaponskillDamage(target, player, params, primary, attack, calcParams, action)

        if damage == 0 then
            -- The logic above sets the action as a miss if CE/VE are 0 on the target
            -- because the landed hits are (correctly) set to 0
            -- Atonement is not known to miss and should always report as a hit.
            -- It is fairly unique in that regard, which is why it is handled as a special case here.
            action:resolution(target:getID(), xi.action.resolution.HIT)
            action:messageID(target:getID(), xi.msg.basic.DAMAGE)
        end

        return calcParams.tpHitsLanded, calcParams.extraHitsLanded, calcParams.criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/burning_blade.lua
-----------------------------------
do
    -----------------------------------
    -- Burning Blade
    -- Sword weapon skill
    -- Skill Level: 30
    -- Desription: Deals Fire elemental damage to enemy. Damage varies with TP.
    -- Aligned with the Flame Gorget.
    -- Aligned with the Flame Belt.
    -- Element: Fire
    -- Modifiers: STR:20%  INT:20%
    -- 100%TP    200%TP    300%TP
    -- 1.00      2.00      2.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.burning_blade.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 2.0, 2.5 }
        params.str_wsc = 0.2 params.int_wsc = 0.2
        params.ele = xi.element.FIRE
        params.skill = xi.skill.SWORD
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.0, 2.1, 3.4 }
            params.str_wsc = 0.4 params.int_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            local swordSkill = player:getSkillLevel(xi.skill.SWORD)
            local burnPower  = math.min(15, 3 + math.floor(swordSkill / 20))

            target:addStatusEffect(xi.effect.BURN, { power = burnPower, duration = 45, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/fast_blade.lua
-----------------------------------
do
    -----------------------------------
    -- Fast Blade
    -- Sword weapon skill
    -- Skill Level: 5
    -- Delivers a two-hit attack. Damage varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Soil Gorget.
    -- Aligned with the Soil Belt.
    -- Element: None
    -- Modifiers: STR:20%  DEX:20%
    -- 100%TP    200%TP    300%TP
    -- 1.00      1.50      2.00
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.fast_blade.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.0, 1.5, 2.0 }
        params.str_wsc = 0.2 params.dex_wsc = 0.2

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.4 params.dex_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            player:addStatusEffect(xi.effect.REGEN, { power = 2, duration = 30, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/red_lotus_blade.lua
-----------------------------------
do
    -----------------------------------
    -- Red Lotus Blade
    -- Sword weapon skill
    -- Skill Level: 50
    -- Deals fire elemental damage to enemy. Damage varies with TP.
    -- Aligned with the Flame Gorget & Breeze Gorget.
    -- Aligned with the Flame Belt & Breeze Belt.
    -- Element: Fire
    -- Modifiers: STR:40%  INT:40%
    -- 100%TP    200%TP    300%TP
    -- 1.00      2.38      3.75
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.red_lotus_blade.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 2.5, 3.0 }
        params.str_wsc = 0.3 params.int_wsc = 0.4
        params.ele = xi.element.FIRE
        params.skill = xi.skill.SWORD
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.0, 2.38, 3.75 }
            params.str_wsc = 0.4 params.int_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.ELEMENTALRES_DOWN, { power = 15, duration = 45, origin = player, subPower = xi.element.FIRE })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/savage_blade.lua
-----------------------------------
do
    -----------------------------------
    -- Savage Blade
    -- Sword weapon skill
    -- Skill Level: 240
    -- Delivers an aerial attack comprised of two hits. Damage varies with TP.
    -- In order to obtain Savage Blade, the quest Old Wounds must be completed.
    -- Will stack with Sneak Attack.
    -- Aligned with the Breeze Gorget, Thunder Gorget & Soil Gorget
    -- Aligned with the Breeze Belt, Thunder Belt & Soil Belt.
    -- Element: None
    -- Modifiers: STR:50%  MND:50%
    -- 100%TP    200%TP    300%TP
    -- 4.00      10.25      13.75
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.savage_blade.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 2
        params.ftpMod = { 1.75, 2.25, 3.0 }
        params.str_wsc = 0.4
        params.mnd_wsc = 0.4

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 4.0, 10.25, 13.75 }
            params.str_wsc = 0.5
        end

        if player:getMainJob() == xi.job.PLD then
            params.vit_wsc = 0.6
            params.str_wsc = 0.3
            params.mnd_wsc = 0.0
            params.bonusWSmods = math.floor(player:getStat(xi.mod.DEF) / 10)
        end

        local damage, criticalHit, tpHits, extraHits =
            xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if damage > 0 then
            local duration = 45 + math.floor((tp - 1000) / 100) * 3

            if xi.wsEffect.set(player, xi.wsEffect.SAVAGE_BLADE_DAMAGE, 15, duration) then
                xi.wsEffect.message(player, 'Damage increased by 15%, and enmity generation is increased by 25%!')
            end
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/seraph_blade.lua
-----------------------------------
do
    -----------------------------------
    -- Seraph Blade
    -- Sword weapon skill
    -- Skill Level: 125
    -- Deals light elemental damage to enemy. Damage varies with TP.
    -- Ignores shadows.
    -- Aligned with the Soil Gorget.
    -- Aligned with the Soil Belt.
    -- Element: Light
    -- Modifiers: STR:40%  MND:40%
    -- 100%TP    200%TP    300%TP
    -- 1.125      2.625      4.125
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.seraph_blade.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod = { 1.0, 2.5, 3.0 }
        params.str_wsc = 0.3 params.mnd_wsc = 0.3
        params.ele = xi.element.LIGHT
        params.skill = xi.skill.SWORD
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.125, 2.625, 4.125 }
            params.str_wsc = 0.4 params.mnd_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/shining_blade.lua
-----------------------------------
do
    -----------------------------------
    -- Shining Blade
    -- Sword weapon skill
    -- Skill Level: 100
    -- Deals light elemental damage to enemy. Damage varies with TP.
    -- Aligned with the Soil Gorget.
    -- Aligned with the Soil Belt.
    -- Element: Light
    -- Modifiers: STR:40%  MND:40%
    -- 100%TP    200%TP    300%TP
    -- 1.125      2.222      3.523
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.shining_blade.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 1
        params.ftpMod = { 1.0, 2.0, 2.5 }
        params.str_wsc = 0.2 params.mnd_wsc = 0.2
        params.ele = xi.element.LIGHT
        params.skill = xi.skill.SWORD
        params.includemab = true

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod = { 1.125, 2.222, 3.523 }
            params.str_wsc = 0.4 params.mnd_wsc = 0.4
        end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

        if damage > 0 then
            target:addStatusEffect(xi.effect.FLASH, { power = 100, duration = 5, origin = player })
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/spirits_within.lua
-----------------------------------
do
    -----------------------------------
    -- Spirits Within
    -- Sword weapon skill
    -- Spirits Within Sword Weapon Skill
    -- TrolandAdded by Troland
    -- Skill Level: 175
    -- Delivers an unavoidable attack. Damage varies with HP and TP.
    -- Not aligned with any "elemental gorgets" or "elemental belts" due to it's absence of Skillchain properties.
    -- Element: None
    -- Modifiers: HP:
    -- 100%TP    200%TP    300%TP
    -- 12.5%       50%      100%
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.spirits_within.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.ftpMod  = { 0.0625, 0.1875, 0.46875 } -- https://www.bg-wiki.com/index.php?title=Spirits_Within&oldid=269806

        local attack =
        {
            ['type'] = xi.attackType.BREATH,
            ['slot'] = xi.slot.MAIN,
            ['weaponType'] = player:getWeaponSkillType(xi.slot.MAIN),
            ['damageType'] = xi.damageType.ELEMENTAL
        }

        local calcParams =
        {
            wsID = wsID, -- need 'calcParams.wsID' passed to global
            criticalHit = false,
            hitsLanded = 1,
            tpHitsLanded = 0,
            extraHitsLanded = 0,
            shadowsAbsorbed = 0,
            bonusTP = 0
        }

        local playerHP = player:getHP()
        local dmg = 0

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.ftpMod  = { 0.125, 0.5, 1 } -- https://www.bg-wiki.com/ffxi/Spirits_Within
        end

        local ftp = xi.weaponskills.fTP(tp, params.ftpMod)
        dmg = math.floor(playerHP * ftp)

        local damage = dmg
        damage = math.floor(damage * xi.combat.damage.calculateDamageAdjustment(target, false, false, false, true))
        damage = math.floor(damage * xi.spells.damage.calculateAbsorption(target, xi.element.NONE, false))
        damage = math.floor(damage * xi.spells.damage.calculateNullification(target, xi.element.NONE, false, true))
        damage = math.floor(target:handleSevereDamage(damage, false))

        if damage > 0 then
            if player:getOffhandDmg() > 0 then
                calcParams.tpHitsLanded = 2
            else
                calcParams.tpHitsLanded = 1
            end
        end

        if player:getMod(xi.mod.WEAPONSKILL_DAMAGE_BASE + wsID) > 0 then
            damage = damage * (100 + player:getMod(xi.mod.WEAPONSKILL_DAMAGE_BASE + wsID)) / 100
        end

        damage = damage * xi.settings.main.WEAPON_SKILL_POWER
        calcParams.finalDmg = damage

        -- Todo: xi.weaponskills.doBreathWeaponskill() instead of all this.
        damage = xi.weaponskills.takeWeaponskillDamage(target, player, {}, primary, attack, calcParams, action)

        return calcParams.tpHitsLanded, calcParams.extraHitsLanded, calcParams.criticalHit, damage
    end)
end

-----------------------------------
-- Source: scripts/actions/weaponskills/swift_blade.lua
-----------------------------------
do
    -----------------------------------
    -- Swift Blade
    -- Sword weapon skill
    -- Skill Level: 225
    -- Delivers a three-hit attack. params.accuracy varies with TP.
    -- Will stack with Sneak Attack.
    -- Aligned with the Shadow Gorget & Soil Gorget.
    -- Aligned with the Shadow Belt & Soil Belt.
    -- Element: None
    -- Modifiers: STR:50%  MND:50%
    -- 100%TP    200%TP    300%TP
    -- 1.50      1.50      1.50
    -----------------------------------
    m:addOverride('xi.actions.weaponskills.swift_blade.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
        local params = {}
        params.numHits = 3
        params.ftpMod = { 1.5, 1.7, 1.9 }
        params.vit_wsc = 0.5
        params.mnd_wsc = 0.4
        -- Sufficient data for ACC bonus/penalty does not exist; assuming no penalty and 10% increase per 1000 TP
        -- http://wiki.ffo.jp/html/382.html does not list ACC Bonus
        -- https://www.bg-wiki.com/ffxi/Swift_Blade does not list ACC Bonus
        params.accVaries = { 15, 30, 60 } -- TODO: verify exact number

        if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
            params.str_wsc = 0.5 params.mnd_wsc = 0.5
            params.multiHitfTP = true
        end

            -- Sanctum Custom: PLD-enhanced Swift Blade
        -- if player:getMainJob() == xi.job.PLD then
        --    params.vit_wsc = 0.7
        --    params.str_wsc = 0.3
        -- end

        local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doPhysicalWeaponskill(player, target, wsID, params, tp, action, primary, taChar)

        if
            damage > 0 and
            xi.wsEffect.set(player, xi.wsEffect.SWIFT_BLADE_CRIT, 15, 60)
        then
            xi.wsEffect.message(player, 'Your next Sword weaponskill gains +15% critical hit rate!')
        end

        return tpHits, extraHits, criticalHit, damage
    end)
end

return m
