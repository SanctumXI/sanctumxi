-----------------------------------
-- Pod Ejection
-- Family: Biotechnological Weapons
-- Description: Spawns two Gunpods
-- Type: Summoning
-- Range: Self
-- Notes: Used only by Proto-Omega on a randomized timer.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

local gunpodIds = zones[xi.zone.APOLLYON].CENTRAL_APOLLYON.mob.GUNPODS

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    mob:timer(3000, function(mobArg)
        if mobArg:isAlive() then
            local battlefield = mobArg:getBattlefield()
            local players     = battlefield and battlefield:getPlayers() or {}

            for _, gunpodId in ipairs(gunpodIds) do
                local gunpod = GetMobByID(gunpodId)

                if gunpod and gunpod:getStatus() == xi.status.DISAPPEAR then
                    gunpod:setSpawn(mobArg:getXPos(), mobArg:getYPos(), mobArg:getZPos(), mobArg:getRotPos())
                    gunpod:spawn()

                    local player = utils.randomEntry(players)
                    if player then
                        gunpod:updateEnmity(player)
                    end
                end
            end
        end
    end)

    skill:setMsg(0)
    return 0
end

return mobskillObject
