-----------------------------------
-- Sanctum artifact treasure coffers
-----------------------------------
require('modules/module_utils')
require('scripts/globals/treasure')
-----------------------------------

local m = Module:new('sanctum_af_coffers')

local cofferVar = '[AF]SanctumCoffer'

-- This is the complete final distribution for the 30 original direct-coffer
-- pieces.  Old gauntlet locations are intentionally not changed.
local classicDistribution =
{
    { resource = 'scripts/quests/jeuno/Borghertzs_Warring_Hands',    section = 4, job = xi.job.WAR, item = xi.item.FIGHTERS_CUISSES,    level = 58, oldZone = xi.zone.CASTLE_ZVAHL_BAILEYS,     zone = xi.zone.KUFTAL_TUNNEL       },
    { resource = 'scripts/quests/jeuno/Borghertzs_Warring_Hands',    section = 5, job = xi.job.WAR, item = xi.item.FIGHTERS_MASK,       level = 56, oldZone = xi.zone.CRAWLERS_NEST,             zone = xi.zone.THE_BOYAHDA_TREE     },
    { resource = 'scripts/quests/jeuno/Borghertzs_Striking_Hands',   section = 4, job = xi.job.MNK, item = xi.item.TEMPLE_CYCLAS,       level = 58, oldZone = xi.zone.BEADEAUX,                  zone = xi.zone.THE_BOYAHDA_TREE     },
    { resource = 'scripts/quests/jeuno/Borghertzs_Striking_Hands',   section = 5, job = xi.job.MNK, item = xi.item.TEMPLE_CROWN,        level = 56, oldZone = xi.zone.GARLAIGE_CITADEL,          zone = xi.zone.KUFTAL_TUNNEL       },
    { resource = 'scripts/quests/jeuno/Borghertzs_Healing_Hands',    section = 4, job = xi.job.WHM, item = xi.item.HEALERS_PANTALOONS,  level = 56, oldZone = xi.zone.CRAWLERS_NEST,             zone = xi.zone.TORAIMARAI_CANAL     },
    { resource = 'scripts/quests/jeuno/Borghertzs_Healing_Hands',    section = 5, job = xi.job.WHM, item = xi.item.HEALERS_CAP,         level = 54, oldZone = xi.zone.GARLAIGE_CITADEL,          zone = xi.zone.SEA_SERPENT_GROTTO   },
    { resource = 'scripts/quests/jeuno/Borghertzs_Sorcerous_Hands',  section = 4, job = xi.job.BLM, item = xi.item.WIZARDS_COAT,        level = 58, oldZone = xi.zone.MONASTIC_CAVERN,           zone = xi.zone.DEN_OF_RANCOR        },
    { resource = 'scripts/quests/jeuno/Borghertzs_Sorcerous_Hands',  section = 5, job = xi.job.BLM, item = xi.item.WIZARDS_TONBAN,      level = 56, oldZone = xi.zone.THE_ELDIEME_NECROPOLIS,   zone = xi.zone.KUFTAL_TUNNEL       },
    { resource = 'scripts/quests/jeuno/Borghertzs_Vermillion_Hands', section = 4, job = xi.job.RDM, item = xi.item.WARLOCKS_TABARD,      level = 58, oldZone = xi.zone.CASTLE_OZTROJA,            zone = xi.zone.DEN_OF_RANCOR        },
    { resource = 'scripts/quests/jeuno/Borghertzs_Vermillion_Hands', section = 5, job = xi.job.RDM, item = xi.item.WARLOCKS_TIGHTS,      level = 56, oldZone = xi.zone.GARLAIGE_CITADEL,          zone = xi.zone.TORAIMARAI_CANAL     },
    { resource = 'scripts/quests/jeuno/Borghertzs_Sneaky_Hands',     section = 4, job = xi.job.THF, item = xi.item.ROGUES_CULOTTES,      level = 56, oldZone = xi.zone.CASTLE_OZTROJA,            zone = xi.zone.IFRITS_CAULDRON      },
    { resource = 'scripts/quests/jeuno/Borghertzs_Sneaky_Hands',     section = 5, job = xi.job.THF, item = xi.item.ROGUES_VEST,          level = 58, oldZone = xi.zone.CASTLE_ZVAHL_BAILEYS,     zone = xi.zone.TORAIMARAI_CANAL     },
    { resource = 'scripts/quests/jeuno/Borghertzs_Stalwart_Hands',   section = 4, job = xi.job.PLD, item = xi.item.GALLANT_BREECHES,     level = 58, oldZone = xi.zone.BEADEAUX,                  zone = xi.zone.KUFTAL_TUNNEL       },
    { resource = 'scripts/quests/jeuno/Borghertzs_Stalwart_Hands',   section = 5, job = xi.job.PLD, item = xi.item.GALLANT_CORONET,      level = 56, oldZone = xi.zone.GARLAIGE_CITADEL,          zone = xi.zone.IFRITS_CAULDRON      },
    { resource = 'scripts/quests/jeuno/Borghertzs_Shadowy_Hands',    section = 4, job = xi.job.DRK, item = xi.item.CHAOS_CUIRASS,        level = 58, oldZone = xi.zone.CASTLE_OZTROJA,            zone = xi.zone.DEN_OF_RANCOR        },
    { resource = 'scripts/quests/jeuno/Borghertzs_Shadowy_Hands',    section = 5, job = xi.job.DRK, item = xi.item.CHAOS_FLANCHARD,      level = 56, oldZone = xi.zone.MONASTIC_CAVERN,           zone = xi.zone.THE_BOYAHDA_TREE     },
    { resource = 'scripts/quests/jeuno/Borghertzs_Wild_Hands',       section = 4, job = xi.job.BST, item = xi.item.BEAST_JACKCOAT,       level = 58, oldZone = xi.zone.BEADEAUX,                  zone = xi.zone.IFRITS_CAULDRON      },
    { resource = 'scripts/quests/jeuno/Borghertzs_Wild_Hands',       section = 5, job = xi.job.BST, item = xi.item.BEAST_HELM,           level = 56, oldZone = xi.zone.GARLAIGE_CITADEL,          zone = xi.zone.TEMPLE_OF_UGGALEPIH },
    { resource = 'scripts/quests/jeuno/Borghertzs_Harmonious_Hands', section = 4, job = xi.job.BRD, item = xi.item.CHORAL_CANNIONS,      level = 56, oldZone = xi.zone.CASTLE_OZTROJA,            zone = xi.zone.IFRITS_CAULDRON      },
    { resource = 'scripts/quests/jeuno/Borghertzs_Harmonious_Hands', section = 5, job = xi.job.BRD, item = xi.item.CHORAL_ROUNDLET,      level = 54, oldZone = xi.zone.CRAWLERS_NEST,             zone = xi.zone.QUICKSAND_CAVES      },
    { resource = 'scripts/quests/jeuno/Borghertzs_Chasing_Hands',    section = 4, job = xi.job.RNG, item = xi.item.HUNTERS_BRACCAE,      level = 56, oldZone = xi.zone.CRAWLERS_NEST,             zone = xi.zone.TEMPLE_OF_UGGALEPIH },
    { resource = 'scripts/quests/jeuno/Borghertzs_Chasing_Hands',    section = 5, job = xi.job.RNG, item = xi.item.HUNTERS_JERKIN,       level = 58, oldZone = xi.zone.MONASTIC_CAVERN,           zone = xi.zone.DEN_OF_RANCOR        },
    { resource = 'scripts/quests/jeuno/Borghertzs_Loyal_Hands',      section = 4, job = xi.job.SAM, item = xi.item.MYOCHIN_HAIDATE,      level = 54, oldZone = xi.zone.QUICKSAND_CAVES,           zone = xi.zone.QUICKSAND_CAVES      },
    { resource = 'scripts/quests/jeuno/Borghertzs_Loyal_Hands',      section = 5, job = xi.job.SAM, item = xi.item.MYOCHIN_DOMARU,       level = 58, oldZone = xi.zone.TEMPLE_OF_UGGALEPIH,       zone = xi.zone.TEMPLE_OF_UGGALEPIH },
    { resource = 'scripts/quests/jeuno/Borghertzs_Lurking_Hands',    section = 4, job = xi.job.NIN, item = xi.item.NINJA_KYAHAN,         level = 54, oldZone = xi.zone.SEA_SERPENT_GROTTO,        zone = xi.zone.SEA_SERPENT_GROTTO   },
    { resource = 'scripts/quests/jeuno/Borghertzs_Lurking_Hands',    section = 5, job = xi.job.NIN, item = xi.item.NINJA_HATSUBURI,      level = 56, oldZone = xi.zone.THE_BOYAHDA_TREE,          zone = xi.zone.THE_BOYAHDA_TREE     },
    { resource = 'scripts/quests/jeuno/Borghertzs_Dragon_Hands',     section = 4, job = xi.job.DRG, item = xi.item.DRACHEN_MAIL,         level = 58, oldZone = xi.zone.IFRITS_CAULDRON,           zone = xi.zone.IFRITS_CAULDRON      },
    { resource = 'scripts/quests/jeuno/Borghertzs_Dragon_Hands',     section = 5, job = xi.job.DRG, item = xi.item.DRACHEN_GREAVES,      level = 54, oldZone = xi.zone.QUICKSAND_CAVES,           zone = xi.zone.QUICKSAND_CAVES      },
    { resource = 'scripts/quests/jeuno/Borghertzs_Calling_Hands',    section = 4, job = xi.job.SMN, item = xi.item.EVOKERS_DOUBLET,      level = 58, oldZone = xi.zone.TEMPLE_OF_UGGALEPIH,       zone = xi.zone.TEMPLE_OF_UGGALEPIH },
    { resource = 'scripts/quests/jeuno/Borghertzs_Calling_Hands',    section = 5, job = xi.job.SMN, item = xi.item.EVOKERS_PIGACHES,     level = 56, oldZone = xi.zone.TORAIMARAI_CANAL,          zone = xi.zone.TORAIMARAI_CANAL     },
}

