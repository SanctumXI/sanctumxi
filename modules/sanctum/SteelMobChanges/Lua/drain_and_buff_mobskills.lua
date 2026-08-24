require('modules/module_utils')

local m = Module:new('steel_mobchanges_drain_and_buff_mobskills')

m:addOverride('xi.actions.mobskills.blood_drain.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage         = mob:getMainLvl() + 2,
        fTP                = { 1.5, 2.0, 2.5 },
        element            = xi.element.NONE,
        attackType         = xi.attackType.MAGICAL,
        damageType         = xi.damageType.NONE,
        shadowBehavior     = xi.mobskills.shadowBehavior.NUMSHADOWS_1,
        skipMagicBonusDiff = true,
    }

    if mob:getPool() == xi.mobPool.ASANBOSAM then
        params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS
    end

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        skill:setMsg(xi.mobskills.mobDrainMove(mob, target, xi.mobskills.drainType.HP, info.damage, info.attackType, info.damageType))
    end

    return info.damage
end)

m:addOverride('xi.actions.mobskills.scissor_guard.onMobWeaponSkill', function(mob, target, skill, action)
    xi.mobskills.mobBuffMove(target, xi.effect.COUNTER_BOOST, 25, 0, 30)
    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.DEFENSE_BOOST, 100, 0, 30))

    return xi.effect.DEFENSE_BOOST
end)

m:addOverride('xi.actions.mobskills.water_wall.onMobWeaponSkill', function(mob, target, skill, action)
    xi.mobskills.mobBuffMove(target, xi.effect.MAGIC_DEF_BOOST, 75, 0, 30)
    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.DEFENSE_BOOST, 75, 0, 30))

    return xi.effect.DEFENSE_BOOST
end)

return m
