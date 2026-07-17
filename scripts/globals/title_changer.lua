-----------------------------------
-- Title Changer NPC Functions
-----------------------------------
xi = xi or {}
xi.titleChanger = xi.titleChanger or {}

local titleLockVar = '[TITLE]Locked'

local function titleMask(player, titleGroup)
    local returnValue = 0
    local titles = {}

    if titleGroup and titleGroup.title then
        titles = titleGroup.title
    end

    for i = 1, 28 do
        if titles[i] == nil or titles[i] == 0 or not player:hasTitle(titles[i]) then
            returnValue = bit.bor(returnValue, bit.lshift(1, i))
        end
    end

    return returnValue
end

local function startTitleEvent(player, eventId, titleInfo)
    player:startEvent(
        eventId,
        titleMask(player, titleInfo[1]),
        titleMask(player, titleInfo[2]),
        titleMask(player, titleInfo[3]),
        titleMask(player, titleInfo[4]),
        titleMask(player, titleInfo[5]),
        titleMask(player, titleInfo[6]),
        1,
        player:getGil()
    )
end

-----------------------------------
-- public title changer functions
-----------------------------------

xi.titleChanger.onTrigger = function(player, eventId, titleInfo)
    local titleLocked = player:getCharVar(titleLockVar) ~= 0

    player:setFreezeFlag(true)
    player:customMenu({
        title = 'What will you do?',

        options =
        {
            {
                'Change Title.',
                function(playerArg)
                    startTitleEvent(playerArg, eventId, titleInfo)
                end,
            },
            {
                titleLocked and 'Unlock Title.' or 'Lock Title.',
                function(playerArg)
                    playerArg:setCharVar(titleLockVar, titleLocked and 0 or 1)
                end,
            },
            {
                'Never mind.',
                function(playerArg)
                end,
            },
        },

        onCancelled = function(playerArg)
            playerArg:setFreezeFlag(false)
        end,

        onEnd = function(playerArg)
            playerArg:setFreezeFlag(false)
        end,
    })
end

xi.titleChanger.onEventFinish = function(player, csid, option, eventId, titleInfo)
    if csid == eventId then
        local group = titleInfo[bit.rshift(option, 8) + 1]
        if group then
            local title = group.title[option % 256]
            if title and player:delGil(group.cost) then
                player:forceSetTitle(title)
            end
        end
    end
end
