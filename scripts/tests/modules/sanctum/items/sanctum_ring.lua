describe('Sanctum Ring', function()
    it('applies the configured Dedication effect', function()
        local item = dofile('scripts/items/caliber_ring.lua')
        local module = dofile('modules/sanctum/items/sanctum_ring.lua')
        local applied

        for _, override in ipairs(module.overrides) do
            if override.name == 'xi.items.caliber_ring.onItemUse' then
                applyOverride(item, 'onItemUse', override.func, override.name, '')
            end
        end

        stub('xi.itemUtils.addItemExpEffect', function(target, effect, power, duration, cap)
            applied = { target, effect, power, duration, cap }
        end)

        local target = {}
        item.onItemUse(target)

        assert(applied[1] == target)
        assert(applied[2] == xi.effect.DEDICATION)
        assert(applied[3] == 100)
        assert(applied[4] == 43200)
        assert(applied[5] == 20000)
    end)
end)
