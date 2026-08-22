-----------------------------------
-- Sanctum Beastmaster subjob Charm effectiveness
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_charm_success')

local subjobCharmEffectiveness = 0.75

m:addOverride('xi.job_utils.beastmaster.getCharmChance', function(charmer, target, includeMods)
    local chance = super(charmer, target, includeMods)

    if
        charmer and
        charmer:isPC() and
        charmer:getMainJob() ~= xi.job.BST and
        charmer:getSubJob() == xi.job.BST
    then
        return chance * subjobCharmEffectiveness
    end

    return chance
end)

return m
