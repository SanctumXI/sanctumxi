-----------------------------------
-- xi.effect.EMPOWERED
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addListener('EQUIP_CHANGE', xi.wsEffect.weaponChangeListener, function(player, equipSlot)
        if
            equipSlot == xi.slot.MAIN and
            xi.wsEffect.peek(player) ~= xi.wsEffect.NONE
        then
            xi.wsEffect.clear(player)
            xi.wsEffect.message(player, 'Your power fades')
        end
    end)

    if xi.wsEffect.has(target, xi.wsEffect.BLACK_HALO_MP) then
        target:addListener('MELEE_SWING_HIT', 'BLACK_HALO_MP', function(player)
            local mpRestored = player:addMP(player:getCharVar(xi.wsEffect.charVars.POWER))

            if mpRestored > 0 then
                player:timer(500, function(playerArg)
                    playerArg:messageBasic(xi.msg.basic.RECOVERS_MP, 0, mpRestored)
                end)
            end
        end)
    elseif xi.wsEffect.has(target, xi.wsEffect.BLACK_HALO_CRIT) then
        target:addMod(xi.mod.CRIT_DMG_INCREASE, target:getCharVar(xi.wsEffect.charVars.POWER))
    elseif xi.wsEffect.has(target, xi.wsEffect.DANCING_EDGE_SA) then
        target:addMod(xi.mod.AUGMENTS_SA, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:addListener('MELEE_SWING_HIT', 'DANCING_EDGE_SA', function(player)
            if player:hasStatusEffect(xi.effect.SNEAK_ATTACK) then
                player:timer(0, function(playerArg)
                    if xi.wsEffect.has(playerArg, xi.wsEffect.DANCING_EDGE_SA) then
                        xi.wsEffect.consume(playerArg)
                        xi.wsEffect.message(playerArg, 'Dancing Edge empowered Sneak Attack!')
                    end
                end)
            end
        end)
    elseif xi.wsEffect.has(target, xi.wsEffect.TACHI_KASHA_TP) then
        target:addMod(xi.mod.WS_NO_DEPLETE, target:getCharVar(xi.wsEffect.charVars.POWER))
    elseif xi.wsEffect.has(target, xi.wsEffect.SICKLE_MOON_DRAIN) then
        target:addListener('MELEE_SWING_HIT', 'SICKLE_MOON_DRAIN', function(player)
            local hpRestored = player:addHP(math.max(1, math.floor(player:getMaxHP() / 100)))

            if hpRestored > 0 then
                player:timer(500, function(playerArg)
                    playerArg:messageBasic(xi.msg.basic.RECOVERS_HP, 0, hpRestored)
                end)
            end
        end)
    elseif xi.wsEffect.has(target, xi.wsEffect.GROUND_STRIKE_DA) then
        local function consumeGroundStrikeDoubleAttack(player)
            player:timer(0, function(playerArg)
                if xi.wsEffect.has(playerArg, xi.wsEffect.GROUND_STRIKE_DA) then
                    xi.wsEffect.consume(playerArg)
                    xi.wsEffect.message(playerArg, 'Ground Strike empowered your attack to strike twice!')
                end
            end)
        end

        target:addMod(xi.mod.DOUBLE_ATTACK, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:addListener('MELEE_SWING_HIT', 'GROUND_STRIKE_DA_HIT', consumeGroundStrikeDoubleAttack)
        target:addListener('MELEE_SWING_MISS', 'GROUND_STRIKE_DA_MISS', consumeGroundStrikeDoubleAttack)
    elseif xi.wsEffect.has(target, xi.wsEffect.DETONATOR_QUICK_DRAW) then
        local quickDrawAbilities =
        {
            [xi.jobAbility.FIRE_SHOT]    = true,
            [xi.jobAbility.ICE_SHOT]     = true,
            [xi.jobAbility.WIND_SHOT]    = true,
            [xi.jobAbility.EARTH_SHOT]   = true,
            [xi.jobAbility.THUNDER_SHOT] = true,
            [xi.jobAbility.WATER_SHOT]   = true,
            [xi.jobAbility.LIGHT_SHOT]   = true,
            [xi.jobAbility.DARK_SHOT]    = true,
        }

        target:addListener('ABILITY_USE', 'DETONATOR_QUICK_DRAW', function(player, abilityTarget, ability)
            if ability and quickDrawAbilities[ability:getID()] then
                player:timer(0, function(playerArg)
                    if xi.wsEffect.has(playerArg, xi.wsEffect.DETONATOR_QUICK_DRAW) then
                        xi.wsEffect.consume(playerArg)
                        xi.wsEffect.message(playerArg, 'Detonator empowered your Quick Draw!')
                    end
                end)
            end
        end)
    elseif xi.wsEffect.has(target, xi.wsEffect.DETONATOR_BARRAGE) then
        target:addListener('RANGE_START', 'DETONATOR_BARRAGE_START', function(player)
            if player:hasStatusEffect(xi.effect.BARRAGE) then
                player:setLocalVar('DetonatorBarrageActive', 1)
            end
        end)

        target:addListener('RANGE_STATE_EXIT', 'DETONATOR_BARRAGE_EXIT', function(player, rangedTarget)
            if player:getLocalVar('DetonatorBarrageActive') == 1 then
                player:setLocalVar('DetonatorBarrageActive', 0)

                if rangedTarget and xi.wsEffect.has(player, xi.wsEffect.DETONATOR_BARRAGE) then
                    xi.wsEffect.consume(player)
                    xi.wsEffect.message(player, 'Detonator added one shot to your Barrage!')
                end
            end
        end)
    elseif xi.wsEffect.has(target, xi.wsEffect.SPIRAL_HELL_ABSORB) then
        target:addListener('MAGIC_USE', 'SPIRAL_HELL_ABSORB', function(player, spellTarget, spell)
            local family = spell and spell:getSpellFamily() or xi.magic.spellFamily.NONE

            if
                family == xi.magic.spellFamily.ABSORB or
                family == xi.magic.spellFamily.DRAIN or
                family == xi.magic.spellFamily.ASPIR
            then
                player:timer(0, function(playerArg)
                    if xi.wsEffect.has(playerArg, xi.wsEffect.SPIRAL_HELL_ABSORB) then
                        xi.wsEffect.consume(playerArg)
                        xi.wsEffect.message(playerArg, 'Spiral Hell empowered your spell!')
                    end
                end)
            end
        end)
    elseif xi.wsEffect.has(target, xi.wsEffect.SPIRAL_HELL_CRIT) then
        local function countSpiralHellAttack(player)
            local attackCount = player:getLocalVar('SpiralHellAttackCount') + 1

            if attackCount >= 5 then
                player:delMod(xi.mod.SPIRAL_HELL_FORCE_CRIT, 1)
                player:setLocalVar('SpiralHellAttackCount', 0)
            else
                player:setLocalVar('SpiralHellAttackCount', attackCount)

                if attackCount == 4 then
                    player:addMod(xi.mod.SPIRAL_HELL_FORCE_CRIT, 1)
                end
            end
        end

        target:addMod(xi.mod.CRIT_DMG_INCREASE, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:setLocalVar('SpiralHellAttackCount', 0)
        target:addListener('MELEE_SWING_HIT', 'SPIRAL_HELL_CRIT_HIT', countSpiralHellAttack)
        target:addListener('MELEE_SWING_MISS', 'SPIRAL_HELL_CRIT_MISS', countSpiralHellAttack)
    elseif xi.wsEffect.has(target, xi.wsEffect.SAVAGE_BLADE_DAMAGE) then
        target:addMod(xi.mod.SAVAGE_BLADE_ENMITY, 1)
        target:addMod(xi.mod.SAVAGE_BLADE_DAMAGE, target:getCharVar(xi.wsEffect.charVars.POWER))
    end
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('BLACK_HALO_MP')
    target:removeListener('DANCING_EDGE_SA')
    target:removeListener('SICKLE_MOON_DRAIN')
    target:removeListener('GROUND_STRIKE_DA_HIT')
    target:removeListener('GROUND_STRIKE_DA_MISS')
    target:removeListener('DETONATOR_QUICK_DRAW')
    target:removeListener('DETONATOR_BARRAGE_START')
    target:removeListener('DETONATOR_BARRAGE_EXIT')
    target:removeListener('SPIRAL_HELL_ABSORB')
    target:removeListener('SPIRAL_HELL_CRIT_HIT')
    target:removeListener('SPIRAL_HELL_CRIT_MISS')
    target:removeListener(xi.wsEffect.weaponChangeListener)
    target:setLocalVar('DetonatorBarrageActive', 0)
    target:setLocalVar('SpiralHellAttackCount', 0)

    if target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.CUSTOM_MOD then
        xi.wsEffect.clearTrackedMods(target)
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    elseif target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.BLACK_HALO_CRIT then
        target:delMod(xi.mod.CRIT_DMG_INCREASE, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    elseif target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.DANCING_EDGE_SA then
        target:delMod(xi.mod.AUGMENTS_SA, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    elseif target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.TACHI_KASHA_TP then
        target:delMod(xi.mod.WS_NO_DEPLETE, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    elseif target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.GROUND_STRIKE_DA then
        target:delMod(xi.mod.DOUBLE_ATTACK, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    elseif target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.BLADE_TEN_NINJUTSU then
        target:delMod(xi.mod.BLADE_TEN_NINJUTSU, 1)
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    elseif target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.DETONATOR_BARRAGE then
        target:delMod(xi.mod.BARRAGE_COUNT, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    elseif target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.SPIRAL_HELL_CRIT then
        target:delMod(xi.mod.CRIT_DMG_INCREASE, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:delMod(xi.mod.SPIRAL_HELL_FORCE_CRIT, 1)
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    elseif target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.SAVAGE_BLADE_DAMAGE then
        target:delMod(xi.mod.SAVAGE_BLADE_ENMITY, 1)
        target:delMod(xi.mod.SAVAGE_BLADE_DAMAGE, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    end
end

return effectObject
