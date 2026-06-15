m:addOverride('xi.player.onPlayerLevelDown', function(player)
    super(player)

    local decoratedMessage = string.format(
        '%s %s has deleveled to level %u on %s! %s',
        openingDecoration,
        player:getName(),
        player:getMainLvl(),
        xi.jobName[player:getMainJob()][2],
        closingDecoration
    )

    -- Sends announcement via ZMQ to all processes and zones
    player:printToArea(decoratedMessage, xi.msg.channel.SYSTEM_3, xi.msg.area.SYSTEM, '', false)
end)