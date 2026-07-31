-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Mamool Ja Sophist
-----------------------------------
local zhayolmGlobal = require('scripts/zones/Zhayolm_Remnants/globals')
-----------------------------------

---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller or optParams.noKiller then
        local instance = mob:getInstance()

        if instance then
            local stage    = instance:getStage()

            if stage == 3 then
                zhayolmGlobal.trySpawnThirdFloorMadame(instance, zhayolmGlobal.thirdFloorPath.NORTH)
            end
        end
    end
end

return entity
