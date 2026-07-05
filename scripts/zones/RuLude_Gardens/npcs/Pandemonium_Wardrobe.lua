-----------------------------------
-- Pandemonium Wardrobe
-----------------------------------
---@type TNpcEntity
local entity = {}

-----------------------------------
-- Item IDs
-----------------------------------

local ITEM =
{
    HEROISM_CRYSTAL = 9877,
    DARK_MATTER     = 9062,

    RIDILL          = 16555,
    SHADOW_RING     = 14646,
}

-----------------------------------
-- Config
-----------------------------------

local AUGMENT_COUNT  = 2
local REWARD_DELAY   = 1000 -- milliseconds
local GREETING_DELAY = 1200 -- milliseconds

-----------------------------------
-- Value Weight Tables
-----------------------------------

local valueWeights1 =
{
    { value = 1, weight = 100 },
}

local valueWeights3 =
{
    { value = 1, weight = 60 },
    { value = 2, weight = 30 },
    { value = 3, weight = 10 },
}

local valueWeights5 =
{
    { value = 1, weight = 50 },
    { value = 2, weight = 25 },
    { value = 3, weight = 15 },
    { value = 4, weight = 7  },
    { value = 5, weight = 3  },
}

local valueWeights10 =
{
    { value = 1,  weight = 40 },
    { value = 2,  weight = 24 },
    { value = 3,  weight = 14 },
    { value = 4,  weight = 8  },
    { value = 5,  weight = 5  },
    { value = 6,  weight = 3  },
    { value = 7,  weight = 2  },
    { value = 8,  weight = 2  },
    { value = 9,  weight = 1  },
    { value = 10, weight = 1  },
}

-----------------------------------
-- Ridill Augments
-----------------------------------

local ridillHeroismAugments =
{
    { id = 512, name = 'STR', valueWeights = valueWeights5, weight = 100 },
    { id = 513, name = 'DEX', valueWeights = valueWeights5, weight = 100 },
    { id = 514, name = 'VIT', valueWeights = valueWeights5, weight = 100 },
    { id = 515, name = 'AGI', valueWeights = valueWeights5, weight = 100 },
    { id = 516, name = 'INT', valueWeights = valueWeights5, weight = 100 },
    { id = 517, name = 'MND', valueWeights = valueWeights5, weight = 100 },
    { id = 518, name = 'CHR', valueWeights = valueWeights5, weight = 100 },
}

local ridillDarkMatterAugments =
{
    { id = 768, name = 'Fire resist',      valueWeights = valueWeights5, weight = 100 },
    { id = 769, name = 'Ice resist',       valueWeights = valueWeights5, weight = 100 },
    { id = 770, name = 'Wind resist',      valueWeights = valueWeights5, weight = 100 },
    { id = 771, name = 'Earth resist',     valueWeights = valueWeights5, weight = 100 },
    { id = 772, name = 'Lightning resist', valueWeights = valueWeights5, weight = 100 },
    { id = 773, name = 'Water resist',     valueWeights = valueWeights5, weight = 100 },
    { id = 774, name = 'Light resist',     valueWeights = valueWeights5, weight = 100 },
    { id = 775, name = 'Dark resist',      valueWeights = valueWeights5, weight = 100 },
}

-----------------------------------
-- Shadow Ring Augments
-----------------------------------

local shadowRingHeroismAugments =
{
    { id = 137, name = 'Regen',       valueWeights = valueWeights5,  weight = 100 },
    { id = 138, name = 'Refresh',     valueWeights = valueWeights5,  weight = 100 },
    { id = 139, name = 'Rapid Shot',  valueWeights = valueWeights3,  weight = 100 },
    { id = 140, name = 'Fast Cast',   valueWeights = valueWeights3,  weight = 100 },
    { id = 141, name = 'Conserve MP', valueWeights = valueWeights10, weight = 100 },
}

