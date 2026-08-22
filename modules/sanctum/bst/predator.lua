-----------------------------------
-- Sanctum Beastmaster Predator trait
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_bst_predator')

xi.trait.PREDATOR = 140

local killerVar = 'sanctumPredatorKiller'
local listenerName = 'SANCTUM_PREDATOR_EXP'

local healingByDifficulty =
{
    [xi.mobDifficulty.TOO_WEAK]             = 5,
    [xi.mobDifficulty.INCREDIBLY_EASY_PREY] = 8,
    [xi.mobDifficulty.EASY_PREY]            = 11,
    [xi.mobDifficulty.DECENT_CHALLENGE]     = 13,
    [xi.mobDifficulty.EVEN_MATCH]           = 15,
    [xi.mobDifficulty.TOUGH]                = 17,
    [xi.mobDifficulty.VERY_TOUGH]           = 19,
    [xi.mobDifficulty.INCREDIBLY_TOUGH]     = 22,
}

local function healPlayer(player, mob)
    local percent = healingByDifficulty[player:checkDifficulty(mob)]
    if not percent then
        return
    end

    local amount = math.floor(player:getMaxHP() * percent / 100)
    local healed = player:addHP(amount)
    if healed <= 0 then
        return
    end

    player:messageBasic(xi.msg.basic.RECOVERS_HP, 0, healed)
end

local function registerListener(player)
    player:removeListener(listenerName)
    player:addListener('EXPERIENCE_POINTS', listenerName, function(playerArg, mob, exp)
        if
            not mob or
            mob:getObjType() ~= xi.objType.MOB or
            mob:getLocalVar(killerVar) ~= playerArg:getID()
        then
            return
        end

        mob:setLocalVar(killerVar, 0)

        if exp > 0 and playerArg:hasTrait(xi.trait.PREDATOR) then
            healPlayer(playerArg, mob)
        end
    end)
end

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)
    registerListener(player)
end)

m:addOverride('xi.mob.onMobDeathEx', function(mob, player, isKiller, isWeaponSkillKill)
    super(mob, player, isKiller, isWeaponSkillKill)

    if
        not isKiller or
        player:isDead() or
        not player:hasTrait(xi.trait.PREDATOR) or
        mob:getCallForHelpFlag() or
        player:hasStatusEffect(xi.effect.BATTLEFIELD)
    then
        return
    end

    if player:checkDifficulty(mob) == xi.mobDifficulty.TOO_WEAK then
        healPlayer(player, mob)
        return
    end

    mob:setLocalVar(killerVar, player:getID())
end)

return m
