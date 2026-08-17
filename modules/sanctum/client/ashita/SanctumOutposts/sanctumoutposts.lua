addon.name      = 'sanctumoutposts'
addon.author    = 'Sanctum Edition'
addon.version   = '1.2.0'
addon.desc      = 'Shows a retail-style menu for Sanctum outpost liaisons.'

require 'common'
local imgui = require 'imgui'
local ffi = require 'ffi'
local d3d8 = require 'd3d8'
require 'd3d8.d3dx8'

local protocolPrefix = '[SOP1]'
local registrationRetrySeconds = 5
local heartbeatSeconds = 10
local menuTimeoutSeconds = 60
local menuFontPath = 'C:\\Windows\\Fonts\\consolab.ttf'
local menuFontSize = 20
local visibleRouteCount = 5
local menuLeftOffset = 20
local menuBottomOffset = 102

local windowTextureFiles =
{
    bg = { file = 'Window6-bg.png', width = 1024, height = 1024 },
    tl = { file = 'Window6-tl.png', width = 491, height = 491 },
    tr = { file = 'Window6-tr.png', width = 21, height = 491 },
    bl = { file = 'Window6-bl.png', width = 491, height = 21 },
    br = { file = 'Window6-br.png', width = 21, height = 21 },
    arrow = { file = 'SelectionArrow.png', width = 16, height = 24 },
}

local regionNames =
{
    [0]  = 'Ronfaure',
    [1]  = 'Zulkheim',
    [2]  = 'Norvallen',
    [3]  = 'Gustaberg',
    [4]  = 'Derfland',
    [5]  = 'Sarutabaruta',
    [6]  = 'Kolshushu',
    [7]  = 'Aragoneu',
    [8]  = 'Fauregandi',
    [9]  = 'Valdeaunia',
    [10] = 'Qufim',
    [11] = "Li'Telor",
    [12] = 'Kuzotz',
    [13] = 'Vollbow',
    [14] = 'Elshimo Lowlands',
    [15] = 'Elshimo Uplands',
    [18] = 'Tavnazia',
}

local menu =
{
    registered = false,
    open = false,
    mode = 'list',
    token = nil,
    routes = {},
    selectedIndex = 1,
    firstVisibleIndex = 1,
    confirmationChoice = 1,
    error = nil,
    expiresAt = 0,
    font = nil,
    textures = {},
    nextRegistrationAttempt = 0,
    nextHeartbeat = 0,
    previousDpadAngle = -1,
}

local function isLoggedIn()
    local party = AshitaCore:GetMemoryManager():GetParty()
    if party == nil then
        return false
    end

    local name = party:GetMemberName(0)
    return name ~= nil and name:trim('\0'):len() > 0
end

local function loadWindowTextures()
    local device = d3d8.get_device()
    if device == nil then
        return
    end

    for name, textureInfo in pairs(windowTextureFiles) do
        local texturePointer = ffi.new('IDirect3DTexture8*[1]')
        local path = ('%s\\assets\\%s'):fmt(addon.path, textureInfo.file)
        if ffi.C.D3DXCreateTextureFromFileA(device, path, texturePointer) == ffi.C.S_OK then
            menu.textures[name] =
            {
                image = texturePointer[0],
                width = textureInfo.width,
                height = textureInfo.height,
            }
        end
    end
end

local function releaseWindowTextures()
    for _, texture in pairs(menu.textures) do
        if texture.image ~= nil then
            texture.image:Release()
            texture.image = nil
        end
    end

    menu.textures = {}
end

local function sendServerCommand(action)
    if not isLoggedIn() then
        return false
    end

    local message = ('!outpost_menu %s'):fmt(action)
    local packetLength = 6 + #message + 1
    local alignedLength = math.floor((packetLength + 3) / 4) * 4
    local packet = {}

    for index = 1, alignedLength do
        packet[index] = 0
    end

    packet[1] = 0xB5
    packet[2] = alignedLength / 2
    packet[5] = 0x00
    packet[6] = 0x00

    for index = 1, #message do
        packet[6 + index] = message:byte(index)
    end

    AshitaCore:GetPacketManager():AddOutgoingPacket(0x0B5, packet)
    return true
