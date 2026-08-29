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
    zoneBossSanctumRingOwnedScrollChance = 75,
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

-- Charged items and activatable enchantments are reserved for level 60+ camps.
data.specialEffectCosmetics =
{
    [xi.item.AGENT_COAT]              = true,
    [xi.item.ARK_SABER]               = true,
    [xi.item.ARK_SCYTHE]              = true,
    [xi.item.ARK_SWORD]               = true,
    [xi.item.ARK_TABAR]               = true,
    [xi.item.ARK_TACHI]               = true,
    [legacyCosmetics.charmWand]       = true,
    [xi.item.CHOCOBO_BERET]           = true,
    [xi.item.CITRULLUS_SHIRT]         = true,
    [xi.item.DESTRIER_BERET]          = true,
    [xi.item.DREAM_BOOTS_P1]          = true,
    [xi.item.DREAM_HAT_P1]            = true,
    [xi.item.DREAM_MITTENS_P1]        = true,
    [legacyCosmetics.guideBeret]      = true,
    [legacyCosmetics.ibushiShinai]    = true,
    [xi.item.KORRIGAN_BERET]          = true,
    [xi.item.KORRIGAN_MASQUE]         = true,
    [xi.item.KORRIGAN_SUIT]           = true,
    [xi.item.MAESTROS_BATON]          = true,
    [legacyCosmetics.mandragoraBeret] = true,
    [xi.item.MELOMANE_MALLET]         = true,
    [xi.item.MOOGLE_CAP]              = true,
    [xi.item.MOOGLE_ROD]              = true,
    [legacyCosmetics.moogleShirt]     = true,
    [xi.item.MOOGLE_SUIT]             = true,
    [xi.item.NOMAD_CAP]               = true,
    [xi.item.PACHYPODIUM_MASQUE]      = true,
    [xi.item.REDEYES]                 = true,
    [xi.item.SHADOW_LORD_SHIRT]       = true,
    [legacyCosmetics.snowBunnyHat]    = true,
    [legacyCosmetics.sproutBeret]     = true,
    [xi.item.STARLET_JABOT]           = true,
    [xi.item.TOWN_MOOGLE_SHIELD]      = true,
}

data.levelSixtyPlusCosmeticCamps =
{
    FeiYin = { hellish_weapon = true },
    Bostaunieux_Oubliette =
    {
        mousse = true,
        haunt  = true,
    },
    Labyrinth_of_Onzozo = { torama = true },
    Wajaom_Woodlands    = { lesser_colibri = true },
    Bhaflau_Thickets    = { lesser_colibri = true },
    RuAun_Gardens =
    {
        flamingo      = true,
        groundskeeper = true,
    },
    The_Shrine_of_RuAvitau =
    {
        aura_pot    = true,
        aura_statue = true,
    },
    The_Boyahda_Tree =
    {
        bark_spider    = true,
        death_cap      = true,
        mourioche      = true,
        skimmer        = true,
        bark_tarantula = true,
    },
    Kuftal_Tunnel =
    {
        sand_lizard   = true,
        kuftal_digger = true,
        ovinnik       = true,
    },
    RoMaeve =
    {
        low_level_weapons  = true,
        high_level_weapons = true,
        cursed_puppet      = true,
    },
}

