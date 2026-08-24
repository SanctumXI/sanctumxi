-----------------------------------
-- Sanctum model ID browser
-----------------------------------
---@type TCommand
local commandObj = {}

local modelListPath  = 'documentation/model_ids.txt'
local maximumModelId = 0xFFFF
local defaultPageSize = 8
local maximumPageSize = 12
local galleryColumns  = 4
local gallerySpacing  = 5
local sessions        = {}
local documentedIds   = {}
local documentedCount = 0
local documentedMax   = -1
local modelListError

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'sss',
}

local function message(player, text)
    player:printToPlayer('[Model Browser] ' .. text, xi.msg.channel.SYSTEM_3)
end

local function loadDocumentedIds()
    local file = io.open(modelListPath, 'r')
    if file == nil then
        modelListError = 'Could not open ' .. modelListPath .. '.'
        return false
    end

    local ids = {}
    local count = 0
    local highest = -1

    for line in file:lines() do
        local idText = line:match('^%s*(%d+)%s*$') or line:match('^%s*(%d+)%s+')
        local modelId = tonumber(idText)

        if modelId ~= nil and modelId <= maximumModelId and not ids[modelId] then
            ids[modelId] = true
            count = count + 1
            highest = math.max(highest, modelId)
        end
    end

    file:close()
    documentedIds = ids
    documentedCount = count
    documentedMax = highest
    modelListError = nil
    return true
end

local function sessionKey(player)
    return player:getID()
end

local function clearSession(player)
    local key = sessionKey(player)
    local session = sessions[key]

    if session == nil then
        return 0
    end

    local cleared = 0
    for _, entity in ipairs(session.entities) do
        if entity ~= nil and entity:getZoneID() == session.zoneId then
            entity:setStatus(xi.status.DISAPPEAR)
            cleared = cleared + 1
        end
    end

    sessions[key] = nil
    return cleared
end

local function pageSize(value)
    local count = math.floor(tonumber(value) or defaultPageSize)
    return math.max(1, math.min(maximumPageSize, count))
end

local function modelId(value, fallback)
    local id = math.floor(tonumber(value) or fallback)
    return math.max(0, math.min(maximumModelId, id))
end

local function collectPage(startId, count)
    local ids = {}

    for id = startId, maximumModelId do
        if not documentedIds[id] then
            table.insert(ids, id)
            if #ids == count then
                break
            end
        end
    end

    return ids
end

local function previousPageStart(firstId, count)
    local ids = {}

    for id = firstId - 1, 0, -1 do
        if not documentedIds[id] then
            table.insert(ids, 1, id)
            if #ids == count then
                break
            end
        end
    end

    return ids[1]
end

local function galleryPosition(playerPosition, slot, count)
    local row = math.floor((slot - 1) / galleryColumns)
    local column = (slot - 1) % galleryColumns
    local rowCount = math.min(galleryColumns, count - row * galleryColumns)
    local lateral = (column - (rowCount - 1) / 2) * gallerySpacing
    local forward = 7 + row * gallerySpacing
    local angle = playerPosition.rot * 2 * math.pi / 256
    local forwardX = math.cos(angle)
    local forwardZ = math.sin(angle)
    local rightX = -forwardZ
    local rightZ = forwardX

    return
    {
        x = playerPosition.x + forwardX * forward + rightX * lateral,
        y = playerPosition.y,
        z = playerPosition.z + forwardZ * forward + rightZ * lateral,
        rotation = (playerPosition.rot + 128) % 256,
    }
end

local function createEntity(player, slot, id, position)
    return player:getZone():insertDynamicEntity({
        objtype              = xi.objType.NPC,
        name                 = string.format('ModelBrowser_%u_%u', player:getID(), slot),
        packetName           = string.format('Model %05u', id),
        look                 = id,
        x                    = position.x,
        y                    = position.y,
        z                    = position.z,
        rotation             = position.rotation,
        widescan             = 0,
        releaseIdOnDisappear = true,
        onTrigger            = function(triggerPlayer, npc)
            message(triggerPlayer, string.format('Selected model ID %u.', npc:getModelId()))
        end,
    })
end

local function updateEntity(entity, id, position)
    entity:setModelId(id)
    entity:renameEntity(string.format('Model %05u', id), true)
    entity:setPos(position.x, position.y, position.z, position.rotation)
end

