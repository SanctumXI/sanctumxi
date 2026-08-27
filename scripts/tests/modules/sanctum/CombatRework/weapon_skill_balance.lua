describe('Sanctum weapon skill balance adjustments', function()
    local captured

    local function replaceFunction(path, func)
        stub(path, func)
        local parts = {}
        for part in path:gmatch('[^.]+') do
            table.insert(parts, part)
        end

        local parent = _G
        for index = 1, #parts - 1 do
            parent = parent[parts[index]]
        end

        parent[parts[#parts]] = func
    end

    local function applyModule(path)
        local module = dofile(path)
        for _, override in ipairs(module.overrides) do
            if
                override.name == 'xi.weaponskills.doPhysicalWeaponskill' or
                override.name == 'xi.weaponskills.doMagicWeaponskill'
            then
                local parts = {}
                for part in override.name:gmatch('[^.]+') do
                    table.insert(parts, part)
                end

                local parent = _G
                for index = 1, #parts - 1 do
                    parent = parent[parts[index]]
                end

                applyOverride(parent, parts[#parts], override.func, override.name, path)
            end
        end
    end

    local function assertTriplet(values, first, second, third)
        assert(values[1] == first and values[2] == second and values[3] == third)
    end

    local function physical(wsID, params)
        xi.weaponskills.doPhysicalWeaponskill({}, {}, wsID, params or {}, 1000, {}, true, nil)
        return captured
    end

    local function magic(wsID, params)
        xi.weaponskills.doMagicWeaponskill({}, {}, wsID, params or {}, 1000, {}, true)
        return captured
    end

    before_each(function()
        captured = nil

        replaceFunction('xi.weaponskills.doPhysicalWeaponskill', function(_, _, _, params)
            captured = params
            return 101, false, 1, 0
        end)

        replaceFunction('xi.weaponskills.doMagicWeaponskill', function(_, _, _, params)
            captured = params
            return 103, false, 1, 0
        end)

        applyModule('modules/sanctum/CombatRework/Lua/WeaponSkills/general.lua')
    end)

    it('applies the requested hand-to-hand formulas', function()
        local params = physical(xi.weaponskill.SHOULDER_TACKLE, { vit_wsc = 0.3 })
        assert(params.vit_wsc == 0.4)

        params = physical(xi.weaponskill.ONE_INCH_PUNCH, { str_wsc = 0.4 })
        assert(params.str_wsc == 0.2)
        assertTriplet(params.ignoredDefense, 0.25, 0.5, 0.75)

        params = physical(xi.weaponskill.EXPLODING_PALM, { str_wsc = 0.75, dex_wsc = 0.5 })
        assert(params.str_wsc == 0.5 and params.dex_wsc == 0.3)

        params = physical(xi.weaponskill.DRAGON_KICK, { str_wsc = 1.0, vit_wsc = 0.5 })
        assert(params.str_wsc == 0.3 and params.dex_wsc == 0.5 and params.vit_wsc == nil)
        assertTriplet(params.ftpMod, 1.5, 2.0, 2.5)
        assertTriplet(params.atkVaries, 1.5, 1.5, 1.5)

        params = physical(xi.weaponskill.FINAL_HEAVEN, { str_wsc = 0.6 })
        assert(params.str_wsc == 0.6 and params.mnd_wsc == 0.6)
        assertTriplet(params.ftpMod, 2.45, 3.0, 3.45)
        assertTriplet(params.atkVaries, 1.3, 1.425, 1.55)

        params = physical(xi.weaponskill.STRINGING_PUMMEL, { str_wsc = 0.32, vit_wsc = 0.32 })
        assert(params.str_wsc == 0.3 and params.dex_wsc == 0.3 and params.vit_wsc == nil)

        params = physical(xi.weaponskill.VICTORY_SMITE, { str_wsc = 0.6, multiHitfTP = true })
        assert(params.str_wsc == 0.4 and params.multiHitfTP)
        assertTriplet(params.ftpMod, 2.0, 2.5, 3.0)
        assertTriplet(params.critVaries, 0.2, 0.4, 0.6)
    end)

    it('applies the requested sword formulas while retaining unlisted properties', function()
        local params = magic(xi.weaponskill.BURNING_BLADE, { str_wsc = 0.2, int_wsc = 0.2, ele = xi.element.FIRE })
        assert(params.str_wsc == 0.2 and params.int_wsc == 0.3 and params.ele == xi.element.FIRE)

        params = physical(xi.weaponskill.FLAT_BLADE, { str_wsc = 0.3 })
        assertTriplet(params.ftpMod, 1.0, 1.5, 2.0)
        assert(params.str_wsc == 0.3)

        params = magic(xi.weaponskill.SHINING_BLADE, { str_wsc = 0.2, mnd_wsc = 0.2 })
        assert(params.str_wsc == 0.2 and params.mnd_wsc == 0.3)

        params = magic(xi.weaponskill.SERAPH_BLADE, { str_wsc = 0.3, mnd_wsc = 0.3 })
        assert(params.str_wsc == 0.3 and params.mnd_wsc == 0.4)

        params = physical(xi.weaponskill.CIRCLE_BLADE, { str_wsc = 0.35 })
        assertTriplet(params.ftpMod, 1.0, 1.5, 2.0)
        assert(params.str_wsc == 0.35)

        params = physical(xi.weaponskill.SAVAGE_BLADE, { str_wsc = 0.4, mnd_wsc = 0.4 })
        assert(params.str_wsc == 0.4 and params.agi_wsc == 0.4 and params.mnd_wsc == nil)
        assertTriplet(params.atkVaries, 1.2, 1.2, 1.2)

        params = physical(xi.weaponskill.SWIFT_BLADE, { vit_wsc = 0.5, mnd_wsc = 0.4, accVaries = { 15, 30, 60 } })
        assert(params.str_wsc == 0.5 and params.dex_wsc == 0.5)
        assert(params.vit_wsc == nil and params.mnd_wsc == nil and params.accVaries[2] == 30)
        assertTriplet(params.ftpMod, 1.25, 1.5, 1.75)

        params = physical(xi.weaponskill.REQUIESCAT, { mnd_wsc = 0.85, atkVaries = { 0.8, 0.9, 1.0 } })
        assert(params.str_wsc == 0.2 and params.mnd_wsc == 0.7)
        assertTriplet(params.ftpMod, 0.9, 1.1, 1.3)
        assertTriplet(params.atkVaries, 0.8, 0.9, 1.0)

        params = physical(xi.weaponskill.KNIGHTS_OF_ROUND, { ftpMod = { 3, 3, 3 } })
        assertTriplet(params.atkVaries, 1.5, 1.5, 1.5)
        assertTriplet(params.ftpMod, 3, 3, 3)
    end)

    it('applies the requested great katana formulas while retaining hybrid flags', function()
        local params = physical(xi.weaponskill.TACHI_HOBAKU, { str_wsc = 0.3 })
        assertTriplet(params.ftpMod, 1.0, 1.5, 2.0)
        assertTriplet(params.atkVaries, 1.5, 1.5, 1.5)

        params = physical(xi.weaponskill.TACHI_GOTEN, { str_wsc = 0.3, hybridWS = true })
        assert(params.str_wsc == 0.3 and params.int_wsc == 0.3 and params.hybridWS)
        assertTriplet(params.ftpMod, 1.0, 1.5, 2.0)

        params = physical(xi.weaponskill.TACHI_KAGERO, { str_wsc = 0.5, hybridWS = true })
        assert(params.str_wsc == 0.5 and params.int_wsc == 0.3 and params.hybridWS)

        params = physical(xi.weaponskill.TACHI_JINPU, { str_wsc = 0.4, hybridWS = true, numHits = 2 })
        assert(params.str_wsc == 0.3 and params.int_wsc == 0.3 and params.numHits == 2)
        assertTriplet(params.ftpMod, 1.0, 1.5, 2.0)

        params = physical(xi.weaponskill.TACHI_KOKI, { str_wsc = 0.5, mnd_wsc = 0.3, hybridWS = true })
        assert(params.str_wsc == 0.3 and params.mnd_wsc == 0.3 and params.hybridWS)
        assertTriplet(params.ftpMod, 1.0, 1.5, 2.0)

        params = physical(xi.weaponskill.TACHI_KAITEN, { str_wsc = 0.6 })
        assert(params.str_wsc == 0.6)
        assertTriplet(params.ftpMod, 2.5, 3.0, 3.5)
        assertTriplet(params.atkVaries, 1.5, 1.5, 1.5)

        params = physical(xi.weaponskill.TACHI_FUDO, { str_wsc = 0.6 })
        assert(params.str_wsc == 0.6)
        assertTriplet(params.ftpMod, 3.5, 4.0, 5.0)
        assertTriplet(params.atkVaries, 1.5, 1.5, 1.5)
    end)
end)
