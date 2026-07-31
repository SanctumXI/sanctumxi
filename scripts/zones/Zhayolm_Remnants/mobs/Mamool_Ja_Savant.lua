-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Mamool Ja Savant
-----------------------------------
local ID = zones[xi.zone.ZHAYOLM_REMNANTS]
local zhayolmGlobal = require('scripts/zones/Zhayolm_Remnants/globals')
-----------------------------------
local equipCells =
{
    xi.item.UNDULATUS_CELL,
    xi.item.VIRGA_CELL,
    xi.item.CUMULUS_CELL,
}

---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:addListener('ITEM_DROPS', 'SAVANT_ITEM_DROPS', function(mobArg, loot)
        if mobArg:getID() == ID.mob.MAMOOL_JA_SAVANT[1] then
            local cellDrops = {}
            for i = 1, #equipCells do
                table.insert(cellDrops, equipCells[i])
            end

            local cell1 = xi.item.CIRROCUMULUS_CELL
            local cell2 = table.remove(cellDrops, math.randomInt(1, #cellDrops))
            local cell3 = table.remove(cellDrops, math.randomInt(1, #cellDrops))
            local cell4 = table.remove(cellDrops, math.randomInt(1, #cellDrops))
            loot:addItem(cell1, xi.drop_rate.GUARANTEED)
            loot:addItem(cell2, xi.drop_rate.GUARANTEED)
            loot:addItem(cell3, xi.drop_rate.VERY_COMMON)
            loot:addItem(cell4, xi.drop_rate.VERY_COMMON)
        end
    end)

    mob:addListener('TREASUREPOOL', 'SAVANT_ADDED_DROPS', function(mobArg, target, itemid)
        local cells =
        {
            xi.item.CIRROCUMULUS_CELL,
            xi.item.UNDULATUS_CELL,
            xi.item.VIRGA_CELL,
            xi.item.CUMULUS_CELL
        }

        if utils.contains(itemid, cells) then
            target:addTreasure(itemid, mobArg)
        end
    end)
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
                if progress == 1 then
                    zhayolmGlobal.completeSecondFloorRoute(instance, progress)
                end
            elseif stage == 3 then
                zhayolmGlobal.trySpawnThirdFloorMadame(instance, zhayolmGlobal.thirdFloorPath.NORTH)
            end
        end
    end
end

return entity
