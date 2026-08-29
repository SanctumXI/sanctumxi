-- Isolated entities; real pact scripts, damage helpers, module overrides and SQL flags.
testOutput = ''
local function passed(message)
    testOutput = testOutput .. message .. '\n'
end

local nextEnum = 10000
local function enum()
    return setmetatable({}, { __index = function(values, key)
        nextEnum = nextEnum + 1
        rawset(values, key, nextEnum)
        return nextEnum
    end })
end

bit = require('bit')
require = function()
end

function set(values)
    local result = {}
    for _, value in ipairs(values) do
        result[value] = true
    end

    return result
end

xi =
{
    mod = enum(), effect = enum(), attackType = enum(), damageType = enum(),
    element = enum(), skill = enum(), job = enum(), attackAnimation = enum(),
    skillchainType = enum(), merit = enum(), action = { category = enum() },
    msg = { basic = enum() }, battlefield = { id = enum() }, magic = { spell = enum(), spellFamily = enum() },
    job_utils = { summoner = {} }, combat = { physical = {}, physicalHitRate = {}, damage = {}, magicHitRate = {}, magicBurst = {}, tp = {} },
    spells = { damage = {} }, wsEffect = {}, jp = enum(), direction = enum(),
    settings = { main = { ENABLE_SOA = 0 }, map = { BLOOD_PACT_SHARED_TIMER = false } },
    data = { levelCorrection = {}, element = {} },
    actions = { abilities = { pets = {} } },
    effects = {}, objType = enum(), auraTarget = enum(), effectFlag = enum(), mobMod = enum(),
}
for _, name in ipairs({ 'job', 'job_ability', 'add_type', 'mod', 'effect', 'skill', 'skill_rank', 'attack_type', 'action', 'msg', 'magic', 'merit', 'pet_id', 'recast', 'direction' }) do
    dofile(ROOT .. 'scripts/enum/' .. name .. '.lua')
end

xi.element = { NONE = 0, FIRE = 1, ICE = 2, WIND = 3, EARTH = 4, THUNDER = 5, WATER = 6, LIGHT = 7, DARK = 8 }
xi.damageType = { NONE = 0, PIERCING = 1, SLASHING = 2, BLUNT = 3, HAND_TO_HAND = 4, ELEMENTAL = 5, FIRE = 6, ICE = 7, WIND = 8, EARTH = 9, THUNDER = 10, WATER = 11, LIGHT = 12, DARK = 13 }
utils = {}
utils.clamp = function(value, low, high)
    return math.max(low, math.min(value, high))
end

utils.defaultIfNil = function(value, fallback)
    if value == nil then
        return fallback
    end

    return value
end

