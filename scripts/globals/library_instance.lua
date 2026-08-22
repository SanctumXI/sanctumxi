-----------------------------------
-- Celennia Memorial Library instance configuration
-----------------------------------
local instanceManager = require('scripts/globals/sanctum/instance_manager')
local treasuryNpc     = require('scripts/globals/sanctum/linkshell_treasury_npc')
local teleporterNpc   = require('scripts/globals/sanctum/library_teleporter')
require('scripts/globals/shop')

local libraryInstance = {}

libraryInstance.id = 28400
libraryInstance.registrationVar = '[SanctumLibrary]LinkshellId'
libraryInstance.registrationTimeVar = '[SanctumLibrary]RegisteredAt'
libraryInstance.pendingRefundVar = '[SanctumLibrary]RefundGil'
libraryInstance.registrationCooldown =
    xi.settings and
    xi.settings.sanctum and
    xi.settings.sanctum.LIBRARY_REGISTRATION_COOLDOWN or
    7 * 24 * 60 * 60
libraryInstance.linkshellAccessCost =
    xi.settings and
    xi.settings.sanctum and
    xi.settings.sanctum.LIBRARY_LINKSHELL_ACCESS_COST or
    500000
libraryInstance.idleTimeoutSeconds =
    xi.settings and
    xi.settings.sanctum and
    xi.settings.sanctum.LIBRARY_INSTANCE_IDLE_TIMEOUT or
    15 * 60
libraryInstance.creationTimeoutMs =
    xi.settings and
    xi.settings.sanctum and
    xi.settings.sanctum.LIBRARY_INSTANCE_CREATION_TIMEOUT or
    3 * 60 * 1000
libraryInstance.maxActiveCopies =
    xi.settings and
    xi.settings.sanctum and
    xi.settings.sanctum.LIBRARY_MAX_ACTIVE_INSTANCES or
    64
libraryInstance.linkshellHolderType = 1
libraryInstance.purchaseResult =
{
    SUCCESS          = 0,
    ALREADY_UNLOCKED = 1,
    NO_LINKSHELL     = 2,
    NOT_HOLDER       = 3,
    INSUFFICIENT_GIL = 4,
    FAILED           = 5,
    COOLDOWN_ACTIVE  = 6,
}

-- The normal shop client displays a maximum of 16 entries.
libraryInstance.specialShopStock =
{
    { xi.item.X_POTION,                  8000 },
    { xi.item.HI_ETHER,                  5000 },
    { xi.item.FLASK_OF_PANACEA,         10000 },
    { xi.item.REMEDY,                    2500 },
    { xi.item.FLASK_OF_ECHO_DROPS,        800 },
    { xi.item.FLASK_OF_HOLY_WATER,       3000 },
    { xi.item.PINCH_OF_PRISM_POWDER,      500 },
    { xi.item.POT_OF_SILENT_OIL,          500 },
    { xi.item.RERAISER,                 10000 },
    { xi.item.HI_RERAISER,              25000 },
    { xi.item.VILE_ELIXIR,              50000 },
    { xi.item.SCROLL_OF_INSTANT_WARP,    1000 },
    { xi.item.SCROLL_OF_INSTANT_RERAISE, 1000 },
    { xi.item.TOOLBAG_SHIHEI,            5000 },
    { xi.item.PLATE_OF_SOLE_SUSHI,       5000 },
    { xi.item.YELLOW_CURRY_BUN,          5000 },
}

libraryInstance.getEquippedLinkshellID = function(player)
    return player:getLinkshellID(1)
end

libraryInstance.getEquippedLinkshellType = function(player)
    return player:getLinkshellType(1)
end

libraryInstance.hasLinkshellAccess = function(player, linkshellId)
    if not linkshellId or linkshellId == 0 then
        return false
    end

    local lookupSucceeded, hasAccess = pcall(function()
        return player:hasLinkshellLibraryAccess(linkshellId)
    end)

    return lookupSucceeded and hasAccess
end

libraryInstance.getOwnedLinkshellLibraryID = function(player)
    local lookupSucceeded, linkshellId = pcall(function()
        return player:getOwnedLinkshellLibraryID()
    end)

    return lookupSucceeded and linkshellId or 0
end