data.cosmeticCamps =
{
    Valkurm_Dunes =
    {
        thread_leech = { legacyCosmetics.woodenKatana },
        hill_lizard  = { xi.item.EGG_HELM },
    },
    Qufim_Island =
    {
        greater_pugil = { xi.item.DREAM_TROUSERS_P1 },
        land_worm     = { xi.item.DREAM_BELL_P1 },
        clipper       = { xi.item.DREAM_ROBE_P1 },
    },
    Korroloka_Tunnel =
    {
        clipper = { xi.item.CRUSTACEAN_SHIRT },
        combat  = { xi.item.HARDWOOD_KATANA },
    },
    Gusgen_Mines =
    {
        bandersnatch = { xi.item.HORROR_HEAD },
        myconid      = { legacyCosmetics.witchHat },
    },
    Batallia_Downs =
    {
        may_fly = { xi.item.STARLET_FLOWER },
        ba      = { xi.item.STARLET_BOOTS },
    },
    Jugner_Forest =
    {
        stag_beetle    = { xi.item.BATTLEDORE },
        jugner_funguar = { xi.item.MANDRAGORA_SHIRT },
    },
    Carpenters_Landing =
    {
        battrap  = { xi.item.ADENIUM_MASQUE },
        birdtrap = { xi.item.ADENIUM_SUIT },
    },
    Rolanberry_Fields =
    {
        berry_grub = { xi.item.MANDRAGORA_SUIT },
        death_wasp = { legacyCosmetics.pumpkinHead },
    },
    Pashhow_Marshlands =
    {
        gadfly        = { xi.item.POROGGO_FLEECE },
        marsh_funguar = { legacyCosmetics.poroggoCassock },
    },
    Buburimu_Peninsula =
    {
        bull_dhalmel = { xi.item.CHOCOBO_SHIELD },
        zu           = { xi.item.CHOCOBO_MASQUE },
    },
    Maze_of_Shakhrami =
    {
        maze_maker = { xi.item.SHINAI },
        abyss_worm = { legacyCosmetics.pitchfork },
    },
    Ordelles_Caves =
    {
        dung_beetle    = { xi.item.BEHEMOTH_MASQUE },
        goliath_beetle = { xi.item.BEHEMOTH_SUIT },
    },
    Attohwa_Chasm =
    {
        antlion_family = { xi.item.BOTULUS_SUIT },
        flesh_eater    = { xi.item.MITHKABOB_SHIRT },
    },
    Castle_Oztroja =
    {
        yagudo_family = { xi.item.MOOGLE_MASQUE },
        cutter        = { xi.item.MOOGLE_GUARD },
    },
    Garlaige_Citadel =
    {
        funnel_bats = { xi.item.GREEN_MOOGLE_MASQUE },
        oil_spill   = { xi.item.STARLET_GLOVES },
    },
    Meriphataud_Mountains =
    {
        wandering_sapling = { xi.item.MANDRAGORA_MASQUE },
        raptor             = { xi.item.JODY_SHIRT },
        coeurl             = { xi.item.LYCOPODIUM_MASQUE },
    },
    Sauromugue_Champaign =
    {
        goblin_family    = { xi.item.GOBLIN_MASQUE },
        sabertooth_tiger = { xi.item.KAKAI_CAP },
    },
    The_Boyahda_Tree =
    {
        bark_spider    = { xi.item.KORRIGAN_BERET, xi.item.KORRIGAN_SUIT },
        death_cap      = { legacyCosmetics.mandragoraBeret, xi.item.PACHYPODIUM_MASQUE },
        mourioche      = { legacyCosmetics.snowBunnyHat },
        skimmer        = { legacyCosmetics.sproutBeret },
        bark_tarantula = { xi.item.KORRIGAN_MASQUE },
    },
    Kuftal_Tunnel =
    {
        sand_lizard   = { xi.item.DESTRIER_BERET, xi.item.CHOCOBO_BERET },
        kuftal_digger = { xi.item.MOOGLE_ROD },
        ovinnik       = { xi.item.MELOMANE_MALLET, xi.item.MAESTROS_BATON },
    },
    Eastern_Altepa_Desert =
    {
        giant_spider   = { xi.item.HEART_APRON },
        sand_beetle    = { xi.item.HEARTBEATER },
        flesh_eater    = { xi.item.TREAT_STAFF },
        desert_dhalmel = { xi.item.CHOCOBO_SUIT },
    },
    Western_Altepa_Desert =
    {
        desert_worm     = { legacyCosmetics.trickStaff },
        desert_dhalmel  = { xi.item.DINNER_JACKET },
        desert_beetle   = { xi.item.AGENT_BOOTS },
        tulwar_scorpion = { xi.item.LOTUS_KATANA },
    },
    FeiYin =
    {
        underworld_bats = { xi.item.JINGLY_ROD },
        camazotz        = { xi.item.AGENT_HOOD },
        droma           = { xi.item.STARLET_SKIRT },
        specter         = { xi.item.MALICE_MASHER },
        killing_weapon  = { xi.item.DINNER_HOSE },
        hellish_weapon  = { xi.item.ARK_TABAR, xi.item.ARK_SCYTHE },
    },
    Bostaunieux_Oubliette =
    {
        funnel_bats = { xi.item.GREEN_MOOGLE_SUIT },
        werebat     = { xi.item.POROGGO_COAT },
        mousse      = { xi.item.MOOGLE_SUIT },
        haunt       = { xi.item.SHADOW_LORD_SHIRT, xi.item.REDEYES },
    },
    Labyrinth_of_Onzozo =
    {
        cockatrice   = { xi.item.WYRMKING_MASQUE },
        mushussu     = { xi.item.WYRMKING_SUIT },
        flying_manta = { xi.item.GOBLIN_SUIT },
        torama       = { xi.item.MOOGLE_CAP, xi.item.NOMAD_CAP },
    },
    Wajaom_Woodlands =
    {
        lesser_colibri = { legacyCosmetics.moogleShirt, legacyCosmetics.guideBeret },
    },
    Bhaflau_Thickets =
    {
        lesser_colibri = { xi.item.CITRULLUS_SHIRT },
    },
    RuAun_Gardens =
    {
        flamingo      = { xi.item.DREAM_MITTENS_P1, xi.item.DREAM_BOOTS_P1 },
        groundskeeper = { xi.item.STARLET_JABOT, xi.item.DREAM_HAT_P1 },
    },
    The_Shrine_of_RuAvitau =
    {
        aura_pot    = { xi.item.AGENT_COAT, xi.item.AGENT_PANTS },
        aura_statue = { xi.item.TOWN_MOOGLE_SHIELD },
    },
    Fort_Ghelsba =
    {
        orcish_infantry     = { xi.item.GIL_NABBER_SHIRT },
        orcish_flamethrower = { xi.item.JUBILEE_SHIRT },
    },
    RoMaeve =
    {
        low_level_weapons  = { xi.item.ARK_SABER, legacyCosmetics.charmWand },
        high_level_weapons = { xi.item.ARK_SWORD },
        cursed_puppet      = { xi.item.ARK_TACHI, legacyCosmetics.ibushiShinai },
    },
}

return data
