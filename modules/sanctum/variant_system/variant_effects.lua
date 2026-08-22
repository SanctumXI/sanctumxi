local data = require('modules/sanctum/variant_system/variant_tables')

local effects = {}

local function selectEntries(pool, count)
    local available = {}
    local selected  = {}

    for index, entryId in ipairs(pool) do
        available[index] = entryId
    end

    for _ = 1, math.min(count, #available) do
        local index = math.randomInt(1, #available)

        selected[#selected + 1] = available[index]
        table.remove(available, index)
    end

    return selected
end

local function addTrackedModifier(mob, state, modifierId, value)
    if modifierId == nil or value == nil or value == 0 then
        return
    end

    mob:addMod(modifierId, value)
    state.appliedModifiers[#state.appliedModifiers + 1] =
    {
        mod   = modifierId,
        value = value,
    }
end

local function applyCatalogEntry(mob, state, entry)
    if entry == nil then
        return
    end

    local modifiers = {}

    for _, modifier in ipairs(entry.modifiers or {}) do
        modifiers[#modifiers + 1] = modifier
    end

    if entry.buildModifiers ~= nil then
        for _, modifier in ipairs(entry.buildModifiers(mob, state) or {}) do
            modifiers[#modifiers + 1] = modifier
        end
    end

    for _, modifier in ipairs(modifiers) do
        addTrackedModifier(mob, state, modifier.mod, modifier.value)
    end

    for flag, value in pairs(entry.flags or {}) do
        state[flag] = value
    end
end

local function getEligibleBuffPool(level)
    for _, tier in ipairs(data.levelBuffPools) do
        if level >= tier.minLevel and level <= tier.maxLevel then
            local eligible = {}

            for _, category in ipairs(data.buffCategoryOrder) do
                for _, buffId in ipairs(tier.buffs[category] or {}) do
                    if data.buffCatalog[buffId] ~= nil then
                        eligible[#eligible + 1] = buffId
                    end
                end
            end

            return eligible
        end
    end

    return {}
end

function effects.resetAppliedState(state)
    if state == nil then
        return
    end

    -- Mob stat calculation restores base modifiers before every SPAWN listener.
    state.appliedModifiers   = {}
    state.poisonAttacks      = false
    state.skillchainWeakness = false
end

function effects.applyBuffs(mob, state, count, automaticHpBonus)
    local pool = getEligibleBuffPool(mob:getMainLvl())

    state.buffIds          = selectEntries(pool, count)
    state.automaticHpBonus = automaticHpBonus
    state.poisonAttacks    = false

    if automaticHpBonus > 0 then
        addTrackedModifier(mob, state, xi.mod.HPP, automaticHpBonus)
    end

    for _, buffId in ipairs(state.buffIds) do
        applyCatalogEntry(mob, state, data.buffCatalog[buffId])
    end

    mob:updateHealth()
    mob:setHP(mob:getMaxHP())
end

function effects.applyWeakness(mob, state)
    state.weaknessId         = nil
    state.weaknessName       = nil
    state.weaknessRevealed   = false
    state.skillchainWeakness = false
    state.lastSkillchainLink = 0

    if #data.globalWeaknessPool == 0 then
        return
    end

    local weaknessId = data.globalWeaknessPool[math.randomInt(1, #data.globalWeaknessPool)]
    local weakness   = data.weaknessCatalog[weaknessId]

    if weakness == nil then
        return
    end

    state.weaknessId   = weaknessId
    state.weaknessName = weakness.name
    applyCatalogEntry(mob, state, weakness)
    mob:updateHealth()
    mob:setHP(mob:getMaxHP())
end

function effects.getBuffNames(state)
    local names = {}

    for _, buffId in ipairs(state.buffIds or {}) do
        local entry = data.buffCatalog[buffId]
        names[#names + 1] = entry ~= nil and entry.name or buffId
    end

    return names
end

return effects
