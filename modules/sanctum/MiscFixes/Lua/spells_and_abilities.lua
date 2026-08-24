-----------------------------------
-- Targeted spell and ability fixes.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('sanctum_miscfixes_spells_and_abilities')

local skulkersCapeId = 13692

local function isBarSpellEffect(effectId)
    return
        (effectId >= xi.effect.BARFIRE and effectId <= xi.effect.BARWATER) or
        effectId == xi.effect.BARAMNESIA or
        (effectId >= xi.effect.BARSLEEP and effectId <= xi.effect.BARVIRUS)
end

-- Bar-element and Bar-status spells use the era duration curve: 150 seconds
-- through 180 skill, scaling to a 240-second cap.
m:addOverride('xi.spells.enhancing.calculateEnhancingDuration', function(caster, target, spell, spellId, spellGroup, spellEffect)
    if not isBarSpellEffect(spellEffect) then
        local duration = super(caster, target, spell, spellId, spellGroup, spellEffect)

        if
            (spellEffect == xi.effect.SNEAK or spellEffect == xi.effect.INVISIBLE) and
            caster:hasEquipped(skulkersCapeId)
        then
            duration = duration * 1.5
        end

        return duration
    end

    local duration = 150

    if
        not caster:isPet() and
        target:hasStatusEffect(xi.effect.EMBOLDEN) and
        spellGroup == xi.magic.spellGroup.WHITE
    then
        duration = duration * (0.5 + target:getMod(xi.mod.EMBOLDEN_DURATION) / 100)
    end

    duration = duration + duration * caster:getMod(xi.mod.ENH_MAGIC_DURATION) / 100

    if caster:getMainJob() == xi.job.RDM then
        duration = duration + caster:getMerit(xi.merit.ENHANCING_MAGIC_DURATION) + caster:getJobPointLevel(xi.jp.ENHANCING_DURATION)
    end

    local skillLevel = caster:getSkillLevel(spell:getSkillType())
    duration = math.min(math.max(duration + 0.8 * (skillLevel - 180), 150), 240)

    if
        caster:hasStatusEffect(xi.effect.COMPOSURE) and
        caster:getID() == target:getID()
    then
        duration = duration * 3
    end

    if
        caster:hasStatusEffect(xi.effect.PERPETUANCE) and
        spellGroup == xi.magic.spellGroup.WHITE
    then
        duration = duration * 2
    end

    return duration
end)

-- ENH_DRAIN_ASPIR is the gear potency modifier used by Drain and Aspir.
m:addOverride('xi.spells.absorb.doDrainingSpell', function(caster, target, spell)
    local gearBonus = caster:getMod(xi.mod.ENH_DRAIN_ASPIR)
    if gearBonus == 0 then
        return super(caster, target, spell)
    end

    caster:addMod(xi.mod.AUGMENTS_ABSORB, gearBonus)
    local damage = super(caster, target, spell)
    caster:delMod(xi.mod.AUGMENTS_ABSORB, gearBonus)

    return damage
end)

-- Earthen Ward must not replace an existing Stoneskin effect.
m:addOverride('xi.actions.abilities.pets.earthen_ward.onPetAbility', function(target, pet, petskill, summoner, action)
    xi.job_utils.summoner.onUseBloodPact(target, petskill, summoner, action)

    if target:hasStatusEffect(xi.effect.STONESKIN) then
        petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        return
    end

    local amount     = pet:getMainLvl() * 2 + 50
    local typeEffect = xi.effect.STONESKIN

    if target:addStatusEffect(typeEffect, { power = amount, duration = 900, origin = pet, tier = 3 }) then
        if target:getID() == action:getPrimaryTargetID() then
            petskill:setMsg(xi.msg.basic.SKILL_GAIN_EFFECT_2)
        else
            petskill:setMsg(xi.msg.basic.JA_GAIN_EFFECT)
        end
    else
        petskill:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
        return
    end

    return typeEffect
end)

m:addOverride('xi.actions.spells.white.stoneskin.onSpellCast', function(caster, target, spell)
    local currentStoneskin = target:getStatusEffect(xi.effect.STONESKIN)

    if currentStoneskin and currentStoneskin:getTier() == 1 then
        local spellId   = spell:getID()
        local basePower = xi.spells.enhancing.calculateEnhancingBasePower(caster, target, spell, spellId, xi.effect.STONESKIN)
        local newPower  = xi.spells.enhancing.calculateEnhancingFinalPower(caster, target, spell, basePower, spell:getSpellGroup(), 1, xi.effect.STONESKIN)

        if newPower > currentStoneskin:getPower() then
            target:delStatusEffectSilent(xi.effect.STONESKIN)
        end
    end

    return super(caster, target, spell)
end)

-- Trusts must use their master's party when Moonlight applies its area Refresh.
m:addOverride('xi.actions.weaponskills.moonlight.onUseWeaponSkill', function(player, target, wsID, tp, primary, action, taChar)
    if player:isPC() then
        return super(player, target, wsID, tp, primary, action, taChar)
    end

    local lvl       = player:getSkillLevel(xi.skill.CLUB)
    local damage    = lvl / 7
    local damagemod = damage * ((50 + (tp * 0.12)) / 160)
    damagemod = damagemod * xi.settings.main.WEAPON_SKILL_POWER

    local function applyMoonlightEffects(member)
        if not member:isDead() and member:checkDistance(player) <= 6 then
            member:addStatusEffect(xi.effect.REFRESH, { power = 1, duration = 45, origin = player })
        end
    end

    applyMoonlightEffects(player)

    local master = player:getMaster()
    local party  = master and master:getPartyWithTrusts() or {}

    for _, member in pairs(party) do
        if member:getID() ~= player:getID() then
            applyMoonlightEffects(member)
        end
    end

    return 1, 0, false, damagemod
end)

return m
