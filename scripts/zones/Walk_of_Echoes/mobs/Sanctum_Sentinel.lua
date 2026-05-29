local entity = {}

entity.onMobSpawn = function(mob)

    mob:setMod(xi.mod.ATT, 120)
    mob:setMod(xi.mod.DEF, 80)

end

entity.onMobFight = function(mob, target)

    if mob:getHPP() < 50 and mob:getLocalVar("rage") == 0 then

        mob:setLocalVar("rage", 1)

        mob:useMobAbility(695)

    end
end

entity.onMobDeath = function(mob, player)

    player:addCurrency("sanctum_tokens", 5)

end

return entity