-----------------------------------
-- Custom Soap Seller
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('custom_soap_seller')
m:setEnabled(true)

local KEY_ITEM  = xi.ki.COSMO_CLEANSE
local COST      = 30000
local TIMER_VAR = '[Custom]SoapTimer'
local COOLDOWN  = 23 * 3600

local buySoap = function(player)
    local timer = player:getCharVar(TIMER_VAR)

    if player:hasKeyItem(KEY_ITEM) then
        player:printToPlayer('You already possess a Cosmo-Cleanse.', xi.msg.channel.NS_SAY)
        return
    end

    if VanadielTime() < timer then
        player:printToPlayer('You cannot buy another Cosmo-Cleanse yet.', xi.msg.channel.NS_SAY)
        return
    end

    if player:getGil() < COST then
        player:printToPlayer(string.format('You need %u gil to buy a Cosmo-Cleanse.', COST), xi.msg.channel.NS_SAY)
        return
    end

    player:setCharVar(TIMER_VAR, VanadielTime() + COOLDOWN)
    player:delGil(COST)
    npcUtil.giveKeyItem(player, KEY_ITEM)
end

local soapMenu =
{
    title = 'Buy a Cosmo-Cleanse?',
    options =
    {
        {
            'Yes. 30,000 gil.',
            function(player)
                buySoap(player)
            end,
        },
        {
            'No.',
            function(player)
            end,
        },
    },
}

m:addOverride('xi.zones.Apollyon.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype  = xi.objType.NPC,
        name     = 'Soap Dealer',
        look     = 143,
        x        = 631.98,
        y        = 0,
        z        = -591.52,
        rotation = 83,


        onTrigger = function(player, npc)
            player:customMenu(soapMenu)
        end,
    })

     zone:insertDynamicEntity({
        objtype  = xi.objType.NPC,
        name     = 'Soap Dealer',
        look     = 143,
        x        = -636.17,
        y        = 0,
        z        = -591.79,
        rotation = 24,

-- { -636.169, 0.000, -591.786, 24 }, -- !pos -636.169 0.000 -591.786 38
        onTrigger = function(player, npc)
            player:customMenu(soapMenu)
        end,
    })
        
end)

return m
