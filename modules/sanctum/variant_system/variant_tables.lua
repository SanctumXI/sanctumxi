local data = {}

-- These base event items exist in item_basic.sql but are omitted from xi.item.
local legacyCosmetics =
{
    sproutBeret      = 15198,
    guideBeret       = 15199,
    pumpkinHead      = 13916,
    charmWand        = 18399,
    woodenKatana     = 17830,
    snowBunnyHat     = 11490,
    witchHat         = 16075,
    trickStaff       = 17565,
    mandragoraBeret  = 15204,
    pitchfork        = 18102,
    moogleShirt      = 26546,
    ibushiShinai     = 17748,
    poroggoCassock   = 23803,
}

data.settings =
{
    variantChance        = 10,
    chainbreakerChance   = 15,
    criticalRevealChance = 25,
    chainbreakerDelay    = 5000,
    chainbreakerLockout  = 3600,
    chainbreakerScale    = 1.25,
    claimPriority        = 30000,
}

data.buffCatalog =
{
    hp_25 =
    {
        name     = 'HP +25%',
        minLevel = 1,
        modifiers =
        {
            { mod = xi.mod.HPP, value = 25 },
        },
    },

    base_stats_10 =
    {
        name     = 'Base Stats +10%',
        minLevel = 1,
        buildModifiers = function(mob)
            local modifiers = {}
            local stats =
            {
                xi.mod.STR,
                xi.mod.DEX,
                xi.mod.VIT,
                xi.mod.AGI,
                xi.mod.INT,
                xi.mod.MND,
                xi.mod.CHR,
            }

            for _, stat in ipairs(stats) do
                modifiers[#modifiers + 1] =
                {
                    mod   = stat,
                    value = math.max(1, math.floor(mob:getStat(stat) * 0.10)),
                }
            end

            return modifiers
        end,
    },

    attack_15 =
    {
        name      = 'Attack +15%',
        minLevel  = 1,
        modifiers =
        {
            { mod = xi.mod.ATTP, value = 15 },
        },
    },

    defense_20 =
    {
        name      = 'Defense +20%',
        minLevel  = 1,
        modifiers =
        {
            { mod = xi.mod.DEFP, value = 20 },
        },
    },

    accuracy_25 =
    {
        name      = 'Accuracy +25',
        minLevel  = 1,
        modifiers =
        {
            { mod = xi.mod.ACC, value = 25 },
        },
    },

    evasion_25 =
    {
        name      = 'Evasion +25',
        minLevel  = 1,
        modifiers =
        {
            { mod = xi.mod.EVA, value = 25 },
        },
    },

    regen_3 =
    {
        name      = 'Regen +3',
        minLevel  = 1,
        modifiers =
        {
            { mod = xi.mod.REGEN, value = 3 },
        },
    },

    poison_attacks =
    {
        name     = 'Poison Attacks',
        minLevel = 1,
        flags =
        {
            poisonAttacks = true,
        },
    },

    double_attack_10 =
    {
        name      = 'Double Attack +10%',
        minLevel  = 1,
        modifiers =
        {
            { mod = xi.mod.DOUBLE_ATTACK, value = 10 },
        },
    },

    haste_10 =
    {
        name      = 'Haste +10%',
        minLevel  = 1,
        modifiers =
        {
            { mod = xi.mod.HASTE_ABILITY, value = 1000 },
        },
    },

    regain_50 =
    {
        name      = 'Regain +50',
        minLevel  = 1,
        modifiers =
        {
            { mod = xi.mod.REGAIN, value = 50 },
        },
    },

    magic_attack_20 =
    {
        name      = 'Magic Attack +20',
        minLevel  = 51,
        modifiers =
        {
            { mod = xi.mod.MATT, value = 20 },
        },
    },

    magic_defense_20 =
    {
        name      = 'Magic Defense +20',
        minLevel  = 51,
        modifiers =
        {
            { mod = xi.mod.MDEF, value = 20 },
        },
    },

    fast_cast_15 =
    {
        name      = 'Fast Cast +15%',
        minLevel  = 51,
        modifiers =
        {
            { mod = xi.mod.FASTCAST, value = 15 },
        },
    },

    refresh_3 =
    {
        name      = 'Refresh +3',
        minLevel  = 51,
        modifiers =
        {
            { mod = xi.mod.REFRESH, value = 3 },
        },
    },

    store_tp_20 =
    {
        name      = 'Store TP +20',
        minLevel  = 51,
        modifiers =
        {
            { mod = xi.mod.STORETP, value = 20 },
        },
    },

    triple_attack_5 =
    {
        name      = 'Triple Attack +5%',
        minLevel  = 51,
        modifiers =
        {
            { mod = xi.mod.TRIPLE_ATTACK, value = 5 },
        },
    },

    damage_taken_10 =
    {
        name      = 'Damage Taken -10%',
        minLevel  = 66,
        modifiers =
        {
            { mod = xi.mod.DMG, value = -1000 },
        },
    },

    magic_evasion_40 =
    {
        name      = 'Magic Evasion +40',
        minLevel  = 66,
        modifiers =
        {
            { mod = xi.mod.MEVA, value = 40 },
        },
    },

    counter_10 =
    {
        name      = 'Counter +10%',
        minLevel  = 66,
        modifiers =
        {
            { mod = xi.mod.COUNTER, value = 10 },
        },
    },

    critical_hit_rate_10 =
    {
        name      = 'Critical Hit Rate +10%',
        minLevel  = 66,
        modifiers =
        {
            { mod = xi.mod.CRITHITRATE, value = 10 },
        },
    },

    subtle_blow_25 =
    {
        name      = 'Subtle Blow +25',
        minLevel  = 66,
        modifiers =
        {
            { mod = xi.mod.SUBTLE_BLOW, value = 25 },
        },
    },
}

data.regionBuffPools =
{
    [xi.region.ZULKHEIM] =
    {
        'hp_25',
        'base_stats_10',
        'attack_15',
        'defense_20',
        'accuracy_25',
        'evasion_25',
        'regen_3',
        'poison_attacks',
        'double_attack_10',
        'haste_10',
        'regain_50',
        'magic_attack_20',
        'magic_defense_20',
        'fast_cast_15',
        'refresh_3',
        'store_tp_20',
        'triple_attack_5',
        'damage_taken_10',
        'magic_evasion_40',
        'counter_10',
        'critical_hit_rate_10',
        'subtle_blow_25',
    },
}

data.weaknessCatalog =
{
    piercing_25 =
    {
        name = 'Piercing damage +25%',
        modifiers =
        {
            { mod = xi.mod.PIERCE_SDT, value = 2500 },
        },
    },

    blunt_25 =
    {
        name = 'Blunt damage +25%',
        modifiers =
        {
            { mod = xi.mod.IMPACT_SDT, value = 2500 },
            { mod = xi.mod.HTH_SDT, value = 2500 },
        },
    },

    slashing_25 =
    {
        name = 'Slashing damage +25%',
        modifiers =
        {
            { mod = xi.mod.SLASH_SDT, value = 2500 },
        },
    },

    magic_25 =
    {
        name = 'Magic damage +25%',
        modifiers =
        {
            { mod = xi.mod.UDMGMAGIC, value = 2500 },
        },
    },

    skillchain_25 =
    {
        name = 'Skillchain damage +25%',
        flags =
        {
            skillchainWeakness = true,
        },
    },
}

data.globalWeaknessPool =
{
    'piercing_25',
    'blunt_25',
    'slashing_25',
    'magic_25',
    'skillchain_25',
}

data.cosmeticPools =
{
    {
        minLevel = 1,
        maxLevel = 20,
        items =
        {
            legacyCosmetics.sproutBeret,
            legacyCosmetics.guideBeret,
            xi.item.EGG_HELM,
            legacyCosmetics.pumpkinHead,
            xi.item.HORROR_HEAD,
            xi.item.DREAM_HAT_P1,
            legacyCosmetics.charmWand,
            legacyCosmetics.woodenKatana,
            xi.item.SHINAI,
            xi.item.BATTLEDORE,
        },
    },
    {
        minLevel = 21,
        maxLevel = 30,
        items =
        {
            xi.item.REDEYES,
            legacyCosmetics.snowBunnyHat,
            legacyCosmetics.witchHat,
            xi.item.DREAM_ROBE_P1,
            xi.item.DREAM_MITTENS_P1,
            xi.item.DREAM_BOOTS_P1,
            xi.item.HEART_APRON,
            xi.item.HEARTBEATER,
            xi.item.TREAT_STAFF,
            legacyCosmetics.trickStaff,
        },
    },
    {
        minLevel = 31,
        maxLevel = 40,
        items =
        {
            xi.item.CHOCOBO_BERET,
            xi.item.DESTRIER_BERET,
            legacyCosmetics.mandragoraBeret,
            xi.item.KORRIGAN_BERET,
            xi.item.MOOGLE_CAP,
            xi.item.NOMAD_CAP,
            xi.item.MOOGLE_ROD,
            xi.item.DREAM_BELL_P1,
            legacyCosmetics.pitchfork,
            xi.item.HARDWOOD_KATANA,
        },
    },
    {
        minLevel = 41,
        maxLevel = 50,
        items =
        {
            legacyCosmetics.moogleShirt,
            xi.item.MANDRAGORA_SHIRT,
            xi.item.CITRULLUS_SHIRT,
            xi.item.JODY_SHIRT,
            xi.item.GIL_NABBER_SHIRT,
            xi.item.CRUSTACEAN_SHIRT,
            xi.item.MITHKABOB_SHIRT,
            xi.item.JUBILEE_SHIRT,
            xi.item.SHADOW_LORD_SHIRT,
            xi.item.LOTUS_KATANA,
        },
    },
    {
        minLevel = 51,
        maxLevel = 60,
        items =
        {
            xi.item.CHOCOBO_MASQUE,
            xi.item.GOBLIN_MASQUE,
            xi.item.MANDRAGORA_MASQUE,
            xi.item.LYCOPODIUM_MASQUE,
            xi.item.KORRIGAN_MASQUE,
            xi.item.PACHYPODIUM_MASQUE,
            xi.item.ADENIUM_MASQUE,
            xi.item.KAKAI_CAP,
            xi.item.DREAM_TROUSERS_P1,
            legacyCosmetics.ibushiShinai,
        },
    },
    {
        minLevel = 61,
        maxLevel = 70,
        items =
        {
            xi.item.CHOCOBO_SUIT,
            xi.item.GOBLIN_SUIT,
            xi.item.MANDRAGORA_SUIT,
            xi.item.KORRIGAN_SUIT,
            xi.item.ADENIUM_SUIT,
            xi.item.DINNER_JACKET,
            xi.item.DINNER_HOSE,
            xi.item.STARLET_JABOT,
            xi.item.STARLET_SKIRT,
            xi.item.AGENT_COAT,
        },
    },
    {
        minLevel = 71,
        maxLevel = 80,
        items =
        {
            xi.item.MOOGLE_MASQUE,
            xi.item.GREEN_MOOGLE_MASQUE,
            xi.item.POROGGO_FLEECE,
            legacyCosmetics.poroggoCassock,
            xi.item.AGENT_HOOD,
            xi.item.AGENT_PANTS,
            xi.item.AGENT_BOOTS,
            xi.item.STARLET_FLOWER,
            xi.item.STARLET_GLOVES,
            xi.item.STARLET_BOOTS,
        },
    },
    {
        minLevel = 81,
        maxLevel = 84,
        items =
        {
            xi.item.MOOGLE_SUIT,
            xi.item.GREEN_MOOGLE_SUIT,
            xi.item.POROGGO_COAT,
            xi.item.CHOCOBO_SHIELD,
            xi.item.MOOGLE_GUARD,
            xi.item.TOWN_MOOGLE_SHIELD,
            xi.item.JINGLY_ROD,
            xi.item.MAESTROS_BATON,
            xi.item.MELOMANE_MALLET,
            xi.item.MALICE_MASHER,
        },
    },
    {
        minLevel = 85,
        maxLevel = 255,
        items =
        {
            xi.item.WYRMKING_MASQUE,
            xi.item.WYRMKING_SUIT,
            xi.item.BEHEMOTH_MASQUE,
            xi.item.BEHEMOTH_SUIT,
            xi.item.BOTULUS_SUIT,
            xi.item.ARK_SABER,
            xi.item.ARK_SWORD,
            xi.item.ARK_SCYTHE,
            xi.item.ARK_TABAR,
            xi.item.ARK_TACHI,
        },
    },
}

return data
