-----------------------------------
-- Targeted quest, battlefield, and ENM fixes.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/npc_util')
-----------------------------------

local m = Module:new('sanctum_miscfixes_quests_and_battlefields')

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

return m