libraryInstance.purchaseLinkshellAccess = function(player, expectedLinkshellId)
    local purchaseSucceeded, result = pcall(function()
        return player:purchaseLinkshellLibraryAccess(
            1,
            expectedLinkshellId,
            libraryInstance.linkshellAccessCost,
            libraryInstance.registrationCooldown
        )
    end)

    return purchaseSucceeded and result or libraryInstance.purchaseResult.FAILED
end

libraryInstance.getRegisteredLinkshellID = function(player)
    return player:getCharVar(libraryInstance.registrationVar)
end

libraryInstance.claimPendingRefund = function(player)
    local amount = player:getCharVar(libraryInstance.pendingRefundVar)
    if amount <= 0 then
        return 0
    end

    local previousGil = player:getGil()
    player:addGil(amount)
    if player:getGil() < previousGil + amount then
        return 0
    end

    player:setCharVar(libraryInstance.pendingRefundVar, 0)
    return amount
end

libraryInstance.getRegistrationCooldownRemaining = function(player)
    if libraryInstance.getRegisteredLinkshellID(player) == 0 then
        return 0
    end

    local registeredAt = player:getCharVar(libraryInstance.registrationTimeVar)
    if registeredAt == 0 then
        -- Existing registrations predate cooldown tracking. Start their first
        -- cooldown when the new system encounters them.
        registeredAt = GetSystemTime()
        player:setCharVar(libraryInstance.registrationTimeVar, registeredAt)
    end

    return math.max(0, registeredAt + libraryInstance.registrationCooldown - GetSystemTime())
end

libraryInstance.formatRegistrationCooldown = function(seconds)
    local totalMinutes = math.max(1, math.ceil(seconds / 60))
    local totalHours = math.ceil(totalMinutes / 60)

    if totalHours >= 24 then
        local days = math.floor(totalHours / 24)
        local hours = totalHours % 24
        local result = string.format('%u day%s', days, days == 1 and '' or 's')

        if hours > 0 then
            result = string.format('%s, %u hour%s', result, hours, hours == 1 and '' or 's')
        end

        return result
    end

    if totalMinutes >= 60 then
        return string.format('%u hour%s', totalHours, totalHours == 1 and '' or 's')
    end

    return string.format('%u minute%s', totalMinutes, totalMinutes == 1 and '' or 's')
end

libraryInstance.getLinkshellNameByID = function(player, linkshellId)
    if not linkshellId or linkshellId == 0 then
        return nil
    end

    local lookupSucceeded, linkshellName = pcall(function()
        return player:getLinkshellNameByID(linkshellId)
    end)

    if lookupSucceeded and linkshellName ~= '' then
        return linkshellName
    end

    -- Keep Lua-only reloads useful until the map server is rebuilt.
    for slot = 1, 2 do
        if player:getLinkshellID(slot) == linkshellId then
            local linkshellName = player:getLinkshellName(slot)
            if linkshellName and linkshellName ~= '' then
                return linkshellName
            end
        end
    end

    return nil
end

libraryInstance.getRegisteredLinkshellName = function(player)
    local registeredId = libraryInstance.getRegisteredLinkshellID(player)
    if registeredId == 0 then
        return 'None'
    end

    return libraryInstance.getLinkshellNameByID(player, registeredId) or 'a linkshell'
end

libraryInstance.register = function(player, expectedLinkshellId)
    local linkshellId = libraryInstance.getEquippedLinkshellID(player)
    if linkshellId == 0 then
        return false, 'Equip the linkshell you want to register in Linkshell slot 1.'
    end

    if expectedLinkshellId and linkshellId ~= expectedLinkshellId then
        return false, 'The linkshell in slot 1 changed. Please speak with me again.'
    end

    if not libraryInstance.hasLinkshellAccess(player, linkshellId) then
        return false, 'The linkshell holder must unlock Library access before members can register.'
    end

    local registeredId = libraryInstance.getRegisteredLinkshellID(player)
    if registeredId ~= 0 and registeredId ~= linkshellId then
        local cooldownRemaining = libraryInstance.getRegistrationCooldownRemaining(player)
        if cooldownRemaining > 0 then
            return false, string.format(
                'You can register a new linkshell in %s.',
                libraryInstance.formatRegistrationCooldown(cooldownRemaining)
            )
        end
    elseif registeredId == linkshellId then
        return true
    end

    player:setCharVar(libraryInstance.registrationVar, linkshellId)
    player:setCharVar(libraryInstance.registrationTimeVar, GetSystemTime())
    return true
