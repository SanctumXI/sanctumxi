require('scripts/globals/mixins')

g_mixins = g_mixins or {}

g_mixins.dynamis_no_exp = function(mob)
    mob:addListener('SPAWN', 'DYNAMIS_NO_EXP', function(mobArg)
        mobArg:setMobMod(xi.mobMod.EXP_BONUS, -100)
    end)
end

return g_mixins.dynamis_no_exp