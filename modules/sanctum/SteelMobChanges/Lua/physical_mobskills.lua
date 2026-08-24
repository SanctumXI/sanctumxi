require('modules/module_utils')

local m = Module:new('steel_mobchanges_physical_mobskills')

m:addOverride('xi.actions.mobskills.big_scissors.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage     = mob:getWeaponDmg(),
        numHits        = 2,
        fTP            = { 1.0, 1.25, 1.5 },
        attackType     = xi.attackType.PHYSICAL,
        damageType     = xi.damageType.SLASHING,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_2,
    }
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

m:addOverride('xi.actions.mobskills.blockhead.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage     = mob:getWeaponDmg(),
        numHits        = 1,
        fTP            = { 2.0, 2.5, 3.0 },
        attackType     = xi.attackType.PHYSICAL,
        damageType     = xi.damageType.BLUNT,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1,
    }
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

m:addOverride('xi.actions.mobskills.damnation_dive.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage     = mob:getWeaponDmg(),
        numHits        = 1,
        fTP            = { 2.25, 2.5, 2.75 },
        attackType     = xi.attackType.PHYSICAL,
        damageType     = xi.damageType.SLASHING,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3,
    }
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.STUN, 1, 0, 4)
    end

    return info.damage
end)

m:addOverride('xi.actions.mobskills.helldive.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage     = mob:getWeaponDmg(),
        numHits        = 1,
        fTP            = { 2.0, 2.25, 2.5 },
        attackType     = xi.attackType.PHYSICAL,
        damageType     = xi.damageType.BLUNT,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_2,
    }
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

m:addOverride('xi.actions.mobskills.jet_stream.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage     = mob:getWeaponDmg(),
        numHits        = 3,
        fTP            = { 1.0, 1.1, 1.2 },
        attackType     = xi.attackType.PHYSICAL,
        damageType     = xi.damageType.BLUNT,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3,
    }
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

m:addOverride('xi.actions.mobskills.pecking_flurry.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage     = mob:getWeaponDmg(),
        numHits        = 4,
        fTP            = { 0.75, 0.85, 1.0 },
        attackType     = xi.attackType.PHYSICAL,
        damageType     = xi.damageType.SLASHING,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_4,
    }
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

local function powerAttack(mob, target, skill, action)
    local params =
    {
        baseDamage       = mob:getWeaponDmg(),
        numHits          = 1,
        fTP              = { 1.2, 1.4, 1.6 },
        attackType       = xi.attackType.PHYSICAL,
        damageType       = xi.damageType.HAND_TO_HAND,
        shadowBehavior   = xi.mobskills.shadowBehavior.NUMSHADOWS_1,
        attackMultiplier = { 2.0, 2.0, 2.0 },
    }
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

m:addOverride('xi.actions.mobskills.power_attack.onMobWeaponSkill', powerAttack)
m:addOverride('xi.actions.mobskills.power_attack_beetle.onMobWeaponSkill', powerAttack)

m:addOverride('xi.actions.mobskills.screwdriver.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage     = mob:getWeaponDmg(),
        numHits        = 1,
        fTP            = { 1.5, 1.75, 2.0 },
        attackType     = xi.attackType.PHYSICAL,
        damageType     = xi.damageType.SLASHING,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1,
        canCrit        = true,
        criticalChance = { 0.25, 0.5, 1.0 },
    }
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

m:addOverride('xi.actions.mobskills.sharp_sting.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage     = mob:getWeaponDmg(),
        numHits        = 1,
        fTP            = { 1.5, 1.75, 2.0 },
        attackType     = xi.attackType.PHYSICAL,
        damageType     = xi.damageType.PIERCING,
        shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1,
        skipParry      = false,
        skipGuard      = false,
        skipBlock      = false,
    }
    local info = xi.mobskills.mobRangedMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

m:addOverride('xi.actions.mobskills.sickle_slash.onMobWeaponSkill', function(mob, target, skill, action)
    local params =
    {
        baseDamage       = mob:getWeaponDmg(),
        numHits          = 1,
        fTP              = { 2.0, 2.0, 2.0 },
        attackType       = xi.attackType.PHYSICAL,
        damageType       = xi.damageType.BLUNT,
        shadowBehavior   = xi.mobskills.shadowBehavior.NUMSHADOWS_1,
        attackMultiplier = { 1.5, 1.5, 1.5 },
        canCrit          = true,
        criticalChance   = { 0.25, 0.5, 1.0 },
    }
    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

return m
