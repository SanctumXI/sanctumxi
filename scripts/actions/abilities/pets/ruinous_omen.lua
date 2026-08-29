-----------------------------------
-- Ruinous Omen
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.summoner.canUseBloodPact(player, player:getPet(), target, ability)
end

abilityObject.onPetAbility = function(target, pet, skill, summoner, action)
    xi.job_utils.summoner.onUseBloodPact(target, skill, summoner, action)

    local currentHP = target:getHP()
    local damageCap = math.max(0, currentHP - 1)
    if target:isNM() then
        damageCap = math.floor(currentHP * 0.10)
    end

    local params =
    {
        baseDamage = math.floor(currentHP * math.randomInt(1, 99) / 100),
        fTP = { 1.0, 1.0, 1.0 },
        int_wSC = 0.30,
        element = xi.element.DARK,
        attackType = xi.attackType.MAGICAL,
        damageType = xi.damageType.DARK,
        shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS,
        primaryMessage = xi.msg.basic.USES_JA_TAKE_DAMAGE,
    }

    local info = xi.mobskills.mobMagicalMove(pet, target, skill, action, params)
    info.damage = math.min(info.damage, damageCap)

    if xi.mobskills.processDamage(pet, target, skill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    summoner:setMP(0)
    return info.damage
end

return abilityObject
