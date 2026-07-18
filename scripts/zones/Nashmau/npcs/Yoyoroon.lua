-----------------------------------
-- Area: Nashmau
--  NPC: Yoyoroon
-----------------------------------
local ID = zones[xi.zone.NASHMAU]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { 2239,   5000, }, -- Tension Spring
        { 2243,   5000, }, -- Loudspeaker
        { 2246,   5000, }, -- Accelerator
        { 2251,   5000, }, -- Armor Plate
        { 2254,   5000, }, -- Stabilizer
        { 2258,   5000, }, -- Mana Jammer
        { 2262,   5000, }, -- Auto-Repair Kit
        { 2266,   5000, }, -- Mana Tank
        { 2329,   5000, }, -- Smoke Screen
        { 2352,   5000, }, -- Condenser
        { 2354,   5000, }, -- Economizer
        { 2240,  10000, }, -- Inhibitor
        { 2242,  10000, }, -- Mana Booster
        { 2247,  10000, }, -- Scope
        { 2250,  10000, }, -- Shock Absorber
        { 2255,  10000, }, -- Volt Gun
        { 2260,  10000, }, -- Stealth Screen
        { 2264,  10000, }, -- Damage Gauge
        { 2268,  10000, }, -- Mana Conserver
        { 2351,  10000, }, -- Dynamo
        { 2238,  30000, }, -- Strobe
        { 2409,  30000, }, -- Flame Holder
        { 2410,  30000, }, -- Ice Maker
        { 2248,  30000, }, -- Pattern Reader
        { 2411,  30000, }, -- Replicator
        { 2252,  30000, }, -- Analyzer
        { 2256,  30000, }, -- Heat Seeker
        { 2259,  30000, }, -- Heatsink
        { 2263,  30000, }, -- Flashbulb
        { 2267,  30000, }, -- Mana Converter
        { 2412,  30000, }, -- Hammermill
        { 2244,  30000, }, -- Scanner
        { 3313,  30000, }, -- Vivi-Valve
        { 3312,  30000, }, -- Percolator
        { 2348,  30000, }, -- Tranquilizer
        { 2349,  30000, }, -- Turbo Charger
        { 2347,  30000, }, -- Reactive Shield
        { 2413,  30000, }, -- Coiler
        { 2265,  75000, }, -- Auto-Repair Kit II
        { 2269,  75000, }, -- Mana Tank II
        { 2241,  75000, }, -- Tension Spring II
        { 2245,  75000, }, -- Loudspeaker II
        { 2249,  75000, }, -- Accelerator II
        { 2253,  75000, }, -- Armor Plate II
        { 2257,  75000, }, -- Stabilizer II
        { 2261,  75000, }, -- Mana Jammer II
        { 2322, 150000, }, -- Attuner
        { 2323, 150000, }, -- Tactical Processor
        { 2324, 150000, }, -- Drum Magazine
        { 2325, 150000, }, -- Equalizer
        { 2326, 150000, }, -- Target Marker
        { 2327, 150000, }, -- Mana Channeler
        { 2328, 150000, }, -- Eraser
    }

    player:showText(npc, ID.text.YOYOROON_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
