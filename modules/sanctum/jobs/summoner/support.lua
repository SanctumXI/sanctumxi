-----------------------------------
-- Sanctum Summoner support abilities
-----------------------------------
require('modules/module_utils')
require('scripts/globals/avatars_favor')
require('scripts/globals/job_utils/summoner')
-----------------------------------

local m = Module:new('sanctum_summoner_support')

m:addOverride('xi.actions.abilities.apogee.onAbilityCheck', function(player, target, ability)
    return xi.msg.basic.UNABLE_TO_USE_JA2, 0
end)

m:addOverride('xi.actions.abilities.apogee.onUseAbility', function(player, target, ability)
    return 0
end)

m:addOverride('xi.avatarsFavor.applyAvatarsFavorAuraToPet', function(target, effect)
    local pet = target:getPet()
    if not pet or pet:getPetID() ~= xi.petId.DIABOLOS then
        return super(target, effect)
    end

    pet:addStatusEffect(xi.effect.DIABOLOSS_FAVOR,
    {
        power = 6,
        duration = 15,
        origin = pet,
        tick = 3,
        subType = xi.effect.DIABOLOSS_FAVOR,
        subPower = 3,
        tier = xi.auraTarget.ALLIES,
        flag = bit.bor(xi.effectFlag.NO_LOSS_MESSAGE, xi.effectFlag.AURA),
    })
end)

m:addOverride('xi.effects.diaboloss_favor.onEffectGain', function(target, effect)
    effect:addMod(xi.mod.CRITHITRATE, 3)
end)

m:addOverride('xi.effects.diaboloss_favor.onEffectLose', function(target, effect)
end)

local wards =
{
    inferno_howl = { effect = xi.effect.ENFIRE, power = 15, duration = 180 },
    earthen_armor = { effect = xi.effect.EARTHEN_ARMOR, power = 75, subPower = 50, duration = 60 },
    crystal_blessing = { tp = 200 },
}

for name, data in pairs(wards) do
    -- These pacts have database rows but no base script to create their cache table.
    xi.module.ensureTable('xi.actions.abilities.pets.' .. name)

    m:addOverride('xi.actions.abilities.pets.' .. name .. '.onAbilityCheck', function(player, target, ability)
        return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
    end)

    m:addOverride('xi.actions.abilities.pets.' .. name .. '.onPetAbility', function(target, pet, skill, master, action)
        xi.job_utils.summoner.onUseBloodPact(target, skill, master, action)

        if data.tp then
            target:addTP(data.tp)
            skill:setMsg(xi.msg.basic.TP_INCREASE)
            return target:getTP()
        end

        local applied = target:addStatusEffect(data.effect,
        {
            power = data.power,
            duration = data.duration,
            origin = pet,
            subPower = data.subPower or 0,
        })

        if not applied then
            skill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
            return 0
        end

        if target:getID() == action:getPrimaryTargetID() then
            skill:setMsg(xi.msg.basic.SKILL_GAIN_EFFECT_2)
        else
            skill:setMsg(xi.msg.basic.JA_GAIN_EFFECT)
        end

        return data.effect
    end)
end

return m
