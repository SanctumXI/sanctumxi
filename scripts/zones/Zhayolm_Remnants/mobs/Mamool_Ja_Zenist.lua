-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Mamool Ja Zenist
-----------------------------------
local zhayolmGlobal = require('scripts/zones/Zhayolm_Remnants/globals')
-----------------------------------

---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:addImmunity(xi.immunity.SILENCE)
    -- only first floor mobs should have higher delay
    local instance = mob:getInstance()

    if instance then
        local stage    = instance:getStage()
        if stage == 1 then
            mob:setDelay(480)
            mob:setMod(xi.mod.ATT, 60)
            mob:setMod(xi.mod.MAIN_DMG_RATING, -32)
            mob:setMod(xi.mod.INT, -25)
            mob:setMod(xi.mod.MATT, -10)
        elseif stage == 2 then
            mob:addListener('TREASUREPOOL', 'ZENIST_ADDED_DROPS', function(mobArg, target, itemid)
                target:addTreasure(itemid, mobArg)
            end)
        end
    end
end

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller or optParams.noKiller then
        local instance = mob:getInstance()

        if instance then
            local stage    = instance:getStage()
            local progress = instance:getProgress()

            if stage == 1 then
                xi.salvage.spawnTempChest(mob,
                {
                    rate = 1000,
                    itemID_1 = xi.item.DUSTY_POTION,
                    itemAmount_1 = 18
                })
                mob:setDropID(0)
            elseif stage == 2 then
                xi.salvage.spawnTempChest(mob,
                {
                    rate = 1000,
                    itemID_1 = xi.item.DUSTY_ETHER,
                    itemAmount_1 = 10
                })
                if progress == 2 then
                    zhayolmGlobal.completeSecondFloorRoute(instance, progress)
                end
            elseif stage == 3 then
                zhayolmGlobal.trySpawnThirdFloorMadame(instance, zhayolmGlobal.thirdFloorPath.SOUTH)
            end
        end
    end
end

return entity
