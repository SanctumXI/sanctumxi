-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Archaic Rampart
-----------------------------------
local ID = zones[xi.zone.ZHAYOLM_REMNANTS]
local zhayolmGlobal = require('scripts/zones/Zhayolm_Remnants/globals')
mixins = { require('scripts/mixins/families/rampart') }
-----------------------------------

---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    local mobID = mob:getID()

    mob:setMobMod(xi.mobMod.ROAM_DISTANCE, 0)
    mob:setMobMod(xi.mobMod.ROAM_TURNS, 0)
    mob:setLocalVar('spawnCount', 1)
    if
        utils.contains(mobID, utils.slice(ID.mob.ARCHAIC_RAMPART, 7, 9)) or
        utils.contains(mobID, utils.slice(ID.mob.ARCHAIC_RAMPART, 3, 5))
    then
        mob:setLocalVar('spawnOffset', 2)
        mob:setAggressive(false)
        mob:setMobMod(xi.mobMod.NO_LINK, 0)
    end
end

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller or optParams.noKiller then
        local instance = mob:getInstance()

        if instance then
            local stage    = instance:getStage()
            local mobID    = mob:getID()

            if stage == 3 then
                xi.salvage.spawnTempChest(mob, { rate = 1000 })

                local path = mobID == ID.mob.ARCHAIC_RAMPART[1] and
                    zhayolmGlobal.thirdFloorPath.SOUTH or
                    zhayolmGlobal.thirdFloorPath.NORTH

                zhayolmGlobal.trySpawnThirdFloorMadame(instance, path)
            elseif
                instance:getStage() == 5 and
                mobID ~= ID.mob.ARCHAIC_RAMPART[6] and
                mobID ~= ID.mob.ARCHAIC_RAMPART[10]
            then
                xi.salvage.spawnTempChest(mob, { rate = 1000 })
            end
        end
    end
end

return entity