local shadowRingDarkMatterAugments =
{
    { id = 142, name = 'Store TP',        valueWeights = valueWeights5,  weight = 100 },
    { id = 143, name = 'Double Attack',   valueWeights = valueWeights5,  weight = 100 },
    { id = 144, name = 'Triple Attack',   valueWeights = valueWeights3,  weight = 100 },
    { id = 145, name = 'Counter',         valueWeights = valueWeights10, weight = 100 },
    { id = 146, name = 'Dual Wield',      valueWeights = valueWeights5,  weight = 100 },

    -- Rare augment rolls.
    { id = 147, name = 'Treasure Hunter', valueWeights = valueWeights1,  weight = 8   },
    { id = 148, name = 'Gilfinder',       valueWeights = valueWeights1,  weight = 8   },
}

-----------------------------------
-- Recipes
-----------------------------------

local augmentRecipes =
{
    [ITEM.RIDILL] =
    {
        itemId   = ITEM.RIDILL,
        itemName = 'Ridill',

        pools =
        {
            [ITEM.HEROISM_CRYSTAL] = ridillHeroismAugments,
            [ITEM.DARK_MATTER]     = ridillDarkMatterAugments,
        },
    },

    [ITEM.SHADOW_RING] =
    {
        itemId   = ITEM.SHADOW_RING,
        itemName = 'Shadow Ring',

        pools =
        {
            [ITEM.HEROISM_CRYSTAL] = shadowRingHeroismAugments,
            [ITEM.DARK_MATTER]     = shadowRingDarkMatterAugments,
        },
    },
}

local catalystNames =
{
    [ITEM.HEROISM_CRYSTAL] = 'Heroism Crystal',
    [ITEM.DARK_MATTER]     = 'Dark Matter',
}

-----------------------------------
-- Helpers
-----------------------------------

local function printNpc(player, npcName, text)
    player:printToPlayer(text, 0, npcName)
end

local function copyAugmentPool(pool)
    local copied = {}

    for index, augment in ipairs(pool) do
        copied[index] =
        {
            id           = augment.id,
            name         = augment.name,
            valueWeights = augment.valueWeights,
            weight       = augment.weight or 100,
        }
    end

    return copied
end

