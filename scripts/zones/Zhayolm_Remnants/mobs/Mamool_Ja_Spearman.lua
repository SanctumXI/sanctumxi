-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Mamool Ja Spearman (DRG)
-----------------------------------
local zhayolmGlobal = require('scripts/zones/Zhayolm_Remnants/globals')
-- mixins = { require('scripts/mixins/master') }
-----------------------------------

---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    local instance = mob:getInstance()
--[[
    local mobID    = mob:getID()

    if mobID >= 17076358 then
        mob:setPet(GetMobByID(mobID + 3, instance))
    else
        mob:setPet(GetMobByID(mobID + 1, instance))
    end
]]
    if instance and instance:getStage() == 2 then
        mob:addListener('TREASUREPOOL', 'SPEARMAN_ADDED_DROPS', function(mobArg, target, itemid)
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
                    itemID_1 = xi.item.DUSTY_POTION,
                    itemAmount_1 = 10,
                })
                if progress == 3 then
                    zhayolmGlobal.completeSecondFloorRoute(instance, progress)
                end
            elseif stage == 3 then
                zhayolmGlobal.trySpawnThirdFloorMadame(instance, zhayolmGlobal.thirdFloorPath.SOUTH)
            end
        end
    end
end

return entity
