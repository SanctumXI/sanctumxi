-----------------------------------
-- Sanctum Labyrinth Entry NPC
-----------------------------------

local entity = {}

entity.onTrigger = function(player, npc)

    if player:getMainLvl() < 75 then
        player:PrintToPlayer("Only level 75 adventurers may enter the Sanctum Labyrinth.")
        return
    end

    local party = player:getParty()

    if party == nil then
        player:PrintToPlayer("You must be in a party to enter.")
        return
    end

    player:startEvent(1000)

end

entity.onEventFinish = function(player, csid, option)

    if csid == 1000 then

        local party = player:getParty()
        local members = party:getMembers()

        for _, member in pairs(members) do

            if member ~= nil then

                member:setPos(
                    0,
                    0,
                    0,
                    0,
                    182
                )

                member:PrintToPlayer("You have entered the Sanctum Labyrinth.")

            end
        end
    end
end

return entity