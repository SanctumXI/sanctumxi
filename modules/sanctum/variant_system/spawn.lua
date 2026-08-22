-----------------------------------
-- Sanctum spawn shortcuts
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'ss',
}

local function message(player, text)
    player:printToPlayer('[Sanctum Spawn] ' .. text)
end

commandObj.onTrigger = function(player, spawnType, level)
    spawnType = tostring(spawnType or ''):lower()

    if spawnType ~= 'zoneboss' and spawnType ~= 'boss' then
        message(player, 'Usage: !spawn zoneboss [level]')
        return
    end

    local api = rawget(_G, 'SanctumVariantSystem')
    if api == nil then
        message(player, 'The Variant System is not loaded.')
        return
    end

    local runtime = api.getRuntime(player:getZoneID())
    if runtime == nil then
        if api.isZoneConfigured ~= nil and api.isZoneConfigured(player:getZoneID()) then
            message(player, 'This Variant zone is not initialized. Restart the map server.')
        else
            message(player, 'This zone has no configured Variant families.')
        end

        return
    end

    local success, result = api.forceZoneBoss(runtime, player, tonumber(level))

    message(player, success and ('Spawned ' .. result .. '.') or result)
end

return commandObj
