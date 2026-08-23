-----------------------------------
-- Targeted gameplay fixes that do not require engine changes.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/npc_util')
-----------------------------------

local m = Module:new('sanctum_miscfixes')

-- Inside the Belly originally accepted 18 fish. The remaining trades were
-- added in version updates from 2009 onward.
local outOfEraInsideTheBellyFish =
{
    [xi.item.BLADEFISH_1]       = true,
    [xi.item.GAVIAL_FISH]       = true,
    [xi.item.VEYDAL_WRASSE_1]   = true,
    [xi.item.MORINABALIGI]      = true,
    [xi.item.TURNABALIGI]       = true,
    [xi.item.KALKANBALIGI]      = true,
    [xi.item.PTERYGOTUS]        = true,
    [xi.item.GERROTHORAX]       = true,
    [xi.item.PIRARUCU]          = true,
    [xi.item.MEGALODON]         = true,
    [xi.item.YAYINBALIGI]       = true,
    [xi.item.LAKERDA]           = true,
    [xi.item.KILICBALIGI]       = true,
    [xi.item.MONKE_ONKE_1]      = true,
    [xi.item.AHTAPOT]           = true,
    [xi.item.ARMORED_PISCES]    = true,
    [xi.item.MOLA_MOLA]         = true,
    [xi.item.GUGRU_TUNA_1]      = true,
    [xi.item.ISTAVRIT_1]        = true,
    [xi.item.GIGANT_OCTOPUS_1]  = true,
    [xi.item.THREE_EYED_FISH_1] = true,
    [xi.item.GIGANT_SQUID]      = true,
    [xi.item.RHINOCHIMERA_1]    = true,
    [xi.item.GRIMMONITE]        = true,
    [xi.item.TITANIC_SAWFISH]   = true,
    [xi.item.PELAZOEA]          = true,
    [xi.item.DORADO_GAR]        = true,
    [xi.item.CROCODILOS]        = true,
    [xi.item.ABAIA]             = true,
    [xi.item.MATSYA]            = true,
    [xi.item.SORYU]             = true,
    [xi.item.SEKIRYU]           = true,
    [xi.item.HAKURYU]           = true,
    [xi.item.FAR_EAST_PUFFER]   = true,
}

local skulkersCapeId = 13692
local talismanCapeId = 15485

local function grantFlee(player)
    player:delStatusEffect(xi.effect.FLEE)
    player:addStatusEffect(xi.effect.FLEE, { power = 10000, duration = 30, origin = player })
end

local wakingTheBeastKeyItems =
{
    xi.ki.EYE_OF_FLAMES,
    xi.ki.EYE_OF_FROST,
    xi.ki.EYE_OF_GALES,
    xi.ki.EYE_OF_STORMS,
    xi.ki.EYE_OF_TIDES,
    xi.ki.EYE_OF_TREMORS,
    xi.ki.RAINBOW_RESONATOR,
}

local function hasWakingTheBeastKeyItems(player)
    for _, keyItem in ipairs(wakingTheBeastKeyItems) do
        if not player:hasKeyItem(keyItem) then
            return false
        end
    end

    return true
end

local function finishWakingTheBeast(player)
    for _, keyItem in ipairs(wakingTheBeastKeyItems) do
        player:delKeyItem(keyItem)
    end

    npcUtil.giveKeyItem(player, xi.ki.FADED_RUBY)
end