-- eligibility = 'started' mirrors the original ToAU commission unlock: the
-- AF3 quest must be accepted or completed.  DNC and SCH retain their original
-- requirement that AF2 be completed.
local additionalDistribution =
{
    { resource = 'scripts/quests/ahtUrhgan/BLU_AF3_Transformations',        eligibility = 'started',   bit = 0,  job = xi.job.BLU, item = xi.item.MAGUS_SHALWAR,       level = 54, zone = xi.zone.SEA_SERPENT_GROTTO   },
    { resource = 'scripts/quests/ahtUrhgan/BLU_AF3_Transformations',        eligibility = 'started',   bit = 1,  job = xi.job.BLU, item = xi.item.MAGUS_BAZUBANDS,     level = 56, zone = xi.zone.KUFTAL_TUNNEL       },
    { resource = 'scripts/quests/ahtUrhgan/BLU_AF3_Transformations',        eligibility = 'started',   bit = 2,  job = xi.job.BLU, item = xi.item.MAGUS_JUBBAH,        level = 58, zone = xi.zone.DEN_OF_RANCOR        },
    { resource = 'scripts/quests/ahtUrhgan/COR_AF3_Against_All_Odds',      eligibility = 'started',   bit = 3,  job = xi.job.COR, item = xi.item.CORSAIRS_GANTS,      level = 54, zone = xi.zone.QUICKSAND_CAVES      },
    { resource = 'scripts/quests/ahtUrhgan/COR_AF3_Against_All_Odds',      eligibility = 'started',   bit = 4,  job = xi.job.COR, item = xi.item.CORSAIRS_BOTTES,     level = 56, zone = xi.zone.TORAIMARAI_CANAL     },
    { resource = 'scripts/quests/ahtUrhgan/COR_AF3_Against_All_Odds',      eligibility = 'started',   bit = 5,  job = xi.job.COR, item = xi.item.CORSAIRS_FRAC,       level = 58, zone = xi.zone.THE_BOYAHDA_TREE     },
    { resource = 'scripts/quests/ahtUrhgan/PUP_AF3_Puppetmaster_Blues',    eligibility = 'started',   bit = 6,  job = xi.job.PUP, item = xi.item.PUPPETRY_BABOUCHES, level = 54, zone = xi.zone.SEA_SERPENT_GROTTO   },
    { resource = 'scripts/quests/ahtUrhgan/PUP_AF3_Puppetmaster_Blues',    eligibility = 'started',   bit = 7,  job = xi.job.PUP, item = xi.item.PUPPETRY_DASTANAS,  level = 56, zone = xi.zone.TEMPLE_OF_UGGALEPIH },
    { resource = 'scripts/quests/ahtUrhgan/PUP_AF3_Puppetmaster_Blues',    eligibility = 'started',   bit = 8,  job = xi.job.PUP, item = xi.item.PUPPETRY_TOBE,      level = 58, zone = xi.zone.TORAIMARAI_CANAL     },
    { resource = 'scripts/quests/jeuno/DNC_AF2_The_Road_to_Divadom',       eligibility = 'completed', bit = 9,  job = xi.job.DNC, items = { xi.item.DANCERS_BANGLES_M,   xi.item.DANCERS_BANGLES_F   }, level = 52, zone = xi.zone.QUICKSAND_CAVES  },
    { resource = 'scripts/quests/jeuno/DNC_AF2_The_Road_to_Divadom',       eligibility = 'completed', bit = 10, job = xi.job.DNC, items = { xi.item.DANCERS_TIARA_M,     xi.item.DANCERS_TIARA_F     }, level = 54, zone = xi.zone.KUFTAL_TUNNEL    },
    { resource = 'scripts/quests/jeuno/DNC_AF2_The_Road_to_Divadom',       eligibility = 'completed', bit = 11, job = xi.job.DNC, items = { xi.item.DANCERS_TOE_SHOES_M, xi.item.DANCERS_TOE_SHOES_F }, level = 56, zone = xi.zone.IFRITS_CAULDRON  },
    { resource = 'scripts/quests/crystalWar/SCH_AF2_Downward_Helix',       eligibility = 'completed', bit = 12, job = xi.job.SCH, item = xi.item.SCHOLARS_LOAFERS,     level = 54, zone = xi.zone.SEA_SERPENT_GROTTO   },
    { resource = 'scripts/quests/crystalWar/SCH_AF2_Downward_Helix',       eligibility = 'completed', bit = 13, job = xi.job.SCH, item = xi.item.SCHOLARS_PANTS,       level = 56, zone = xi.zone.THE_BOYAHDA_TREE     },
    { resource = 'scripts/quests/crystalWar/SCH_AF2_Downward_Helix',       eligibility = 'completed', bit = 14, job = xi.job.SCH, item = xi.item.SCHOLARS_GOWN,        level = 58, zone = xi.zone.DEN_OF_RANCOR        },
}