end

local function cleanProtocolField(value)
    return (value or ''):gsub('[%z\1-\31]', ''):trim()
end

local function closeMenu(notifyServer)
    if notifyServer and menu.token ~= nil then
        sendServerCommand(('cancel %s'):fmt(menu.token))
    end

    menu.open = false
    menu.mode = 'list'
    menu.token = nil
    menu.routes = {}
    menu.selectedIndex = 1
    menu.firstVisibleIndex = 1
    menu.confirmationChoice = 1
    menu.error = nil
end

local function openMenu(payload)
    local token, routePayload = payload:match('^([^|]+)|(.*)$')
    if token == nil then
        return
    end

    local routes = {}
    for route in routePayload:gmatch('[^;]+') do
        local region, gil = route:match('^(%d+),(%d+)$')
        region = tonumber(region)
        gil = tonumber(gil)
        if region ~= nil and gil ~= nil and regionNames[region] ~= nil then
            routes[#routes + 1] =
            {
                region = region,
                name = regionNames[region],
                gil = gil,
            }
        end
    end

    if #routes == 0 then
        return
    end

    menu.open = true
    menu.mode = 'list'
    menu.token = token
    menu.routes = routes
    menu.selectedIndex = 1
    menu.firstVisibleIndex = 1
    menu.confirmationChoice = 1
    menu.error = nil
    menu.expiresAt = os.clock() + menuTimeoutSeconds
end

local function keepSelectionVisible()
    if menu.selectedIndex < menu.firstVisibleIndex then
        menu.firstVisibleIndex = menu.selectedIndex
    elseif menu.selectedIndex >= menu.firstVisibleIndex + visibleRouteCount then
        menu.firstVisibleIndex = menu.selectedIndex - visibleRouteCount + 1
    end

    local maximumFirstIndex = math.max(1, #menu.routes - visibleRouteCount + 1)
    menu.firstVisibleIndex = math.max(1, math.min(menu.firstVisibleIndex, maximumFirstIndex))
end

local function handleProtocolMessage(message)
    local prefixStart = message:find(protocolPrefix, 1, true)
    if prefixStart == nil then
        return false
    end

    local payload = cleanProtocolField(message:sub(prefixStart + #protocolPrefix))
    if payload == 'READY' then
        menu.registered = true
        menu.nextHeartbeat = os.clock() + heartbeatSeconds
        return true
    end

    if payload:sub(1, 5) == 'OPEN|' then
        menu.registered = true
        openMenu(payload:sub(6))
        return true
    end

    if payload == 'CLOSE' then
        closeMenu(false)
        return true
    end

    if payload:sub(1, 6) == 'ERROR|' then
        menu.error = payload:sub(7)
        menu.mode = 'error'
        menu.expiresAt = os.clock() + 10
        return true
    end

    return true
end

local function changeSelection(direction)
    if menu.mode == 'confirm' then
        menu.confirmationChoice = menu.confirmationChoice == 1 and 2 or 1
        return
    end

    if menu.mode ~= 'list' or #menu.routes == 0 then
        return
    end

    menu.selectedIndex = menu.selectedIndex + direction
    if menu.selectedIndex < 1 then
        menu.selectedIndex = #menu.routes
    elseif menu.selectedIndex > #menu.routes then
        menu.selectedIndex = 1
    end

    keepSelectionVisible()
end

local function activateSelection()
    if menu.mode == 'list' then
        if menu.routes[menu.selectedIndex] ~= nil then
            menu.mode = 'confirm'
            menu.confirmationChoice = 1
        end

        return
    end

    if menu.mode == 'confirm' then
        if menu.confirmationChoice == 2 then
            menu.mode = 'list'
            return
        end

        local route = menu.routes[menu.selectedIndex]
        if route ~= nil and menu.token ~= nil then
            sendServerCommand(('select %s %u'):fmt(menu.token, route.region))
            menu.mode = 'waiting'
            menu.expiresAt = os.clock() + 10
        end

        return
    end

    if menu.mode == 'error' then
        closeMenu(true)
    end
end

local function cancelSelection()
    if menu.mode == 'confirm' then
        menu.mode = 'list'
    else
        closeMenu(true)
    end
end

local function pushMenuStyle()
    imgui.PushStyleColor(ImGuiCol_Text, { 0.92, 0.96, 1.00, 1.00 })
    imgui.PushStyleColor(ImGuiCol_WindowBg, { 0.00, 0.00, 0.00, 0.00 })
    imgui.PushStyleColor(ImGuiCol_ChildBg, { 0.00, 0.00, 0.00, 0.00 })
    imgui.PushStyleColor(ImGuiCol_Border, { 0.00, 0.00, 0.00, 0.00 })
    imgui.PushStyleColor(ImGuiCol_Header, { 0.00, 0.00, 0.00, 0.00 })
    imgui.PushStyleColor(ImGuiCol_HeaderHovered, { 0.00, 0.00, 0.00, 0.00 })
    imgui.PushStyleColor(ImGuiCol_HeaderActive, { 0.00, 0.00, 0.00, 0.00 })

    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, { 9, 7 })
    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, 0)
    imgui.PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0)
    imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 0, 1 })
    imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 0 })
