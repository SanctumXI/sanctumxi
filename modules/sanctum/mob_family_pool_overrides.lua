-----------------------------------
-- Sanctum per-pool family exceptions
-- Preserves legacy distinctions that now share one upstream species row.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('sanctum_mob_family_pool_overrides')
m:setEnabled(true)

local poolOverrides =
{
    [21] = { speed = 65 },
    [34] = { speed = 50 },
    [68] = { speed = 50 },
    [118] = { speed = 55 },
    [134] = { speed = 55 },
    [236] = { speed = 50 },
    [238] = { speed = 65 },
    [330] = { speed = 65 },
    [738] = { speed = 30 },
    [1053] = { speed = 55 },
    [1154] = { speed = 60 },
    [1306] = { detection = bit.bor(xi.detects.MAGIC, xi.detects.SIGHT) },
    [1798] = { speed = 55 },
    [1841] = { speed = 55 },
    [1851] = { speed = 50 },
    [2223] = { speed = 50 },
    [2246] = { speed = 55 },
    [2378] = { speed = 55 },
    [2417] = { speed = 60 },
    [2423] = { speed = 55 },
    [2729] = { speed = 55 },
    [3188] = { speed = 45 },
    [3350] = { speed = 65 },
    [3540] = { speed = 65 },
    [3652] = { speed = 50 },
    [3816] = { speed = 65 },
    [4052] = { speed = 55 },
    [4217] = { speed = 55 },
    [4221] = { speed = 55 },
    [4223] = { speed = 65 },
    [4265] = { speed = 55 },
    [4308] = { speed = 50 },
    [4503] = { speed = 65 },
    [4562] = { speed = 65 },
    [4671] = { speed = 65 },
    [4673] = { speed = 65 },
    [4700] = { speed = 50 },
    [4713] = { speed = 65 },
    [4714] = { speed = 65 },
    [5067] = { acc = 2 },
    [5128] = { detection = bit.bor(xi.detects.MAGIC, xi.detects.SIGHT) },
    [5691] = { speed = 65 },
    [5692] = { speed = 65 },
    [6055] = { speed = 55 },
    [6059] = { speed = 60 },
    [7153] = { speed = 50 },
}

-- Attach overrides to the mob lifecycle instead of querying zone entities.
-- This supports static, dynamic, and instance mobs without startup warnings,
-- and ensures stat ranks are set before CalculateMobStats runs on spawn.
local zoneMobNames =
{
    ['Abyssea-Grauberg'] = { 'Rencounter_Chariot' },
    ['Abyssea-Konschtat'] = { 'Balaur' },
    ['Abyssea-Tahrongi'] = { 'Quetzalli' },
    ['Abyssea-Uleguerand'] = { 'Veri_Selen' },
    ['Abyssea-Vunkerl'] = { 'Div-e_Sepid' },
    ['Al_Zahbi'] = { 'Gurfurlur_the_Menacing' },
    ['AlTaieu'] = { 'Absolute_Virtue' },
    ['Arrapago_Reef'] = { 'Lil_Apkallu', 'Velionis' },
    ['Bhaflau_Thickets'] = { 'Lividroot_Amooshah', 'Skoffin' },
    ['Caedarva_Mire'] = { 'Verdelet', 'Zikko' },
    ['Cirdas_Caverns'] = { 'Crepuscular_Worm' },
    ['Crawlers_Nest_[S]'] = { 'Kalos_Eunomia' },
    ['Dynamis-Tavnazia'] = { 'Kindreds_Vouivre' },
    ['Dynamis-Xarcabard'] = { 'Andrass_Vouivre', 'Arch_Dynamis_Lord', 'Caims_Vouivre', 'Dynamis_Lord', 'Kindreds_Vouivre' },
    ['Escha_RuAun'] = { 'Ark_Angel_GK', 'Ark_Angel_MR', 'Seiryu-Escha', 'Suzaku-Escha' },
    ['Halvung'] = { 'Achamoth', 'Gurfurlur_the_Menacing' },
    ['Kuftal_Tunnel'] = { 'Guivre' },
    ['LaLoff_Amphitheater'] = { 'Ark_Angel_GK', 'Ark_Angel_MR' },
    ['Mamook'] = { 'Watch_Wyvern' },
    ['Mount_Zhayolm'] = { 'Anantaboga', 'Claret', 'Khromasoul_Bhurborlor' },
    ['Nyzul_Isle'] = { 'Aiatar', 'Seiryu', 'Suzaku' },
    ['Riverne-Site_A01'] = { 'Aiatar' },
    ['RuAun_Gardens'] = { 'Groundskeeper', 'Seiryu', 'Suzaku' },
    ['Ruhotz_Silvermines'] = { 'Guivre' },
    ['Sacrificial_Chamber'] = { 'Graviton', 'Molybiton', 'Tungsiton' },
    ['The_Shrine_of_RuAvitau'] = { 'Faust', 'Qing_Long', 'Seiryu_pet', 'Suzaku_pet', 'Zhu_Que' },
    ['Upper_Delkfutts_Tower'] = { 'Porphyrion' },
    ['Wajaom_Woodlands'] = { 'Gurfurlur_the_Menacing', 'Vulpangue' },
    ['Walk_of_Echoes'] = { 'Larzos' },
}

local function applyPoolOverride(mob)
    local override = poolOverrides[mob:getPool()]

    if not override then
        return
    end

    if override.speed then
        mob:setBaseSpeed(override.speed)
        mob:setAnimationSpeed(override.speed)
    end

    if override.acc then
        mob:setStatRank(xi.stat.ACC, override.acc)
    end

    if override.detection then
        mob:setMobMod(xi.mobMod.DETECTION, override.detection)
    end
end

local function mobScriptExists(zoneName, mobName)
    local scriptPath = string.format('scripts/zones/%s/mobs/%s.lua', zoneName, mobName)
    local scriptFile = io.open(scriptPath, 'r')

    if not scriptFile then
        return false
    end

    scriptFile:close()
    return true
end

local function addPoolOverride(zoneName, mobName)
    if mobScriptExists(zoneName, mobName) then
        m:addOverride(string.format('xi.zones.%s.mobs.%s.onMobInitialize', zoneName, mobName), function(mob)
            super(mob)
            applyPoolOverride(mob)
        end)
    else
        -- Scriptless entities still need a cached lifecycle table so static,
        -- dynamic, and instance-spawned copies all receive the override.
        xi.module.ensureTable(string.format('xi.zones.%s.mobs.%s', zoneName, mobName))
        xi.zones[zoneName].mobs[mobName].onMobInitialize = function(mob)
            applyPoolOverride(mob)
        end
    end
end

for zoneName, mobNames in pairs(zoneMobNames) do
    for _, mobName in ipairs(mobNames) do
        addPoolOverride(zoneName, mobName)
    end
end

return m
