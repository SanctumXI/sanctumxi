local function makeMob(config, isBoss)
    config.mobMods = config.mobMods or {}
    config.mobMods[xi.mobMod.IDLE_DESPAWN] = config.mobMods[xi.mobMod.IDLE_DESPAWN] or 180
    config.mobMods[xi.mobMod.NO_DROPS]     = 1
    config.mobMods[xi.mobMod.ALWAYS_AGGRO] = 1
    config.mobMods[xi.mobMod.SOUND_RANGE]  = config.mobMods[xi.mobMod.SOUND_RANGE] or 15
    config.mobAbilitiesEnabled = true

    if isBoss then
        config.hpMultiplier = config.hpMultiplier or 3
        config.mobMods[xi.mobMod.EXP_BONUS] = config.mobMods[xi.mobMod.EXP_BONUS] or 500
    end

    return config
end

local mobs =
{
    doomWorm = makeMob(
    {
        name        = 'Doom Worm',
        groupId     = 42,
        groupZoneId = 5,
        minLevel    = 53,
        maxLevel    = 54,
        mobMods     =
        {
            [xi.mobMod.SPELL_LIST] = 153,
        },
    }, false),

    bastardWorm = makeMob(
    {
        name         = 'Bastard Worm',
        groupId      = 37,
        groupZoneId  = 81,
        minLevel     = 60,
        maxLevel     = 60,
        hpMultiplier = 3,
        mobMods      =
        {
            [xi.mobMod.SPELL_LIST] = 154,
        },
        mods =
        {
            [xi.mod.ATTP] = 100,
            [xi.mod.DEFP] = 100,
            [xi.mod.ACC]  = 100,
            [xi.mod.EVA]  = 50,
        },
    }, true),

    duneLizard = makeMob(
    {
        name        = 'Dune Lizard',
        groupId     = 23,
        groupZoneId = 103,
        minLevel    = 32,
        maxLevel    = 33,
    }, false),

    duneLeech = makeMob(
    {
        name        = 'Dune Leech',
        groupId     = 26,
        groupZoneId = 103,
        minLevel    = 32,
        maxLevel    = 33,
    }, false),

    duneQueen = makeMob(
    {
        name         = 'Dune Queen',
        groupId      = 26,
        groupZoneId  = 103,
        minLevel     = 35,
        maxLevel     = 35,
        hpMultiplier = 2,
        mods =
        {
            [xi.mod.ATTP] = 25,
            [xi.mod.DEFP] = 25,
            [xi.mod.ACC]  = 20,
        },
    }, true),

    duneSovereign = makeMob(
    {
        name         = 'Dune Sovereign',
        groupId      = 30,
        groupZoneId  = 103,
        minLevel     = 37,
        maxLevel     = 37,
        hpMultiplier = 3,
        mods =
        {
            [xi.mod.ATTP] = 40,
            [xi.mod.DEFP] = 40,
            [xi.mod.ACC]  = 30,
            [xi.mod.EVA]  = 15,
        },
    }, true),

    kuftalLizard = makeMob(
    {
        name        = 'Kuftal Lizard',
        groupId     = 7,
        groupZoneId = 174,
        minLevel    = 62,
        maxLevel    = 63,
    }, false),

    kuftalCrab = makeMob(
    {
        name        = 'Kuftal Crab',
        groupId     = 8,
        groupZoneId = 174,
        minLevel    = 62,
        maxLevel    = 63,
    }, false),

    kuftalCancer = makeMob(
    {
        name         = 'Kuftal Cancer',
        groupId      = 35,
        groupZoneId  = 174,
        minLevel     = 65,
        maxLevel     = 65,
        hpMultiplier = 2,
        mods =
        {
            [xi.mod.ATTP] = 40,
            [xi.mod.DEFP] = 40,
            [xi.mod.ACC]  = 35,
        },
    }, true),

    kuftalTyrant = makeMob(
    {
        name         = 'Kuftal Tyrant',
        groupId      = 16,
        groupZoneId  = 174,
        minLevel     = 67,
        maxLevel     = 67,
        hpMultiplier = 3,
        mods =
        {
            [xi.mod.ATTP] = 60,
            [xi.mod.DEFP] = 60,
            [xi.mod.ACC]  = 50,
            [xi.mod.EVA]  = 25,
        },
    }, true),

    skyFlamingo = makeMob(
    {
        name        = 'Sky Flamingo',
        groupId     = 2,
        groupZoneId = 130,
        minLevel    = 77,
        maxLevel    = 78,
    }, false),

    skyKeeper = makeMob(
    {
        name        = 'Sky Keeper',
        groupId     = 3,
        groupZoneId = 130,
        minLevel    = 77,
        maxLevel    = 78,
    }, false),

    skyGuardian = makeMob(
    {
        name         = 'Sky Guardian',
        groupId      = 3,
        groupZoneId  = 130,
        minLevel     = 80,
        maxLevel     = 80,
        hpMultiplier = 2,
        mods =
        {
            [xi.mod.ATTP] = 50,
            [xi.mod.DEFP] = 50,
            [xi.mod.ACC]  = 45,
        },
    }, true),

    skyAscendant = makeMob(
    {
        name         = 'Sky Ascendant',
        groupId      = 13,
        groupZoneId  = 130,
        minLevel     = 82,
        maxLevel     = 82,
        hpMultiplier = 3,
        mods =
        {
            [xi.mod.ATTP] = 75,
            [xi.mod.DEFP] = 75,
            [xi.mod.ACC]  = 60,
            [xi.mod.EVA]  = 30,
        },
    }, true),
}

function mobs.get(key)
    return mobs[key]
end

function mobs.applyStats(mob, definition)
    for mobMod, value in pairs(definition.mobMods or {}) do
        mob:setMobMod(mobMod, value)
    end

    for mod, value in pairs(definition.mods or {}) do
        mob:setMod(mod, value)
    end

    if definition.maxHp then
        mob:setMaxHP(definition.maxHp)
        mob:setHP(definition.maxHp)
    elseif definition.hpMultiplier then
        mob:setMaxHP(math.floor(mob:getMaxHP() * definition.hpMultiplier))
        mob:setHP(mob:getMaxHP())
    end

    if definition.mobAbilitiesEnabled ~= nil then
        mob:setMobAbilityEnabled(definition.mobAbilitiesEnabled)
    end
end

function mobs.onSpawn(mob, definition, context)
    if definition.onSpawn then
        definition.onSpawn(mob, context)
    end
end

function mobs.onFight(mob, target, definition, context)
    if definition.onFight then
        definition.onFight(mob, target, context)
    end
end

function mobs.onDeath(mob, player, optParams, definition, context)
    if definition.onDeath then
        definition.onDeath(mob, player, optParams, context)
    end
end

function mobs.onDespawn(mob, definition, context)
    if definition.onDespawn then
        definition.onDespawn(mob, context)
    end
end

return mobs