end

libraryInstance.isRegisteredMember = function(player, linkshellId)
    local registeredId = libraryInstance.getRegisteredLinkshellID(player)
    local equippedId = libraryInstance.getEquippedLinkshellID(player)

    if registeredId == 0 then
        return false, 'Register a linkshell with the secretary first.'
    end

    if not libraryInstance.hasLinkshellAccess(player, registeredId) then
        return false, 'Your registered linkshell has not unlocked Library access.'
    end

    if equippedId ~= registeredId then
        return false, 'Equip your registered linkshell in Linkshell 1 to use its Library.'
    end

    if linkshellId and registeredId ~= linkshellId then
        return false, 'This Library instance belongs to a different linkshell.'
    end

    return true
end

local function getLinkshellConfig(linkshellId)
    return
    {
        definitionId    = libraryInstance.id,
        destinationZone = xi.zone.CELENNIA_MEMORIAL_LIBRARY,
        exitZone        = xi.zone.EASTERN_ADOULIN,
        exitPosition    = { x = -86.2, y = -0.15, z = -76, rot = 220 },
        copyKey         = string.format('linkshell_library_%u', linkshellId),
        creationTimeoutMs  = libraryInstance.creationTimeoutMs,
        idleTimeoutSeconds = libraryInstance.idleTimeoutSeconds,
        maxActiveCopies    = libraryInstance.maxActiveCopies,
        sleepWhenEmpty     = true,
        canEnter        = function(player)
            return libraryInstance.isRegisteredMember(player, linkshellId)
        end,

        entryMessage    = function(player)
            return string.format('Library of %s', libraryInstance.getRegisteredLinkshellName(player))
        end,
    }
end

libraryInstance.enterRegistered = function(player)
    local allowed, message = libraryInstance.isRegisteredMember(player)
    if not allowed then
        player:printToPlayer(message, xi.msg.channel.SYSTEM_3)
        return false
    end

    return instanceManager.enter(player, getLinkshellConfig(libraryInstance.getRegisteredLinkshellID(player)))
end

local function canUseCurrentLibrary(player)
    local instance = player:getInstance()
    local linkshellId = instance and instance:getLocalVar('SanctumLibraryLinkshellId') or 0
    return linkshellId ~= 0 and libraryInstance.isRegisteredMember(player, linkshellId)
end

local function printLibraryAccessDenied(player)
    local allowed, message = canUseCurrentLibrary(player)
    if not allowed then
        player:printToPlayer(message or 'You are not authorized to use this Library.', xi.msg.channel.SYSTEM_3)
    end

    return allowed
end

local function getLook(look)
    if LQS and LQS.look then
        return LQS.look(look)
    end

    return 82
end

local function getFace(faceName)
    return LQS and LQS.face and LQS.face[faceName] or 1
end

