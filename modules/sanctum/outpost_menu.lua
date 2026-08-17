-----------------------------------
-- Sanctum Outpost Menu
-----------------------------------
---@type TCommand
local commandObj = {}

local protocolPrefix    = '[SOP1]'
local enabledLocalVar   = '[SanctumOutpost]Enabled'
local heartbeatLocalVar = '[SanctumOutpost]Heartbeat'
local heartbeatTimeout  = 30
local sessionTimeout    = 60
local maximumDistance   = 10
local sessions          = {}
local sequence          = 0

local outpostMenu = {}

local function sendProtocol(player, payload)
    local message = protocolPrefix .. payload
    if #message > 150 then
        return false
    end

    player:printToPlayer(message, xi.msg.channel.SYSTEM_1)
    return true
end

local function sessionKey(player)
    return player:getID()
end

local function createToken(player)
    sequence = (sequence + 1) % 65536
    return string.format('%04X%04X', player:getID() % 65536, sequence)
end

local function clearSession(player)
    sessions[sessionKey(player)] = nil
end

function outpostMenu.isEnabled(player)
    return
        player:getLocalVar(enabledLocalVar) == 1 and
        player:getLocalVar(heartbeatLocalVar) >= GetSystemTime() - heartbeatTimeout
end

function outpostMenu.open(player, npc, destinations, onSelect)
    if not outpostMenu.isEnabled(player) then
        return false
    end

    local routePayloads = {}
    local routesByRegion = {}

    for _, destination in ipairs(destinations) do
        if not destination.locked and destination.region ~= nil then
            local gilCost = destination.costs and destination.costs.gil or 0
            routesByRegion[destination.region] = destination
            table.insert(routePayloads, string.format('%u,%u', destination.region, gilCost))
        end
    end

    if #routePayloads == 0 then
        return false
    end

    local token = createToken(player)
    sessions[sessionKey(player)] =
    {
        token        = token,
        zoneId       = player:getZoneID(),
        npc          = npc,
        routes       = routesByRegion,
        onSelect     = onSelect,
        expiresAt    = GetSystemTime() + sessionTimeout,
    }

    if not sendProtocol(player, string.format('OPEN|%s|%s', token, table.concat(routePayloads, ';'))) then
        clearSession(player)
        return false
    end

    return true
end

local function selectRoute(player, token, region)
    local session = sessions[sessionKey(player)]
    if session == nil or session.token ~= token then
        sendProtocol(player, 'ERROR|That warp request is no longer valid.')
        return
    end

    if GetSystemTime() > session.expiresAt then
        clearSession(player)
        sendProtocol(player, 'ERROR|That warp request has expired.')
        return
    end

    if
        player:getZoneID() ~= session.zoneId or
        player:checkDistance(session.npc) > maximumDistance
    then
        clearSession(player)
        sendProtocol(player, 'ERROR|You moved too far away from the liaison.')
        return
    end

    local destination = session.routes[region]
    if destination == nil then
        sendProtocol(player, 'ERROR|That destination is not available.')
        return
    end

    clearSession(player)
    session.onSelect(player, destination, session.npc)
    sendProtocol(player, 'CLOSE')
end

commandObj.cmdprops =
{
    permission = 0,
    parameters = 'ssi',
}

commandObj.onTrigger = function(player, action, token, region)
    action = string.lower(action or 'on')

    if action == 'on' then
        player:setLocalVar(enabledLocalVar, 1)
        player:setLocalVar(heartbeatLocalVar, GetSystemTime())
        sendProtocol(player, 'READY')
        return
    end

    if action == 'ping' then
        player:setLocalVar(enabledLocalVar, 1)
        player:setLocalVar(heartbeatLocalVar, GetSystemTime())
        return
    end

    if action == 'off' then
        player:setLocalVar(enabledLocalVar, 0)
        player:setLocalVar(heartbeatLocalVar, 0)
        clearSession(player)
        return
    end

    if action == 'cancel' then
        local session = sessions[sessionKey(player)]
        if session ~= nil and session.token == token then
            clearSession(player)
        end

        return
    end

    if action == 'select' and token ~= nil and region ~= nil then
        selectRoute(player, token, region)
    end
end

_G.SanctumOutpostMenu = outpostMenu

return commandObj