utils.splitStr = function(value, separator)
    local parts = {}
    for part in value:gmatch('[^' .. separator .. ']+') do
        parts[#parts + 1] = part
    end

    return parts
end

math.randomFloat = function()
    return 0.5
end

math.randomInt = function()
    return 100
end

dofile(ROOT .. 'modules/module_utils.lua')
dofile(ROOT .. 'scripts/globals/combat/physical_utilities.lua')
dofile(ROOT .. 'scripts/globals/combat/damage_multipliers.lua')
dofile(ROOT .. 'scripts/utils/combat_utils.lua')
dofile(ROOT .. 'scripts/globals/summon.lua')
dofile(ROOT .. 'scripts/globals/job_utils/summoner.lua')
dofile(ROOT .. 'scripts/globals/pets.lua')
dofile(ROOT .. 'scripts/globals/pets/avatar.lua')
dofile(ROOT .. 'scripts/globals/avatars_favor.lua')
xi['effects'].diaboloss_favor = dofile(ROOT .. 'scripts/effects/diaboloss_favor.lua')
xi.actions.abilities.apogee = dofile(ROOT .. 'scripts/actions/abilities/apogee.lua')
dofile(ROOT .. 'modules/sanctum/CombatRework/Lua/Jobs/summoner.lua')
dofile(ROOT .. 'modules/sanctum/CombatRework/Lua/Mobs/mobskill_calculations.lua')
dofile(ROOT .. 'modules/sanctum/CombatRework/Lua/Spells/damage_calculations.lua')

for _, path in ipairs(petFiles) do
    local name = path:match('([^/]+)%.lua$')
    xi.actions.abilities.pets[name] = dofile(ROOT .. path)
end

local function loadModule(path)
    local module = dofile(ROOT .. path)
    for _, override in ipairs(module.overrides) do
        local parts = utils.splitStr(override.name, '.')
        local parent = _G
        for index = 1, #parts - 1 do
            parent = assert(parent[parts[index]], override.name)
        end

        if parent[parts[#parts]] == nil then
            parent[parts[#parts]] = function()
            end
        end

        assert(type(parent[parts[#parts]]) == 'function', override.name)
        applyOverride(parent, parts[#parts], override.func, override.name, path)
    end
end

xi.wsEffect.getSpiritTakerSummonerPetDamageBonus = function(pet)
    return pet.spiritTaker or 0
end

xi.data.levelCorrection.isLevelCorrectedZone = function()
    return false
end

xi.data.element.getElementalSDTModifier = function(element)
    return 20000 + element
end

xi.data.element.getElementalResistanceRankModifier = function(element)
    return 20100 + element
end

xi.data.element.getElementalAbsorptionModifier = function(element)
    return 20200 + element
end

xi.data.element.getElementalNullificationModifier = function(element)
    return 20300 + element
end

xi.data.element.getElementalPotencyMerit = function(element)
    return 20400 + element
end

xi.data.element.getAssociatedBarspellEffect = function(element)
    return 20500 + element
end

xi.data.statusEffect =
{
    isTargetImmune = function()
        return false
    end,

    isTargetResistant = function()
        return false
    end,

    isEffectNullified = function()
        return false
    end,
}
xi.combat.magicHitRate.calculateResistRate = function(_, target)
    return target.resist or 1
end

xi.combat.magicBurst.getMagicBurstTier = function(target)
    return target.burst or 0
end

xi.mobskills.calculatePetMagicAccuracyBonus = function()
    return 0
end

xi.spells.damage.calculateDayAndWeather = function(pet)
    return pet.weather or 1
end

xi.combat.tp.getSingleMeleeHitTPReturn = function()
    return 100
end

xi.combat.tp.calculateTPGainOnPhysicalDamage = function()
    return 100
end

xi.combat.physicalHitRate.getPhysicalHitRate = function()
    return 1
end

xi.combat.physical.calculateMeleeStatFactor = function()
    return 0
end

xi.summon.getSummoningSkillOverCap = function()
    return 0
end

local realPhysical = xi.summon.avatarPhysicalMove

loadModule('modules/sanctum/jobs/summoner/blood_pacts.lua')
loadModule('modules/sanctum/jobs/summoner/summons.lua')
loadModule('modules/sanctum/jobs/summoner/support.lua')
local playerPhysical = xi.summon.avatarPhysicalMove

local function entity()
    local actor = { mods = {}, effects = {}, merits = {}, stats = {}, tp = 0, mp = 5000, hp = 10000, damage = 0, damageCalls = 0, localVars = {}, recasts = {}, level = 75, id = 1, avatar = true, pc = true }
    function actor:getMod(key)
        return self.mods[key] or 0
    end

    function actor:setMod(key, value)
        self.mods[key] = value
    end

    function actor:addMod(key, value)
        self.mods[key] = self:getMod(key) + value
    end

    function actor:delMod(key, value)
        self.mods[key] = self:getMod(key) - value
    end

    function actor:getStat(key)
        return self.stats[key] or 100
    end

    function actor:getMainLvl()
        return self.level
    end

    function actor:getMainJob()
        return xi.job.SMN
    end

    function actor:getPetID()
        return self.petId or xi.petId.CARBUNCLE
    end

    function actor:getPet()
        return self.pet
    end

    function actor:getObjType()
        return self.pc and xi.objType.PC or xi.objType.MOB
    end

    function actor:setMobMod(key, value)
        self.mods[key] = value
    end

    function actor:updateHealth()
    end

    function actor:getMaxMP()
        return 5000
    end

    function actor:setMP(value)
        self.mp = value
    end

    function actor:addListener()
    end

    function actor:getCurrentAction()
        return xi.action.category.PET_MOBABILITY_FINISH
    end

    function actor:hasStatusEffect(key)
        return self.effects[key] ~= nil
    end

    function actor:getStatusEffect(key)
        return self.effects[key]
    end

    function actor:delStatusEffect(key)
        self.effects[key] = nil
    end

    function actor:dispelStatusEffect()
        self.dispelled = true
    end

    function actor:addStatusEffect(key, value)
        self.effects[key] = value
        return true
    end

    function actor:canGainStatusEffect()
        return true
    end

    function actor:getStatusEffectElement()
        return xi.element.NONE
    end

    function actor:checkDamageCap(damage)
        return damage
    end

    function actor:takeDamage(damage)
        self.damage = self.damage + damage
        self.hp = self.hp - damage
        self.damageCalls = self.damageCalls + 1
    end

    function actor:updateEnmityFromDamage()
    end

    function actor:addBaseEnmity()
    end

    function actor:getID()
        return self.id
    end

    function actor:isAvatar()
        return self.avatar
    end

    function actor:isPC()
        return self.pc
    end

    function actor:isMob()
        return not self.pc
    end

    function actor:isBehind()
        return false
    end

    function actor:getTP()
        return self.tp
    end

    function actor:setTP(value)
        self.tp = value
    end

    function actor:addTP(value)
        self.tp = math.min(3000, self.tp + value)
    end

    function actor:getMP()
        return self.mp
    end

    function actor:delMP(value)
        self.mp = self.mp - value
    end

    function actor:getLocalVar(key)
        return self.localVars[key] or 0
    end

    function actor:setLocalVar(key, value)
        self.localVars[key] = value
    end

    function actor:addRecast(id, group, duration)
        self.recasts[group] = duration
    end

    function actor:resetRecast(id, group)
        self.recasts[group] = 0
    end

    function actor:getBaseDelay()
        return 240
    end

    function actor:getWeaponDmg()
        return 100
    end

    function actor:getMerit(key)
        return self.merits[key] or 0
    end

    function actor:getJobPointLevel()
        return 0
    end

    function actor:getMaster()
        return self.master
    end

    function actor:handleSevereDamage(damage)
        return damage
    end

    function actor:handleAfflatusMiseryDamage()
    end

    function actor:getHP()
        return self.hp
    end

    function actor:getMaxHP()
        return 10000
    end

    function actor:addHP(amount)
        self.hp = self.hp + amount
    end

    function actor:wakeUp()
        self.effects[xi.effect.SLEEP_I] = nil
    end

    function actor:checkLiementAbsorb()
        return self.liement or 1
    end

    return actor
end

local function skill(identifier)
    return {
        id = identifier, tp = 0, msg = xi.msg.basic.USES_JA_TAKE_DAMAGE,
        getID = function(self)
            return self.id
        end,

        getTP = function(self)
            return self.tp
        end,

        setMsg = function(self, value)
            self.msg = value
        end,

        getMsg = function(self)
            return self.msg
        end,

        getPrimaryTargetID = function()
            return 1
        end,

        isAoE = function()
            return false
        end,

        isConal = function()
            return false
        end,

        setAttackType = function()
        end,

        setCritical = function()
        end,
    }
end

local action =
{
    getPrimaryTargetID = function()
        return 1
    end,
}
function GetAbility(identifier)
    return {
        getID = function()
            return identifier
        end,

        getAddType = function()
            return 0
        end,

        getRecastID = function()
            return 173
        end,
    }
end

local function startPact(pet, pact)
    -- Match the traced CPetSkillState contract, using the flags after the real SQL.
    if bit.band(petFlags[pact.id], 4) == 0 then
        pact.tp = pet.tp
        pet.tp = 0
    end
end

local function setup(name, tp)
    local pet, target, master = entity(), entity(), entity()
    pet.master = master
    master.pet = pet
    target.pc = false
    master.avatar = false
    pet.tp = tp or 0
    master.localVars.bpRecastTime = 60
    local identifier = xi.jobAbility[name:upper()]
    local pact = skill(identifier)
    startPact(pet, pact)
    return pet, target, master, pact
end

local function use(name, pet, target, master, pact)
    return xi.actions.abilities.pets[name].onPetAbility(target, pet, pact, master, action)
end

local function fixedPhysical(hits, damage)
    xi.summon.avatarPhysicalMove = function()
        return { damage = damage, hitslanded = hits }
    end
end

-- Every legacy level-75 handler must apply mitigation, not merely a representative move.
for _, name in ipairs({ 'axe_kick', 'barracuda_dive', 'camisado', 'chaotic_strike', 'claw', 'crescent_fang', 'double_punch', 'double_slap', 'eclipse_bite', 'megalith_throw', 'moonlit_charge', 'mountain_buster', 'poison_nails', 'predator_claws', 'punch', 'regal_scratch', 'rock_buster', 'rock_throw', 'roundhouse', 'rush', 'shock_strike', 'spinning_dive', 'tail_whip', 'welt' }) do
    fixedPhysical(1, 100)
    local pet, target, master, pact = setup(name, 3000)
    target.mods[xi.mod.DMGPHYS] = -5000
    assert(use(name, pet, target, master, pact) == 50, name)
    assert(target.damage == 50, name)
    assert(pact.tp == 3000, name)
    assert(pet.tp == ((name == 'welt' or name == 'roundhouse') and 100 or 0), name)
end

passed('All 24 non-hybrid physical handlers apply PDT and consume the original TP.')

for _, name in ipairs({ 'welt', 'roundhouse' }) do
    for _, blocked in ipairs({ false, true }) do
        local avatar, enemy, owner, skillObject = setup(name, 3000)
        avatar.tp = 23
        enemy.mods[xi.mod.UTSUSEMI] = blocked and 1 or 0
        use(name, avatar, enemy, owner, skillObject)
        assert(avatar.tp == (blocked and 23 or 123))
    end
end

local pet, target, master, pact = setup('poison_nails', 1000)
target.mods[xi.mod.DMG] = -2500
target.mods[xi.mod.PIERCE_SDT] = -5000
target.mods[xi.mod.PHALANX] = 2
target.mods[xi.mod.STONESKIN] = 5
pet.mods[xi.mod.BP_DAMAGE] = 100
assert(use('poison_nails', pet, target, master, pact) == 67)
assert(target.mods[xi.mod.STONESKIN] == 0)
passed('Physical type resistance, general DT, BP damage, Phalanx and Stoneskin are applied once.')

local effectMoves = { poison_nails = xi.effect.POISON, tail_whip = xi.effect.WEIGHT, moonlit_charge = xi.effect.BLINDNESS, crescent_fang = xi.effect.PARALYSIS, shock_strike = xi.effect.STUN, chaotic_strike = xi.effect.STUN }
for name, effect in pairs(effectMoves) do
    for _, outcome in ipairs({ 'hit', 'miss', 'shadow', 'invincible', 'stoneskin', 'dodge' }) do
        pet, target, master, pact = setup(name, 1500)
        fixedPhysical(outcome == 'miss' and 0 or 1, outcome == 'miss' and 0 or 100)
        if outcome == 'shadow' then
            target.mods[xi.mod.UTSUSEMI] = 1
        end

        if outcome == 'invincible' then
            target.effects[xi.effect.INVINCIBLE] = {}
        end

        if outcome == 'stoneskin' then
            target.mods[xi.mod.STONESKIN] = 1000
        end

        if outcome == 'dodge' then
            target.effects[xi.effect.PERFECT_DODGE] = {}
        end

        local result = use(name, pet, target, master, pact)
        assert(target:hasStatusEffect(effect) == (outcome == 'hit'), name .. ':' .. outcome)
        if outcome == 'shadow' then
            assert(result == 1 and target.damageCalls == 0 and target.damage == 0)
            assert(pact.msg == xi.msg.basic.SHADOW_ABSORB)
        end
    end
end

passed('Six added effects: successful hits work; misses, shadows and zero-damage defenses do not debuff.')

fixedPhysical(1, 100)
pet, target, master, pact = setup('tail_whip')
target.resist = 0.125
use('tail_whip', pet, target, master, pact)
assert(not target:hasStatusEffect(xi.effect.WEIGHT))
target.resist = 0.5
use('tail_whip', pet, target, master, pact)
assert(target.effects[xi.effect.WEIGHT].duration == 60)

fixedPhysical(5, 500)
pet, target, master, pact = setup('rush')
target.mods[xi.mod.UTSUSEMI] = 5
assert(use('rush', pet, target, master, pact) == 5)
assert(target.damage == 0 and target.damageCalls == 0)
fixedPhysical(3, 300)
pet, target, master, pact = setup('predator_claws')
target.mods[xi.mod.UTSUSEMI] = 1
assert(use('predator_claws', pet, target, master, pact) == 200)
assert(target.damage == 200)
passed('Full and partial multi-hit shadow absorption preserve packet counts without chip damage.')

for _, name in ipairs({ 'burning_strike', 'flaming_crush' }) do
    fixedPhysical(1, 100)
    pet, target, master, pact = setup(name, 3000)
    target.mods[xi.mod.UTSUSEMI] = 1
    pet.stats[xi.mod.INT] = 120
    assert(use(name, pet, target, master, pact) == 1)
    assert(target.damage == 0 and target.damageCalls == 0)
    pet, target, master, pact = setup(name)
    target.mods[xi.mod.DMGPHYS] = -5000
    target.mods[xi.mod.UDMGMAGIC] = -10000
    assert(use(name, pet, target, master, pact) == 50)
end

passed('Both Ifrit hybrids respect blocked physical hits and magical mitigation.')

-- Exercise the original physical formula too, not only the fixed-damage fixture.
xi.summon.avatarPhysicalMove = playerPhysical
pet, target, master, pact = setup('punch')
local unmitigated = use('punch', pet, target, master, pact)
pet, target, master, pact = setup('punch')
target.mods[xi.mod.DMGPHYS] = -5000
assert(use('punch', pet, target, master, pact) == math.floor(unmitigated / 2))

for _, storedTP in ipairs({ 0, 750, 1500, 3000 }) do
    pet, target, master, pact = setup('punch', storedTP)
    pet.tp = 23
    local baseline = realPhysical(pet, target, pact, 1, 1, 3.5, 0, xi.mobskills.physicalTpBonus.NO_EFFECT, 1, 2, 3)
    local scaled = playerPhysical(pet, target, pact, 1, 1, 3.5, 0, xi.mobskills.physicalTpBonus.DMG_VARIES, 1, 2, 3)
    assert(scaled.damage == baseline.damage * (1 + storedTP / 1500))
    assert(pet.tp == 23)
end

passed('TP-dependent physical formulas read the saved TP with classic interpolation.')

local function magicalDamage(name, tp, rank, merit)
    local avatar, enemy, owner, skillObject = setup(name, tp)
    if merit then
        owner.merits[merit] = rank * 400
    end

    local damage = use(name, avatar, enemy, owner, skillObject)
    assert(avatar.tp == 0)
    return damage
end

for _, entry in ipairs({ { 'meteor_strike', xi.merit.METEOR_STRIKE }, { 'heavenly_strike', xi.merit.HEAVENLY_STRIKE }, { 'wind_blade', xi.merit.WIND_BLADE }, { 'geocrush', xi.merit.GEOCRUSH }, { 'thunderstorm', xi.merit.THUNDERSTORM }, { 'grand_fall', xi.merit.GRANDFALL } }) do
    local previous = 0
    for rank = 1, 5 do
        local damage = magicalDamage(entry[1], 0, rank, entry[2])
        assert(damage > previous, entry[1] .. ':' .. rank)
        previous = damage
    end

    assert(magicalDamage(entry[1], 0, 1, entry[2]) < magicalDamage(entry[1], 1500, 1, entry[2]))
    assert(magicalDamage(entry[1], 1500, 1, entry[2]) < magicalDamage(entry[1], 3000, 1, entry[2]))
    assert(magicalDamage(entry[1], 3000, 1, entry[2]) == magicalDamage(entry[1], 3000, 5, entry[2]))
end

passed('All six merit pacts scale at every rank and at 0/1500/3000 TP; the 3000 cap holds.')

pet, target, master, pact = setup('meteorite', 3000)
assert(use('meteorite', pet, target, master, pact) == 650)
assert(target.damage == 650 and pet.tp == 0)
for _, defense in ipairs({ 'mdt', 'shield', 'stoneskin', 'shadow', 'nullify', 'absorb', 'mab', 'bp', 'weather', 'resist' }) do
    pet, target, master, pact = setup('meteorite', 3000)
    if defense == 'mdt' then
        target.mods[xi.mod.DMGMAGIC] = -5000
    end

    if defense == 'shield' then
        target.mods[xi.mod.UDMGMAGIC] = -10000
    end

    if defense == 'stoneskin' then
        target.mods[xi.mod.STONESKIN] = 1000
    end

    if defense == 'shadow' then
        target.mods[xi.mod.UTSUSEMI] = 1
    end

    if defense == 'nullify' then
        target.mods[xi.mod.NULL_MAGICAL_DAMAGE] = 100
    end

    if defense == 'absorb' then
        target.mods[xi.mod.MAGIC_ABSORB] = 100
    end

    if defense == 'mab' then
        pet.mods[xi.mod.MATT] = 100
    end

    if defense == 'bp' then
        pet.mods[xi.mod.BP_DAMAGE] = 95
        pet.spiritTaker = 5
    end

    if defense == 'weather' then
        pet.weather = 1.1
    end

    if defense == 'resist' then
        target.resist = 0.5
    end

    local expected = { mdt = 325, shield = 0, stoneskin = 0, shadow = 0, nullify = 0, absorb = -650, mab = 1300, bp = 1300, weather = 715, resist = 325 }
    use('meteorite', pet, target, master, pact)
    assert(target.damage == expected[defense], defense .. ':' .. target.damage)
end

passed('Meteorite uses real mitigation, nullification/absorption, MAB, BP bonuses, weather and resistance.')

for _, burst in ipairs({ 0, 1 }) do
    pet, target, master, pact = setup('fire_iv', 1500)
    target.burst = burst
    use('fire_iv', pet, target, master, pact)
    assert(pact.msg == (burst == 0 and xi.msg.basic.USES_JA_TAKE_DAMAGE or xi.msg.basic.JA_MAGIC_BURST))
end

passed('Fire IV distinguishes normal hits from real bursts using the actual burst helpers.')

pet, target, master, pact = setup('thunderspark', 3000)
pet.tp = 23  -- TP earned after the skill state already consumed the original TP.
local firstDamage = use('thunderspark', pet, target, master, pact)
local second = entity()
second.id = 2
second.pc = false
assert(use('thunderspark', pet, second, master, pact) == firstDamage)
assert(pet.tp == 23 and pact.tp == 3000)
assert(master.mp == 5000 - 38)

for _, name in ipairs({ 'sonic_buffet', 'tornado_ii' }) do
    pet, target, master, pact = setup(name, 3000)
    pet.tp = 23
    assert(use(name, pet, target, master, pact) > 0)
    assert(pet.tp == 23 and pact.tp == 3000)
    assert(target.dispelled == (name == 'sonic_buffet' and true or nil))
end

pet, target, master, pact = setup('spring_water', 3000)
target.hp = 0
second = entity()
second.hp = 0
second.id = 2
assert(use('spring_water', pet, target, master, pact) == 816)
assert(use('spring_water', pet, second, master, pact) == 816)
assert(master.mp == 5000 - 99 and pet.tp == 0)
pet, target, master, pact = setup('healing_ruby', 3000)
target.hp = 0
assert(use('healing_ruby', pet, target, master, pact) == 1335.25)
assert(pet.tp == 0)
passed('Area damage/healing reuse one TP snapshot; MP is charged once; later TP is not consumed again.')

for _, identifier in ipairs({ xi.magic.spell.ALEXANDER, xi.magic.spell.ATOMOS }) do
    local caster = entity()
    local spell =
    {
        getID = function()
            return identifier
        end,
    }
    assert(xi.pet.onCastingCheck(caster, caster, spell) == xi.msg.basic.MAGIC_CANNOT_CAST)
end

for _, identifier in ipairs({ xi.petId.ALEXANDER, xi.petId.ATOMOS }) do
    local caster = entity()
    function caster:spawnPet()
        error('disabled player summon reached spawnPet')
    end

    xi.pet.spawnPet(caster, identifier)
end

for _, name in ipairs({ 'perfect_defense', 'deconstruction', 'chronoshift' }) do
    pet, target, master, pact = setup(name)
    local ability = xi.actions.abilities.pets[name]
    assert(ability.onAbilityCheck(master, target, {}) == xi.msg.basic.UNABLE_TO_USE_JA2)
    assert(ability.onPetAbility(target, pet, pact, master, action) == 0)
    assert(next(target.effects) == nil and master.mp == 5000)
end

passed('Alexander/Atomos casting, spawn helpers and special actions are blocked for players.')

for _, entry in ipairs({ { xi.magic.spell.HASTE, 48 }, { xi.magic.spell.PROTECT_IV, 63 }, { xi.magic.spell.SHELL, 10 } }) do
    for _, offset in ipairs({ -1, 0 }) do
        local spirit = entity()
        spirit.level = entry[2] + offset
        local canCast = false
        for _, buff in ipairs(xi.pets.avatar.getLightSpiritBuffs(spirit)) do
            if buff.spell == entry[1] then
                canCast = true
            end
        end

        assert(canCast == (offset == 0))
    end
end

passed('Light Spirit selects Shell, Haste and Protect IV at 10/48/63, not the preceding levels.')

assert(xi.actions.abilities.apogee.onAbilityCheck(entity(), entity(), {}) == xi.msg.basic.UNABLE_TO_USE_JA2)
local owner = entity()
xi.actions.abilities.apogee.onUseAbility(owner, owner, {})
assert(not owner:hasStatusEffect(xi.effect.APOGEE))
passed('Apogee cannot be used or grant its status.')

for _, baseCost in ipairs({ 1, 2, 3, 4, 5 }) do
    for identifier = xi.petId.FIRE_SPIRIT, xi.petId.DARK_SPIRIT do
        pet, target, master, pact = setup('punch')
        pet.petId = identifier
        master.mods[xi.mod.AVATAR_PERPETUATION] = baseCost
        xi.pets.avatar.onMobSpawn(pet)
        assert(master.mods[xi.mod.AVATAR_PERPETUATION] == math.min(baseCost, 2))
    end
end

pet, target, master, pact = setup('punch')
master.mods[xi.mod.AVATAR_PERPETUATION] = 9
xi.pets.avatar.onMobSpawn(pet)
assert(master.mods[xi.mod.AVATAR_PERPETUATION] == 9)
passed('Spirit upkeep is capped at 2 MP per tick without increasing low-level costs or changing avatars.')

pet, target, master, pact = setup('punch')
pet.petId = xi.petId.DIABOLOS
xi.avatarsFavor.applyAvatarsFavorAuraToPet(master, {})
assert(pet.effects[xi.effect.DIABOLOSS_FAVOR].subPower == 3)
local favor = { mods = {} }
function favor:addMod(key, amount)
    self.mods[key] = (self.mods[key] or 0) + amount
end

xi['effects'].diaboloss_favor.onEffectGain(target, favor)
assert(favor.mods[xi.mod.CRITHITRATE] == 3 and favor.mods[xi.mod.REFRESH] == nil)
passed('Diabolos Favor grants a fixed 3 critical-rate points and no Refresh modifier.')

pet, target, master, pact = setup('spring_water')
target.effects[xi.effect.PLAGUE] = {}
use('spring_water', pet, target, master, pact)
assert(not target:hasStatusEffect(xi.effect.PLAGUE))
assert(target.effects[xi.effect.REFRESH].power == 2)
assert(target.effects[xi.effect.REFRESH].duration == 180)
passed('Spring Water removes Plague and grants Refresh 2 for 180 seconds.')

for _, entry in ipairs({ { 'inferno_howl', xi.effect.ENFIRE, 15, 72, 180 }, { 'earthen_armor', xi.effect.EARTHEN_ARMOR, 75, 156, 60 } }) do
    pet, target, master, pact = setup(entry[1], 1500)
    second = entity()
    second.id = 2
    assert(use(entry[1], pet, target, master, pact) == entry[2])
    assert(pact.msg == xi.msg.basic.SKILL_GAIN_EFFECT_2)
    assert(use(entry[1], pet, second, master, pact) == entry[2])
    assert(pact.msg == xi.msg.basic.JA_GAIN_EFFECT)
    for _, member in ipairs({ target, second }) do
        assert(member.effects[entry[2]].power == entry[3])
        assert(member.effects[entry[2]].duration == entry[5])
    end

    if entry[1] == 'earthen_armor' then
        assert(target.effects[entry[2]].subPower == 50)
    end

    assert(master.mp == 5000 - entry[4] and pet.tp == 0)
end

pet, target, master, pact = setup('crystal_blessing', 3000)
second = entity()
second.id = 2
second.tp = 2950
assert(use('crystal_blessing', pet, target, master, pact) == 200)
assert(use('crystal_blessing', pet, second, master, pact) == 3000)
assert(target.tp == 200 and second.tp == 3000)
assert(master.mp == 4799 and pet.tp == 0)
assert(pact.msg == xi.msg.basic.TP_INCREASE)
passed('All three new wards execute for multiple targets, consume TP/MP once, and preserve TP caps.')
