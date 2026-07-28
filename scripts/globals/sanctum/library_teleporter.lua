-----------------------------------
-- Runtime-instance teleporter NPC helper.
-----------------------------------
local teleporter = {}

local function isDestinationUnlocked(player, destination)
    if destination.level and player:getMainLvl() < destination.level then
        return false
    end

    return not destination.check or destination.check(player)
end

local function applyPreTeleportEffects(player, config)
    for _, effectInfo in ipairs(config.preTeleportEffects or {}) do
        local duration = effectInfo.duration
        if type(duration) == 'function' then
            duration = duration(player)
        end

        if effectInfo.removeConflicting then
            player:delStatusEffectsByFlag(xi.effectFlag.INFLUENCE, true)
        end

        player:addStatusEffect(effectInfo.effect, effectInfo.power or 0, 0, duration or 3600)
    end
end

local function executeTeleport(player, config, destination)
    applyPreTeleportEffects(player, config)

    if config.animation then
        player:injectActionPacket(
            player:getID(),
            config.animation.actionID or 6,
            config.animation.animID or 600,
            0, 0, 0, 0, 0
        )
    end

    player:timer(config.teleportDelay or 1500, function(playerArg)
        local pos = destination.pos
        playerArg:setPos(pos[1], pos[2], pos[3], pos[4], pos[5])
    end)
end

local function showConfirmation(player, npc, config, destination, canUse)
    player:timer(100, function(playerArg)
        playerArg:customMenu(
        {
            title = string.format('Travel to %s?', destination.name),
            options =
            {
                {
                    'Yes',
                    function(confirmingPlayer)
                        if not canUse(confirmingPlayer) then
                            return
                        end

                        local gilCost = destination.costs and destination.costs.gil or 0
                        if gilCost > 0 and confirmingPlayer:getGil() < gilCost then
                            confirmingPlayer:printToPlayer(
                                config.insufficientGil or 'You do not have enough Gil.',
                                0,
                                npc:getPacketName()
                            )
                            return
                        end

                        if gilCost > 0 then
                            confirmingPlayer:delGil(gilCost)
                        end

                        executeTeleport(confirmingPlayer, config, destination)
                    end,
                },
                {
                    'No',
                    function(confirmingPlayer)
                        confirmingPlayer:printToPlayer(
                            config.cancelled or 'Perhaps another time.',
                            0,
                            npc:getPacketName()
                        )
                    end,
                },
            },
        })
    end)
end

local function showDestinationPage(player, npc, config, canUse, page)
    local itemsPerPage = config.itemsPerPage or 4
    local totalPages = math.max(1, math.ceil(#config.destinations / itemsPerPage))
    local firstItem = ((page - 1) * itemsPerPage) + 1
    local lastItem = math.min(firstItem + itemsPerPage - 1, #config.destinations)
    local options = {}

    for index = firstItem, lastItem do
        local destination = config.destinations[index]
        local unlocked = isDestinationUnlocked(player, destination)
        local gilCost = destination.costs and destination.costs.gil or 0
        local label = destination.name

        if unlocked and gilCost > 0 then
            label = string.format('%s (%u Gil)', label, gilCost)
        end

        table.insert(options,
        {
            label,
            function(selectingPlayer)
                if not canUse(selectingPlayer) then
                    return
                end

                if not isDestinationUnlocked(selectingPlayer, destination) then
                    selectingPlayer:printToPlayer(
                        string.format('%s is locked. %s.', destination.name, destination.lockText or 'Prerequisite required'),
                        0,
                        npc:getPacketName()
                    )
                    return
                end

                showConfirmation(selectingPlayer, npc, config, destination, canUse)
            end,
        })
    end

    if page < totalPages then
        table.insert(options, { '(Next)', function(playerArg) showDestinationPage(playerArg, npc, config, canUse, page + 1) end })
    end

    if page > 1 then
        table.insert(options, { '(Previous)', function(playerArg) showDestinationPage(playerArg, npc, config, canUse, page - 1) end })
    end

    table.insert(options,
    {
        'Cancel',
        function(playerArg)
            playerArg:printToPlayer(config.cancelled or 'Perhaps another time.', 0, npc:getPacketName())
        end,
    })

    player:timer(100, function(playerArg)
        playerArg:customMenu(
        {
            title = totalPages > 1 and string.format('%s (%u/%u)', config.menuTitle, page, totalPages) or config.menuTitle,
            options = options,
        })
    end)
end

teleporter.insert = function(instance, config, canUse)
    return instance:insertDynamicEntity(
    {
        objtype = xi.objType.NPC,
        name = config.name,
        packetName = config.name,
        look = config.look,
        x = config.pos[1],
        y = config.pos[2],
        z = config.pos[3],
        rotation = config.pos[4],
        widescan = 1,
        onTrigger = function(player, npc)
            if not canUse(player) then
                return
            end

            npc:lookAt(player:getPos())
            player:printToPlayer(config.greeting, xi.msg.channel.SYSTEM_3)
            showDestinationPage(player, npc, config, canUse, 1)
        end,
    })
end

return teleporter
