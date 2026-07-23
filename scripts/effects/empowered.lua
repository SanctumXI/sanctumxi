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
    end
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('BLACK_HALO_MP')
end

return effectObject
