require('scripts/globals/mixins')

g_mixins = g_mixins or {}
g_mixins.families = g_mixins.families or {}

xi = xi or {}
xi.mixin = xi.mixin or {}
xi.mixin.hydra = xi.mixin.hydra or {}

local function nextRegrow(mob)
    local headRegrowMin = (mob:getLocalVar('headRegrowMin') ~= 0 and mob:getLocalVar('headRegrowMin')) or 120
    local headRegrowMax = (mob:getLocalVar('headRegrowMax') ~= 0 and mob:getLocalVar('headRegrowMax')) or 240

    mob:setLocalVar('headgrow', GetSystemTime() + math.randomInt(headRegrowMin, headRegrowMax))
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
    local headgrow = mob:getLocalVar('headgrow')
    local broken   = mob:getAnimationSub()

    if headgrow < GetSystemTime() and broken > 0 then
        mob:setAnimationSub(broken - 1)
        nextRegrow(mob)
    end

    recalcAttackRates(mob)
end

-- Call this from the mob's own entity.onCriticalHit hook. Unlike the CRITICAL_TAKE
-- listener event (which only fires for normal melee/ranged swings), onCriticalHit
-- also fires for weaponskill crits (and crits that land for 0 damage), matching
-- bgwiki's documented head-loss behavior.
xi.mixin.hydra.onCriticalHit = function(mob)
    local broken          = mob:getAnimationSub()
    local headBreakChance = (mob:getLocalVar('headBreakChance') ~= 0 and mob:getLocalVar('headBreakChance')) or 15

    if math.randomInt(1, 100) <= headBreakChance and broken < 2 then
        mob:setAnimationSub(broken + 1)
        nextRegrow(mob)
        recalcAttackRates(mob)
    end
end

g_mixins.families.hydra = function(hydraMob)
    -- 15% chance to destroy one head (its right, then its left)
    -- Head grows back after some time (default 2-4 minutes)
    -- 0 -> 1 = 3 to 2 heads
    -- 1 -> 2 = 2 to 1 heads
    -- 2 -> 1 = 1 to 2 heads, plays regrow anim
    -- 1 -> 0 = 2 to 3 heads, plays regrow anim
    hydraMob:addListener('ROAM_TICK', 'HYDRA_ROAM_TICK', checkRegrowHead)
    hydraMob:addListener('COMBAT_TICK', 'HYDRA_COMBAT_TICK', checkRegrowHead)
end

return g_mixins.families.hydra
