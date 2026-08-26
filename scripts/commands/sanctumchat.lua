-----------------------------------
-- func: sanctumchat
-- desc: Registers the SanctumChat Ashita addon and synchronizes authoritative
--       player-pet ownership records for the caller's current zone/instance.
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

local function formatPetDisplayName(value, omitFamiliar)
    local displayName = string.gsub(value or '', '_', ' ')
    displayName       = string.gsub(displayName, '(%u)(%u%l)', '%1 %2')
    displayName       = string.gsub(displayName, '([%l%d])(%u)', '%1 %2')
    displayName       = string.gsub(displayName, '%s+', ' ')

    if omitFamiliar then
        displayName = string.gsub(displayName, '[%s%._%-]*Familiar$', '')
    end

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
    if pet == nil or pet:getPetID() == xi.petId.WYVERN then
        return
    end

    local packetName = pet:getPacketName()
    if packetName == '' then
        packetName = pet:getName()
    end

    recipient:printToPlayer(string.format(
        '%s%s|%s|%s|%u',
        mappingPrefix,
        sanitizeProtocolField(packetName),
        sanitizeProtocolField(owner:getName()),
        sanitizeProtocolField(formatPetDisplayName(pet:getName(), owner:hasJugPet())),
        pet:getID()), xi.msg.channel.SYSTEM_1)
end

local function synchronizeZonePets(player)
    local playerInstance = player:getInstance()

    for _, owner in pairs(player:getZone():getPlayers()) do
        if owner:getInstance() == playerInstance then
            sendPetMapping(player, owner)
        end
    end
end

commandObj.onTrigger = function(player, action)
    action = string.lower(action or 'on')
    local isSilent = false
    if string.sub(action, 1, 7) == 'silent_' then
        action   = string.sub(action, 8)
        isSilent = true
    end

    if action == 'off' then
        player:setLocalVar(enabledLocalVar, 0)
        if not isSilent then
            player:printToPlayer(statusPrefix .. 'OFF', xi.msg.channel.SYSTEM_1)
        end

        return
    end

    if action == 'on' or action == 'sync' then
        player:setLocalVar(enabledLocalVar, 1)
        if not isSilent or action == 'on' then
            player:printToPlayer(statusPrefix .. 'READY', xi.msg.channel.SYSTEM_1)
        end

        synchronizeZonePets(player)
        return
    end

    player:printToPlayer('Usage: !sanctumchat on|sync|off')
end

return commandObj
