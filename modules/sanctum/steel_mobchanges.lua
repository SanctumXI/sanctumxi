require('modules/module_utils')

local m = Module:new('steel_mobchanges')

local ixionBehavior = bit.bor(xi.behavior.NO_TURN, xi.behavior.STANDBACK)

local function resetIxionSkillState(mob)
    mob:setLocalVar('pendingIxionSkill', 0)
    mob:setLocalVar('activeIxionSkill', 0)
    mob:setLocalVar('activeIxionSkillCount', 0)
end

local function restoreIxionCombat(mob)
    mob:setLocalVar('activeIxionSkill', 0)
    mob:setLocalVar('activeIxionSkillCount', 0)

    if mob:getAnimationSub() == 1 or mob:getLocalVar('isBusy') ~= 0 then
        return
    end

    mob:setBehavior(bit.band(mob:getBehavior(), bit.bnot(ixionBehavior)))
    mob:setAutoAttackEnabled(true)
    mob:setMobAbilityEnabled(true)
end

local function addIxionPreListener(mob)
    mob:addListener('WEAPONSKILL_STATE_ENTER', 'STEEL_IXION_WS_STATE_ENTER_PRE', function(mobArg, skillId)
        if skillId == xi.mobSkill.DI_GLOW then
            mobArg:setLocalVar('steelIxionPreBehavior', mobArg:getBehavior())
        end
    end)
end

local function addIxionPostListeners(mob)
    mob:addListener('WEAPONSKILL_STATE_ENTER', 'STEEL_IXION_WS_STATE_ENTER_POST', function(mobArg, skillId)
        if skillId == xi.mobSkill.DI_GLOW then
            mobArg:setLocalVar('activeIxionSkill', mobArg:getLocalVar('pendingIxionSkill'))
            mobArg:setLocalVar('activeIxionSkillCount', 0)
            mobArg:setBehavior(bit.bor(mobArg:getLocalVar('steelIxionPreBehavior'), ixionBehavior))
        end
    end)

    mob:addListener('WEAPONSKILL_STATE_EXIT', 'STEEL_IXION_WS_STATE_EXIT', function(mobArg, skillId, completed)
        local activeSkill = mobArg:getLocalVar('activeIxionSkill')

        if
            (skillId == xi.mobSkill.DI_GLOW and not completed) or
            (activeSkill ~= 0 and skillId == activeSkill)
        then
            local remainingSkills = math.max(0, mobArg:getLocalVar('activeIxionSkillCount') - 1)
            mobArg:setLocalVar('activeIxionSkillCount', remainingSkills)

            if skillId == xi.mobSkill.DI_GLOW or remainingSkills == 0 then
                restoreIxionCombat(mobArg)
            end
        end
    end)

    mob:setLocalVar('steelIxionListeners', 1)
end

m:addOverride('xi.darkixion.roamingMods', function(mob)
    super(mob)
    resetIxionSkillState(mob)
end)

m:addOverride('xi.darkixion.onMobSpawn', function(mob)
    addIxionPreListener(mob)
    super(mob)
    addIxionPostListeners(mob)
end)

m:addOverride('xi.darkixion.onBattlefieldMobSpawn', function(mob)
    addIxionPreListener(mob)
    super(mob)
    resetIxionSkillState(mob)
    addIxionPostListeners(mob)
end)

m:addOverride('xi.darkixion.onBattlefieldMobDisengage', function(mob)
    super(mob)
    resetIxionSkillState(mob)
end)

m:addOverride('xi.darkixion.onMobWeaponSkill', function(target, mob, skill)
    local skillId = skill:getID()

    if skillId == xi.mobSkill.DI_GLOW then
        local activeSkill = mob:getLocalVar('pendingIxionSkill')
        if activeSkill ~= 0 then
            local skillCount = 1
            if mob:getLocalVar('BattlefieldIxion') ~= 1 and mob:getAnimationSub() == 3 then
                skillCount = 2
            end

            mob:setLocalVar('activeIxionSkill', activeSkill)
            mob:setLocalVar('activeIxionSkillCount', skillCount)
        end
    end

    super(target, mob, skill)

    if skillId == xi.mobSkill.DI_GLOW then
        local activeSkill = mob:getLocalVar('lastIxionSkill')
        if activeSkill ~= 0 then
            mob:setLocalVar('activeIxionSkill', activeSkill)
        end

        mob:queue(0, function(mobArg)
            if mobArg:getLocalVar('activeIxionSkill') ~= 0 then
                restoreIxionCombat(mobArg)
            end
        end)
    end
end)

m:addOverride('xi.darkixion.onMobFight', function(mob, target)
    if mob:getLocalVar('steelIxionListeners') == 0 then
        addIxionPreListener(mob)
        addIxionPostListeners(mob)
    end

    if
        mob:getAnimationSub() ~= 1 and
        bit.band(mob:getBehavior(), ixionBehavior) ~= 0 and
        not xi.combat.behavior.isEntityBusy(mob)
    then
        restoreIxionCombat(mob)
    end

    super(mob, target)
end)

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

m:addOverride('xi.actions.mobskills.scissor_guard.onMobWeaponSkill', function(mob, target, skill, action)
    xi.mobskills.mobBuffMove(target, xi.effect.COUNTER_BOOST, 25, 0, 30)
    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.DEFENSE_BOOST, 100, 0, 30))

    return xi.effect.DEFENSE_BOOST
end)

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

m:addOverride('xi.actions.mobskills.water_wall.onMobWeaponSkill', function(mob, target, skill, action)
    xi.mobskills.mobBuffMove(target, xi.effect.MAGIC_DEF_BOOST, 75, 0, 30)
    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.DEFENSE_BOOST, 75, 0, 30))

    return xi.effect.DEFENSE_BOOST
end)

return m
