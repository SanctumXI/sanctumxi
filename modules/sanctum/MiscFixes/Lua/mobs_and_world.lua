-----------------------------------
-- Targeted mob, encounter, and shared world fixes.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_miscfixes_mobs_and_world')

-- Ix'aern DRK resists enfeebles but only has a hard immunity to Stun.
-- Retain its standard NM Terror immunity while allowing Bind/Shadowbind.
local ixDrkEnfeebleImmunities =
{
    xi.immunity.BIND,
    xi.immunity.BLIND,
    xi.immunity.DARK_SLEEP,
    xi.immunity.ELEGY,
    xi.immunity.GRAVITY,
    xi.immunity.LIGHT_SLEEP,
    xi.immunity.PARALYZE,
    xi.immunity.SILENCE,
    xi.immunity.SLOW,
}

m:addOverride('xi.zones.The_Garden_of_RuHmet.mobs.Ixaern_DRK.onMobInitialize', function(mob)
    super(mob)

    for _, immunity in ipairs(ixDrkEnfeebleImmunities) do
        mob:delImmunity(immunity)
    end
end)

-- Ix'aern DRG's Wynavs cannot be slept, but they can be bound.
m:addOverride('xi.zones.The_Garden_of_RuHmet.mobs.Ixaern_DRGs_Wynav.onMobSpawn', function(mob)
    super(mob)
    mob:delImmunity(xi.immunity.BIND)
end)

-- Manipulator does not award gil on defeat.
m:addOverride('xi.zones.Temple_of_Uggalepih.mobs.Manipulator.onMobInitialize', function(mob)
    super(mob)
    mob:setMobMod(xi.mobMod.GIL_MIN, -1)
    mob:setMobMod(xi.mobMod.GIL_MAX, -1)
end)

-- Sabotender Bailarin has a 10% lottery chance from its Bailaor placeholder.
m:addOverride('xi.zones.Quicksand_Caves.mobs.Sabotender_Bailaor.onMobDespawn', function(mob)
    local ID = zones[xi.zone.QUICKSAND_CAVES]

    xi.mob.phOnDespawn(mob, ID.mob.SABOTENDER_BAILARIN, 10, 9000)
end)

-- Chocobo rentals cost a flat 500 gil in every rental zone.
m:addOverride('xi.chocobo.getPrice', function(player)
    return 500
end)

-- Trial-sized avatars do not inherit the Prime Avatar Light resistance rank.
local trialAvatarSpawnPaths =
{
    'xi.zones.Cloister_of_Flames.mobs.Ifrit_Prime_TSTBF.onMobSpawn',
    'xi.zones.Cloister_of_Frost.mobs.Shiva_Prime_TSTBI.onMobSpawn',
    'xi.zones.Cloister_of_Gales.mobs.Garuda_Prime_TSTBW.onMobSpawn',
    'xi.zones.Cloister_of_Storms.mobs.Ramuh_Prime_TSTBL.onMobSpawn',
    'xi.zones.Cloister_of_Tides.mobs.Leviathan_Prime_TSTBW.onMobSpawn',
    'xi.zones.Cloister_of_Tremors.mobs.Titan_Prime_TSTBE.onMobSpawn',
}

for _, spawnPath in ipairs(trialAvatarSpawnPaths) do
    m:addOverride(spawnPath, function(mob)
        super(mob)
        mob:setMod(xi.mod.LIGHT_RES_RANK, 0)
    end)
end

m:addOverride('xi.actions.mobskills.sticky_thread.onMobWeaponSkill', function(mob, target, skill, action)
    if target:hasStatusEffect(xi.effect.HASTE) then
        skill:setMsg(xi.msg.basic.SKILL_NO_EFFECT)
        return xi.effect.NONE
    end

    return super(mob, target, skill, action)
end)

-- Doll Typhoon strikes a random two to four times.
m:addOverride('xi.actions.mobskills.typhoon.onMobWeaponSkill', function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.numHits        = math.randomInt(2, 4)
    params.fTP            = { 1.0, 1.0, 1.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_4

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

-- The fishing system checks this timestamp before Devil Manta can be hooked again.
-- This mob has no base script, so install its despawn callback directly.
xi.module.ensureTable('xi.zones.Kuftal_Tunnel.mobs.Devil_Manta')
xi.zones.Kuftal_Tunnel.mobs.Devil_Manta.onMobDespawn = function(mob)
    mob:setLocalVar('lastTOD', GetSystemTime())
end

return m