m:addOverride('xi.server.onServerStart', function()
    super()

    xi.module.modifyInteractionEntry('scripts/quests/otherAreas/Inside_the_Belly', function(quest)
        for _, sectionIdx in ipairs({ 2, 3 }) do
            local zaldon      = quest.sections[sectionIdx][xi.zone.SELBINA]['Zaldon']
            local baseOnTrade = zaldon.onTrade

            zaldon.onTrade = function(player, npc, trade)
                for itemSlot = 0, trade:getSlotCount() - 1 do
                    if outOfEraInsideTheBellyFish[trade:getItemId(itemSlot)] then
                        return
                    end
                end

                return baseOnTrade(player, npc, trade)
            end

            zaldon.onTrigger = function(player, npc)
                local fishingSkill = xi.crafting.getTotalSkill(player, xi.skill.FISHING)
                local tier         = 4

                if fishingSkill < 40 then
                    tier = 1
                elseif fishingSkill < 50 then
                    tier = 2
                elseif fishingSkill < 75 then
                    tier = 3
                end

                local csTier =
                {
                    {
                        162,
                        xi.item.GIANT_CATFISH_1,
                        xi.item.DARK_BASS_1,
                        xi.item.OGRE_EEL_1,
                        xi.item.ZAFMLUG_BASS,
                    },

                    {
                        163,
                        xi.item.ZAFMLUG_BASS,
                        xi.item.GIANT_DONKO_1,
                        xi.item.BHEFHEL_MARLIN_1,
                        xi.item.JUNGLE_CATFISH,
                        xi.item.SILVER_SHARK,
                    },

                    {
                        164,
                        xi.item.JUNGLE_CATFISH,
                        xi.item.EMPEROR_FISH,
                        xi.item.SILVER_SHARK,
                        xi.item.TAKITARO,
                        xi.item.SEA_ZOMBIE,
                        xi.item.GIANT_CHIRAI,
                    },

                    {
                        165,
                        xi.item.TAKITARO,
                        xi.item.SEA_ZOMBIE,
                        xi.item.TITANICTUS,
                        xi.item.CAVE_CHERAX,
                        xi.item.TRICORN,
                        xi.item.RYUGU_TITAN,
                        xi.item.LIK,
                        xi.item.GUGRUSAURUS,
                    },
                }

                return quest:event(unpack(csTier[tier]))
            end
        end
    end)

    xi.module.modifyInteractionEntry('scripts/quests/jeuno/Tenshodo_Membership', function(quest)
        local section = quest.sections[1]
        local legacyNpcs =
        {
            section[xi.zone.PORT_BASTOK]['Jabbar'],
            section[xi.zone.PORT_BASTOK]['Silver_Owl'],
        }

        section.check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                (status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.JEUNO) >= 3)
        end

        for _, npcEntry in ipairs(legacyNpcs) do
            local baseOnTrigger = npcEntry.onTrigger

            npcEntry.onTrigger = function(player, npc)
                if
                    player:getQuestStatus(quest.areaId, quest.questId) == xi.questStatus.QUEST_ACCEPTED and
                    quest:getVar(player, 'Prog') == 0
                then
                    quest:setVar(player, 'Prog', 1)
                end

                return baseOnTrigger(player, npc)
            end
        end
    end)

    local wakingTheBeast = xi.battlefield.contents[xi.battlefield.id.WAKING_THE_BEAST_FULLMOON]
    if wakingTheBeast then
        local baseOnBattlefieldWin = wakingTheBeast.onBattlefieldWin

        wakingTheBeast.onBattlefieldWin = function(content, player, battlefield)
            if hasWakingTheBeastKeyItems(player) then
                player:setLocalVar('battlefieldWin', battlefield:getID())

                if player:isDead() then
                    finishWakingTheBeast(player)
                end
            end

            return baseOnBattlefieldWin(content, player, battlefield)
        end
    end
end)

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

m:addOverride('xi.items.mistmelt.onItemCheck', function(target, item, param, player)
    if target:getName() ~= 'Ouryu' then
        return xi.msg.basic.ITEM_UNABLE_TO_USE
    elseif target:checkDistance(player) > 10 then
        return xi.msg.basic.TOO_FAR_AWAY
    end

    return 0
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

m:addOverride('xi.actions.mobskills.sticky_thread.onMobWeaponSkill', function(mob, target, skill, action)
    if target:hasStatusEffect(xi.effect.HASTE) then
        skill:setMsg(xi.msg.basic.SKILL_NO_EFFECT)
        return xi.effect.NONE
    end

    return super(mob, target, skill, action)
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
