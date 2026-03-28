-----------------------------------
-- Add some test NPCs to Whitegate
-----------------------------------
require('modules/module_utils')

local m = Module:new('whitegatewarp')

local menu  = {}
local page1 = {}
local page2 = {}

local delaySendMenu = function(player, menuForPlayer)
    player:timer(50, function(playerArg)
        playerArg:customMenu(menuForPlayer)
    end)
end

menu =
{
    title = 'Test Menu (Paginated)',
    options = {},
}

page1 =
{
    {
        'Send me to Jeuno!',
        function(playerArg)
            playerArg:setPos(0, 0, 0, 0, xi.zone.LOWER_JEUNO)
        end,
    },
    {
        'Send me to Bastok!',
        function(playerArg)
            playerArg:setPos(0, 0, 0, 0, xi.zone.BASTOK_MINES)
        end,
    },
    {
        'Next Page',
        function(playerArg)
            menu.options = page2
            delaySendMenu(playerArg, menu)
        end,
    },
}

page2 =
{
    {
        'Send me to Nashmau!',
        function(playerArg)
            playerArg:setPos(0, 0, 0, 0, xi.zone.NASHMAU)
        end,
    },
    {
        'Previous Page',
        function(playerArg)
            menu.options = page1
            delaySendMenu(playerArg, menu)
        end,
    },
}

m:addOverride('xi.zones.Aht_Urhgan_Whitegate.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype  = xi.objType.NPC,
        name     = 'Warp Book',
        look     = 2433,
        x        = 80.000,
        y        = 0.000,
        z        = 70.000,
        rotation = 0,
        widescan = 1,

        onTrigger = function(player, npc)
            menu.options = page1
            delaySendMenu(player, menu)
        end,
    })
end)

return m