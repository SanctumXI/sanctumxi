-----------------------------------
-- Sanctum weapon-skill effect support
-- Source: scripts/globals/ws_system.lua
-----------------------------------
require('modules/module_utils')
-----------------------------------

-----------------------------------
-- Weaponskill Custom Effect System
-----------------------------------

xi = xi or {}

-- Keep the custom IDs with the subsystem instead of requiring edits to the
-- Lua enum files. The matching C++ integrations are documented in README.md.
xi.effect = xi.effect or {}
xi.mod    = xi.mod or {}

xi.effect.EMPOWERED = xi.effect.EMPOWERED or 635
xi.effect.RESOLVE   = xi.effect.RESOLVE or 810

xi.mod.BLADE_TEN_NINJUTSU       = xi.mod.BLADE_TEN_NINJUTSU or 1206
xi.mod.SPIRAL_HELL_FORCE_CRIT   = xi.mod.SPIRAL_HELL_FORCE_CRIT or 1207
xi.mod.SAVAGE_BLADE_ENMITY      = xi.mod.SAVAGE_BLADE_ENMITY or 1208
xi.mod.SAVAGE_BLADE_DAMAGE      = xi.mod.SAVAGE_BLADE_DAMAGE or 1209

xi.wsEffect =
{
    NONE              = 0,
    CHAKRA_BOOST      = 1,
    BLAST_ARROW_ACC   = 2,
    CUSTOM_MOD        = 3,
    CALAMITY_AXE_CRIT = 4,
    JUDGMENT_HOLY_DMG = 5,
    BLACK_HALO_BASH   = 6,
    BLACK_HALO_CRIT   = 7,
    BLACK_HALO_MP     = 8,
    DANCING_EDGE_SA   = 9,
    EVISCERATION_CRIT = 10,
    FULL_BREAK_DAMAGE = 11,
    STEEL_CYCLONE_DEF = 12,
    TACHI_GEKKO_DAMAGE = 13,
    TACHI_KASHA_TP     = 14,
    SICKLE_MOON_DRAIN  = 15,
    GROUND_STRIKE_BASH = 16,
    GROUND_STRIKE_DA   = 17,
    GROUND_STRIKE_HOLY = 18,
    ASURAN_FISTS_COMBO = 19,
    BLADE_TEN_NINJUTSU = 20,
    WHEELING_THRUST_JUMP = 21,
    IMPULSE_DRIVE_DAMAGE = 22,
    BLAST_SHOT_ACC       = 23,
    DETONATOR_QUICK_DRAW = 24,
    DETONATOR_BARRAGE    = 25,
    CROSS_REAPER_MB      = 26,
    SPIRAL_HELL_ABSORB   = 27,
    SPIRAL_HELL_CRIT     = 28,
    SWIFT_BLADE_CRIT     = 29,
    SAVAGE_BLADE_DAMAGE  = 30,
    FULL_SWING_DAMAGE    = 31,
    WEAPON_BASH_ELEMENTAL = 32,
    SPIRIT_TAKER_ECHO     = 33,
    SPIRIT_TAKER_SMN_PET_DAMAGE = 34,
}

-----------------------------------
-- Weaponskill Custom Effect Helpers
-----------------------------------

xi.wsEffect.charVars =
{
    EFFECT = 'Sanctum_wsEffect',
    POWER  = 'Sanctum_wsPower',
    EXPIRE = 'Sanctum_wsExpire',
}

xi.wsEffect.weaponChangeListener = 'WS_EMPOWERED_WEAPON_CHANGE'

