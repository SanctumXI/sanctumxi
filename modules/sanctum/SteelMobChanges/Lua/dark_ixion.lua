require('modules/module_utils')

local m = Module:new('steel_mobchanges_dark_ixion')

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

return m
