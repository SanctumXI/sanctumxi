-----------------------------------
-- Area: Balga's Dais
--  Mob: Divine Reproach
-- KSNM: Wing and a Prayer
-----------------------------------
mixins =
{
    require('scripts/mixins/job_special'),
}
-----------------------------------

local tuning =
{
    level               = 85,
    hpBonus             = 0,
    attackBonus         = 0,
    defenseBonus        = 0,
    accuracyBonus       = 0,
    evasionBonus        = 0,
    magicAttackBonus    = 0,
    regain              = 20,
    physicalDamageTaken = -5000,
    rangedDamageTaken   = 0,
    breathDamageTaken   = 0,
    magicDamageTaken    = 0,
}

---@type TMobEntity
local entity = {}

-- Keep this mob's own enmity list in sync with its allies -- see Tzee_Xicus_Hierophant.lua
-- for the full explanation of why this matters.
local function syncEnmity(mob)
    local battlefield = mob:getBattlefield()
    if not battlefield then
        return
    end

    for _, ally in pairs(battlefield:getMobs(true, true)) do
        if ally:getID() ~= mob:getID() and ally:isAlive() then
            for _, entry in ipairs(ally:getEnmityList()) do
                if entry.entity then
                    local myCE, myVE = 0, 0
                    for _, mine in ipairs(mob:getEnmityList()) do
                        if mine.entity:getID() == entry.entity:getID() then
                            myCE, myVE = mine.ce, mine.ve
                            break
                        end
                    end

                    local ceDelta = entry.ce - myCE
                    local veDelta = entry.ve - myVE
                    if ceDelta > 0 or veDelta > 0 then
                        mob:addEnmity(entry.entity, math.max(ceDelta, 0), math.max(veDelta, 0))
                    end
                end
            end
        end
    end
end

entity.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.SILENCE)
end

entity.onMobSpawn = function(mob)
    if mob:getMainLvl() ~= tuning.level then
        mob:setMobLevel(tuning.level)
    end

    mob:addMod(xi.mod.HP, tuning.hpBonus)
    mob:addMod(xi.mod.ATT, tuning.attackBonus)
    mob:addMod(xi.mod.DEF, tuning.defenseBonus)
    mob:addMod(xi.mod.ACC, tuning.accuracyBonus)
    mob:addMod(xi.mod.EVA, tuning.evasionBonus)
    mob:addMod(xi.mod.MATT, tuning.magicAttackBonus)
    mob:setMod(xi.mod.REGAIN, tuning.regain)
    mob:setMod(xi.mod.UDMGPHYS, tuning.physicalDamageTaken)
    mob:setMod(xi.mod.UDMGRANGE, tuning.rangedDamageTaken)
    mob:setMod(xi.mod.UDMGBREATH, tuning.breathDamageTaken)
    mob:setMod(xi.mod.UDMGMAGIC, tuning.magicDamageTaken)

    -- Air elemental: strongly resists its own element (Wind), weak to its opposite (Earth).
    mob:setMod(xi.mod.WIND_SDT, 4000)
    mob:setMod(xi.mod.WIND_RES_RANK, 10)
    mob:setMod(xi.mod.EARTH_SDT, -1000)

    -- An ephemeral wind-being: resists Slow and Paralyze.
    mob:setMod(xi.mod.SLOW_RES_RANK, 8)
    mob:setMod(xi.mod.PARALYZE_RES_RANK, 8)

    mob:setHP(mob:getMaxHP())

    -- Half of the Elemental-Air family's base speed of 55.
    mob:setBaseSpeed(27)
end

entity.onMobFight = function(mob, target)
    syncEnmity(mob)
end

return entity
