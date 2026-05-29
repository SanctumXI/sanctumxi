local entity = {}

entity.onMobSpawn = function(mob)

    mob:setMod(xi.mod.ATT, 250)
    mob:setMod(xi.mod.DEF, 180)

end

entity.onMobFight = function(mob, target)

    local hp = mob:getHPP()

    if hp < 70 and mob:getLocalVar("phase2") == 0 then

        mob:setLocalVar("phase2", 1)

        mob:useMobAbility(710)

        mob:sayText("You trespass within the Sanctum!")

    end

    if hp < 40 and mob:getLocalVar("adds") == 0 then

        mob:setLocalVar("adds", 1)

        SpawnMob(17800060)
        SpawnMob(17800061)

    end
end

entity.onMobDeath = function(mob, player)

    player:addCurrency("sanctum_tokens", 50)

end

return entity