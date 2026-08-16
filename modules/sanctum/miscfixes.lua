-----------------------------------
-- Targeted gameplay fixes that do not require engine changes.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/npc_util')
-----------------------------------

local m = Module:new('sanctum_miscfixes')

-- Ix'aern DRK resists enfeebles but only has a hard immunity to Stun.
-- Retain its standard NM Terror immunity while allowing Bind/Shadowbind.
local ixDrkEnfeebleImmunities =
{
    xi.immunity.BIND,
    xi.immunity.BLIND,
    xi.immunity.DARK_SLEEP,
    xi.immunity.ELEGY,
    xi.immunity.GRAVITY,
    xi.immunity.LIGHT_SLEEP,
    xi.immunity.PARALYZE,
    xi.immunity.SILENCE,
    xi.immunity.SLOW,
}

m:addOverride('xi.zones.The_Garden_of_RuHmet.mobs.Ixaern_DRK.onMobInitialize', function(mob)
    super(mob)

    for _, immunity in ipairs(ixDrkEnfeebleImmunities) do
        mob:delImmunity(immunity)
    end
end)

-- Ix'aern DRG's Wynavs cannot be slept, but they can be bound.
m:addOverride('xi.zones.The_Garden_of_RuHmet.mobs.Ixaern_DRGs_Wynav.onMobSpawn', function(mob)
    super(mob)
    mob:delImmunity(xi.immunity.BIND)
end)

-- Manipulator does not award gil on defeat.
m:addOverride('xi.zones.Temple_of_Uggalepih.mobs.Manipulator.onMobInitialize', function(mob)
    super(mob)
    mob:setMobMod(xi.mobMod.GIL_MIN, -1)
    mob:setMobMod(xi.mobMod.GIL_MAX, -1)
end)

-- Sabotender Bailarin has a 10% lottery chance from its Bailaor placeholder.
m:addOverride('xi.zones.Quicksand_Caves.mobs.Sabotender_Bailaor.onMobDespawn', function(mob)
    local ID = zones[xi.zone.QUICKSAND_CAVES]

    xi.mob.phOnDespawn(mob, ID.mob.SABOTENDER_BAILARIN, 10, 9000)
end)

-- Chocobo rentals cost a flat 500 gil in every rental zone.
m:addOverride('xi.chocobo.getPrice', function(player)
    return 500
end)

-- Trial-sized avatars do not inherit the Prime Avatar Light resistance rank.
local trialAvatarSpawnPaths =
{
    'xi.zones.Cloister_of_Flames.mobs.Ifrit_Prime_TSTBF.onMobSpawn',
    'xi.zones.Cloister_of_Frost.mobs.Shiva_Prime_TSTBI.onMobSpawn',
    'xi.zones.Cloister_of_Gales.mobs.Garuda_Prime_TSTBW.onMobSpawn',
    'xi.zones.Cloister_of_Storms.mobs.Ramuh_Prime_TSTBL.onMobSpawn',
    'xi.zones.Cloister_of_Tides.mobs.Leviathan_Prime_TSTBW.onMobSpawn',
    'xi.zones.Cloister_of_Tremors.mobs.Titan_Prime_TSTBE.onMobSpawn',
}

for _, spawnPath in ipairs(trialAvatarSpawnPaths) do
    m:addOverride(spawnPath, function(mob)
        super(mob)
        mob:setMod(xi.mod.LIGHT_RES_RANK, 0)
    end)
end

-- Ghebi Damomohe grants Astral Covenant on the normal real-time ENM cooldown.
m:addOverride('xi.zones.Lower_Jeuno.npcs.Ghebi_Damomohe.onTrade', function(player, npc, trade)
    local astralCovenantCooldown = player:getCharVar('[ENM]AstralCovenant')

    if
        npcUtil.tradeMatches(trade, xi.item.FLORID_STONE) and
        player:hasKeyItem(xi.ki.PSOXJA_PASS) and
        astralCovenantCooldown <= GetSystemTime()
    then
        player:startEvent(10047, xi.item.FLORID_STONE)
        player:confirmTrade()
        return
    end

    return super(player, npc, trade)
end)

m:addOverride('xi.zones.Lower_Jeuno.npcs.Ghebi_Damomohe.onTrigger', function(player, npc)
    local astralCovenantCooldown = player:getCharVar('[ENM]AstralCovenant')

    if
        player:hasKeyItem(xi.ki.PSOXJA_PASS) and
        not player:hasKeyItem(xi.ki.ASTRAL_COVENANT)
    then
        if astralCovenantCooldown <= GetSystemTime() then
            player:startEvent(106, 4, 1, xi.item.FLORID_STONE, xi.ki.PSOXJA_PASS, xi.ki.ASTRAL_COVENANT)
        else
            local cooldownExpiry = VanadielTime() + astralCovenantCooldown - GetSystemTime()

            player:startEvent(106, 4, 2, xi.ki.ASTRAL_COVENANT, cooldownExpiry)
        end
    else
        player:startEvent(106, 4)
    end
end)

m:addOverride('xi.zones.Lower_Jeuno.npcs.Ghebi_Damomohe.onEventFinish', function(player, csid, option, npc)
    if csid == 10047 then
        player:setCharVar('[ENM]AstralCovenant', GetSystemTime() + xi.settings.main.ENM_COOLDOWN * 3600)
        npcUtil.giveKeyItem(player, xi.ki.ASTRAL_COVENANT)
        return
    end

    return super(player, csid, option, npc)
end)

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
        return super(caster, target, spell, spellId, spellGroup, spellEffect)
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

-- Doll Typhoon strikes a random two to four times.
m:addOverride('xi.actions.mobskills.typhoon.onMobWeaponSkill', function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.numHits        = math.randomInt(2, 4)
    params.fTP            = { 1.0, 1.0, 1.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_4

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end)

-- The fishing system checks this timestamp before Devil Manta can be hooked again.
-- This mob has no base script, so install its despawn callback directly.
xi.module.ensureTable('xi.zones.Kuftal_Tunnel.mobs.Devil_Manta')
xi.zones.Kuftal_Tunnel.mobs.Devil_Manta.onMobDespawn = function(mob)
    mob:setLocalVar('lastTOD', GetSystemTime())
end

return m
