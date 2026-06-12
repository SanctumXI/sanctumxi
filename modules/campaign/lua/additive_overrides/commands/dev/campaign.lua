-----------------------------------
-- func: campaign <command> (player)
-- commands:
-- !campaign start (player) starts campaign for the current player
-- !campaign stop  (player) stops campaign (if any) currently running in the player's zone
-- !campaign win (player) win the campaign (if any) currently running in the player's zone
-----------------------------------
require("modules/contrib/lua/additive_overrides/systems/campaign/campaign_core")
-----------------------------------
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = "ss"
}

local function error(player, msg)
    local usage = "Usage: !campaign <command> (player)"
    player:PrintToPlayer(msg .. "\n" .. usage)
end

commandObj.onTrigger = function(player, command)
    local zone = player:getZone()
    local zoneID = zone:getID()
	local isbattle = GetBattleStatus(zoneID)
    switch(command): caseof
    {
        ["start"] = function()
            xi.campaign.start(player)
            player:PrintToPlayer(string.format("%s campaign started", player:getZoneName()))
        end,

        ["stop"] = function()
            xi.campaign.stop(player)
            player:PrintToPlayer(string.format("%s campaign stopped", player:getZoneName()))
        end,

        ["win"] = function()
            xi.campaign.win(player)
        end,
        ["check"] = function()
            player:PrintToPlayer(string.format("Current Status: %d", isbattle), xi.msg.channel.SYSTEM_3)
        end,
    }
end
return commandObj