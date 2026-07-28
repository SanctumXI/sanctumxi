-----------------------------------
-- Area: Castle Oztroja
--   NM: Tzee Xicu the Manifest
-- TODO: messages should be zone-wide
-----------------------------------
local ID = zones[xi.zone.CASTLE_OZTROJA]
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.spawnPoints =
{
    { x =  -96.516, y = -73.255, z =   97.807 },
    { x = -100.003, y = -72.000, z =   94.327 },
    { x =  -94.285, y = -72.000, z =   94.315 },
    { x = -101.619, y = -72.000, z =   89.486 },
    { x = -105.111, y = -72.000, z =   91.326 },
    { x =  -97.662, y = -72.000, z =   89.326 },
    { x =  -94.900, y = -72.000, z =   92.646 },
    { x = -101.309, y = -72.000, z =   91.051 },
    { x =  -96.052, y = -72.000, z =   97.626 },
    { x =  -96.787, y = -72.000, z =   97.103 },
    { x = -106.305, y = -72.000, z =   95.115 },
    { x =  -96.559, y = -72.000, z =   92.495 },
    { x =  -93.889, y = -72.000, z =   91.814 },
    { x = -101.447, y = -72.000, z =   99.111 },
    { x =  -99.392, y = -72.000, z =   95.825 },
    { x = -102.082, y = -72.000, z =   92.241 },
    { x =  -99.952, y = -72.000, z =   91.543 },
    { x =  -97.150, y = -72.000, z =   97.036 },
    { x = -101.140, y = -72.000, z =   99.131 },
    { x =  -96.798, y = -72.000, z =   93.610 },
    { x =  -97.732, y = -72.000, z =   98.785 },
    { x =  -98.356, y = -72.000, z =   91.743 },
    { x = -101.428, y = -72.000, z =   96.497 },
    { x =  -99.824, y = -72.000, z =   92.164 },
    { x = -110.096, y = -72.000, z =   94.758 },
    { x = -102.046, y = -72.000, z =   98.383 },
    { x = -105.329, y = -72.000, z =   90.984 },
    { x =  -98.941, y = -72.000, z =   98.240 },
    { x =  -99.414, y = -72.000, z =   94.626 },
    { x = -101.338, y = -72.000, z =  100.293 },
    { x =  -93.301, y = -72.000, z =   95.551 },
    { x = -108.852, y = -72.000, z =   92.674 },
    { x =  -95.815, y = -72.000, z =   90.632 },
    { x =  -97.344, y = -72.000, z =   98.520 },
    { x =  -98.281, y = -72.000, z =   94.926 },
    { x = -104.539, y = -72.000, z =   96.002 },
    { x = -105.598, y = -72.000, z =   93.795 },
    { x = -100.509, y = -72.000, z =   98.520 },
    { x = -100.445, y = -72.000, z =   94.454 },
    { x =  -99.853, y = -72.000, z =   99.968 },
    { x =  -94.184, y = -72.000, z =   93.107 },
    { x =  -97.927, y = -72.000, z =   89.527 },
    { x =  -99.731, y = -72.000, z =   90.636 },
    { x =  -96.157, y = -72.000, z =   89.671 },
    { x = -107.448, y = -72.000, z =   91.881 },
    { x = -103.679, y = -72.000, z =   91.665 },
    { x =  -97.963, y = -72.000, z =   93.322 },
    { x =  -98.314, y = -72.000, z =  100.180 },
    { x = -101.960, y = -72.000, z =   97.769 },
    { x = -103.268, y = -72.000, z =   96.397 }
}

-- Mirrors Tzee Xicu's Hierophant (KSNM: Wing and a Prayer). See scripts/zones/Balgas_Dais/mobs/Tzee_Xicus_Hierophant.lua
local physicalDamageTaken   = 0
local auraPhysicalReduction = -5000
local auraReturnTime        = 600

local function enableAura(mob)
    if not mob:hasStatusEffect(xi.effect.COLURE_ACTIVE) then
        mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.WEIGHT, subPower = 50, tier = xi.auraTarget.ENEMIES, flag = xi.effectFlag.AURA })
    end

    mob:setMod(xi.mod.UDMGPHYS, physicalDamageTaken + auraPhysicalReduction)
end

local function disableAura(mob)
    mob:delStatusEffectSilent(xi.effect.COLURE_ACTIVE)
    mob:setMod(xi.mod.UDMGPHYS, physicalDamageTaken)
end

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Yagudos_Elemental')
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:setMod(xi.mod.AURA_SIZE, -125)
end

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.SILENCE_RES_RANK, 12)
    mob:setMod(xi.mod.REGAIN, 20)
    mob:setMod(xi.mod.UDMGMAGIC, -5000)
    mob:setMod(xi.mod.ACC, 30)

    -- Yagudo priest: high resistance to Silence (a support caster), and mild Wind
    -- alignment (weak to its opposite, Earth) matching its Yagudo family.
    mob:setMod(xi.mod.WIND_SDT, -1500)
    mob:setMod(xi.mod.EARTH_SDT, 500)

    -- A support caster wants to keep casting: resists Paralyze and Poison.
    mob:setMod(xi.mod.PARALYZE_RES_RANK, 8)
    mob:setMod(xi.mod.SLOW_RES_RANK, 8)
    mob:setMod(xi.mod.POISON_RES_RANK, 6)

    mob:setMobMod(xi.mobMod.SKILL_LIST, 2100)
    mob:setLocalVar('auraPhase', 0)
    mob:setLocalVar('auraReturn', 0)
    mob:setBaseSpeed(55)

    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = xi.mobSkill.VORTICOSE_SANDS, cooldown = 180, hpp = 75 },
        },
    })

    enableAura(mob)
end

entity.onMobFight = function(mob, target)
    local auraPhase = mob:getLocalVar('auraPhase')

    if
        auraPhase == 0 and
        mob:getHPP() <= 70
    then
        disableAura(mob)
        mob:setLocalVar('auraPhase', 1)
        mob:setLocalVar('auraReturn', GetSystemTime() + auraReturnTime)
    elseif
        auraPhase == 1 and
        GetSystemTime() >= mob:getLocalVar('auraReturn')
    then
        enableAura(mob)
        mob:setLocalVar('auraPhase', 2)
    end
end

entity.onMobEngage = function(mob, target)
    mob:showText(mob, ID.text.YAGUDO_KING_ENGAGE)
end

entity.onAdditionalEffect = function(mob, target, damage)
    local pTable =
    {
        chance   = 25,
        effectId = xi.effect.PARALYSIS,
        power    = 20,
        duration = 60,
    }

    return xi.combat.action.executeAddEffectEnfeeblement(mob, target, pTable)
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.DEITY_DEBUNKER)
    end

    if optParams.isKiller or optParams.noKiller then
        mob:showText(mob, ID.text.YAGUDO_KING_DEATH)
    end
end

entity.onMobDespawn = function(mob)
    -- reset hqnm system back to the nm placeholder
    local nqId = mob:getID() - 3
    SetServerVariable('[POP]Tzee_Xicu_the_Manifest', GetSystemTime() + 259200) -- 3 days
    SetServerVariable('[PH]Tzee_Xicu_the_Manifest', 0)
    DisallowRespawn(mob:getID(), true)
    DisallowRespawn(nqId, false)
    xi.mob.updateNMSpawnPoint(nqId)
    GetMobByID(nqId):setRespawnTime(math.randomInt(75600, 86400))
end

return entity