local function weightedChoice(entries)
    local totalWeight = 0

    for _, entry in ipairs(entries) do
        totalWeight = totalWeight + (entry.weight or 0)
    end

    if totalWeight <= 0 then
        return nil
    end

    local roll = math.randomInt(1, totalWeight)
    local runningWeight = 0

    for _, entry in ipairs(entries) do
        runningWeight = runningWeight + (entry.weight or 0)

        if roll <= runningWeight then
            return entry
        end
    end

    return entries[#entries]
end

local function rollWeightedValue(valueWeights)
    local chosen = weightedChoice(valueWeights)

    if chosen == nil then
        return 1
    end

    return chosen.value
end

local function rollRandomAugments(pool, count)
    local available = copyAugmentPool(pool)
    local rolled = {}

    for _ = 1, count do
        if #available == 0 then
            break
        end

        local augment = weightedChoice(available)

        if augment == nil then
            break
        end

        -- Remove chosen augment from available pool so the same augment cannot appear twice
        for index, availableAugment in ipairs(available) do
            if availableAugment.id == augment.id then
                table.remove(available, index)
                break
            end
        end

        local displayValue = rollWeightedValue(augment.valueWeights)
        local storedValue = displayValue - 1

        table.insert(rolled,
        {
            id           = augment.id,
            name         = augment.name,
            displayValue = displayValue,
            storedValue  = storedValue,
        })
    end

    table.sort(rolled, function(a, b)
        return a.id < b.id
    end)

    return rolled
end

local function buildAugmentSummary(rolledAugments)
    local parts = {}

    for _, augment in ipairs(rolledAugments) do
        table.insert(parts, string.format('%s +%u', augment.name, augment.displayValue))
    end

    return table.concat(parts, ', ')
end

local function findMatchingTrade(trade)
    if trade:getItemCount() ~= 2 then
        return nil, nil
    end

    for itemId, recipe in pairs(augmentRecipes) do
        if trade:hasItemQty(itemId, 1) then
            if trade:hasItemQty(ITEM.HEROISM_CRYSTAL, 1) then
                return recipe, ITEM.HEROISM_CRYSTAL
            elseif trade:hasItemQty(ITEM.DARK_MATTER, 1) then
                return recipe, ITEM.DARK_MATTER
            end
        end
    end

    return nil, nil
end

local function addAugmentedItem(player, itemId, rolledAugments)
    local aug1 = rolledAugments[1] or { id = 0, storedValue = 0 }
    local aug2 = rolledAugments[2] or { id = 0, storedValue = 0 }
    local aug3 = rolledAugments[3] or { id = 0, storedValue = 0 }
    local aug4 = rolledAugments[4] or { id = 0, storedValue = 0 }

    return player:addItem(
        itemId,
        1,

        aug1.id,
        aug1.storedValue,

        aug2.id,
        aug2.storedValue,

        aug3.id,
        aug3.storedValue,

        aug4.id,
        aug4.storedValue,

        0
    )
end

local function handleAugmentTrade(player, npc, trade)
    local npcName = "P. Wardrobe"
    local recipe, catalystItemId = findMatchingTrade(trade)

    if recipe == nil or catalystItemId == nil then
        printNpc(player, npcName, 'The mandragora gestures annoyedly at the box.')
        return
    end

    local augmentPool = recipe.pools[catalystItemId]

    if augmentPool == nil then
        printNpc(player, npcName, 'The mandragora gestures annoyedly at the box.')
        return
    end

    local catalystName = catalystNames[catalystItemId] or 'strange stone'
    local rolledAugments = rollRandomAugments(augmentPool, AUGMENT_COUNT)
    local augmentSummary = buildAugmentSummary(rolledAugments)

    player:tradeComplete()

    player:timer(REWARD_DELAY, function(playerArg)
        local success = addAugmentedItem(playerArg, recipe.itemId, rolledAugments)

        if success then
            printNpc(playerArg, npcName, 'The mandragora claps its tiny hands together and vanishes briefly into the box.')
            printNpc(playerArg, npcName, string.format('The %s vanishes into the wardrobe.', catalystName))
            printNpc(playerArg, npcName, string.format('Your %s has been rewritten.', recipe.itemName))
            printNpc(playerArg, npcName, string.format('Result: %s.', augmentSummary))
        else
            printNpc(playerArg, npcName, string.format('ERROR: The trade was accepted, but the augmented %s could not be returned.', recipe.itemName))
            printNpc(playerArg, npcName, string.format('Lost result was: %s.', augmentSummary))
            printNpc(playerArg, npcName, 'Tell a GM/admin immediately.')
        end
    end)
end

-----------------------------------
-- NPC Events
-----------------------------------

entity.onTrigger = function(player, npc)
    local npcName = "P. Wardrobe"

    npc:entityAnimationPacket('casm')

    player:timer(GREETING_DELAY, function(playerArg)
        printNpc(playerArg, npcName, 'The mandragora claps its tiny hands together. It gestures to the box it stands on, and you understand the intent.')
        printNpc(playerArg, npcName, 'On the box is a label, which reads simply as Pandemonium Wardrobe. It also shows two crude doodles.')
        printNpc(playerArg, npcName, 'One is a stone of perfect darkness, sketched alongside a heroic figure standing on top of a pile of monsters.')
        printNpc(playerArg, npcName, 'One is a radiant crystal, sketched alongside a valorous figure shown fighting on behalf of others.')
    end)
end

entity.onTrade = function(player, npc, trade)
    handleAugmentTrade(player, npc, trade)
end

return entity