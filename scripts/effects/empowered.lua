-----------------------------------
-- xi.effect.EMPOWERED
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    if xi.wsEffect.has(target, xi.wsEffect.BLACK_HALO_MP) then
        target:addListener('MELEE_SWING_HIT', 'BLACK_HALO_MP', function(player)
            local mpRestored = player:addMP(player:getCharVar(xi.wsEffect.charVars.POWER))

            if mpRestored > 0 then
                player:timer(500, function(playerArg)
                    playerArg:messageBasic(xi.msg.basic.RECOVERS_MP, 0, mpRestored)
                end)
            end
        end)
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
    end
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('BLACK_HALO_MP')
    target:removeListener('DANCING_EDGE_SA')

    if target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.DANCING_EDGE_SA then
        target:delMod(xi.mod.AUGMENTS_SA, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    elseif target:getCharVar(xi.wsEffect.charVars.EFFECT) == xi.wsEffect.TACHI_KASHA_TP then
        target:delMod(xi.mod.WS_NO_DEPLETE, target:getCharVar(xi.wsEffect.charVars.POWER))
        target:setCharVar(xi.wsEffect.charVars.EFFECT, xi.wsEffect.NONE)
        target:setCharVar(xi.wsEffect.charVars.POWER, 0)
        target:setCharVar(xi.wsEffect.charVars.EXPIRE, 0)
    end
end

return effectObject
