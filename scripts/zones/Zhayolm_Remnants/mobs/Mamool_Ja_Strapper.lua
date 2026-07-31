-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Mamool Ja Strapper (BST)
-----------------------------------
local zhayolmGlobal = require('scripts/zones/Zhayolm_Remnants/globals')
-- mixins = { require('scripts/mixins/master') }
-----------------------------------

---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
--[[
    local mobID    = mob:getID()
    local instance = mob:getInstance()

    if mobID >= 17076360 then
        mob:setPet(GetMobByID(mobID + 2, instance))
    else
        mob:setPet(GetMobByID(mobID + 4, instance))
    end
]]
end

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller or optParams.noKiller then
        local instance = mob:getInstance()

        if instance then
            local stage    = instance:getStage()

            if stage == 3 then
                zhayolmGlobal.trySpawnThirdFloorMadame(instance, zhayolmGlobal.thirdFloorPath.SOUTH)
            end
        end
    end
end

return entity