xi.sanctum = xi.sanctum or {}
xi.sanctum.afCoffers =
{
    cofferVar              = cofferVar,
    classicDistribution    = classicDistribution,
    additionalDistribution = additionalDistribution,
}

local function markCofferPiece(player, cofferBit)
    player:setCharVar(cofferVar, utils.mask.setBit(player:getCharVar(cofferVar), cofferBit, true))
end

local function resolveReward(player, entry)
    local candidates = entry.items or { entry.item }

    for _, itemId in ipairs(candidates) do
        if player:canEquipItem(itemId, false) then
            return itemId
        end
    end

    return nil
end

xi.sanctum.afCoffers.resolveReward = resolveReward

local function moveClassicCoffers()
    local entriesByResource = {}

    for _, entry in ipairs(classicDistribution) do
        if entry.oldZone ~= entry.zone then
            entriesByResource[entry.resource] = entriesByResource[entry.resource] or {}
            table.insert(entriesByResource[entry.resource], entry)
        end
    end

    for resource, entries in pairs(entriesByResource) do
        xi.module.modifyInteractionEntry(resource, function(quest)
            for _, entry in ipairs(entries) do
                local section   = quest.sections[entry.section]
                local zoneEntry = section[entry.oldZone]

                section[entry.zone] = zoneEntry
                section[entry.oldZone] = nil
            end
        end)
    end
