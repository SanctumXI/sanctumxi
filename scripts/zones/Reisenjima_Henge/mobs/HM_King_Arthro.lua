-----------------------------------
-- Area: Reisenjima Henge (292)
--  HNM: Hard Mode King Arthro
-----------------------------------
mixins =
{
    require('scripts/mixins/job_special'),
    require('scripts/mixins/rage'),
}

local ID = zones[xi.zone.REISENJIMA_HENGE]

---@type TMobEntity
local entity = {}

local addWaveThresholds =
{
    75,
    50,
    25,
}

local powerfulSpells =
{
    xi.magic.spell.WATERGA_IV,
    xi.magic.spell.FLOOD_II,
    xi.magic.spell.POISONGA_II,
    xi.magic.spell.WATERGA_III,
}

local function cleanupAdds(mob)
    local instance = mob:getInstance()
    if not instance then
        return
    end

    for _, addId in ipairs(ID.mob.HARD_MODE_KNIGHT_CRABS) do
        DespawnMob(addId, instance)
    end
end

local function spawnAddWave(mob, target, wave)
    local instance = mob:getInstance()
    if not instance then
        return
    end

    local firstAdd = (wave - 1) * 2 + 1
    for addIndex = firstAdd, firstAdd + 1 do
        local addId = ID.mob.HARD_MODE_KNIGHT_CRABS[addIndex]
        local add   = GetMobByID(addId, instance)

        if add and not add:isSpawned() then
            add = SpawnMob(addId, instance)
        end

        if add and add:isAlive() then
            add:updateEnmity(target)
        end
    end
end

local function configureMob(mob)
    mob:renameEntity('King Arthro', true)
    mob:setModelSize(3)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
    mob:setMobMod(xi.mobMod.MAGIC_DELAY, 1)
    mob:setMobMod(xi.mobMod.MAGIC_COOL, 20)
    mob:setMobMod(xi.mobMod.NO_SPELL_COST, 1)
    mob:setMod(xi.mod.UFASTCAST, 100)
    mob:setMod(xi.mod.BLACK_MAGIC_RECAST, -60)
    mob:setMod(xi.mod.MATT, 100)
end

entity.onMobInitialize = function(mob)
    configureMob(mob)
end

entity.onMobSpawn = function(mob)
    configureMob(mob)
    cleanupAdds(mob)
    mob:setLocalVar('KnightCrabWave', 0)
    mob:setMobMod(xi.mobMod.CANNOT_GUARD, 1)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
    mob:setMod(xi.mod.ACC, 455)
end

entity.onMobFight = function(mob, target)
    local currentWave = mob:getLocalVar('KnightCrabWave')

    while
        currentWave < #addWaveThresholds and
        mob:getHPP() <= addWaveThresholds[currentWave + 1]
    do
        currentWave = currentWave + 1
        mob:setLocalVar('KnightCrabWave', currentWave)
        spawnAddWave(mob, target, currentWave)
    end
end

entity.onMobSpellChoose = function(mob, target, spellId)
    return powerfulSpells[math.randomInt(1, #powerfulSpells)]
end

entity.onAdditionalEffect = function(mob, target, damage)
    local effect =
    {
        chance   = 25,
        effectId = xi.effect.PARALYSIS,
        power    = 20,
        duration = 60,
    }

    return xi.combat.action.executeAddEffectEnfeeblement(mob, target, effect)
end

entity.onMobDeath = function(mob, player, optParams)
    cleanupAdds(mob)
end

entity.onMobDespawn = function(mob)
    cleanupAdds(mob)
end

return entity
