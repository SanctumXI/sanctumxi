-----------------------------------
-- Ride the Lightning
-- Qu'Bia Arena KSNM99, Themis Orb
-- !additem 1553
-----------------------------------
local qubiaID = zones[xi.zone.QUBIA_ARENA]
-----------------------------------

local content = Battlefield:new({
    zoneId           = xi.zone.QUBIA_ARENA,
    battlefieldId    = xi.battlefield.id.RIDE_THE_LIGHTNING,
    maxPlayers       = 18,
    timeLimit        = utils.minutes(30),
    index            = 22,
    menuName         = 'Ride the Lightning',
    entryName        = 'Ride the Lightning',
    entryNpc         = 'BC_Entrance',
    exitNpc          = 'Burning_Circle',
    requiredItems    = { xi.item.THEMIS_ORB, wearMessage = qubiaID.text.A_CRACK_HAS_FORMED, wornMessage = qubiaID.text.ORB_IS_CRACKED },
    armouryCrates    =
    {
        qubiaID.mob.GHUL_I_BEABAN + 2,
        qubiaID.mob.GHUL_I_BEABAN + 5,
        qubiaID.mob.GHUL_I_BEABAN + 8,
    },
})

content:addEssentialMobs({ 'Ixion' })

content.loot =
{
    {
        { itemId = xi.item.GIL, weight = 10000, amount = 32000 },
    },

    {
        { itemId = xi.item.DARK_IXION_HORN, weight = 10000 },
    },

    {
        { itemId = xi.item.DARK_IXION_TAIL, weight = 10000 },
    },

    {
        { itemId = xi.item.AZOTH, weight = 2400 },
        { itemId = xi.item.NONE,  weight = 7600 },
    },

    {
        { itemId = xi.item.IXION_CAPE, weight = 2400 },
        { itemId = xi.item.NONE,       weight = 7600 },
    },

    {
        { itemId = xi.item.IXION_CLOAK, weight = 2400 },
        { itemId = xi.item.NONE,        weight = 7600 },
    },

    -- Generic KSNM99 synthesis materials.
    {
        { itemId = xi.item.CHUNK_OF_DARKSTEEL_ORE,     weight =  500 },
        { itemId = xi.item.CHUNK_OF_GOLD_ORE,          weight =  500 },
        { itemId = xi.item.CHUNK_OF_MYTHRIL_ORE,       weight =  500 },
        { itemId = xi.item.CHUNK_OF_PLATINUM_ORE,      weight =  500 },
        { itemId = xi.item.EBONY_LOG,                  weight =  500 },
        { itemId = xi.item.MAHOGANY_LOG,               weight =  500 },
        { itemId = xi.item.PETRIFIED_LOG,              weight =  500 },
        { itemId = xi.item.PHILOSOPHERS_STONE,         weight =  500 },
        { itemId = xi.item.SPOOL_OF_GOLD_THREAD,       weight =  500 },
        { itemId = xi.item.SQUARE_OF_RAINBOW_CLOTH,    weight =  500 },
        { itemId = xi.item.SQUARE_OF_RAXA,             weight =  500 },
        { itemId = xi.item.CORAL_FRAGMENT,             weight =  500 },
        { itemId = xi.item.DEMON_HORN,                 weight =  500 },
        { itemId = xi.item.HANDFUL_OF_WYVERN_SCALES,   weight =  500 },
        { itemId = xi.item.RAM_HORN,                    weight =  500 },
        { itemId = xi.item.SLAB_OF_GRANITE,             weight =  500 },
        { itemId = xi.item.RERAISER,                    weight =  500 },
        { itemId = xi.item.HI_RERAISER,                 weight =  500 },
        { itemId = xi.item.VILE_ELIXIR,                 weight =  500 },
        { itemId = xi.item.VILE_ELIXIR_P1,              weight =  500 },
    },

    -- Generic KSNM99 consumables.
    {
        { itemId = xi.item.HI_ETHER_P3,    weight = 2500 },
        { itemId = xi.item.HI_POTION_P3,   weight = 2500 },
        { itemId = xi.item.HI_RERAISER,    weight = 2500 },
        { itemId = xi.item.VILE_ELIXIR_P1, weight = 2500 },
    },

    -- Generic KSNM99 high-quality materials.
    {
        { itemId = xi.item.VIAL_OF_BLACK_BEETLE_BLOOD, weight =  625 },
        { itemId = xi.item.SQUARE_OF_DAMASCENE_CLOTH,  weight =  625 },
        { itemId = xi.item.DAMASCUS_INGOT,              weight =  625 },
        { itemId = xi.item.SPOOL_OF_MALBORO_FIBER,     weight =  625 },
        { itemId = xi.item.PHILOSOPHERS_STONE,         weight = 2000 },
        { itemId = xi.item.PHOENIX_FEATHER,            weight = 3500 },
        { itemId = xi.item.SQUARE_OF_RAXA,             weight = 2000 },
    },

    -- Generic KSNM99 logs and cloth.
    {
        { itemId = xi.item.DIVINE_LOG,              weight = 1000 },
        { itemId = xi.item.LACQUER_TREE_LOG,        weight = 2500 },
        { itemId = xi.item.PETRIFIED_LOG,           weight = 6000 },
        { itemId = xi.item.SQUARE_OF_SHINING_CLOTH, weight =  500 },
    },
}

return content:register()