end

local function addNewCofferPieces()
    local entriesByResource = {}

    for _, entry in ipairs(additionalDistribution) do
        entriesByResource[entry.resource] = entriesByResource[entry.resource] or {}
        table.insert(entriesByResource[entry.resource], entry)
    end

    for resource, entries in pairs(entriesByResource) do
        xi.module.modifyInteractionEntry(resource, function(quest)
            for _, distributionEntry in ipairs(entries) do
                local entry = distributionEntry

                table.insert(quest.sections,
                {
                    check = function(player, status, vars)
                        local hasRequiredQuestStatus = status ~= xi.questStatus.QUEST_AVAILABLE

                        if entry.eligibility == 'completed' then
                            hasRequiredQuestStatus = status == xi.questStatus.QUEST_COMPLETED
                        end

                        return hasRequiredQuestStatus and
                            player:getMainJob() == entry.job and
                            not utils.mask.getBit(player:getCharVar(cofferVar), entry.bit) and
                            resolveReward(player, entry) ~= nil
                    end,

                    [entry.zone] =
                    {
                        ['Treasure_Coffer'] =
                        {
                            onTrade = function(player, npc, trade)
                                local rewardId = resolveReward(player, entry)

                                if
                                    rewardId and
                                    xi.treasure.onTrade(player, npc, trade, 1, rewardId) == rewardId
                                then
                                    markCofferPiece(player, entry.bit)
                                end

                                return quest:noAction()
                            end,
                        },
                    },
                })
            end
        end)
    end