local function getLibraryTeleporters()
    return
    {
        {
            name = 'Skeevy Bastard',
            pos = { -104.005, -2.150, -84.232, 51 },
            look = getLook({ race = xi.race.HUME_M, face = getFace('A1'), body = 15, legs = 15, feet = 15 }),
            greeting = 'Oi, \'ere the hell you want to go mate?',
            menuTitle = 'Choose Your Destination',
            itemsPerPage = 3,
            teleportDelay = 1500,
            animation = { actionID = 6, animID = 600 },
            destinations =
            {
                {
                    name = 'Lower Jeuno',
                    lockText = 'Complete \'A Chocobo\'s Wounds\'',
                    pos = { -35.059, 0.000, -48.293, 214, 245 },
                    costs = { gil = 1500 },
                    level = 1,
                    check = function(player)
                        return player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.CHOCOBOS_WOUNDS)
                    end,
                },
                {
                    name = 'Tavnazian Safehold',
                    lockText = 'Complete \'The Mothercrystals\'',
                    pos = { 0.015, -21.876, 2.125, 67, 26 },
                    costs = { gil = 1500 },
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.THE_MOTHERCRYSTALS)
                    end,
                },
                {
                    name = 'Nashmau',
                    lockText = 'Complete \'Royal Puppeteer\'',
                    pos = { 0.117, 0.000, -31.918, 190, 53 },
                    costs = { gil = 750 },
                    level = 1,
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.TOAU, xi.mission.id.toau.ROYAL_PUPPETEER)
                    end,
                },
                {
                    name = 'Northern San d\'Oria',
                    lockText = 'Rank 3 Required',
                    pos = { 111.108, -0.199, -8.846, 222, 231 },
                    costs = { gil = 500 },
                    level = 1,
                    check = function(player)
                        return player:getRank(player:getNation()) >= 3
                    end,
                },
                {
                    name = 'Port Windurst',
                    lockText = 'Rank 3 Required',
                    pos = { 197.209, -12.000, 222.625, 65, 240 },
                    costs = { gil = 500 },
                    level = 1,
                    check = function(player)
                        return player:getRank(player:getNation()) >= 3
                    end,
                },
                {
                    name = 'Bastok Mines',
                    lockText = 'Rank 3 Required',
                    pos = { 89.570, 0.623, -71.851, 127, 234 },
                    costs = { gil = 500 },
                    level = 1,
                    check = function(player)
                        return player:getRank(player:getNation()) >= 3
                    end,
                },
            },
            insufficientGil = 'You don\'t have enough Gil for this journey.',
            cancelled = 'Perhaps another time. Safe travels!',
        },
        {
            name = 'Slimy Bastard',
            pos = { -106.357, -2.150, -84.431, 52 },
            look = getLook({ race = xi.race.GALKA, face = getFace('A3'), body = 17, legs = 9, feet = 4 }),
            greeting = 'So you want to travel the seas?',
            menuTitle = 'Choose Your Destination',
            itemsPerPage = 4,
            teleportDelay = 1500,
            animation = { actionID = 6, animID = 600 },
            destinations =
            {
                {
                    name = 'Al\'Taieu - South',
                    lockText = 'Sea Access Required',
                    pos = { 0.032, -0.038, -546.619, 191, 33 },
                    costs = { gil = 2000 },
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.GARDEN_OF_ANTIQUITY)
                    end,
                },
                {
                    name = 'Al\'Taieu - West',
                    lockText = 'Sea Access Required',
                    pos = { -597.191, -1.056, -316.257, 10, 33 },
                    costs = { gil = 2000 },
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.GARDEN_OF_ANTIQUITY)
                    end,
                },
                {
                    name = 'Al\'Taieu - East',
                    lockText = 'Sea Access Required',
                    pos = { 566.169, -2.040, -187.122, 9, 33 },
                    costs = { gil = 2000 },
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.GARDEN_OF_ANTIQUITY)
                    end,
                },
            },
            insufficientGil = 'You don\'t have enough Gil for this journey.',
            cancelled = 'Perhaps another time. Safe travels!',
        },
        {
            name = 'Smiley Bastard',
            pos = { -109.130, -2.150, -85.010, 47 },
            look = getLook({ race = xi.race.HUME_M, face = getFace('A4'), body = 10, legs = 19, feet = 3 }),
            greeting = 'The sky is the limit...',
            menuTitle = 'Choose Your Destination',
            itemsPerPage = 4,
            teleportDelay = 1500,
            animation = { actionID = 6, animID = 600 },
            destinations =
            {
                {
                    name = 'Ru\'Aun Gardens - Main',
                    lockText = 'Sky Access Required',
                    pos = { -1.383, -54.040, -607.075, 191, 130 },
                    costs = { gil = 2000 },
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.THE_GATE_OF_THE_GODS)
                    end,
                },
                {
                    name = 'Seiryu Island',
                    lockText = 'Sky Access Required',
                    pos = { 421.342, -8.000, -136.988, 140, 130 },
                    costs = { gil = 2000 },
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.THE_GATE_OF_THE_GODS)
                    end,
                },
                {
                    name = 'Genbu Island',
                    lockText = 'Sky Access Required',
                    pos = { 258.725, -8.000, 356.263, 90, 130 },
                    costs = { gil = 2000 },
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.THE_GATE_OF_THE_GODS)
                    end,
                },
                {
                    name = 'Byakko Island',
                    lockText = 'Sky Access Required',
                    pos = { -258.677, -8.000, 356.137, 38, 130 },
                    costs = { gil = 2000 },
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.THE_GATE_OF_THE_GODS)
                    end,
                },
                {
                    name = 'Suzaku Island',
                    lockText = 'Sky Access Required',
                    pos = { -420.856, -8.000, -136.667, 240, 130 },
                    costs = { gil = 2000 },
                    check = function(player)
                        return player:hasCompletedMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.THE_GATE_OF_THE_GODS)
                    end,
                },
            },
            insufficientGil = 'You don\'t have enough Gil for this journey.',
            cancelled = 'Perhaps another time. Safe travels!',
        },
    }
