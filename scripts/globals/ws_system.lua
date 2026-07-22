-----------------------------------
-- Weaponskill Custom Effect System
-----------------------------------

xi = xi or {}

xi.wsEffect =
{
    NONE          = 0,
    CHAKRA_BOOST  = 1,
    RANGED_WS_HIT = 2,
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
    player:setCharVar(xi.wsEffect.charVars.EFFECT, effect or xi.wsEffect.NONE)
    player:setCharVar(xi.wsEffect.charVars.POWER, power or 0)
    player:setCharVar(xi.wsEffect.charVars.EXPIRE, GetSystemTime() + (duration or 30))

    player:delStatusEffect(xi.effect.EMPOWERED)
    player:addStatusEffect(xi.effect.EMPOWERED, { power = 1, duration = duration or 30, origin = player })
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

xi.wsEffect.clearMod = function(player, mod, power)
    local activeVar = xi.wsEffect.modCharVar(mod)

    if player:getCharVar(activeVar) == power then
        player:delMod(mod, power)
        player:setCharVar(activeVar, 0)
    end
end

xi.wsEffect.applyMod = function(player, mod, power, duration, message)
    local activeVar = xi.wsEffect.modCharVar(mod)
    local tokenVar  = xi.wsEffect.modTokenCharVar(mod)
    local oldPower  = player:getCharVar(activeVar)
    local token     = player:getCharVar(tokenVar) + 1

    -- Prevent stacking the same tracked mod
    if oldPower ~= 0 then
        player:delMod(mod, oldPower)
        player:setCharVar(activeVar, 0)
    end

    player:addMod(mod, power)
    player:setCharVar(activeVar, power)
    player:setCharVar(tokenVar, token)

    if message then
        xi.wsEffect.message(player, message)
    end

    player:timer(duration * 1000, function(playerArg)
        if
            playerArg and
            playerArg:getCharVar(tokenVar) == token
        then
            xi.wsEffect.clearMod(playerArg, mod, power)
            playerArg:setCharVar(tokenVar, 0)
        end
    end)
end

xi.wsEffect.applyMods = function(player, mods, duration, message)
    for _, modData in ipairs(mods) do
        local mod   = modData[1]
        local power = modData[2]

        xi.wsEffect.applyMod(player, mod, power, duration)
    end

    if message then
        xi.wsEffect.message(player, message)
    end
end
