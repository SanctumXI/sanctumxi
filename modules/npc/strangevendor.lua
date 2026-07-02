-----------------------------------
-- Sanctum Food Merchants
-----------------------------------
local m = Module:new("strange_vendor")

local stock =
{
    { 4376, 139  }, -- Meat Jerky
    { 4407, 697  }, -- Carp Sushi
    { 4422, 229  }, -- Orange Juice
    { 4423, 327  }, -- Apple Juice
    { 4499, 126  }, -- Orange Au Lait
    { 4300, 324  }, -- Apple Au Lait
    { 4456, 574  }, -- Boiled Crab
    { 4413, 356  }, -- Apple Pie
    { 4410, 368  }, -- Roast Mushroom
    { 4537, 368  }, -- Roast Carp
    { 5168, 274  }, -- Bataquiche
    { 4219, 500  }, -- Stone Quiver
    { 4220, 750  }, -- Bone Quiver
    { 4227, 500  }, -- Bronze Bolt Quiver
    { 5359, 500  }, -- Bronze Bullet Pouch
    { 4112, 350   }, -- Potion
    { 4128, 450   }, -- Ether
    { 4148, 350   }, -- Antidote
    { 4150, 850   }, -- Eye Drops
    { 4151, 750   }, -- Echo Drops

}

local function foodMerchantTrigger(player, npc)
    player:printToPlayer("Care for some provisions?", xi.msg.channel.NS_SAY, npc:getPacketName())
    xi.shop.general(player, stock)
end

local function addFoodMerchant(zone, x, y, z, rotation)
    zone:insertDynamicEntity({
        objtype    = xi.objType.NPC,
        name       = "DE_STRANGE_VENDOR",
        packetName = "Strange Vendor",
        look       = 141,
        x          = x,
        y          = y,
        z          = z,
        rotation   = rotation,
        widescan   = 1,

        onTrigger = foodMerchantTrigger,
    })
end

-----------------------------------
-- Southern San d'Oria
-----------------------------------
m:addOverride("xi.zones.Southern_San_dOria.Zone.onInitialize", function(zone)
    super(zone)
    addFoodMerchant(zone, -107.569, 1.000, -43.516, 247 )
end)

-----------------------------------
-- Bastok Mines
-----------------------------------
m:addOverride("xi.zones.Bastok_Mines.Zone.onInitialize", function(zone)
    super(zone)
    addFoodMerchant(zone, -21.637, -1.001, -126.333, 212)
end)

-----------------------------------
-- Windurst Woods
-----------------------------------
m:addOverride("xi.zones.Windurst_Woods.Zone.onInitialize", function(zone)
    super(zone)
    addFoodMerchant(zone, 108.651, -5.000, -45.772, 153)
end)

-----------------------------------
-- Valkurm Dunes
-----------------------------------
m:addOverride("xi.zones.Valkurm_Dunes.Zone.onInitialize", function(zone)
    super(zone)
    addFoodMerchant(zone, 133.370, -7.500, 95.380, 21)
end)

-----------------------------------
-- Buburimu Peninsula
-----------------------------------
m:addOverride("xi.zones.Buburimu_Peninsula.Zone.onInitialize", function(zone)
    super(zone)
    addFoodMerchant(zone, -475.300, -32.274, 47.951, 179)
end)

-----------------------------------
-- Qufim Island
-----------------------------------
m:addOverride("xi.zones.Qufim_Island.Zone.onInitialize", function(zone)
    super(zone)
    addFoodMerchant(zone, -253.170, -20.000, 299.942, 226)
end)

return m