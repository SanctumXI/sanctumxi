-----------------------------------
-- Weaponskill Custom Effect System
-----------------------------------

xi = xi or {}

xi.wsEffect =
{
    NONE            = 0,
    CHAKRA_BOOST    = 1,
    BLAST_ARROW_ACC = 2,
    CUSTOM_MOD      = 3,
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

xi.wsEffect.clear = function(player)
    player:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
    player:setCharVar(xi.wsEffect.charVars.POWER, 0)
    player:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)

    player:delStatusEffect(xi.effect.EMPOWERED)
end

xi.wsEffect.set = function(player, effect, power, duration)
    if xi.wsEffect.peek(player) ~= xi.wsEffect.NONE then
        return false
    end

    player:setCharVar(xi.wsEffect.charVars.EFFECT, effect or xi.wsEffect.NONE)
    player:setCharVar(xi.wsEffect.charVars.POWER, power or 0)
    player:setCharVar(xi.wsEffect.charVars.EXPIRE, GetSystemTime() + (duration or 30))

    player:delStatusEffect(xi.effect.EMPOWERED)
    player:addStatusEffect(xi.effect.EMPOWERED, { power = 1, duration = duration or 30, origin = player })

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