xi.wsEffect.clear = function(player)
    local effect = player:getCharVar(xi.wsEffect.charVars.EFFECT)
    local power  = player:getCharVar(xi.wsEffect.charVars.POWER)

    player:removeListener(xi.wsEffect.weaponChangeListener)

    if effect == xi.wsEffect.CUSTOM_MOD then
        xi.wsEffect.clearTrackedMods(player)
    elseif effect == xi.wsEffect.DANCING_EDGE_SA then
        player:delMod(xi.mod.AUGMENTS_SA, power)
    elseif effect == xi.wsEffect.BLACK_HALO_CRIT then
        player:delMod(xi.mod.CRIT_DMG_INCREASE, power)
    elseif effect == xi.wsEffect.TACHI_KASHA_TP then
        player:delMod(xi.mod.WS_NO_DEPLETE, power)
    elseif effect == xi.wsEffect.GROUND_STRIKE_DA then
        player:delMod(xi.mod.DOUBLE_ATTACK, power)
    elseif effect == xi.wsEffect.BLADE_TEN_NINJUTSU then
        player:delMod(xi.mod.BLADE_TEN_NINJUTSU, 1)
    elseif effect == xi.wsEffect.DETONATOR_BARRAGE then
        player:delMod(xi.mod.BARRAGE_COUNT, power)
    elseif effect == xi.wsEffect.SPIRAL_HELL_CRIT then
        player:delMod(xi.mod.CRIT_DMG_INCREASE, power)
        player:delMod(xi.mod.SPIRAL_HELL_FORCE_CRIT, 1)
        player:setLocalVar('SpiralHellAttackCount', 0)
    elseif effect == xi.wsEffect.SAVAGE_BLADE_DAMAGE then
        player:delMod(xi.mod.SAVAGE_BLADE_ENMITY, 1)
        player:delMod(xi.mod.SAVAGE_BLADE_DAMAGE, power)
    end

    player:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
    player:setCharVar(xi.wsEffect.charVars.POWER, 0)
    player:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)

    player:delStatusEffect(xi.effect.EMPOWERED)
end

xi.wsEffect.set = function(player, effect, power, duration)
    -- An empowered weaponskill always replaces the previous empowered effect.
    -- This refreshes matching effects and clears any effect from another WS,
    -- including its temporary modifiers and listeners.
    if xi.wsEffect.peek(player) ~= xi.wsEffect.NONE then
        xi.wsEffect.clear(player)
    end

    player:setCharVar(xi.wsEffect.charVars.EFFECT, effect or xi.wsEffect.NONE)
    player:setCharVar(xi.wsEffect.charVars.POWER, power or 0)
    player:setCharVar(xi.wsEffect.charVars.EXPIRE, GetSystemTime() + (duration or 30))

    player:delStatusEffect(xi.effect.EMPOWERED)

    -- Weapon Bash's spell bonus is intentionally hidden; other custom effects use the Empowered icon.
    if effect ~= xi.wsEffect.WEAPON_BASH_ELEMENTAL then
        player:addStatusEffect(xi.effect.EMPOWERED, { power = 1, duration = duration or 30, origin = player })
    end

    return true
end

xi.wsEffect.isExpired = function(player)
    local expire = player:getCharVar(xi.wsEffect.charVars.EXPIRE)

    return expire > 0 and GetSystemTime() > expire
end

xi.wsEffect.peek = function(player)
    if xi.wsEffect.isExpired(player) then
        xi.wsEffect.clear(player)
        return xi.wsEffect.NONE, 0
    end

    local effect = player:getCharVar(xi.wsEffect.charVars.EFFECT)
    local power  = player:getCharVar(xi.wsEffect.charVars.POWER)

    return effect, power
end

xi.wsEffect.has = function(player, effect)
    local currentEffect = xi.wsEffect.peek(player)

    return currentEffect == effect
end

xi.wsEffect.consume = function(player)
    local effect, power = xi.wsEffect.peek(player)

    if effect ~= xi.wsEffect.NONE then
        xi.wsEffect.clear(player)
    end

    return effect, power
end

xi.wsEffect.message = function(player, message, delay)
    player:printToPlayer(message, xi.msg.channel.SYSTEM_3)
end

-- Returns Spirit Taker's temporary Blood Pact damage bonus for an avatar.
xi.wsEffect.getSpiritTakerSummonerPetDamageBonus = function(pet)
    if not pet:isAvatar() then
        return 0
    end

    local master = pet:getMaster()

    if
        master and
        xi.wsEffect.has(master, xi.wsEffect.SPIRIT_TAKER_SMN_PET_DAMAGE)
    then
        local _, power = xi.wsEffect.peek(master)
        return power
    end

    return 0
end

xi.wsEffect.applyDamageBonus = function(player, damage)
    if xi.wsEffect.has(player, xi.wsEffect.FULL_BREAK_DAMAGE) then
        local _, power = xi.wsEffect.peek(player)

        return math.floor(damage * (100 + power) / 100)
    elseif xi.wsEffect.has(player, xi.wsEffect.SAVAGE_BLADE_DAMAGE) then
        local _, power = xi.wsEffect.peek(player)

        return math.floor(damage * (100 + power) / 100)
    end

    return damage
end

