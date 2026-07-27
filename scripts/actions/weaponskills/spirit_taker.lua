-----------------------------------
-- Spirit Taker
-- Staff weapon skill
-- Skill Level: 215
-- Deals Light elemental damage and converts the damage dealt to own MP. Damage varies with TP.
-- It is a magical weapon skill and cannot miss.
-- Element: Light
-- Modifiers: INT:50%  MND:50%
-- 100%TP    200%TP    300%TP
-- 1.00      1.50      2.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

local echoEligibleJobs =
{
    [xi.job.BLM] = true,
    [xi.job.WHM] = true,
    [xi.job.SCH] = true,
    [xi.job.PLD] = true,
}

local directDamageSkills =
{
    [xi.skill.ELEMENTAL_MAGIC] = true,
    [xi.skill.DARK_MAGIC]      = true,
    [xi.skill.DIVINE_MAGIC]    = true,
}

local echoListenerName      = 'SPIRIT_TAKER_ECHO'
local instantListenerName   = 'SPIRIT_TAKER_ECHO_INSTANT'
local echoCastingVar        = 'SpiritTakerEchoCasting'

local function addSpiritTakerEchoListener(player)
    player:removeListener(echoListenerName)

    player:addListener('MAGIC_USE', echoListenerName, function(caster, target, spell, action)
        -- An echoed spell cannot trigger another echo.
        if caster:getLocalVar(echoCastingVar) == 1 then
            caster:setLocalVar(echoCastingVar, 0)
            caster:removeListener(echoListenerName)
            return
        end

        if not xi.wsEffect.has(caster, xi.wsEffect.SPIRIT_TAKER_ECHO) then
            caster:removeListener(echoListenerName)
            return
        end

        if
            target:getAllegiance() == caster:getAllegiance() or
            not directDamageSkills[spell:getSkillType()]
        then
            return
        end

        xi.wsEffect.consume(caster)

        if math.randomInt(1, 100) <= 10 then
            local spellId = spell:getID()

            caster:setLocalVar(echoCastingVar, 1)

            xi.wsEffect.message(caster, 'Spirit Taker echoed your spell!')

            -- Queue the echo after the original spell has fully resolved.
            caster:timer(3000, function(echoCaster)
                if echoCaster:getLocalVar(echoCastingVar) == 1 then
                    -- Only the echoed spell is instant and free; do not affect intervening casts.
                    echoCaster:addMod(xi.mod.QUICK_MAGIC, 100)
                    echoCaster:removeListener(instantListenerName)
                    echoCaster:addListener('MAGIC_START', instantListenerName, function(instantCaster, echoTarget, echoSpell, echoAction)
                        instantCaster:delMod(xi.mod.QUICK_MAGIC, 100)
                        echoSpell:setMPCost(0)
                        instantCaster:removeListener(instantListenerName)
                    end)

                    echoCaster:castSpell(spellId, target)
                end
            end)

            -- Clean up if the echoed cast cannot start (for example, if its recast is unavailable).
            caster:timer(5000, function(echoCaster)
                if echoCaster:getLocalVar(echoCastingVar) == 1 then
                    echoCaster:setLocalVar(echoCastingVar, 0)
                    echoCaster:delMod(xi.mod.QUICK_MAGIC, 100)
                    echoCaster:removeListener(instantListenerName)
                    echoCaster:removeListener(echoListenerName)
                end
            end)
        else
            caster:removeListener(echoListenerName)
        end
    end)
end

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 1
    params.ftpMod = { 1.0, 1.5, 2.0 }
    params.int_wsc = 0.5 params.mnd_wsc = 0.5
    params.ele = xi.element.LIGHT
    params.skill = xi.skill.STAFF
    params.includemab = true

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)
    player:addMP(math.max(0, damage))

    if player:getMainJob() == xi.job.SMN then
        -- 45 seconds at 1000 TP, scaling to 105 seconds at 3000 TP.
        local duration = 45 + math.floor((math.min(tp, 3000) - 1000) / 100) * 3

        xi.wsEffect.set(player, xi.wsEffect.SPIRIT_TAKER_SMN_PET_DAMAGE, 5, duration)
        xi.wsEffect.message(player, 'Empowered: Your avatar\'s Blood Pact damage is increased by 5%.')
    elseif echoEligibleJobs[player:getMainJob()] then
        xi.wsEffect.set(player, xi.wsEffect.SPIRIT_TAKER_ECHO, 1, 60)
        addSpiritTakerEchoListener(player)
        xi.wsEffect.message(player, 'Your next direct-damage spell may echo.')
    end

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
