-----------------------------------
-- Sanctum weapon-skill Quick Draw integrations
-----------------------------------
require('modules/module_utils')
-----------------------------------

local sanctumModule = Module:new('sanctum_ws_quick_draw')

-----------------------------------
-- Source: scripts/actions/abilities/earth_shot.lua
-----------------------------------
do
-----------------------------------
-- Ability: Earth Shot
-- Consumes a Earth Card to enhance earth-based debuffs. Deals earth-based magic damage
-- Rasp Effect: Enhanced DoT and DEX-, Slow Effect +10%
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    --ranged weapon/ammo: You do not have an appropriate ranged weapon equipped.
    --no card: <name> cannot perform that action.
    if
        player:getWeaponSkillType(xi.slot.RANGED) ~= xi.skill.MARKSMANSHIP or
        player:getWeaponSkillType(xi.slot.AMMO) ~= xi.skill.MARKSMANSHIP
    then
        return 216, 0
    end

    if
        player:hasItem(xi.item.EARTH_CARD, 0) or
        player:hasItem(xi.item.TRUMP_CARD, 0)
    then
        return 0, 0
    else
        return 71, 0
    end
end

abilityObject.onUseAbility = function(player, target, ability, action)
    action:setRecast(math.max(0, action:getRecast() - player:getMod(xi.mod.QUICK_DRAW_RECAST)))
    local params = {}
    params.includemab = true

    local dmg = (2 * (player:getRangedDmg() + player:getAmmoDmg()) + player:getMod(xi.mod.QUICK_DRAW_DMG)) * (1 + player:getMod(xi.mod.QUICK_DRAW_DMG_PERCENT) / 100)
    dmg       = dmg + 2 * player:getJobPointLevel(xi.jp.QUICK_DRAW_EFFECT)
    dmg       = addBonusesAbility(player, xi.element.EARTH, target, dmg, params)

    local bonusAcc = player:getStat(xi.mod.AGI) / 2 + player:getMerit(xi.merit.QUICK_DRAW_ACCURACY) + player:getMod(xi.mod.QUICK_DRAW_MACC)
    dmg            = math.floor(dmg * xi.combat.magicHitRate.calculateResistRate(player, target, 0, 0, 0, xi.element.EARTH, 0, 0, bonusAcc))
    dmg            = math.floor(dmg * xi.spells.damage.calculateAbsorption(target, xi.element.EARTH, false))
    dmg            = math.floor(dmg * xi.spells.damage.calculateNullification(target, xi.element.EARTH, false, false))

    if xi.wsEffect.has(player, xi.wsEffect.DETONATOR_QUICK_DRAW) then
        dmg = math.floor(dmg * 1.5)
    end

    params.targetTPMult = 0 -- Quick Draw does not feed TP
    dmg = xi.ability.takeDamage(target, player, params, true, dmg, xi.attackType.MAGICAL, xi.damageType.EARTH, xi.slot.RANGED, 1, 0, 0, 0, action, nil)

    if dmg > 0 then
        local effects = {}

        local rasp = target:getStatusEffect(xi.effect.RASP)
        if rasp ~= nil then
            table.insert(effects, rasp)
        end

        local threnody = target:getStatusEffect(xi.effect.THRENODY)
        if threnody ~= nil and threnody:getSubPower() == xi.mod.THUNDER_MEVA then
            table.insert(effects, threnody)
        end

        local slow = target:getStatusEffect(xi.effect.SLOW)
        if slow ~= nil then
            table.insert(effects, slow)
        end

        if #effects > 0 then
            local effect    = effects[math.randomInt(1, #effects)]
            local duration  = effect:getDuration()
            local startTime = effect:getStartTime()
            local tick      = effect:getTick()
            local power     = effect:getPower()
            local subpower  = effect:getSubPower()
            local tier      = effect:getTier()
            local effectId  = effect:getEffectType()
            local subId     = effect:getSubType()
            power = power * 1.2
            target:delStatusEffectSilent(effectId)
            target:addStatusEffect(effectId, { power = power, duration = duration, origin = player, tick = tick, subType = subId, subPower = subpower, tier = tier })
            local newEffect = target:getStatusEffect(effectId)

            if newEffect then
                newEffect:setStartTime(startTime)
            end
        end
    end

    local _ = player:delItem(xi.item.EARTH_CARD, 1) or player:delItem(xi.item.TRUMP_CARD, 1)
    target:updateClaim(player)

    return dmg
end



    sanctumModule:addOverride('xi.actions.abilities.earth_shot.onAbilityCheck', abilityObject.onAbilityCheck)
    sanctumModule:addOverride('xi.actions.abilities.earth_shot.onUseAbility', abilityObject.onUseAbility)
end
-----------------------------------
-- Source: scripts/actions/abilities/fire_shot.lua
-----------------------------------
do
-----------------------------------
-- Ability: Fire Shot
-- Consumes a Fire Card to enhance fire-based debuffs. Deals fire-based magic damage
-- Burn effect: Enhanced DoT and INT-
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    --ranged weapon/ammo: You do not have an appropriate ranged weapon equipped.
    --no card: <name> cannot perform that action.
    if
        player:getWeaponSkillType(xi.slot.RANGED) ~= xi.skill.MARKSMANSHIP or
        player:getWeaponSkillType(xi.slot.AMMO) ~= xi.skill.MARKSMANSHIP
    then
        return 216, 0
    end

    if
        player:hasItem(xi.item.FIRE_CARD, 0) or
        player:hasItem(xi.item.TRUMP_CARD, 0)
    then
        return 0, 0
    else
        return 71, 0
    end
end

abilityObject.onUseAbility = function(player, target, ability, action)
    action:setRecast(math.max(0, action:getRecast() - player:getMod(xi.mod.QUICK_DRAW_RECAST)))
    local params = {}
    params.includemab = true

    local dmg = (2 * (player:getRangedDmg() + player:getAmmoDmg()) + player:getMod(xi.mod.QUICK_DRAW_DMG)) * (1 + player:getMod(xi.mod.QUICK_DRAW_DMG_PERCENT) / 100)
    dmg       = dmg + 2 * player:getJobPointLevel(xi.jp.QUICK_DRAW_EFFECT)
    dmg       = addBonusesAbility(player, xi.element.FIRE, target, dmg, params)

    local bonusAcc = player:getStat(xi.mod.AGI) / 2 + player:getMerit(xi.merit.QUICK_DRAW_ACCURACY) + player:getMod(xi.mod.QUICK_DRAW_MACC)
    dmg            = math.floor(dmg * xi.combat.magicHitRate.calculateResistRate(player, target, 0, 0, 0, xi.element.FIRE, 0, 0, bonusAcc))
    dmg            = math.floor(dmg * xi.spells.damage.calculateAbsorption(target, xi.element.FIRE, false))
    dmg            = math.floor(dmg * xi.spells.damage.calculateNullification(target, xi.element.FIRE, false, false))

    if xi.wsEffect.has(player, xi.wsEffect.DETONATOR_QUICK_DRAW) then
        dmg = math.floor(dmg * 1.5)
    end

    params.targetTPMult = 0 -- Quick Draw does not feed TP
    dmg                 = xi.ability.takeDamage(target, player, params, true, dmg, xi.attackType.MAGICAL, xi.damageType.FIRE, xi.slot.RANGED, 1, 0, 0, 0, action, nil)

    if dmg > 0 then
        local effects = {}

        local burn = target:getStatusEffect(xi.effect.BURN)
        if burn ~= nil then
            table.insert(effects, burn)
        end

        local threnody = target:getStatusEffect(xi.effect.THRENODY)
        if threnody ~= nil and threnody:getSubPower() == xi.mod.ICE_MEVA then
            table.insert(effects, threnody)
        end

        if #effects > 0 then
            local effect    = effects[math.randomInt(1, #effects)]
            local duration  = effect:getDuration()
            local startTime = effect:getStartTime()
            local tick      = effect:getTick()
            local power     = effect:getPower()
            local subpower  = effect:getSubPower()
            local tier      = effect:getTier()
            local effectId  = effect:getEffectType()
            local subId     = effect:getSubType()

            power = power * 1.2
            target:delStatusEffectSilent(effectId)
            target:addStatusEffect(effectId, { power = power, duration = duration, origin = player, tick = tick, subType = subId, subPower = subpower, tier = tier })

            local newEffect = target:getStatusEffect(effectId)
            if newEffect then
                newEffect:setStartTime(startTime)
            end
        end
    end

    local _ = player:delItem(xi.item.FIRE_CARD, 1) or player:delItem(xi.item.TRUMP_CARD, 1)
    target:updateClaim(player)

    return dmg
end



    sanctumModule:addOverride('xi.actions.abilities.fire_shot.onAbilityCheck', abilityObject.onAbilityCheck)
    sanctumModule:addOverride('xi.actions.abilities.fire_shot.onUseAbility', abilityObject.onUseAbility)
end
-----------------------------------
-- Source: scripts/actions/abilities/ice_shot.lua
-----------------------------------
do
-----------------------------------
-- Ability: Ice Shot
-- Consumes a Ice Card to enhance ice-based debuffs. Deals ice-based magic damage
-- Frost Effect: Enhanced DoT and AGI-
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    --ranged weapon/ammo: You do not have an appropriate ranged weapon equipped.
    --no card: <name> cannot perform that action.
    if
        player:getWeaponSkillType(xi.slot.RANGED) ~= xi.skill.MARKSMANSHIP or
        player:getWeaponSkillType(xi.slot.AMMO) ~= xi.skill.MARKSMANSHIP
    then
        return 216, 0
    end

    if
        player:hasItem(xi.item.ICE_CARD, 0) or
        player:hasItem(xi.item.TRUMP_CARD, 0)
    then
        return 0, 0
    else
        return 71, 0
    end
end

abilityObject.onUseAbility = function(player, target, ability, action)
    action:setRecast(math.max(0, action:getRecast() - player:getMod(xi.mod.QUICK_DRAW_RECAST)))
    local params = {}
    params.includemab = true

    local dmg = (2 * (player:getRangedDmg() + player:getAmmoDmg()) + player:getMod(xi.mod.QUICK_DRAW_DMG)) * (1 + player:getMod(xi.mod.QUICK_DRAW_DMG_PERCENT) / 100)
    dmg       = dmg + 2 * player:getJobPointLevel(xi.jp.QUICK_DRAW_EFFECT)
    dmg       = addBonusesAbility(player, xi.element.ICE, target, dmg, params)

    local bonusAcc = player:getStat(xi.mod.AGI) / 2 + player:getMerit(xi.merit.QUICK_DRAW_ACCURACY) + player:getMod(xi.mod.QUICK_DRAW_MACC)
    dmg            = math.floor(dmg * xi.combat.magicHitRate.calculateResistRate(player, target, 0, 0, 0, xi.element.ICE, 0, 0, bonusAcc))
    dmg            = math.floor(dmg * xi.spells.damage.calculateAbsorption(target, xi.element.ICE, false))
    dmg            = math.floor(dmg * xi.spells.damage.calculateNullification(target, xi.element.ICE, false, false))

    if xi.wsEffect.has(player, xi.wsEffect.DETONATOR_QUICK_DRAW) then
        dmg = math.floor(dmg * 1.5)
    end

    params.targetTPMult = 0 -- Quick Draw does not feed TP
    dmg                 = xi.ability.takeDamage(target, player, params, true, dmg, xi.attackType.MAGICAL, xi.damageType.ICE, xi.slot.RANGED, 1, 0, 0, 0, action, nil)

    if dmg > 0 then
        local effects = {}

        local frost = target:getStatusEffect(xi.effect.FROST)
        if frost ~= nil then
            table.insert(effects, frost)
        end

        local threnody = target:getStatusEffect(xi.effect.THRENODY)
        if threnody ~= nil and threnody:getSubPower() == xi.mod.WIND_MEVA then
            table.insert(effects, threnody)
        end

        local paralyze = target:getStatusEffect(xi.effect.PARALYSIS)
        if paralyze ~= nil then
            table.insert(effects, paralyze)
        end

        if #effects > 0 then
            local effect    = effects[math.randomInt(1, #effects)]
            local duration  = effect:getDuration()
            local startTime = effect:getStartTime()
            local tick      = effect:getTick()
            local power     = effect:getPower()
            local subpower  = effect:getSubPower()
            local tier      = effect:getTier()
            local effectId  = effect:getEffectType()
            local subId     = effect:getSubType()

            power = power * 1.2
            target:delStatusEffectSilent(effectId)
            target:addStatusEffect(effectId, { power = power, duration = duration, origin = player, tick = tick, subType = subId, subPower = subpower, tier = tier })

            local newEffect = target:getStatusEffect(effectId)
            if newEffect then
                newEffect:setStartTime(startTime)
            end
        end
    end

    local _ = player:delItem(xi.item.ICE_CARD, 1) or player:delItem(xi.item.TRUMP_CARD, 1)
    target:updateClaim(player)

    return dmg
end



    sanctumModule:addOverride('xi.actions.abilities.ice_shot.onAbilityCheck', abilityObject.onAbilityCheck)
    sanctumModule:addOverride('xi.actions.abilities.ice_shot.onUseAbility', abilityObject.onUseAbility)
end
-----------------------------------
-- Source: scripts/actions/abilities/thunder_shot.lua
-----------------------------------
do
-----------------------------------
-- Ability: Thunder Shot
-- Consumes a Thunder Card to enhance lightning-based debuffs. Deals lightning-based magic damage
-- Shock Effect: Enhanced DoT and MND-
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    --ranged weapon/ammo: You do not have an appropriate ranged weapon equipped.
    --no card: <name> cannot perform that action.
    if
        player:getWeaponSkillType(xi.slot.RANGED) ~= xi.skill.MARKSMANSHIP or
        player:getWeaponSkillType(xi.slot.AMMO) ~= xi.skill.MARKSMANSHIP
    then
        return 216, 0
    end

    if
        player:hasItem(xi.item.THUNDER_CARD, 0) or
        player:hasItem(xi.item.TRUMP_CARD, 0)
    then
        return 0, 0
    else
        return 71, 0
    end
end

abilityObject.onUseAbility = function(player, target, ability, action)
    action:setRecast(math.max(0, action:getRecast() - player:getMod(xi.mod.QUICK_DRAW_RECAST)))
    local params = {}
    params.includemab = true

    local dmg = (2 * (player:getRangedDmg() + player:getAmmoDmg()) + player:getMod(xi.mod.QUICK_DRAW_DMG)) * (1 + player:getMod(xi.mod.QUICK_DRAW_DMG_PERCENT) / 100)
    dmg       = dmg + 2 * player:getJobPointLevel(xi.jp.QUICK_DRAW_EFFECT)
    dmg       = addBonusesAbility(player, xi.element.THUNDER, target, dmg, params)

    local bonusAcc = player:getStat(xi.mod.AGI) / 2 + player:getMerit(xi.merit.QUICK_DRAW_ACCURACY) + player:getMod(xi.mod.QUICK_DRAW_MACC)
    dmg            = math.floor(dmg * xi.combat.magicHitRate.calculateResistRate(player, target, 0, 0, 0, xi.element.THUNDER, 0, 0, bonusAcc))
    dmg            = math.floor(dmg * xi.spells.damage.calculateAbsorption(target, xi.element.THUNDER, false))
    dmg            = math.floor(dmg * xi.spells.damage.calculateNullification(target, xi.element.THUNDER, false, false))

    if xi.wsEffect.has(player, xi.wsEffect.DETONATOR_QUICK_DRAW) then
        dmg = math.floor(dmg * 1.5)
    end

    params.targetTPMult = 0 -- Quick Draw does not feed TP
    dmg                 = xi.ability.takeDamage(target, player, params, true, dmg, xi.attackType.MAGICAL, xi.damageType.THUNDER, xi.slot.RANGED, 1, 0, 0, 0, action, nil)

    if dmg > 0 then
        local effects = {}

        local shock = target:getStatusEffect(xi.effect.SHOCK)

        if shock ~= nil then
            table.insert(effects, shock)
        end

        local threnody = target:getStatusEffect(xi.effect.THRENODY)

        if threnody ~= nil and threnody:getSubPower() == xi.mod.WATER_MEVA then
            table.insert(effects, threnody)
        end

        if #effects > 0 then
            local effect    = effects[math.randomInt(1, #effects)]
            local duration  = effect:getDuration()
            local startTime = effect:getStartTime()
            local tick      = effect:getTick()
            local power     = effect:getPower()
            local subpower  = effect:getSubPower()
            local tier      = effect:getTier()
            local effectId  = effect:getEffectType()
            local subId     = effect:getSubType()

            power = power * 1.2
            target:delStatusEffectSilent(effectId)
            target:addStatusEffect(effectId, { power = power, duration = duration, origin = player, tick = tick, subType = subId, subPower = subpower, tier = tier })

            local newEffect = target:getStatusEffect(effectId)
            if newEffect then
                newEffect:setStartTime(startTime)
            end
        end
    end

    local _ = player:delItem(xi.item.THUNDER_CARD, 1) or player:delItem(xi.item.TRUMP_CARD, 1)
    target:updateClaim(player)

    return dmg
end



    sanctumModule:addOverride('xi.actions.abilities.thunder_shot.onAbilityCheck', abilityObject.onAbilityCheck)
    sanctumModule:addOverride('xi.actions.abilities.thunder_shot.onUseAbility', abilityObject.onUseAbility)
end
-----------------------------------
-- Source: scripts/actions/abilities/water_shot.lua
-----------------------------------
do
-----------------------------------
-- Ability: Water Shot
-- Consumes a Water Card to enhance water-based debuffs. Deals water-based magic damage
-- Drown Effect: Enhanced DoT and STR-
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    --ranged weapon/ammo: You do not have an appropriate ranged weapon equipped.
    --no card: <name> cannot perform that action.
    if
        player:getWeaponSkillType(xi.slot.RANGED) ~= xi.skill.MARKSMANSHIP or
        player:getWeaponSkillType(xi.slot.AMMO) ~= xi.skill.MARKSMANSHIP
    then
        return 216, 0
    end

    if
        player:hasItem(xi.item.WATER_CARD, 0) or
        player:hasItem(xi.item.TRUMP_CARD, 0)
    then
        return 0, 0
    else
        return 71, 0
    end
end

abilityObject.onUseAbility = function(player, target, ability, action)
    action:setRecast(math.max(0, action:getRecast() - player:getMod(xi.mod.QUICK_DRAW_RECAST)))
    local params = {}
    params.includemab = true

    local dmg = (2 * (player:getRangedDmg() + player:getAmmoDmg()) + player:getMod(xi.mod.QUICK_DRAW_DMG)) * (1 + player:getMod(xi.mod.QUICK_DRAW_DMG_PERCENT) / 100)
    dmg       = dmg + 2 * player:getJobPointLevel(xi.jp.QUICK_DRAW_EFFECT)
    dmg       = addBonusesAbility(player, xi.element.WATER, target, dmg, params)

    local bonusAcc = player:getStat(xi.mod.AGI) / 2 + player:getMerit(xi.merit.QUICK_DRAW_ACCURACY) + player:getMod(xi.mod.QUICK_DRAW_MACC)
    dmg            = math.floor(dmg * xi.combat.magicHitRate.calculateResistRate(player, target, 0, 0, 0, xi.element.WATER, 0, 0, bonusAcc))
    dmg            = math.floor(dmg * xi.spells.damage.calculateAbsorption(target, xi.element.WATER, false))
    dmg            = math.floor(dmg * xi.spells.damage.calculateNullification(target, xi.element.WATER, false, false))

    if xi.wsEffect.has(player, xi.wsEffect.DETONATOR_QUICK_DRAW) then
        dmg = math.floor(dmg * 1.5)
    end

    params.targetTPMult = 0 -- Quick Draw does not feed TP
    dmg                 = xi.ability.takeDamage(target, player, params, true, dmg, xi.attackType.MAGICAL, xi.damageType.WATER, xi.slot.RANGED, 1, 0, 0, 0, action, nil)

    if dmg > 0 then
        local effects = {}

        local drown = target:getStatusEffect(xi.effect.DROWN)
        if drown ~= nil then
            table.insert(effects, drown)
        end

        local poison = target:getStatusEffect(xi.effect.POISON)
        if poison ~= nil then
            table.insert(effects, poison)
        end

        local threnody = target:getStatusEffect(xi.effect.THRENODY)
        if threnody ~= nil and threnody:getSubPower() == xi.mod.FIRE_MEVA then
            table.insert(effects, threnody)
        end

        if #effects > 0 then
            local effect    = effects[math.randomInt(1, #effects)]
            local duration  = effect:getDuration()
            local startTime = effect:getStartTime()
            local tick      = effect:getTick()
            local power     = effect:getPower()
            local subpower  = effect:getSubPower()
            local tier      = effect:getTier()
            local effectId  = effect:getEffectType()
            local subId     = effect:getSubType()

            power = power * 1.2
            target:delStatusEffectSilent(effectId)
            target:addStatusEffect(effectId, { power = power, duration = duration, origin = player, tick = tick, subType = subId, subPower = subpower, tier = tier })

            local newEffect = target:getStatusEffect(effectId)
            if newEffect then
                newEffect:setStartTime(startTime)
            end
        end
    end

    local _ = player:delItem(xi.item.WATER_CARD, 1) or player:delItem(xi.item.TRUMP_CARD, 1)
    target:updateClaim(player)

    return dmg
end



    sanctumModule:addOverride('xi.actions.abilities.water_shot.onAbilityCheck', abilityObject.onAbilityCheck)
    sanctumModule:addOverride('xi.actions.abilities.water_shot.onUseAbility', abilityObject.onUseAbility)
end
-----------------------------------
-- Source: scripts/actions/abilities/wind_shot.lua
-----------------------------------
do
-----------------------------------
-- Ability: Wind Shot
-- Consumes a Wind Card to enhance wind-based debuffs. Deals wind-based magic damage
-- Choke Effect: Enhanced DoT and VIT-
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    --ranged weapon/ammo: You do not have an appropriate ranged weapon equipped.
    --no card: <name> cannot perform that action.
    if
        player:getWeaponSkillType(xi.slot.RANGED) ~= xi.skill.MARKSMANSHIP or
        player:getWeaponSkillType(xi.slot.AMMO) ~= xi.skill.MARKSMANSHIP
    then
        return 216, 0
    end

    if
        player:hasItem(xi.item.WIND_CARD, 0) or
        player:hasItem(xi.item.TRUMP_CARD, 0)
    then
        return 0, 0
    else
        return 71, 0
    end
end

abilityObject.onUseAbility = function(player, target, ability, action)
    action:setRecast(math.max(0, action:getRecast() - player:getMod(xi.mod.QUICK_DRAW_RECAST)))
    local params = {}
    params.includemab = true

    local dmg = (2 * (player:getRangedDmg() + player:getAmmoDmg()) + player:getMod(xi.mod.QUICK_DRAW_DMG)) * (1 + player:getMod(xi.mod.QUICK_DRAW_DMG_PERCENT) / 100)
    dmg       = dmg + 2 * player:getJobPointLevel(xi.jp.QUICK_DRAW_EFFECT)
    dmg       = addBonusesAbility(player, xi.element.WIND, target, dmg, params)

    local bonusAcc = player:getStat(xi.mod.AGI) / 2 + player:getMerit(xi.merit.QUICK_DRAW_ACCURACY) + player:getMod(xi.mod.QUICK_DRAW_MACC)
    dmg            = math.floor(dmg * xi.combat.magicHitRate.calculateResistRate(player, target, 0, 0, 0, xi.element.WIND, 0, 0, bonusAcc))
    dmg            = math.floor(dmg * xi.spells.damage.calculateAbsorption(target, xi.element.WIND, false))
    dmg            = math.floor(dmg * xi.spells.damage.calculateNullification(target, xi.element.WIND, false, false))

    if xi.wsEffect.has(player, xi.wsEffect.DETONATOR_QUICK_DRAW) then
        dmg = math.floor(dmg * 1.5)
    end

    params.targetTPMult = 0 -- Quick Draw does not feed TP
    dmg                 = xi.ability.takeDamage(target, player, params, true, dmg, xi.attackType.MAGICAL, xi.damageType.WIND, xi.slot.RANGED, 1, 0, 0, 0, action, nil)

    if dmg > 0 then
        local effects = {}

        local choke = target:getStatusEffect(xi.effect.CHOKE)

        if choke ~= nil then
            table.insert(effects, choke)
        end

        local threnody = target:getStatusEffect(xi.effect.THRENODY)

        if threnody ~= nil and threnody:getSubPower() == xi.mod.EARTH_MEVA then
            table.insert(effects, threnody)
        end

        --TODO: Frightful Roar
        --[[local frightfulRoar = target:getStatusEffect(xi.effect.)
        if (frightfulRoar ~= nil) then
            effects[counter] = frightfulRoar
            counter = counter + 1
        end]]

        if #effects > 0 then
            local effect    = effects[math.randomInt(1, #effects)]
            local duration  = effect:getDuration()
            local startTime = effect:getStartTime()
            local tick      = effect:getTick()
            local power     = effect:getPower()
            local subpower  = effect:getSubPower()
            local tier      = effect:getTier()
            local effectId  = effect:getEffectType()
            local subId     = effect:getSubType()

            power = power * 1.2
            target:delStatusEffectSilent(effectId)
            target:addStatusEffect(effectId, { power = power, duration = duration, origin = player, tick = tick, subType = subId, subPower = subpower, tier = tier })

            local newEffect = target:getStatusEffect(effectId)
            if newEffect then
                newEffect:setStartTime(startTime)
            end
        end
    end

    local _ = player:delItem(xi.item.WIND_CARD, 1) or player:delItem(xi.item.TRUMP_CARD, 1)
    target:updateClaim(player)

    return dmg
end



    sanctumModule:addOverride('xi.actions.abilities.wind_shot.onAbilityCheck', abilityObject.onAbilityCheck)
    sanctumModule:addOverride('xi.actions.abilities.wind_shot.onUseAbility', abilityObject.onUseAbility)
end

return sanctumModule