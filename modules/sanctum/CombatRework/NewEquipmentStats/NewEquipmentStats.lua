-----------------------------------
-- Sanctum custom equipment stats
-----------------------------------
require('modules/module_utils')
require('scripts/globals/additional_effects')
require('scripts/globals/combat/action_additional_effect_damage')
require('scripts/globals/combat/action_additional_effect_status')
require('scripts/globals/combat/physical_utilities')
-----------------------------------

local m = Module:new('NewEquipmentStats')

xi.newEquipmentStats = xi.newEquipmentStats or {}

local tacticsTpPerPoint = 5

xi.newEquipmentStats.getProcChance = function(actor, baseChance)
    local chance = baseChance or 0

    -- No chance set on the gear means it never procs. Leave it that way.
    if chance <= 0 then
        return chance
    end

    local bonus = actor and actor:getMod(xi.mod.PROC_RATE) or 0

    return utils.clamp(chance + math.max(0, bonus), 0, 100)
end

local function withProcRate(actor, fedData)
    if type(fedData) ~= 'table' then
        return fedData
    end

    local adjustedData = {}
    for key, value in pairs(fedData) do
        adjustedData[key] = value
    end

    -- The executors treat a missing chance as 100. Match that, or we drop
    -- everyone who leaves it out down to the bonus alone.
    adjustedData.chance = xi.newEquipmentStats.getProcChance(actor, fedData.chance or 100)

    return adjustedData
end

m:addOverride('xi.combat.physical.isBlocked', function(defender, attacker)
    local blocked = super(defender, attacker)

    if blocked and defender:isPC() then
        local tactics = math.max(0, defender:getMod(xi.mod.TACTICS))
        if tactics > 0 then
            defender:addTP(tactics * tacticsTpPerPoint)
        end
    end

    return blocked
end)

m:addOverride('xi.combat.physical.isGuarded', function(defender, attacker)
    local guarded = super(defender, attacker)

    if guarded and defender:isPC() then
        local tactics = math.max(0, defender:getMod(xi.mod.TACTICS))
        if tactics > 0 then
            defender:addTP(tactics * tacticsTpPerPoint)
        end
    end

    return guarded
end)

local function addProcExecutorOverride(name)
    m:addOverride(name, function(actor, target, fedData)
        return super(actor, target, withProcRate(actor, fedData))
    end)
end

addProcExecutorOverride('xi.combat.action.executeAddEffectDamage')
addProcExecutorOverride('xi.combat.action.executeAddEffectEnhancement')
addProcExecutorOverride('xi.combat.action.executeAddEffectEnfeeblement')
addProcExecutorOverride('xi.combat.action.executeAddEffectDispel')

-- Declarative item_mods additional effects read their proc chance inside this
-- function, so this override mirrors the short dispatcher and adjusts the roll.
-- Straight copy of additional_effects.lua with only the chance line changed.
-- super() is no use here, the chance is read off the item inside. Re-copy if
-- that function ever changes.
m:addOverride('xi.additionalEffect.attack', function(attacker, defender, baseAttackDamage, item)
    local params     = {}
    params.lvCorrect = item:getMod(xi.mod.ITEM_ADDEFFECT_LVADJUST)
    params.dStat     = item:getMod(xi.mod.ITEM_ADDEFFECT_DSTAT)
    params.addType   = item:getMod(xi.mod.ITEM_ADDEFFECT_TYPE)
    params.subEffect = item:getMod(xi.mod.ITEM_SUBEFFECT)
    params.damage    = item:getMod(xi.mod.ITEM_ADDEFFECT_DMG)
    params.chance    = xi.newEquipmentStats.getProcChance(attacker, item:getMod(xi.mod.ITEM_ADDEFFECT_CHANCE))
    params.element   = item:getMod(xi.mod.ITEM_ADDEFFECT_ELEMENT)
    params.addStatus = item:getMod(xi.mod.ITEM_ADDEFFECT_STATUS)
    params.power     = item:getMod(xi.mod.ITEM_ADDEFFECT_POWER)
    params.duration  = item:getMod(xi.mod.ITEM_ADDEFFECT_DURATION)

    params.baseAttackDamage = baseAttackDamage

    if item:getReqLvl() > attacker:getMainLvl() then
        return 0, 0, 0
    end

    if math.randomInt(1, 100) > params.chance then
        return 0, 0, 0
    end

    if params.dStat > 0 then
        params.damage = xi.additionalEffect.dStatBonus(attacker, defender, params.dStat, params.damage)
    end

    if xi.additionalEffect.procFunctions[params.addType] then
        return xi.additionalEffect.procFunctions[params.addType](attacker, defender, item, params)
    end

    print('ERR: xi.additionalEffect.attack passed invalid/unimplemented addType of ' .. tostring(params.addType))

    return 0, 0, 0
end)

-- Excalibur is the only current scripted weapon family that rolls directly
-- instead of using one of the common additional-effect executors above.
-- Straight copy of the excalibur_*.lua body with only the roll changed. All ten
-- share the same one.
local function excaliburAdditionalEffect(attacker, defender, baseAttackDamage, item)
    if math.randomInt(1, 100) <= xi.newEquipmentStats.getProcChance(attacker, 7) then
        local params = {}

        params.subEffect  = xi.subEffect.LIGHT_DAMAGE
        params.damageType = xi.damageType.SLASHING
        params.isPhysical = true
        params.damage     = math.floor(attacker:getHP() * 0.25)

        return xi.additionalEffect.procFunctions[xi.additionalEffect.procType.PHYS_DAMAGE](attacker, defender, item, params)
    end

    return 0, 0, 0
end

local excaliburItems =
{
    'excalibur_75',
    'excalibur_80',
    'excalibur_85',
    'excalibur_90',
    'excalibur_95',
    'excalibur_99',
    'excalibur_99_ii',
    'excalibur_119',
    'excalibur_119_ii',
    'excalibur_119_iii',
}

for _, itemName in ipairs(excaliburItems) do
    m:addOverride('xi.items.' .. itemName .. '.onItemAdditionalEffect', function(attacker, defender, baseAttackDamage, item)
        return excaliburAdditionalEffect(attacker, defender, baseAttackDamage, item)
    end)
end

return m
