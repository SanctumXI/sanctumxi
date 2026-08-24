-----------------------------------
-- Sanctum Beastmaster Ready buff merit
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_beastmaster_ready_buff')

xi.job_utils.beastmaster.getReadyBuffDuration = function(owner, duration)
    return duration * (1 + owner:getMerit(xi.merit.READY_BUFF) * 0.05)
end

m:addOverride('xi.actions.abilities.pets.harden_shell.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, math.randomInt(60, 180))

    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.DEFENSE_BOOST, 33, 0, duration))

    return xi.effect.DEFENSE_BOOST
end)

m:addOverride('xi.actions.abilities.pets.water_wall.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 30)

    xi.mobskills.mobBuffMove(target, xi.effect.MAGIC_DEF_BOOST, 75, 0, duration)
    petskill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.DEFENSE_BOOST, 75, 0, duration))

    return xi.effect.DEFENSE_BOOST
end)

m:addOverride('xi.actions.abilities.pets.frenzied_rage.onPetAbility', function(target, pet, petskill, owner, action)
    local duration = xi.job_utils.beastmaster.getReadyBuffDuration(owner, 90)

    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.ATTACK_BOOST, 25, 0, duration))

    return xi.effect.ATTACK_BOOST
end)

return m
