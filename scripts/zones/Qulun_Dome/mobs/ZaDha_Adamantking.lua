-----------------------------------
-- Area: Qulun Dome
--   NM: Za'Dha Adamantking
-- TODO: messages should be zone-wide
-----------------------------------
local ID = zones[xi.zone.QULUN_DOME]
mixins = { require('scripts/mixins/job_special') }
-----------------------------------

-- Mirrors Ro'Hyu Blackanvil (KSNM: Heavy Is the Shell). See scripts/zones/Waughroon_Shrine/mobs/RoHyu_Blackanvil.lua
local function applySlowAura(mob)
    if not mob:hasStatusEffect(xi.effect.COLURE_ACTIVE) then
        mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.SLOW, subPower = 5000, tier = xi.auraTarget.ENEMIES, flag = xi.effectFlag.AURA })
    end
end

---@type TMobEntity
local entity = {}

entity.spawnPoints =
{
    { x = 281.000, y = 43.000, z = 96.000 }
}
entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.GRAVITY)
    mob:setMod(xi.mod.AURA_SIZE, -125)
end

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.DARK_SLEEP_RES_RANK, 11)
    mob:setMod(xi.mod.LIGHT_SLEEP_RES_RANK, 11)
    mob:setMod(xi.mod.SILENCE_RES_RANK, 11)
    mob:setMod(xi.mod.DOUBLE_ATTACK, 50)
    mob:setMod(xi.mod.CRITHITRATE, 10)
    mob:setMod(xi.mod.ACC, 30)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)

    mob:setMod(xi.mod.REGAIN, 20)

    -- Quadav king: strongly resists Earth, slightly weak to its opposite (Wind).
    mob:setMod(xi.mod.EARTH_SDT, -4000)
    mob:setMod(xi.mod.EARTH_RES_RANK, 10)
    mob:setMod(xi.mod.WIND_SDT, 1000)

    -- Tough smith-king: resists Stun and Paralyze.
    mob:setMod(xi.mod.STUN_RES_RANK, 8)
    mob:setMod(xi.mod.PARALYZE_RES_RANK, 8)
    mob:setMod(xi.mod.SLOW_RES_RANK, 8)

    mob:setMobMod(xi.mobMod.SKILL_LIST, 2098)

    xi.mix.jobSpecial.config(mob, {
        between = 5,
        specials =
        {
            { id = xi.mobSkill.MIGHTY_STRIKES_1, hpp = 80 },
            { id = xi.mobSkill.MIGHTY_STRIKES_1, hpp = 40 },
            { id = xi.mobSkill.MIGHTY_STRIKES_1, hpp = 5 },
        },
    })

    applySlowAura(mob)
end

entity.onMobFight = function(mob, target)
    applySlowAura(mob)

    if mob:getHPP() <= 40 then
        mob:setMobMod(xi.mobMod.SKILL_LIST, 2099)
    end
end

entity.onMobEngage = function(mob, target)
    mob:showText(mob, ID.text.QUADAV_KING_ENGAGE)
end

entity.onAdditionalEffect = function(mob, target, damage)
    return xi.mob.onAddEffect(mob, target, damage, xi.mob.ae.SLOW, { power = 3000 })
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.ADAMANTKING_USURPER)
    end

    if optParams.isKiller then
        mob:showText(mob, ID.text.QUADAV_KING_DEATH)
    end
end

entity.onMobDespawn = function(mob)
    -- reset hqnm system back to the nm placeholder
    local nqId = mob:getID() - 1
    SetServerVariable('[POP]Za_Dha_Adamantking', GetSystemTime() + 259200) -- 3 days
    SetServerVariable('[PH]Za_Dha_Adamantking', 0)
    DisallowRespawn(mob:getID(), true)
    DisallowRespawn(nqId, false)
    xi.mob.updateNMSpawnPoint(nqId)
    GetMobByID(nqId):setRespawnTime(math.randomInt(75600, 86400))
end

return entity
