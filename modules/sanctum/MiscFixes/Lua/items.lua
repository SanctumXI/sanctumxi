-----------------------------------
-- Targeted item behavior fixes.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_miscfixes_items')

local talismanCapeId = 15485

local function grantFlee(player)
    player:delStatusEffect(xi.effect.FLEE)
    player:addStatusEffect(xi.effect.FLEE, { power = 10000, duration = 30, origin = player })
end

local function copRingOnDrop(target, item, recycleBin)
    if recycleBin then
        return
    end

    local missionArea = xi.mission.log_id.COP
    local missionId   = xi.mission.id.cop.DAWN
    local ringDrops   = xi.mission.getVar(target, missionArea, missionId, 'ringDrops')
    local expiry      = NextJstDay()

    if ringDrops > 0 then
        expiry = GetSystemTime() + 7 * 24 * 60 * 60
    end

    xi.mission.setVar(target, missionArea, missionId, 'Timer', 1, expiry)
    xi.mission.setVar(target, missionArea, missionId, 'ringDrops', ringDrops + 1)
end

for _, itemName in ipairs({ 'rajas_ring', 'sattva_ring', 'tamas_ring' }) do
    m:addOverride('xi.items.' .. itemName .. '.onItemDrop', function(target, item, recycleBin)
        copRingOnDrop(target, item, recycleBin)
    end)
end

m:addOverride('xi.items.mistmelt.onItemCheck', function(target, item, param, player)
    if target:getName() ~= 'Ouryu' then
        return xi.msg.basic.ITEM_UNABLE_TO_USE
    elseif target:checkDistance(player) > 10 then
        return xi.msg.basic.TOO_FAR_AWAY
    end

    return 0
end)

xi.module.ensureTable('xi.items.talisman_cape')
local talismanCape = xi['items']['talisman_cape']

talismanCape.onItemCheck = function(target, item, param, user)
    if target:getStatusEffectBySource(xi.effect.ENCHANTMENT, xi.effectSourceType.EQUIPPED_ITEM, talismanCapeId) then
        target:delStatusEffect(xi.effect.ENCHANTMENT, nil, xi.effectSourceType.EQUIPPED_ITEM, talismanCapeId)
    end

    return 0
end

talismanCape.onItemUse = function(target, user)
    if target:hasEquipped(talismanCapeId) then
        target:addStatusEffect(xi.effect.ENCHANTMENT, { duration = 1800, origin = user, sourceType = xi.effectSourceType.EQUIPPED_ITEM, sourceTypeParam = talismanCapeId })
    end
end

talismanCape.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.MP, 12)
    effect:addMod(xi.mod.ENMITY, -2)
end

talismanCape.onEffectLose = function(target, effect)
end

xi.module.ensureTable('xi.items.chicken_knife')
local chickenKnife = xi['items']['chicken_knife']

chickenKnife.onItemEquip = function(player, item)
    player:addListener('TAKE_DAMAGE', 'CHICKEN_KNIFE_ATTACK', function(playerArg, damage, attacker, attackType)
        if
            damage > 0 and
            attacker and
            (attacker:isMob() or attacker:isPet()) and
            (attackType == xi.attackType.PHYSICAL or attackType == xi.attackType.RANGED)
        then
            local dLvl = attacker:getMainLvl() - playerArg:getMainLvl()
            local chance = utils.clamp(100 * 0.0096906 * math.exp(0.176839 * dLvl), 1.33, 33)

            if dLvl >= 1 and math.randomInt(1, 100) <= chance then
                grantFlee(playerArg)
            end
        end
    end)
end

chickenKnife.onItemUnequip = function(player, item)
    player:removeListener('CHICKEN_KNIFE_ATTACK')
end

xi.module.ensureTable('xi.items.caitiffs_socks')
local caitiffsSocks = xi['items']['caitiffs_socks']

caitiffsSocks.onItemEquip = function(player, item)
    player:addListener('TAKE_DAMAGE', 'CAITIFFS_SOCKS_HIT', function(playerArg, _, attacker, attackType)
        if
            attacker and
            (attacker:isMob() or attacker:isPet()) and
            (attackType == xi.attackType.PHYSICAL or attackType == xi.attackType.RANGED) and
            playerArg:getHPP() <= 25 and
            playerArg:getTP() < 1000 and
            math.randomInt(1, 100) <= 10
        then
            grantFlee(playerArg)
        end
    end)
end

caitiffsSocks.onItemUnequip = function(player, item)
    player:removeListener('CAITIFFS_SOCKS_HIT')
end

return m
