-----------------------------------
-- Variant System GM controls
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'sss',
}

local function message(player, text)
    player:printToPlayer('[Variant Test] ' .. text)
end

local function showHelp(player)
    message(player, '!varianttest variant - force the targeted configured mob into a Variant')
    message(player, '!varianttest chain [key] [level] - spawn a Chainbreaker at its source target or at you')
    message(player, '!varianttest status [key] - show family cooldown and spawn state')
    message(player, '!varianttest clear <key|all> - clear family cooldowns')
    message(player, '!varianttest zoneboss [level] - spawn this zone boss at you')
    message(player, '!spawn zoneboss [level] - shortcut for spawning this zone boss at you')
    message(player, '!varianttest zonestatus - show zone boss progress and participation')
    message(player, '!varianttest zonekills <count> - set the zone boss Chainbreaker count')
    message(player, '!varianttest inspect - show the targeted mob buffs and weakness')
end

local function getApiAndRuntime(player)
    local api = rawget(_G, 'SanctumVariantSystem')
    if api == nil then
        message(player, 'The Variant System is not loaded.')
        return nil, nil
    end

    local runtime = api.getRuntime(player:getZoneID())
    if runtime == nil then
        if api.isZoneConfigured ~= nil and api.isZoneConfigured(player:getZoneID()) then
            message(player, 'This Variant zone is not initialized. Restart the map server.')
        else
            message(player, 'This zone has no configured Variant families.')
        end

        return nil, nil
    end

    return api, runtime
end

local function getTarget(player)
    local target = player:getCursorTarget()

    if target ~= nil and target:isMob() then
        return target
    end

    return nil
end

local function resolveConfig(api, runtime, target, key)
    if key ~= nil and #key > 0 then
        return api.findMobConfig(runtime, key)
    end

    return api.getMobConfig(target)
end

local function formatDuration(seconds)
    local minutes = math.floor(seconds / 60)
    local remainder = seconds % 60

    return string.format('%um %02us', minutes, remainder)
end

local function showStatus(player, api, runtime, mobConfig)
    local status = api.getStatus(runtime, mobConfig)
    if status == nil then
        return
    end

    if not status.hasChainbreaker then
        message(player, string.format('%s (%s): Variant only; no Chainbreaker configured.', status.displayName, status.key))
        return
    end

    local state = 'available'
    if status.active then
        state = 'active'
    elseif status.pending then
        state = 'pending'
    elseif status.cooldownRemaining > 0 then
        state = 'cooldown ' .. formatDuration(status.cooldownRemaining)
    end

    message(player, string.format('%s (%s): %s', status.displayName, status.key, state))
end

commandObj.onTrigger = function(player, action, first, second)
    action = tostring(action or 'help'):lower()

    if action == 'help' or action == '?' then
        showHelp(player)
        return
    end

    local api, runtime = getApiAndRuntime(player)
    if api == nil then
        return
    end

    local target = getTarget(player)

    if action == 'variant' or action == 'force' then
        local success, result = api.forceVariant(target)
        message(player, success and ('Forced ' .. result .. '.') or result)
        return
    end

    if action == 'chain' or action == 'chainbreaker' then
        local key = first
        local level = tonumber(second)

        if tonumber(first) ~= nil then
            key = nil
            level = tonumber(first)
        end

        local mobConfig = resolveConfig(api, runtime, target, key)
        if mobConfig == nil then
            message(player, 'Target a configured source mob or provide its key.')
            return
        end

        local sourceMob = api.getMobConfig(target) == mobConfig and target or nil
        local success, result = api.forceChainbreaker(
            runtime,
            mobConfig,
            player,
            sourceMob,
            level)

        message(player, success and ('Spawned ' .. result .. '.') or result)
        return
    end

    if action == 'zoneboss' or action == 'boss' then
        local success, result = api.forceZoneBoss(runtime, player, tonumber(first))
        message(player, success and ('Spawned ' .. result .. '.') or result)
        return
    end

    if action == 'zonestatus' or action == 'bossstatus' then
        local status = api.getZoneBossStatus(runtime)

        if status == nil then
            message(player, 'This zone has no configured Zone Boss.')
            return
        end

        local state = status.active and 'active' or (status.pending and 'pending' or 'inactive')

        message(player, string.format(
            '%s: %s; Chainbreakers %u/%u; roll %u%%; participants %u; points %u; EXP %u/point capped at %u.',
            status.displayName,
            state,
            status.killCount,
            status.threshold,
            status.chance,
            status.participantCount,
            status.totalPoints,
            status.xpPerPoint,
            status.xpCap))
        return
    end

    if action == 'zonekills' or action == 'bosskills' then
        local count = tonumber(first)

        if count == nil then
            message(player, 'Provide a Chainbreaker kill count.')
            return
        end

        api.setZoneBossKillCount(runtime, count)
        message(player, string.format(
            'Set this zone boss Chainbreaker count to %u.',
            math.max(0, math.floor(count))))
        return
    end

    if action == 'status' or action == 'cooldown' then
        local mobConfig = resolveConfig(api, runtime, target, first)
        if mobConfig ~= nil then
            showStatus(player, api, runtime, mobConfig)
            return
        end

        if first ~= nil then
            message(player, 'Unknown Variant family key: ' .. first)
            return
        end

        for _, config in ipairs(api.getConfigs(runtime)) do
            showStatus(player, api, runtime, config)
        end

        return
    end

    if action == 'clear' then
        if first == 'all' then
            local cleared = 0

            for _, config in ipairs(api.getConfigs(runtime)) do
                if api.clearCooldown(runtime, config) then
                    cleared = cleared + 1
                end
            end

            if cleared == 0 then
                message(player, 'This zone has no configured Chainbreaker cooldowns.')
            else
                message(player, string.format('Cleared %u Chainbreaker cooldowns in this zone.', cleared))
            end

            return
        end

        local mobConfig = resolveConfig(api, runtime, target, first)
        if mobConfig == nil then
            message(player, 'Target a configured family or provide its key.')
            return
        end

        if not api.clearCooldown(runtime, mobConfig) then
            message(player, 'That Variant family does not have a Chainbreaker configured yet.')
            return
        end

        message(player, 'Cleared the ' .. mobConfig.chainbreaker.displayName .. ' cooldown.')
        return
    end

    if action == 'inspect' then
        local description = api.describeMob(target)
        if description == nil then
            message(player, 'Target a configured Variant or Chainbreaker.')
            return
        end

        local buffs = #description.buffNames > 0 and
            table.concat(description.buffNames, ', ') or 'none'
        local weakness = description.weaknessName or 'none'

        message(player, string.format(
            '%s: %s; automatic HP +%u%%; buffs: %s; weakness: %s (%s)',
            description.displayName,
            description.kind,
            description.automaticHpBonus,
            buffs,
            weakness,
            description.weaknessRevealed and 'revealed' or 'hidden'))

        if description.kind == 'Zone Boss' then
            message(player, string.format(
                'Participation: %u players, %u total points.',
                description.participantCount,
                description.totalPoints))
        end

        return
    end

    showHelp(player)
end

return commandObj
