require('scripts/globals/mixins')

g_mixins = g_mixins or {}
g_mixins.families = g_mixins.families or {}

xi = xi or {}
xi.mixin = xi.mixin or {}
xi.mixin.hydra = xi.mixin.hydra or {}

local function scheduleHeadRegrow(mob)
    local headRegrowMin = (mob:getLocalVar('headRegrowMin') ~= 0 and mob:getLocalVar('headRegrowMin')) or 120
    local headRegrowMax = (mob:getLocalVar('headRegrowMax') ~= 0 and mob:getLocalVar('headRegrowMax')) or 240

    for slot = 1, 2 do
        if mob:getLocalVar('headgrow' .. slot) == 0 then
            mob:setLocalVar('headgrow' .. slot, GetSystemTime() + math.randomInt(headRegrowMin, headRegrowMax))
            return
        end
    end
end

-- 15% base chance to Double/Triple Attack, +10% each at 75/50/25% HP (45% total at
-- 25% HP or lower), -10% per missing head.
local function recalcAttackRates(mob)
    local brokenHeads = mob:getAnimationSub()
    local hpp         = mob:getHPP()

    local hppBonus = 0
    if hpp <= 75 then
        hppBonus = hppBonus + 10
    end

    if hpp <= 50 then
        hppBonus = hppBonus + 10
    end

    if hpp <= 25 then
        hppBonus = hppBonus + 10
    end

    local rate = utils.clamp(15 + hppBonus - (brokenHeads * 10), 0, 100)

    mob:setMod(xi.mod.DOUBLE_ATTACK, rate)
    mob:setMod(xi.mod.TRIPLE_ATTACK, rate)
end

local function checkRegrowHead(mob)
    local currentTime = GetSystemTime()
    local broken      = mob:getAnimationSub()
    local regrown     = 0

    for slot = 1, 2 do
        local regrowTime = mob:getLocalVar('headgrow' .. slot)

        if regrowTime > 0 and regrowTime <= currentTime then
            mob:setLocalVar('headgrow' .. slot, 0)
            regrown = regrown + 1
        end
    end

    if regrown > 0 and broken > 0 then
        mob:setAnimationSub(math.max(0, broken - regrown))
    elseif broken > 0 then
        -- Safeguard mobs that spawn with missing heads but no scheduled timer.
        local scheduledHeads = 0
        for slot = 1, 2 do
            if mob:getLocalVar('headgrow' .. slot) > 0 then
                scheduledHeads = scheduledHeads + 1
            end
        end

        for _ = scheduledHeads + 1, broken do
            scheduleHeadRegrow(mob)
        end
    end

    recalcAttackRates(mob)
end

local function breakHead(mob)
    local broken = mob:getAnimationSub()

    if broken < 2 then
        mob:setAnimationSub(broken + 1)
        scheduleHeadRegrow(mob)
        recalcAttackRates(mob)
    end
end

-- Call this from the mob's own entity.onCriticalHit hook. Unlike the CRITICAL_TAKE
-- listener event (which only fires for normal melee/ranged swings), onCriticalHit
-- also fires for weaponskill crits (and crits that land for 0 damage), matching
-- bgwiki's documented head-loss behavior.
xi.mixin.hydra.onCriticalHit = function(mob)
    -- A configured damage threshold replaces the retail-style random critical check.
    if mob:getLocalVar('headBreakDamageThreshold') > 0 then
        return
    end

    local headBreakChance = (mob:getLocalVar('headBreakChance') ~= 0 and mob:getLocalVar('headBreakChance')) or 15

    if math.randomInt(1, 100) <= headBreakChance then
        breakHead(mob)
    end
end

xi.mixin.hydra.onDamageTaken = function(mob, amount)
    local damageThreshold = mob:getLocalVar('headBreakDamageThreshold')

    if damageThreshold > 0 and amount >= damageThreshold then
        breakHead(mob)
    end
end

g_mixins.families.hydra = function(hydraMob)
    -- 15% chance to destroy one head (its right, then its left)
    -- Head grows back after some time (default 2-4 minutes)
    -- 0 -> 1 = 3 to 2 heads
    -- 1 -> 2 = 2 to 1 heads
    -- 2 -> 1 = 1 to 2 heads, plays regrow anim
    -- 1 -> 0 = 2 to 3 heads, plays regrow anim
    hydraMob:addListener('TAKE_DAMAGE', 'HYDRA_TAKE_DAMAGE', function(mob, amount)
        xi.mixin.hydra.onDamageTaken(mob, amount)
    end)

    hydraMob:addListener('ROAM_TICK', 'HYDRA_ROAM_TICK', checkRegrowHead)
    hydraMob:addListener('COMBAT_TICK', 'HYDRA_COMBAT_TICK', checkRegrowHead)
end

return g_mixins.families.hydra
