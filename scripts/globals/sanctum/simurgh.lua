-----------------------------------
-- Sanctum: Hard Mode Simurgh
-----------------------------------
xi = xi or {}
xi.sanctum = xi.sanctum or {}
xi.sanctum.simurgh = xi.sanctum.simurgh or {}

local simurgh = xi.sanctum.simurgh

simurgh.aspectData =
{
    {
        name        = 'Aetherplume',
        effectText  = 'Simurgh absorbs magic damage.',
        modifiers   = { { xi.mod.MAGIC_ABSORB, 100 } },
    },
    {
        name        = 'Ironplume',
        effectText  = 'Simurgh absorbs physical damage.',
        modifiers   = { { xi.mod.PHYS_ABSORB, 100 } },
    },
    {
        name        = 'Lifequill',
        effectText  = 'Simurgh gains powerful regeneration.',
        modifiers   = { { xi.mod.REGEN, 500 } },
    },
    {
        name        = 'Warquill',
        effectText  = 'Simurgh rapidly regains TP.',
        modifiers   = { { xi.mod.REGAIN, 100 } },
    },
    {
        name        = 'Ragewing',
        effectText  = 'Simurgh trades attack speed for overwhelming attack.',
        modifiers   =
        {
            { xi.mod.ATT,    500 },
            { xi.mod.DELAYP,  50 },
        },
    },
    {
        name        = 'Miragewing',
        effectText  = 'Simurgh becomes extraordinarily evasive.',
        modifiers   = { { xi.mod.EVA, 500 } },
    },
    {
        name        = 'Hexbane',
        effectText  = 'Simurgh gains immense resistance to enfeebling effects.',
        modifiers   = { { xi.mod.STATUSRES, 100 } },
    },
    {
        name        = 'Stormtalon',
        effectText  = 'Simurgh gains wind damage on every attack.',
        windDamage  = true,
    },
}

local function getZoneIds()
    return zones[xi.zone.REISENJIMA_HENGE]
end

function simurgh.sendMessage(mob, message)
    local instance = mob:getInstance()

    if not instance then
        return
    end

    for _, player in ipairs(instance:getChars()) do
        player:printToPlayer(message, xi.msg.channel.SYSTEM_3)
    end
end

function simurgh.getAspectIndex(add)
    local ID = getZoneIds()

    for index, addId in ipairs(ID.mob.HARD_MODE_SIMURGH_ASPECTS) do
        if add:getID() == addId then
            return index
        end
    end

    return nil
end

function simurgh.getBoss(entity)
    local instance = entity:getInstance()

    if not instance then
        return nil
    end

    local ID = getZoneIds()

    return GetMobByID(ID.mob.HARD_MODE_SIMURGH, instance)
end

local function applyAspectModifiers(mob, aspect, multiplier)
    for _, modifier in ipairs(aspect.modifiers or {}) do
        mob:addMod(modifier[1], modifier[2] * multiplier)
    end
end

function simurgh.setAspectActive(mob, index, isActive, silent)
    if not mob or not mob:isAlive() then
        return
    end

    local aspect   = simurgh.aspectData[index]
    local varName  = 'AspectBuff' .. index
    local wasActive = mob:getLocalVar(varName) == 1

    if not aspect or isActive == wasActive then
        return
    end

    mob:setLocalVar(varName, isActive and 1 or 0)
    applyAspectModifiers(mob, aspect, isActive and 1 or -1)

    if aspect.windDamage then
        mob:setMobMod(xi.mobMod.ADD_EFFECT, isActive and 1 or 0)
    end

    if not silent then
        if isActive then
            simurgh.sendMessage(mob, string.format('%s joins the fight! Simurgh is empowered!', aspect.name))
        else
            simurgh.sendMessage(mob, string.format('%s falls. Its blessing fades from Simurgh.', aspect.name))
        end
    end
end

function simurgh.syncAspectBuffs(mob, silent)
    if not mob or not mob:isAlive() then
        return
    end

    local ID = getZoneIds()

    for index = 1, #simurgh.aspectData do
        local add      = GetMobByID(ID.mob.HARD_MODE_SIMURGH_ASPECTS[index], mob:getInstance())
        local isActive = add and add:isAlive() or false

        simurgh.setAspectActive(mob, index, isActive, silent)
    end
end

function simurgh.cleanupAdds(mob)
    local instance = mob:getInstance()

    if not instance then
        return
    end

    local ID = getZoneIds()

    for _, addId in ipairs(ID.mob.HARD_MODE_SIMURGH_ASPECTS) do
        DespawnMob(addId, instance)
    end
end

return simurgh
