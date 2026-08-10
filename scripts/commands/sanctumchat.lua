-----------------------------------
-- func: sanctumchat
-- desc: Registers the SanctumChat Ashita addon and synchronizes authoritative
--       player-pet ownership records for the caller's local alliance.
-----------------------------------
---@type TCommand
local commandObj = {}

local enabledLocalVar = '[SanctumChat]Enabled'
local mappingPrefix   = '[SCMAP1]'
local statusPrefix    = '[SCCHAT1]'

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's',
}

local function sanitizeProtocolField(value)
    return string.gsub(value or '', '[%c|]', '_')
end

local function formatPetDisplayName(value)
    local displayName = string.gsub(value or '', '_', ' ')
    displayName       = string.gsub(displayName, '(%u)(%u%l)', '%1 %2')
    displayName       = string.gsub(displayName, '([%l%d])(%u)', '%1 %2')
    displayName       = string.gsub(displayName, '%s+', ' ')
    return string.gsub(displayName, '^%s*(.-)%s*$', '%1')
end

local function sendPetMapping(recipient, owner)
    if
        owner == nil or
        not owner:isPC() or
        owner:getZoneID() ~= recipient:getZoneID()
    then
        return
    end

    local pet = owner:getPet()
    if pet == nil then
        return
    end

    recipient:printToPlayer(string.format(
        '%s%s|%s|%s|%u',
        mappingPrefix,
        sanitizeProtocolField(pet:getPacketName()),
        sanitizeProtocolField(owner:getName()),
        sanitizeProtocolField(formatPetDisplayName(pet:getName())),
        pet:getID()), xi.msg.channel.SYSTEM_1)
end

local function synchronizeAlliancePets(player)
    for _, member in ipairs(player:getAlliance()) do
        sendPetMapping(player, member)
    end
end

commandObj.onTrigger = function(player, action)
    action = string.lower(action or 'on')

    if action == 'off' then
        player:setLocalVar(enabledLocalVar, 0)
        player:printToPlayer(statusPrefix .. 'OFF', xi.msg.channel.SYSTEM_1)
        return
    end

    if action == 'on' or action == 'sync' then
        player:setLocalVar(enabledLocalVar, 1)
        player:printToPlayer(statusPrefix .. 'READY', xi.msg.channel.SYSTEM_1)
        synchronizeAlliancePets(player)
        return
    end

    player:printToPlayer('Usage: !sanctumchat on|sync|off')
end

return commandObj
