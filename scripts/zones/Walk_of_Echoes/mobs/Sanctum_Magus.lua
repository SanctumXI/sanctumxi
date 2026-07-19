local entity = {}

entity.onMobSpawn = function(mob)

    mob:setMod(xi.mod.MATT, 100)

end

entity.onMobFight = function(mob, target)

    if math.randomInt(1, 100) < 15 then

        mob:castSpell(218, target)

    end
end

return entity