end

local function popMenuStyle()
    imgui.PopStyleVar(5)
    imgui.PopStyleColor(7)
end

local function drawShadowedText(drawList, x, y, text, color)
    local shadow = imgui.GetColorU32({ 0.00, 0.00, 0.00, 0.95 })
    drawList:AddText({ x - 1, y }, shadow, text)
    drawList:AddText({ x + 1, y }, shadow, text)
    drawList:AddText({ x, y - 1 }, shadow, text)
    drawList:AddText({ x, y + 1 }, shadow, text)
    drawList:AddText({ x - 1, y - 1 }, shadow, text)
    drawList:AddText({ x + 1, y - 1 }, shadow, text)
    drawList:AddText({ x - 1, y + 1 }, shadow, text)
    drawList:AddText({ x + 1, y + 1 }, shadow, text)
    drawList:AddText({ x, y }, color, text)
end

local function drawTextLine(text, color, xOffset)
    local cursorX, cursorY = imgui.GetCursorScreenPos()
    local _, textHeight = imgui.CalcTextSize(text)
    drawShadowedText(imgui.GetWindowDrawList(), cursorX + (xOffset or 0), cursorY, text, color)
    imgui.Dummy({ 0, textHeight + 2 })
end

local function drawSelectionArrow(drawList, x, centerY)
    local arrowTexture = menu.textures.arrow
    if arrowTexture ~= nil and arrowTexture.image ~= nil then
        drawList:AddImage(
            tonumber(ffi.cast('uint32_t', arrowTexture.image)),
            { x, centerY - 12 },
            { x + 18, centerY + 12 },
            { 0, 0 },
            { 1, 1 },
            0xFFFFFFFF)
        return
    end

    local shadow = imgui.GetColorU32({ 0.00, 0.00, 0.00, 0.95 })
    local outline = imgui.GetColorU32({ 0.78, 0.81, 0.80, 1.00 })
    local fill = imgui.GetColorU32({ 1.00, 0.99, 0.86, 1.00 })

    drawList:AddTriangleFilled(
        { x + 2, centerY - 11 },
        { x + 19, centerY + 1 },
        { x + 2, centerY + 13 },
        shadow)
    drawList:AddTriangleFilled(
        { x, centerY - 11 },
        { x + 17, centerY },
        { x, centerY + 11 },
        outline)
    drawList:AddTriangleFilled(
        { x + 3, centerY - 8 },
        { x + 14, centerY },
        { x + 3, centerY + 8 },
        fill)
end

