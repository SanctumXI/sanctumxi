-- XP Scroll changes

local m = Module:new('xp_scroll_changes')

m:addOverride('xi.items.page_from_miratetes_memoirs.onItemUse', function(target)
    target:addExp(xi.settings.main.EXP_RATE * math.randomInt(3000, 3500))
end)


m:addOverride('xi.items.page_from_the_dragon_chronicles.onItemUse', function(target)
    target:addExp(xi.settings.main.EXP_RATE * math.randomInt(2500, 3000))
end)


return m