local function showPage(player, startId, count)
    if player:getZoneID() ~= xi.zone.GM_HOME then
        message(player, 'Use this command in GM Home. Run !gmhome first.')
        return
    end

    if modelListError ~= nil then
        message(player, modelListError .. ' Use !modelbrowse reload after fixing it.')
        return
    end

    local ids = collectPage(startId, count)
    if #ids == 0 then
        message(player, string.format('No undocumented model IDs exist at or above %u.', startId))
        return
    end

    local key = sessionKey(player)
    local session = sessions[key]
    local reuseEntities = session ~= nil and session.zoneId == player:getZoneID() and #session.entities == #ids

    if not reuseEntities then
        clearSession(player)
        session =
        {
            entities = {},
            zoneId = player:getZoneID(),
        }
    end

    local playerPosition = player:getPos()
    for slot, id in ipairs(ids) do
        local position = galleryPosition(playerPosition, slot, #ids)

        if reuseEntities then
            updateEntity(session.entities[slot], id, position)
        else
            local entity = createEntity(player, slot, id, position)
            if entity == nil then
                for _, createdEntity in ipairs(session.entities) do
                    createdEntity:setStatus(xi.status.DISAPPEAR)
                end

                message(player, 'The zone has no free dynamic entity slots for this gallery.')
                return
            end

            table.insert(session.entities, entity)
        end
    end

    session.ids = ids
    session.count = count
    session.firstId = ids[1]
    session.lastId = ids[#ids]
    sessions[key] = session

    message(player, string.format(
        'Showing %u undocumented IDs from %u through %u: %s',
        #ids,
        session.firstId,
        session.lastId,
        table.concat(ids, ', ')))
end

local function showHelp(player)
    message(player, '!modelbrowse [start] [count] - show undocumented IDs at or above start')
    message(player, '!modelbrowse holes [count] - start with the first gap in the current list')
    message(player, '!modelbrowse new [count] - start after the highest documented ID')
    message(player, '!modelbrowse next | prev - move through undocumented IDs')
    message(player, '!modelbrowse clear - remove your gallery')
    message(player, '!modelbrowse reload - reload documentation/model_ids.txt')
    message(player, string.format('Page size defaults to %u and is capped at %u.', defaultPageSize, maximumPageSize))
end

commandObj.onTrigger = function(player, action, first, second)
    action = tostring(action or 'holes'):lower()

    if action == 'help' or action == '?' then
        showHelp(player)
        return
    end

    if action == 'clear' then
        local cleared = clearSession(player)
        message(player, string.format('Removed %u model browser entities.', cleared))
        return
    end

    if action == 'reload' then
        if loadDocumentedIds() then
            message(player, string.format(
                'Loaded %u documented IDs; highest documented ID is %u.',
                documentedCount,
                documentedMax))
        else
            message(player, modelListError)
        end

        return
    end

    if action == 'status' then
        if modelListError ~= nil then
            message(player, modelListError)
            return
        end

        local session = sessions[sessionKey(player)]
        message(player, string.format(
            'List contains %u documented IDs; highest is %u.',
            documentedCount,
            documentedMax))

        if session ~= nil then
            message(player, 'Active gallery IDs: ' .. table.concat(session.ids, ', '))
        end

        return
    end

    if action == 'next' then
        local session = sessions[sessionKey(player)]
        if session ~= nil and session.lastId >= maximumModelId then
            message(player, 'The active gallery is already at the final possible model ID.')
            return
        end

        local startId = session ~= nil and session.lastId + 1 or 0
        showPage(player, modelId(startId, 0), pageSize(first))
        return
    end

    if action == 'prev' or action == 'previous' then
        local session = sessions[sessionKey(player)]
        if session == nil then
            message(player, 'There is no active gallery. Use !modelbrowse first.')
            return
        end

        local count = pageSize(first or session.count)
        local startId = previousPageStart(session.firstId, count)
        if startId == nil then
            message(player, 'The active gallery is already at the first undocumented ID.')
            return
        end

        showPage(player, startId, count)
        return
    end

    if action == 'holes' then
        showPage(player, 0, pageSize(first))
        return
    end

    if action == 'new' then
        showPage(player, modelId(documentedMax + 1, 0), pageSize(first))
        return
    end

    local startId = tonumber(action)
    if startId ~= nil then
        showPage(player, modelId(startId, 0), pageSize(first))
        return
    end

    if action == 'show' then
        showPage(player, modelId(first, 0), pageSize(second))
        return
    end

    showHelp(player)
end

loadDocumentedIds()

_G.SanctumModelBrowser =
{
    clear = clearSession,
}

return commandObj
