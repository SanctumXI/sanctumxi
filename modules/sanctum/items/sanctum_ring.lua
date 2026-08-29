local m = Module:new('sanctum_ring')

m:addOverride('xi.items.caliber_ring.onItemUse', function(target)
    xi.itemUtils.addItemExpEffect(
        target,
        xi.effect.DEDICATION,
        100,
        43200,
        20000)
end)

return m