xi.wsEffect.applyMagicBurstBonus = function(player, damage, isMagicBurst)
    if isMagicBurst and xi.wsEffect.has(player, xi.wsEffect.CROSS_REAPER_MB) then
        local _, power = xi.wsEffect.peek(player)

        player:timer(0, function(playerArg)
            if xi.wsEffect.has(playerArg, xi.wsEffect.CROSS_REAPER_MB) then
                xi.wsEffect.consume(playerArg)
                xi.wsEffect.message(playerArg, 'Cross Reaper empowered your magic burst!')
            end
        end)

        return math.floor(damage * (100 + power) / 100)
    end

    return damage
end

xi.wsEffect.consumeKasha = function(player)
    if xi.wsEffect.has(player, xi.wsEffect.TACHI_KASHA_TP) then
        xi.wsEffect.consume(player)
        xi.wsEffect.message(player, 'Tachi: Kasha empowered this weaponskill.')
    end
end

-----------------------------------
-- Temporary Mod Helpers for Custom Buffs
-----------------------------------

xi.wsEffect.modCharVar = function(mod)
    return string.format('Sanctum_WsEffectMod_%s', mod)
end

xi.wsEffect.modTokenCharVar = function(mod)
    return string.format('Sanctum_WsEffectModToken_%s', mod)
end

xi.wsEffect.trackedMods = xi.wsEffect.trackedMods or {}

xi.wsEffect.hasActiveMod = function(player)
    for mod in pairs(xi.wsEffect.trackedMods) do
        if player:getCharVar(xi.wsEffect.modCharVar(mod)) ~= 0 then
            return true
        end
    end

    return false
end

xi.wsEffect.clearMod = function(player, mod, power)
    local activeVar = xi.wsEffect.modCharVar(mod)

    if player:getCharVar(activeVar) == power then
        player:delMod(mod, power)
        player:setCharVar(activeVar, 0)
    end
end

xi.wsEffect.clearTrackedMods = function(player)
    for mod in pairs(xi.wsEffect.trackedMods) do
        local activeVar = xi.wsEffect.modCharVar(mod)
        local power     = player:getCharVar(activeVar)

        if power ~= 0 then
            local tokenVar = xi.wsEffect.modTokenCharVar(mod)

            player:delMod(mod, power)
            player:setCharVar(activeVar, 0)
            player:setCharVar(tokenVar, player:getCharVar(tokenVar) + 1)
        end
    end
end

xi.wsEffect.applyModInternal = function(player, mod, power, duration)
    local activeVar = xi.wsEffect.modCharVar(mod)
    local tokenVar  = xi.wsEffect.modTokenCharVar(mod)
    local oldPower  = player:getCharVar(activeVar)
    local token     = player:getCharVar(tokenVar) + 1

    xi.wsEffect.trackedMods[mod] = true

    -- Prevent stacking the same tracked mod
    if oldPower ~= 0 then
        player:delMod(mod, oldPower)
        player:setCharVar(activeVar, 0)
    end

    player:addMod(mod, power)
    player:setCharVar(activeVar, power)
    player:setCharVar(tokenVar, token)

    player:timer(duration * 1000, function(playerArg)
        if
            playerArg and
            playerArg:getCharVar(tokenVar) == token
        then
            xi.wsEffect.clearMod(playerArg, mod, power)
            playerArg:setCharVar(tokenVar, 0)

            if
                not xi.wsEffect.hasActiveMod(playerArg) and
                xi.wsEffect.has(playerArg, xi.wsEffect.CUSTOM_MOD)
            then
                xi.wsEffect.clear(playerArg)
            end
        end
    end)
end

xi.wsEffect.applyMod = function(player, mod, power, duration, message)
    if not xi.wsEffect.set(player, xi.wsEffect.CUSTOM_MOD, 0, duration) then
        return false
    end

    xi.wsEffect.applyModInternal(player, mod, power, duration)

    if message then
        xi.wsEffect.message(player, message)
    end

    return true
end

xi.wsEffect.applyMods = function(player, mods, duration, message)
    if not xi.wsEffect.set(player, xi.wsEffect.CUSTOM_MOD, 0, duration) then
        return false
    end

    for _, modData in ipairs(mods) do
        local mod   = modData[1]
        local power = modData[2]

        xi.wsEffect.applyModInternal(player, mod, power, duration)
    end

    if message then
        xi.wsEffect.message(player, message)
    end

    return true
end

local m = Module:new('sanctum_combat_effect_system')

-- The effect system is installed when this module is loaded. This passthrough
-- gives the module a stable override target and keeps normal fTP behavior.
m:addOverride('xi.weaponskills.fTP', function(tp, ftpTable)
    return super(tp, ftpTable)
end)

return m