end

libraryInstance.setupServices = function(instance)
    if instance:getLocalVar('SanctumLibraryServicesReady') ~= 0 then
        return
    end

    instance:setLocalVar('SanctumLibraryServicesReady', 1)

    instance:insertDynamicEntity(
    {
        objtype = xi.objType.NPC,
        name = 'Linkshell_Bank',
        packetName = 'Linkshell Bank',
        look = getLook({ race = xi.race.HUME_M, face = getFace('A2'), body = 15, legs = 15, feet = 15 }),
        x = -92.046, y = -2.190, z = -90.401, rotation = 108,
        onTrade = function(player, npc, trade)
            if printLibraryAccessDenied(player) then
                treasuryNpc.onTrade(player, npc, trade)
            end
        end,
        onTrigger = function(player, npc)
            if printLibraryAccessDenied(player) then
                treasuryNpc.onTrigger(player, npc)
            end
        end,
    })

    instance:insertDynamicEntity(
    {
        objtype = xi.objType.NPC,
        name = 'LS_Store',
        packetName = 'LS Store',
        look = getLook({ race = xi.race.HUME_F, face = getFace('A1'), body = 10, legs = 10, feet = 10 }),
        x = -91.364, y = -2.190, z = -92.623, rotation = 128,
        onTrigger = function(player, npc)
            if not printLibraryAccessDenied(player) then
                return
            end

            xi.shop.general(player, libraryInstance.specialShopStock)
        end,
    })

    local linkshellMoogle = instance:insertDynamicEntity(
    {
        objtype = xi.objType.NPC,
        name = 'Linkshell_Moogle',
        packetName = 'Vault Moogle',
        look = 82,
        x = -94.733, y = -2.193, z = -97.705, rotation = 137,
        onTrigger = function(player, npc)
            if not printLibraryAccessDenied(player) then
                return
            end

            local linkshellId = libraryInstance.getRegisteredLinkshellID(player)
            if not player:openLinkshellMogLocker(linkshellId) then
                player:printToPlayer(
                    'The Linkshell Bank could not be opened. Please report this failure.',
                    xi.msg.channel.SYSTEM_3
                )
                return
            end

            player:printToPlayer(
                'Mog Safe, Mog Safe 2, and Mog Locker are your linkshell\'s shared Bank, kupo!',
                xi.msg.channel.SYSTEM_3
            )
            player:printToPlayer(
                'Exclusive items cannot be deposited.',
                xi.msg.channel.SYSTEM_3
            )
            player:sendMenu(xi.menuType.MOOGLE)
        end,
    })

    if linkshellMoogle then
        linkshellMoogle:setLocalVar('[SanctumLibrary]LinkshellBankMoogle', 1)
    end

    for _, teleporterConfig in ipairs(getLibraryTeleporters()) do
        teleporterNpc.insert(instance, teleporterConfig, printLibraryAccessDenied)
    end
end

libraryInstance.onCreated = function(player, instance)
    local accepted = instanceManager.onInstanceCreated(player, instance)
    if not accepted then
        return false
    end

    local linkshellId = libraryInstance.getRegisteredLinkshellID(player)
    local allowed = libraryInstance.isRegisteredMember(player, linkshellId)
    if not allowed then
        instance:fail()
        return false
    end

    instance:setLocalVar('SanctumLibraryLinkshellId', linkshellId)
    libraryInstance.setupServices(instance)
    return true
end

libraryInstance.onFailure = function(instance)
    return instanceManager.onInstanceFailure(instance)
end

libraryInstance.onComplete = function(instance)
    return instanceManager.onInstanceComplete(instance)
end

libraryInstance.onTimeUpdate = function(instance, elapsed)
    return instanceManager.onInstanceTimeUpdate(instance, elapsed)
end

return libraryInstance
