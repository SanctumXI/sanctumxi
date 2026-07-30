-----------------------------------
-- Shared behavior for Ro'Hyu Blackanvil and Za'Dha Adamantking.
-----------------------------------
local adamantking =
{
    tormentThresholds  = { 90, 75, 50, 25 },
    diamondShellTimeMs = 60000,
}

adamantking.reset = function(mob)
    mob:setLocalVar('tormentThresholdIndex', 1)
    mob:setLocalVar('adamantkingSequenceBusy', 0)
    mob:setLocalVar('diamondShellQueued', 0)
    mob:setLocalVar('rearDamageNull', 0)
    mob:setLocalVar('diamondShellGeneration', mob:getLocalVar('diamondShellGeneration') + 1)
end

adamantking.tryTorment = function(mob, target)
    local thresholdIndex = mob:getLocalVar('tormentThresholdIndex')
    local threshold      = adamantking.tormentThresholds[thresholdIndex]

    if
        threshold and
        mob:getHPP() <= threshold and
        mob:getLocalVar('adamantkingSequenceBusy') == 0 and
        mob:canUseAbilities() and
        not xi.combat.behavior.isEntityBusy(mob)
    then
        mob:setLocalVar('tormentThresholdIndex', thresholdIndex + 1)
        mob:setLocalVar('adamantkingSequenceBusy', 1)
        mob:useMobAbility(xi.mobSkill.TORMENT_OF_GUDHA, target, nil, true)
    end
end

adamantking.beginDiamondShell = function(mob)
    if mob:getLocalVar('diamondShellQueued') ~= 0 then
        return
    end

    mob:setLocalVar('diamondShellQueued', 1)
    mob:setLocalVar('rearDamageNull', 1)

    local generation = mob:getLocalVar('diamondShellGeneration') + 1
    mob:setLocalVar('diamondShellGeneration', generation)

    -- Generation matching lets a later Torment refresh the full 60 seconds safely.
    mob:timer(adamantking.diamondShellTimeMs, function(mobArg)
        if mobArg:getLocalVar('diamondShellGeneration') == generation then
            mobArg:setLocalVar('rearDamageNull', 0)
        end
    end)

    -- Play Diamond Shell as an immediate follow-up without adding it to the normal TP list.
    mob:timer(500, function(mobArg)
        if
            mobArg:isAlive() and
            mobArg:getLocalVar('diamondShellQueued') == 1
        then
            mobArg:useMobAbility(xi.mobSkill.DIAMOND_SHELL, mobArg, 0, true)
        end
    end)

    -- Do not leave the threshold sequence locked if the follow-up is interrupted.
    mob:timer(6000, function(mobArg)
        if mobArg:getLocalVar('diamondShellQueued') == 1 then
            mobArg:setLocalVar('diamondShellQueued', 0)
            mobArg:setLocalVar('adamantkingSequenceBusy', 0)
        end
    end)
end

adamantking.finishDiamondShell = function(mob)
    mob:setLocalVar('diamondShellQueued', 0)
    mob:setLocalVar('adamantkingSequenceBusy', 0)
end

return adamantking
