-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Mamool Ja Bounder (THF)
-----------------------------------
local zhayolmGlobal = require('scripts/zones/Zhayolm_Remnants/globals')
-----------------------------------

---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    local instance = mob:getInstance()

    if instance and instance:getStage() == 2 then
        mob:addListener('TREASUREPOOL', 'BOUNDER_ADDED_DROPS', function(mobArg, target, itemid)
            target:addTreasure(itemid, mobArg)
        end)
    end
end

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller or optParams.noKiller then
        local instance = mob:getInstance()

        if instance then
            local stage    = instance:getStage()
            local progress = instance:getProgress()

            if stage == 2 then
                xi.salvage.spawnTempChest(mob,
                {
                    rate = 1000,
                    itemID_1 = xi.item.FLASK_OF_STRANGE_MILK,
                    itemAmount_1 = 10,
                })
                if progress == 4 then
                    zhayolmGlobal.completeSecondFloorRoute(instance, progress)
                end
            elseif stage == 3 then
                zhayolmGlobal.trySpawnThirdFloorMadame(instance, zhayolmGlobal.thirdFloorPath.SOUTH)
            end
        end
    end
end

return entity
