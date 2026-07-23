-----------------------------------
-- Energy Steal
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

-- https://www.bg-wiki.com/ffxi/Energy_Steal
weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local fTPAnchors = { 1.5, 2.5, 3.5 }

    local startingAnchor = math.floor(tp / 1000)

    local multiplier = 0

    if tp >= 3000 then
        multiplier = fTPAnchors[3]
    else
        local basefTP   = fTPAnchors[startingAnchor]
        local nextfTP   = fTPAnchors[startingAnchor + 1]
        local multPerTP = (nextfTP - basefTP) / 1000 * (tp - 1000 * startingAnchor)
        -- TP = 1250; multiplier = 1.0 + ( (2.1 - 1.0) / 1000 * (1250 - (1000 * 1))
        --            multiplier = 1.0 + (1.0 / 1000) * 250)
        --            multiplier = 1.0 + 0.275 = 1.275
        multiplier = basefTP + multPerTP
    end

    local skill = player:getSkillLevel(xi.skill.DAGGER)
    local wsc   = player:getStat(xi.mod.MND) * 1.0

    local hpStolen = math.floor((math.floor(skill * 0.11) + wsc) * multiplier)

    if target:isUndead() then
        hpStolen = 0
    else
        hpStolen = math.min(hpStolen, target:getHP())

        target:takeDamage(hpStolen, player, xi.attackType.PHYSICAL, xi.damageType.PIERCING)
        player:addHP(hpStolen)
    end

    action:messageID(target:getID(), xi.msg.basic.SKILL_DRAIN_HP)
    action:param(target:getID(), hpStolen)

    return 1, 0, false, hpStolen
end

return weaponskillObject
