require("modules/module_utils")
local m = Module:new("Sea_Palace_Doors_KI")
local doors = {
"_iyd",
"_iye",
"_iyf",
"_iyg",
"_iyh",
"_iyi",
"_iyj",
"_iyk",
"_iyl",
"_iym",
"_iyn",
"_iyo",
"_iyp",
}
for _, door in ipairs(doors) do
m:addOverride(
"xi.zones.Grand_Palace_of_HuXzoi.npcs." .. door .. ".onTrigger",
function(player, npc)
if player:hasKeyItem(xi.ki.TEAR_OF_ALTANA) then
npc:openDoor(5)
return
end
end
)
end
return m
