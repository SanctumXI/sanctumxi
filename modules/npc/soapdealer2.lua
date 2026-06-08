-----------------------------------
-- Custom Soap Seller
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('custom_soap_seller2')
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

m:addOverride('xi.zones.Temenos.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype  = xi.objType.NPC,
        name     = 'Soap Dealer',
        look     = 143,
        x        = 574.20,
        y        = 0,
        z        = 77.94,
        rotation = 37,
-- { 574.202, 0.000, 77.939, 39 }, -- !pos 574.202 0.000 77.939 37

        onTrigger = function(player, npc)
            player:customMenu(soapMenu)
        end,
    })
end)

return m
