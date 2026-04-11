-----------------------------------
-- Add some test NPCs to Whitegate
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Aht_Urhgan_Whitegate/Zone')

local m = Module:new('whitegatewarp')
m:setEnabled(true)

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
    title = 'Where would you like to go?',
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
        'Send me to Nashmau!',
        function(playerArg)
            playerArg:setPos(0, 0, 0, 0, xi.zone.NASHMAU)
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
        'Send me to Hell!',
        function(playerArg)
            playerArg:setPos(0, 0, 0, 0, xi.zone.IFRITS_CAULDRON)
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
        objtype = xi.objType.NPC,
        name = 'Warp Book',
        x = 80.750,
        y = 0,
        z = 70.25,
        rotation = 128,
        widescan = 1,
        
        onTrigger = function(player, npc)
            menu.options = page1
            delaySendMenu(player, menu)
        end,
    })
end)

return m