end

local function disableDancerCommission()
    xi.module.modifyInteractionEntry('scripts/quests/hiddenQuests/Crafted_Dancer_Artifact', function(quest)
        quest.sections[1].check = function()
            return false
        end

        quest.sections[2].check = function()
            return false
        end
    end)
end

m:addOverride('xi.server.onServerStart', function()
    super()

    moveClassicCoffers()
    addNewCofferPieces()
    disableDancerCommission()
end)

-- Materials, currencies, key-item deliveries, waiting periods, and
-- commissioned AF pickups are disabled.  Neutral dialogue is retained where
-- the original NPC provides it.
m:addOverride('xi.zones.Aht_Urhgan_Whitegate.npcs.Lathuya.onTrade', function()
end)

m:addOverride('xi.zones.Aht_Urhgan_Whitegate.npcs.Lathuya.onTrigger', function()
end)

m:addOverride('xi.zones.Aht_Urhgan_Whitegate.npcs.Lathuya.onEventFinish', function()
end)

m:addOverride('xi.zones.Aht_Urhgan_Whitegate.npcs.Dhima_Polevhia.onTrade', function()
end)

m:addOverride('xi.zones.Aht_Urhgan_Whitegate.npcs.Dhima_Polevhia.onTrigger', function(player, npc)
    player:startEvent(788)
end)

m:addOverride('xi.zones.Aht_Urhgan_Whitegate.npcs.Dhima_Polevhia.onEventFinish', function()
end)

m:addOverride('xi.zones.Nashmau.npcs.Leleroon.onTrigger', function(player, npc)
    player:startEvent(264)
end)

m:addOverride('xi.zones.Nashmau.npcs.Leleroon.onEventFinish', function()
end)

m:addOverride('xi.zones.Windurst_Waters.npcs.Door_House.onTrade', function(player, npc, trade)
    if npc:getID() ~= zones[xi.zone.WINDURST_WATERS].npc.LELEROON_GREEN_DOOR then
        return super(player, npc, trade)
    end
end)

m:addOverride('xi.zones.Windurst_Waters.npcs.Door_House.onTrigger', function(player, npc)
    if npc:getID() == zones[xi.zone.WINDURST_WATERS].npc.LELEROON_GREEN_DOOR then
        player:messageSpecial(zones[xi.zone.WINDURST_WATERS].text.DOOR_FIRMLY_SHUT)
    else
        return super(player, npc)
    end
end)

m:addOverride('xi.zones.Windurst_Waters.npcs.Door_House.onEventFinish', function(player, csid, option, npc)
    if npc:getID() ~= zones[xi.zone.WINDURST_WATERS].npc.LELEROON_GREEN_DOOR then
        return super(player, csid, option, npc)
    end
end)

m:addOverride('xi.zones.Bastok_Mines.npcs.Door_House.onTrade', function(player, npc, trade)
    if npc:getID() ~= zones[xi.zone.BASTOK_MINES].npc.LELEROON_BLUE_DOOR then
        return super(player, npc, trade)
    end
end)

m:addOverride('xi.zones.Bastok_Mines.npcs.Door_House.onTrigger', function(player, npc)
    if npc:getID() ~= zones[xi.zone.BASTOK_MINES].npc.LELEROON_BLUE_DOOR then
        return super(player, npc)
    end
end)

m:addOverride('xi.zones.Bastok_Mines.npcs.Door_House.onEventFinish', function(player, csid, option, npc)
    if npc:getID() ~= zones[xi.zone.BASTOK_MINES].npc.LELEROON_BLUE_DOOR then
        return super(player, csid, option, npc)
    end
end)

m:addOverride('xi.zones.Port_San_dOria.npcs.Raqtibahl.onTrade', function()
end)

m:addOverride('xi.zones.Port_San_dOria.npcs.Raqtibahl.onTrigger', function(player, npc)
    player:startEvent(759)
end)

m:addOverride('xi.zones.Port_San_dOria.npcs.Raqtibahl.onEventFinish', function()
end)

m:addOverride('xi.zones.Bastok_Markets_[S].npcs.Loussaire.onTrigger', function(player, npc)
    player:startEvent(48)
end)

m:addOverride('xi.zones.Bastok_Markets_[S].npcs.Loussaire.onEventFinish', function()
end)

return m
