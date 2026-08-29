-----------------------------------
-- Sanctum Warrior: weaker Berserk and Defender off a subjob
-----------------------------------
require('modules/module_utils')
require('scripts/globals/job_utils/warrior')
-----------------------------------

local m = Module:new('sanctum_warrior_berserk_defender')

-- Both are permanent at a 60 second recast, so a subjob was getting main job potency
-- for free. Main job keeps the level scaled values in job_utils/warrior.lua.
local subjobPower =
{
    berserk  = 10, -- main reaches 21
    defender = 15, -- main reaches 31
}

m:addOverride('xi.job_utils.warrior.useBerserk', function(player, target, ability)
    if player:getMainJob() == xi.job.WAR then
        return super(player, target, ability)
    end

    local power    = subjobPower.berserk + player:getMod(xi.mod.BERSERK_POTENCY)
    local duration = 300 + player:getMod(xi.mod.BERSERK_DURATION)

    player:delStatusEffect(xi.effect.DEFENDER)
    player:addStatusEffect(xi.effect.BERSERK, { power = power, duration = duration, origin = player })

    return xi.effect.BERSERK
end)

m:addOverride('xi.job_utils.warrior.useDefender', function(player, target, ability)
    if player:getMainJob() == xi.job.WAR then
        return super(player, target, ability)
    end

    local power    = subjobPower.defender
    local duration = 300 + player:getMod(xi.mod.DEFENDER_DURATION)

    player:delStatusEffect(xi.effect.BERSERK)
    player:addStatusEffect(xi.effect.DEFENDER, { power = power, duration = duration, origin = player })

    return xi.effect.DEFENDER
end)

return m
