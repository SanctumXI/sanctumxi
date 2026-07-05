-----------------------------------
-- Dynamis procs mixin
-----------------------------------
require('scripts/globals/mixins')
require('scripts/globals/dynamis')
-----------------------------------
g_mixins = g_mixins or {}

g_mixins.dynamis_beastmen = function(dynamisBeastmenMob)
    local procjobs =
    {
        [xi.job.WAR] = 'ws',
        [xi.job.MNK] = 'ja',
        [xi.job.WHM] = 'ma',
        [xi.job.BLM] = 'ma',
        [xi.job.RDM] = 'ma',
        [xi.job.THF] = 'ja',
        [xi.job.PLD] = 'ws',
        [xi.job.DRK] = 'ws',
        [xi.job.BST] = 'ja',
        [xi.job.BRD] = 'ma',
        [xi.job.RNG] = 'ja',
        [xi.job.SAM] = 'ws',
        [xi.job.NIN] = 'ja',
        [xi.job.DRG] = 'ws',
        [xi.job.SMN] = 'ma',
    }

    local familyCurrency =
    {
        [189] = xi.item.ORDELLE_BRONZEPIECE, -- Orc
        [202] = xi.item.ONE_BYNE_BILL,       -- Quadav
        [270] = xi.item.TUKUKU_WHITESHELL,   -- Yagudo
    }

    -- With Treasure Hunter on every procced monster, you can expect approximately 1.7 coins per kill on average.
    -- Without Treasure Hunter, you can expect about 1.25 coins per kill on average.
    -- Without a proc, the coin drop rate is very low (~10%)
    local thCurrency =
    {
        [0] = { single = 100, hundred =  5 },
        [1] = { single = 115, hundred = 10 },
        [2] = { single = 145, hundred = 20 },
        [3] = { single = 190, hundred = 35 },
        [4] = { single = 250, hundred = 50 },
    }

    -----------------------------------
    -- Personal alliance currency helper
    -- Keeps normal Dynamis treasure drops intact.
    -----------------------------------
    local PERSONAL_SINGLE_RATE  = 500 -- 50.0% personal roll for one single currency
    local PERSONAL_HUNDRED_RATE = 20  -- 2.0% personal roll for one 100-piece
    local MAX_LOOT_DISTANCE     = 50

    local function getCurrencyForMob(mob)
        return familyCurrency[mob:getFamily()] or xi.item.TUKUKU_WHITESHELL + math.randomInt(0, 2) * 3
    end

    local function getItemName(itemId)
        local item = GetItemByID(itemId)

        if not item then
            return string.format('item %u', itemId)
        end

        local itemName = item:getName()
        itemName = itemName:gsub('_', ' ')
        itemName = itemName:gsub('^%l', string.upper)

        return itemName
    end

    local function getEligiblePlayers(killer, mob)
        local players = {}
        local seen    = {}

        local function addPlayer(member)
            if not member then
                return
            end

            local id = member:getID()
            if seen[id] then
                return
            end

            if member:getZoneID() ~= mob:getZoneID() then
                return
            end

            if member:isDead() then
                return
            end

            if member:checkDistance(mob) > MAX_LOOT_DISTANCE then
                return
            end

            seen[id] = true
            table.insert(players, member)
        end

        local alliance = killer:getAlliance()
        if alliance then
            for _, group in pairs(alliance) do
                if type(group) == 'table' then
                    for _, member in pairs(group) do
                        addPlayer(member)
                    end
                else
                    addPlayer(group)
                end
            end
        else
            local party = killer:getParty()
            if party then
                for _, member in pairs(party) do
                    addPlayer(member)
                end
            else
                addPlayer(killer)
            end
        end

        return players
    end

    local function givePersonalCurrency(player, mob)
        local currency = getCurrencyForMob(mob)

        -- Independent 100-piece roll.
        if math.randomInt(1, 1000) <= PERSONAL_HUNDRED_RATE then
            if player:getFreeSlotsCount() <= 0 then
                player:printToPlayer('[Personal Loot] Inventory full. Could not receive currency.', 167)
                return
            end

            local hundredPiece = currency + 1
            player:addItem(hundredPiece, 1)
            player:printToPlayer(string.format('[Personal Loot] You obtained %s x1!', getItemName(hundredPiece)), 29)
        end

        -- Independent single currency roll.
        if math.randomInt(1, 1000) <= PERSONAL_SINGLE_RATE then
            if player:getFreeSlotsCount() <= 0 then
                player:printToPlayer('[Personal Loot] Inventory full. Could not receive currency.', 167)
                return
            end

            player:addItem(currency, 1)
            player:printToPlayer(string.format('[Personal Loot] You obtained %s x1!', getItemName(currency)), 29)
        end
    end

    local function givePersonalCurrencyToEligiblePlayers(killer, mob)
        local players = getEligiblePlayers(killer, mob)

        for _, member in ipairs(players) do
            givePersonalCurrency(member, mob)
        end
    end

    dynamisBeastmenMob:addListener('MAGIC_TAKE', 'DYNAMIS_MAGIC_PROC_CHECK', function(target, caster, spell)
        if
            procjobs[target:getMainJob()] == 'ma' and
            math.randomInt(1, 100) <= 8 and
            target:getLocalVar('dynamis_proc') == 0
        then
            xi.dynamis.procMonster(target, caster)
        end
    end)

    dynamisBeastmenMob:addListener('WEAPONSKILL_TAKE', 'DYNAMIS_WS_PROC_CHECK', function(user, target, skill, tp, action)
        if
            procjobs[target:getMainJob()] == 'ws' and
            math.randomInt(1, 100) <= 25 and
            target:getLocalVar('dynamis_proc') == 0
        then
            xi.dynamis.procMonster(target, user)
        end
    end)

    dynamisBeastmenMob:addListener('ABILITY_TAKE', 'DYNAMIS_ABILITY_PROC_CHECK', function(user, target, skill, action)
        if
            procjobs[target:getMainJob()] == 'ja' and
            math.randomInt(1, 100) <= 20 and
            target:getLocalVar('dynamis_proc') == 0
        then
            xi.dynamis.procMonster(target, user)
        end
    end)

    dynamisBeastmenMob:addListener('DEATH', 'DYNAMIS_ITEM_DISTRIBUTION', function(mob, killer)
        if not killer then
            return
        end

        local th            = thCurrency[math.min(mob:getTHlevel(), 4)]
        local currency      = getCurrencyForMob(mob)
        local singleChance  = mob:getMainLvl() > 90 and math.floor(th.single * 1.5) or th.single
        local hundredChance = th.hundred

        -- White (special) adds 100% hundred slot
        if mob:getLocalVar('dynamis_proc') >= 4 then
            killer:addTreasure(currency + 1, mob)
        end

        -- Base hundred slot
        if mob:isNM() then
            killer:addTreasure(currency + 1, mob, hundredChance)
        end

        -- red (high) adds 100% single slot
        if mob:getLocalVar('dynamis_proc') >= 3 then
            killer:addTreasure(currency, mob)
        end

        -- yellow (medium) adds single slot
        if mob:getLocalVar('dynamis_proc') >= 2 then
            killer:addTreasure(currency, mob, singleChance)
        end

        -- blue (low) adds single slot
        if mob:getLocalVar('dynamis_proc') >= 1 then
            killer:addTreasure(currency, mob, singleChance)
        end

        killer:addTreasure(currency, mob, singleChance) -- base single slot

        -- Personal currency rolls for eligible alliance/party/solo members.
        -- This does not replace or reduce the normal Dynamis treasure pool.
        givePersonalCurrencyToEligiblePlayers(killer, mob)
    end)
end

return g_mixins.dynamis_beastmen
