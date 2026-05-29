local entity = {}

local rewards = {

    14550,
    16001,
    18754,

}

entity.onTrigger = function(player, npc)

    local reward = rewards[math.random(#rewards)]

    player:addItem(reward)

    player:messageSpecial(ITEM_OBTAINED, reward)

    player:PrintToPlayer("You obtain a Sanctum reward!")

    npc:setStatus(xi.status.DISAPPEAR)

end

return entity