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

local function modifierEntry(name, mod, value)
    return { name = name, modifiers = { { mod = mod, value = value } } }
end

local function modifierListEntry(name, modifiers)
    return { name = name, modifiers = modifiers }
end

local function flagEntry(name, flag)
    return { name = name, flags = { [flag] = true } }
end

data.settings =
{
    variantChance           = 10,
    chainbreakerChance      = 15,
    criticalRevealChance    = 25,
    chainbreakerDelay       = 30000,
    chainbreakerLockoutMin  = 1800,
    chainbreakerLockoutMax  = 3600,
    chainbreakerScale       = 1.25,
    claimPriority           = 30000,
    zoneBossThreshold       = 20,
    zoneBossChance          = 25,
    zoneBossSpawnDelay      = 5000,
    zoneBossBuffCount       = 5,
    zoneBossActionPoints    = 1,
}

data.buffCatalog =
{
    hp_25 = modifierEntry('HP +25%', xi.mod.HPP, 25),
    base_stats_10 =
    {
        name = 'Base Stats +10%',
        buildModifiers = function(mob)
            local modifiers = {}
            local stats =
            {
                xi.mod.STR, xi.mod.DEX, xi.mod.VIT, xi.mod.AGI,
                xi.mod.INT, xi.mod.MND, xi.mod.CHR,
            }

            for _, stat in ipairs(stats) do
                modifiers[#modifiers + 1] = {
                    mod   = stat,
                    value = math.max(1, math.floor(mob:getStat(stat) * 0.10)),
                }
            end

            return modifiers
        end,
    },
    attack_15           = modifierEntry('Attack +15%', xi.mod.ATTP, 15),
    defense_20          = modifierEntry('Defense +20%', xi.mod.DEFP, 20),
    accuracy_25         = modifierEntry('Accuracy +25', xi.mod.ACC, 25),
    evasion_25          = modifierEntry('Evasion +25', xi.mod.EVA, 25),
    regen_3             = modifierEntry('Regen +3', xi.mod.REGEN, 3),
    poison_attacks      = flagEntry('Poison Attacks', 'poisonAttacks'),
    double_attack_10    = modifierEntry('Double Attack +10%', xi.mod.DOUBLE_ATTACK, 10),
    haste_10            = modifierEntry('Haste +10%', xi.mod.HASTE_ABILITY, 1000),
    regain_50           = modifierEntry('Regain +50', xi.mod.REGAIN, 50),
    magic_attack_20     = modifierEntry('Magic Attack +20', xi.mod.MATT, 20),
    magic_defense_20    = modifierEntry('Magic Defense +20', xi.mod.MDEF, 20),
    fast_cast_15        = modifierEntry('Fast Cast +15%', xi.mod.FASTCAST, 15),
    refresh_3           = modifierEntry('Refresh +3', xi.mod.REFRESH, 3),
    store_tp_20         = modifierEntry('Store TP +20', xi.mod.STORETP, 20),
    triple_attack_5     = modifierEntry('Triple Attack +5%', xi.mod.TRIPLE_ATTACK, 5),
    damage_taken_10     = modifierEntry('Damage Taken -10%', xi.mod.DMG, -1000),
    magic_evasion_40    = modifierEntry('Magic Evasion +40', xi.mod.MEVA, 40),
    counter_10          = modifierEntry('Counter +10%', xi.mod.COUNTER, 10),
    critical_hit_rate_10 = modifierEntry('Critical Hit Rate +10%', xi.mod.CRITHITRATE, 10),
    subtle_blow_25      = modifierEntry('Subtle Blow +25', xi.mod.SUBTLE_BLOW, 25),
}

data.buffCategoryOrder = { 'physical', 'magical', 'misc' }

data.buffCategoryNames =
{
    physical = 'Physical',
    magical  = 'Magical',
    misc     = 'Miscellaneous',
}

local levelOneBuffs =
{
    physical =
    {
        'attack_15', 'defense_20', 'accuracy_25',
        'evasion_25', 'poison_attacks', 'double_attack_10',
    },
    magical = {},
    misc =
    {
        'hp_25', 'base_stats_10', 'regen_3', 'haste_10', 'regain_50',
    },
}

local levelFiftyOneBuffs =
{
    physical =
    {
        'store_tp_20', 'triple_attack_5',
    },
    magical =
    {
        'magic_attack_20', 'magic_defense_20', 'fast_cast_15', 'refresh_3',
    },
    misc = {},
}

local levelSixtySixBuffs =
{
    physical =
    {
        'counter_10', 'critical_hit_rate_10', 'subtle_blow_25',
    },
    magical = { 'magic_evasion_40' },
    misc     = { 'damage_taken_10' },
}

local function combineBuffTiers(...)
    local result = { physical = {}, magical = {}, misc = {} }

    for _, tier in ipairs({ ... }) do
        for _, category in ipairs(data.buffCategoryOrder) do
            for _, buffId in ipairs(tier[category] or {}) do
                result[category][#result[category] + 1] = buffId
            end
        end
    end

    return result
end

data.levelBuffPools =
{
    { minLevel = 1,  maxLevel = 50, buffs = combineBuffTiers(levelOneBuffs) },
    { minLevel = 51, maxLevel = 65, buffs = combineBuffTiers(levelOneBuffs, levelFiftyOneBuffs) },
    { minLevel = 66, maxLevel = 86, buffs = combineBuffTiers(levelOneBuffs, levelFiftyOneBuffs, levelSixtySixBuffs) },
}

data.weaknessCatalog =
{
    piercing_25 = modifierEntry('Piercing damage +25%', xi.mod.PIERCE_SDT, 2500),
    blunt_25 = modifierListEntry('Blunt damage +25%',
    {
        { mod = xi.mod.IMPACT_SDT, value = 2500 },
        { mod = xi.mod.HTH_SDT, value = 2500 },
    }),
    slashing_25   = modifierEntry('Slashing damage +25%', xi.mod.SLASH_SDT, 2500),
    magic_25      = modifierEntry('Magic damage +25%', xi.mod.UDMGMAGIC, 2500),
    skillchain_25 = flagEntry('Skillchain damage +25%', 'skillchainWeakness'),
}

data.globalWeaknessPool =
{
    'piercing_25', 'blunt_25', 'slashing_25', 'magic_25', 'skillchain_25',
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
