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

libraryInstance.configs =
{
    A =
    {
        definitionId    = libraryInstance.id,
        destinationZone = xi.zone.CELENNIA_MEMORIAL_LIBRARY,
        exitZone        = xi.zone.EASTERN_ADOULIN,
        exitPosition    = { x = -86.2, y = -0.15, z = -76, rot = 220 },
        copyKey         = 'library_a',
    },
    B =
    {
        definitionId    = libraryInstance.id,
        destinationZone = xi.zone.CELENNIA_MEMORIAL_LIBRARY,
        exitZone        = xi.zone.EASTERN_ADOULIN,
        exitPosition    = { x = -86.2, y = -0.15, z = -76, rot = 220 },
        copyKey         = 'library_b',
    },
}

local function getConfig(copyName)
    return libraryInstance.configs[string.upper(copyName or '')]
end

libraryInstance.enterCopy = function(player, copyName)
    local config = getConfig(copyName)
    if not config then
        player:printToPlayer('Invalid Library test copy.')
        return false
    end

    return instanceManager.enter(player, config)
end

libraryInstance.enter = function(player)
    return libraryInstance.enterCopy(player, 'A')
end

libraryInstance.getEquippedLinkshellID = function(player)
    return player:getLinkshellID(1)
end

libraryInstance.getRegisteredLinkshellID = function(player)
    return player:getCharVar(libraryInstance.registrationVar)
end

libraryInstance.getRegisteredLinkshellName = function(player)
    local registeredId = libraryInstance.getRegisteredLinkshellID(player)
    if
        registeredId > 0 and
        libraryInstance.getEquippedLinkshellID(player) == registeredId
    then
        local linkshellName = player:getLinkshellName(1)
        if linkshellName and linkshellName ~= '' then
            return linkshellName
        end
    end

    return registeredId > 0 and string.format('Linkshell #%u', registeredId) or 'None'
end

libraryInstance.register = function(player)
    local linkshellId = libraryInstance.getEquippedLinkshellID(player)
    if linkshellId == 0 then
        player:printToPlayer('Equip the linkshell you want to register in Linkshell 1.', xi.msg.channel.SYSTEM_3)
        return false
    end

    local previousId = libraryInstance.getRegisteredLinkshellID(player)
    player:setCharVar(libraryInstance.registrationVar, linkshellId)

    if previousId ~= linkshellId then
        player:printToPlayer('Your Library registration now belongs to the linkshell in Linkshell 1.', xi.msg.channel.SYSTEM_3)
    end

    return true
end

libraryInstance.isRegisteredMember = function(player, linkshellId)
    local registeredId = libraryInstance.getRegisteredLinkshellID(player)
    local equippedId = libraryInstance.getEquippedLinkshellID(player)

    if registeredId == 0 then
        return false, 'Register a linkshell with the secretary first.'
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
        canEnter        = function(player)
            return libraryInstance.isRegisteredMember(player, linkshellId)
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

    instance:insertDynamicEntity(
    {
        objtype = xi.objType.NPC,
        name = 'Nomad_Moogle',
        packetName = 'Nomad Moogle',
        look = 82,
        x = -94.733, y = -2.193, z = -97.705, rotation = 137,
        onTrigger = function(player, npc)
            if not printLibraryAccessDenied(player) then
                return
            end

            local linkshellId = libraryInstance.getRegisteredLinkshellID(player)
            if not player:openLinkshellMogLocker(linkshellId) then
                player:printToPlayer(
                    'The Linkshell Bank could not be opened. Please report this test failure.',
                    xi.msg.channel.SYSTEM_3
                )
                return
            end

            player:printToPlayer(
                'Mog Safe, Mog Safe 2, and Mog Locker are your linkshell\'s shared Bank, kupo!',
                xi.msg.channel.SYSTEM_3
            )
            player:printToPlayer(
                'Exclusive, currency, and linkshell items cannot be deposited.',
                xi.msg.channel.SYSTEM_3
            )
            player:sendMenu(xi.menuType.MOOGLE)
        end,
    })

    for _, teleporterConfig in ipairs(getLibraryTeleporters()) do
        teleporterNpc.insert(instance, teleporterConfig, printLibraryAccessDenied)
    end
end

libraryInstance.clearCopy = function(copyName)
    local config = getConfig(copyName)
    return config and instanceManager.clear(config, true) or false
end

libraryInstance.clearCopies = function()
    libraryInstance.clearCopy('A')
    libraryInstance.clearCopy('B')
end

libraryInstance.getRuntimeID = function(copyName)
    local config = getConfig(copyName)
    return config and instanceManager.getRuntimeID(config) or nil
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

return libraryInstance