local function drawFallbackWindow(drawList, windowX, windowY, windowWidth, windowHeight)
    drawList:AddRectFilled(
        { windowX, windowY },
        { windowX + windowWidth, windowY + windowHeight },
        imgui.GetColorU32({ 0.004, 0.025, 0.105, 0.98 }))

    drawList:AddRect(
        { windowX + 1, windowY + 1 },
        { windowX + windowWidth - 1, windowY + windowHeight - 1 },
        imgui.GetColorU32({ 0.62, 0.52, 0.20, 1.00 }),
        0,
        0,
        1)
end

local function drawTexture(drawList, texture, topLeft, bottomRight, uvBottomRight, tint)
    if texture == nil or texture.image == nil then
        return false
    end

    drawList:AddImage(
        tonumber(ffi.cast('uint32_t', texture.image)),
        topLeft,
        bottomRight,
        { 0, 0 },
        uvBottomRight,
        tint or 0xFFFFFFFF)
    return true
end

local function drawRetailWindow()
    local windowX, windowY = imgui.GetWindowPos()
    local windowWidth, windowHeight = imgui.GetWindowSize()
    local drawList = imgui.GetWindowDrawList()

    local backgroundDrawn = drawTexture(
        drawList,
        menu.textures.bg,
        { windowX, windowY },
        { windowX + windowWidth, windowY + windowHeight },
        { windowWidth / 1024, windowHeight / 1024 },
        imgui.GetColorU32({ 0.68, 0.74, 0.65, 1.00 }))
    if not backgroundDrawn then
        drawFallbackWindow(drawList, windowX, windowY, windowWidth, windowHeight)
        return
    end

    local cornerSize = 21
    local longWidth = windowWidth - cornerSize
    local longHeight = windowHeight - cornerSize

    drawTexture(
        drawList,
        menu.textures.tl,
        { windowX, windowY },
        { windowX + longWidth, windowY + longHeight },
        { longWidth / 491, longHeight / 491 })
    drawTexture(
        drawList,
        menu.textures.tr,
        { windowX + longWidth, windowY },
        { windowX + windowWidth, windowY + longHeight },
        { 1, longHeight / 491 })
    drawTexture(
        drawList,
        menu.textures.bl,
        { windowX, windowY + longHeight },
        { windowX + longWidth, windowY + windowHeight },
        { longWidth / 491, 1 })
    drawTexture(
        drawList,
        menu.textures.br,
        { windowX + longWidth, windowY + longHeight },
        { windowX + windowWidth, windowY + windowHeight },
        { 1, 1 })
end

local function drawRetailScrollbar()
    if #menu.routes <= visibleRouteCount then
        return
    end

    local windowX, windowY = imgui.GetWindowPos()
    local windowWidth, windowHeight = imgui.GetWindowSize()
    local drawList = imgui.GetWindowDrawList()
    local trackX = windowX + windowWidth - 10
    local trackTop = windowY + 7
    local trackBottom = windowY + windowHeight - 7
    local trackHeight = trackBottom - trackTop
    local handleHeight = math.max(24, math.floor(trackHeight * visibleRouteCount / #menu.routes))
    local maximumFirstIndex = #menu.routes - visibleRouteCount + 1
    local progress = (menu.firstVisibleIndex - 1) / (maximumFirstIndex - 1)
    local handleTop = trackTop + math.floor((trackHeight - handleHeight) * progress)
    local track = imgui.GetColorU32({ 0.22, 0.27, 0.32, 0.96 })
    local trackEdge = imgui.GetColorU32({ 0.06, 0.08, 0.11, 1.00 })
    local handle = imgui.GetColorU32({ 0.91, 0.82, 0.91, 1.00 })
    local handleLight = imgui.GetColorU32({ 1.00, 0.95, 1.00, 1.00 })

    drawList:AddRectFilled({ trackX, trackTop }, { trackX + 6, trackBottom }, track)
    drawList:AddLine({ trackX - 1, trackTop }, { trackX - 1, trackBottom }, trackEdge, 1)
    drawList:AddRectFilled({ trackX, handleTop }, { trackX + 6, handleTop + handleHeight }, handle)
    drawList:AddLine({ trackX + 1, handleTop }, { trackX + 1, handleTop + handleHeight }, handleLight, 1)
end

local function renderChoice(id, label, selected, height)
    local clicked = imgui.Selectable('##' .. id, false, 0, { 0, height })
    local minX, minY = imgui.GetItemRectMin()
    local _, maxY = imgui.GetItemRectMax()
    local drawList = imgui.GetWindowDrawList()

    if selected then
        drawSelectionArrow(drawList, minX, (minY + maxY) * 0.5)
    end

    drawShadowedText(
        drawList,
        minX + 29,
        minY + 2,
        label,
        imgui.GetColorU32({ 0.92, 0.96, 1.00, 1.00 }))
    return clicked
end

local function renderRouteList()
    drawTextLine('Select Destination', imgui.GetColorU32({ 0.92, 0.96, 1.00, 1.00 }), -4)

    local finalIndex = math.min(#menu.routes, menu.firstVisibleIndex + visibleRouteCount - 1)
    for index = menu.firstVisibleIndex, finalIndex do
        local route = menu.routes[index]
        local selected = index == menu.selectedIndex
        local label = string.format('%s (%u Gil)', route.name, route.gil)
        if renderChoice('route' .. index, label, selected, 25) then
            menu.selectedIndex = index
            keepSelectionVisible()
            activateSelection()
        end
    end

    drawRetailScrollbar()
end

local function renderConfirmation()
    local route = menu.routes[menu.selectedIndex]
    if route == nil then
        closeMenu(false)
        return
    end

    drawTextLine(
        string.format('Travel to %s for %u Gil?', route.name, route.gil),
        imgui.GetColorU32({ 0.92, 0.96, 1.00, 1.00 }),
        -4)
    imgui.Dummy({ 0, 4 })

    if renderChoice('confirmYes', 'Yes', menu.confirmationChoice == 1, 29) then
        menu.confirmationChoice = 1
        activateSelection()
    end

    if renderChoice('confirmNo', 'No', menu.confirmationChoice == 2, 29) then
        menu.confirmationChoice = 2
        activateSelection()
    end
end

local function renderStatus()
    if menu.mode == 'waiting' then
        drawTextLine(
            'Confirming your destination with the server...',
            imgui.GetColorU32({ 0.92, 0.96, 1.00, 1.00 }))
    else
        drawTextLine(
            menu.error or 'The warp request could not be completed.',
            imgui.GetColorU32({ 1.00, 0.72, 0.72, 1.00 }))
    end
end

local function renderMenu()
    if not menu.open then
        return
    end

    local io = imgui.GetIO()
    local width = math.min(488, io.DisplaySize.x - 20)
    local listRows = math.min(#menu.routes, visibleRouteCount)
    local listHeight = 39 + listRows * 25
    local desiredHeight = menu.mode == 'list' and listHeight or (menu.mode == 'confirm' and 116 or 64)
    local height = math.min(desiredHeight, io.DisplaySize.y - 20)
    local windowX = math.max(4, math.min(menuLeftOffset, io.DisplaySize.x - width - 4))
    local windowY = math.max(4, io.DisplaySize.y - height - menuBottomOffset)
    imgui.SetNextWindowPos({ windowX, windowY }, ImGuiCond_Always)
    imgui.SetNextWindowSize({ width, height }, ImGuiCond_Always)

    pushMenuStyle()
    local flags = bit.bor(
        ImGuiWindowFlags_NoTitleBar,
        ImGuiWindowFlags_NoResize,
        ImGuiWindowFlags_NoMove,
        ImGuiWindowFlags_NoCollapse,
        ImGuiWindowFlags_NoSavedSettings,
        ImGuiWindowFlags_NoScrollbar)

    if imgui.Begin('Outpost Warp##SanctumOutposts', true, flags) then
        drawRetailWindow()
        if menu.font ~= nil then
            imgui.PushFont(menu.font, menuFontSize)
        end

        if menu.mode == 'list' then
            renderRouteList()
        elseif menu.mode == 'confirm' then
            renderConfirmation()
        else
            renderStatus()
        end

        if menu.font ~= nil then
            imgui.PopFont()
        end
    end

    imgui.End()
    popMenuStyle()
end

ashita.events.register('load', 'load_cb', function()
    menu.registered = false
    menu.nextRegistrationAttempt = 0

    if imgui.AddFontFromFileTTF ~= nil and ashita.fs.exists(menuFontPath) then
        menu.font = imgui.AddFontFromFileTTF(menuFontPath, menuFontSize)
    end

    loadWindowTextures()
end)

ashita.events.register('unload', 'unload_cb', function()
    if isLoggedIn() then
        sendServerCommand('off')
    end

    releaseWindowTextures()
end)

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if e.id == 0x000A then
        closeMenu(false)
        menu.registered = false
        menu.nextRegistrationAttempt = os.clock() + 2
    end
end)

ashita.events.register('text_in', 'text_in_cb', function(e)
    if e.message_modified ~= nil and handleProtocolMessage(e.message_modified) then
        e.blocked = true
    end
end)

ashita.events.register('d3d_present', 'present_cb', function()
    local now = os.clock()
    if not menu.registered and now >= menu.nextRegistrationAttempt then
        if sendServerCommand('on') then
            menu.nextRegistrationAttempt = now + registrationRetrySeconds
        end
    elseif menu.registered and now >= menu.nextHeartbeat then
        if sendServerCommand('ping') then
            menu.nextHeartbeat = now + heartbeatSeconds
        else
            menu.registered = false
            menu.nextRegistrationAttempt = now + registrationRetrySeconds
        end
    end

    if menu.open and now > menu.expiresAt then
        closeMenu(true)
    end

    renderMenu()
end)

ashita.events.register('key_data', 'key_data_cb', function(e)
    if not menu.open or not e.down or e.down == 0 then
        return
    end

    if e.key == 200 then
        changeSelection(-1)
    elseif e.key == 208 then
        changeSelection(1)
    elseif e.key == 28 or e.key == 156 then
        activateSelection()
    elseif e.key == 1 then
        cancelSelection()
    elseif e.key == 203 or e.key == 205 then
        e.blocked = true
        return
    else
        return
    end

    e.blocked = true
end)

ashita.events.register('key_state', 'key_state_cb', function(e)
    if not menu.open then
        return
    end

    local keyState = ffi.cast('uint8_t*', e.data_raw)
    keyState[200] = 0
    keyState[203] = 0
    keyState[205] = 0
    keyState[208] = 0
end)

ashita.events.register('mouse', 'mouse_cb', function(e)
    if not menu.open or e.message ~= 522 then
        return
    end

    if e.delta > 0 then
        changeSelection(-1)
    elseif e.delta < 0 then
        changeSelection(1)
    end

    e.blocked = true
end)

ashita.events.register('xinput_button', 'xinput_button_cb', function(e)
    if not menu.open or e.injected or e.state ~= 1 then
        return
    end

    if e.button == 0 then
        changeSelection(-1)
    elseif e.button == 1 then
        changeSelection(1)
    elseif e.button == 12 then
        activateSelection()
    elseif e.button == 13 then
        cancelSelection()
    else
        return
    end

    e.blocked = true
end)

ashita.events.register('dinput_button', 'dinput_button_cb', function(e)
    if not menu.open or e.injected then
        return
    end

    if e.button == 32 then
        if e.state ~= menu.previousDpadAngle then
            if e.state == 0 then
                changeSelection(-1)
                e.blocked = true
            elseif e.state == 18000 then
                changeSelection(1)
                e.blocked = true
            end

            menu.previousDpadAngle = e.state
        end

        return
    end

    if e.state ~= 128 then
        return
    end

    if e.button == 48 or e.button == 49 then
        activateSelection()
    elseif e.button == 50 then
        cancelSelection()
    else
        return
    end

    e.blocked = true
end)
