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

    local function assertWsc(params, expected)
        local fields = { 'str_wsc', 'dex_wsc', 'vit_wsc', 'agi_wsc', 'int_wsc', 'mnd_wsc', 'chr_wsc' }

        for _, field in ipairs(fields) do
            assert(params[field] == expected[field])
        end
    end

    local function assertCases(invoke, cases)
        for _, case in ipairs(cases) do
            local params = invoke(case.id,
            {
                str_wsc        = 0.91,
                dex_wsc        = 0.92,
                vit_wsc        = 0.93,
                agi_wsc        = 0.94,
                int_wsc        = 0.95,
                mnd_wsc        = 0.96,
                chr_wsc        = 0.97,
                ftpMod         = { 9, 9, 9 },
                atkVaries      = { 9, 9, 9 },
                critVaries     = { 0.01, 0.02, 0.03 },
                accVaries      = { 1, 2, 3 },
                ignoredDefense = { 0.01, 0.02, 0.03 },
                numHits        = 9,
                marker         = true,
            })

            assert(params.marker)

            if case.wsc then
                assertWsc(params, case.wsc)
            end

            if case.ftp then
                assertTriplet(params.ftpMod, case.ftp[1], case.ftp[2], case.ftp[3])
            end

            if case.atk then
                assertTriplet(params.atkVaries, case.atk[1], case.atk[2], case.atk[3])
            elseif case.removeAtk then
                assert(params.atkVaries == nil)
            end

            if case.crit then
                assertTriplet(params.critVaries, case.crit[1], case.crit[2], case.crit[3])
            end

            if case.acc then
                assertTriplet(params.accVaries, case.acc[1], case.acc[2], case.acc[3])
            end

            if case.defense then
                assertTriplet(params.ignoredDefense, case.defense[1], case.defense[2], case.defense[3])
            elseif case.removeDefense then
                assert(params.ignoredDefense == nil)
            end

            if case.hits then
                assert(params.numHits == case.hits)
            end
        end
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

    it('applies the requested dagger formulas', function()
        assertCases(physical,
        {
            {
                id = xi.weaponskill.VIPER_BITE,
                wsc = { dex_wsc = 0.5 },
                ftp = { 1.0, 1.25, 1.5 },
                atk = { 1.75, 1.75, 1.75 },
            },
            { id = xi.weaponskill.SHADOWSTITCH, wsc = { chr_wsc = 0.5 }, ftp = { 1.5, 1.75, 2.0 } },
            { id = xi.weaponskill.DANCING_EDGE, ftp = { 1.0, 1.2, 1.4 } },
            { id = xi.weaponskill.SHARK_BITE, atk = { 1.5, 1.5, 1.5 } },
            { id = xi.weaponskill.MERCY_STROKE, ftp = { 3.5, 3.75, 4.0 }, atk = { 1.5, 1.5, 1.5 } },
            { id = xi.weaponskill.MANDALIC_STAB, ftp = { 3.0, 3.5, 4.0 }, atk = { 1.5, 1.5, 1.5 } },
        })

        assertCases(magic,
        {
            { id = xi.weaponskill.GUST_SLASH, wsc = { dex_wsc = 0.2, int_wsc = 0.3 } },
            { id = xi.weaponskill.CYCLONE, wsc = { dex_wsc = 0.3, int_wsc = 0.4 } },
            { id = xi.weaponskill.AEOLIAN_EDGE, wsc = { dex_wsc = 0.3, int_wsc = 0.3 } },
        })
    end)

    it('applies the requested great sword formulas', function()
        assertCases(physical,
        {
            { id = xi.weaponskill.HARD_SLASH, ftp = { 2.0, 2.25, 2.5 } },
            { id = xi.weaponskill.POWER_SLASH, crit = { 0.25, 0.5, 0.75 } },
            {
                id = xi.weaponskill.SHOCKWAVE,
                wsc = { str_wsc = 0.3, mnd_wsc = 0.5 },
                ftp = { 1.5, 2.0, 2.5 },
            },
            { id = xi.weaponskill.CRESCENT_MOON, ftp = { 1.5, 2.0, 2.5 }, atk = { 1.5, 1.5, 1.5 } },
            {
                id = xi.weaponskill.SICKLE_MOON,
                wsc = { str_wsc = 0.2, agi_wsc = 0.4 },
                ftp = { 2.0, 2.5, 3.0 },
            },
            {
                id = xi.weaponskill.SPINNING_SLASH,
                wsc = { str_wsc = 0.5 },
                ftp = { 2.0, 2.5, 3.0 },
                removeAtk = true,
            },
            { id = xi.weaponskill.GROUND_STRIKE, removeAtk = true },
            { id = xi.weaponskill.SCOURGE, ftp = { 3.0, 3.5, 4.0 }, atk = { 1.5, 1.5, 1.5 } },
            {
                id = xi.weaponskill.TORCLEAVER,
                wsc = { str_wsc = 0.3, vit_wsc = 0.4 },
                ftp = { 4.0, 4.5, 5.5 },
            },
        })

        assertCases(magic,
        {
            { id = xi.weaponskill.FROSTBITE, ftp = { 1.5, 2.0, 2.5 } },
            { id = xi.weaponskill.FREEZEBITE, wsc = { int_wsc = 0.6 }, ftp = { 1.5, 2.0, 2.5 } },
            { id = xi.weaponskill.HERCULEAN_SLASH, wsc = { vit_wsc = 1.0 }, ftp = { 3.0, 3.3, 3.6 } },
        })
    end)

    it('applies the requested axe and scythe formulas', function()
        assertCases(physical,
        {
            { id = xi.weaponskill.SMASH_AXE, ftp = { 1.25, 1.5, 1.75 } },
            { id = xi.weaponskill.GALE_AXE, wsc = { str_wsc = 0.4, int_wsc = 0.2 } },
            { id = xi.weaponskill.AVALANCHE_AXE, wsc = { str_wsc = 0.4, int_wsc = 0.2 } },
            { id = xi.weaponskill.SPINNING_AXE, wsc = { str_wsc = 0.3, dex_wsc = 0.5 } },
            {
                id = xi.weaponskill.CALAMITY,
                wsc = { str_wsc = 0.4, vit_wsc = 0.4 },
                ftp = { 2.0, 2.5, 3.0 },
                atk = { 1.25, 1.25, 1.25 },
            },
            { id = xi.weaponskill.DECIMATION, ftp = { 1.75, 2.0, 2.5 }, acc = { 20, 40, 80 } },
            {
                id = xi.weaponskill.ONSLAUGHT,
                wsc = { str_wsc = 0.3, dex_wsc = 0.3 },
                ftp = { 2.75, 3.25, 4.0 },
                atk = { 1.25, 1.25, 1.25 },
            },
            {
                id = xi.weaponskill.NIGHTMARE_SCYTHE,
                wsc = { str_wsc = 0.25, int_wsc = 0.5 },
                ftp = { 1.25, 1.5, 1.75 },
            },
            {
                id = xi.weaponskill.SPINNING_SCYTHE,
                wsc = { str_wsc = 0.3, int_wsc = 0.2 },
                ftp = { 1.0, 1.5, 2.0 },
            },
            {
                id = xi.weaponskill.VORPAL_SCYTHE,
                wsc = { str_wsc = 0.5, int_wsc = 0.2 },
                crit = { 0.33, 0.66, 1.0 },
            },
            {
                id = xi.weaponskill.GUILLOTINE,
                wsc = { str_wsc = 0.25, int_wsc = 0.25 },
                ftp = { 1.0, 1.0, 1.0 },
                hits = 4,
            },
            {
                id = xi.weaponskill.CROSS_REAPER,
                wsc = { str_wsc = 0.5, int_wsc = 0.3 },
                ftp = { 2.25, 2.5, 3.0 },
            },
            {
                id = xi.weaponskill.INSURGENCY,
                wsc = { str_wsc = 0.2, int_wsc = 0.5 },
                ftp = { 1.0, 1.25, 1.5 },
                hits = 4,
            },
        })
    end)

    it('applies the requested polearm, club, and staff formulas', function()
        assertCases(physical,
        {
            {
                id = xi.weaponskill.VORPAL_THRUST,
                ftp = { 1.0, 1.25, 1.5 },
                crit = { 0.33, 0.66, 1.0 },
            },
            {
                id = xi.weaponskill.WHEELING_THRUST,
                ftp = { 1.5, 1.75, 2.0 },
                defense = { 0.2, 0.4, 0.6 },
            },
            {
                id = xi.weaponskill.IMPULSE_DRIVE,
                wsc = { str_wsc = 0.3, dex_wsc = 0.3 },
                ftp = { 2.0, 2.5, 3.0 },
                removeDefense = true,
            },
            { id = xi.weaponskill.GEIRSKOGUL, atk = { 1.5, 1.5, 1.5 } },
            {
                id = xi.weaponskill.DRAKESBANE,
                wsc = { str_wsc = 0.3, dex_wsc = 0.3 },
                removeAtk = true,
            },
            { id = xi.weaponskill.STARDIVER, wsc = { str_wsc = 0.8 }, ftp = { 0.75, 1.25, 1.5 } },
            { id = xi.weaponskill.BRAINSHAKER, ftp = { 1.0, 1.25, 1.5 } },
            { id = xi.weaponskill.SKULLBREAKER, wsc = { str_wsc = 0.6 } },
            {
                id = xi.weaponskill.TRUE_STRIKE,
                wsc = { str_wsc = 0.3, mnd_wsc = 0.3 },
                ftp = { 1.25, 1.5, 1.75 },
                crit = { 1.0, 1.0, 1.0 },
                atk = { 1.5, 1.5, 1.5 },
            },
            {
                id = xi.weaponskill.JUDGMENT,
                wsc = { str_wsc = 0.4, mnd_wsc = 0.4 },
                ftp = { 2.5, 3.0, 3.5 },
            },
            {
                id = xi.weaponskill.HEXA_STRIKE,
                wsc = { str_wsc = 0.2 },
                ftp = { 1.0, 1.0, 1.0 },
                crit = { 0.1, 0.3, 0.5 },
            },
            {
                id = xi.weaponskill.BLACK_HALO,
                wsc = { str_wsc = 0.4, int_wsc = 0.5 },
                ftp = { 1.5, 2.5, 3.0 },
            },
            {
                id = xi.weaponskill.RANDGRITH,
                wsc = { str_wsc = 0.4, mnd_wsc = 0.4 },
                ftp = { 2.75, 3.0, 3.25 },
                atk = { 2.0, 2.0, 2.0 },
            },
            {
                id = xi.weaponskill.GATE_OF_TARTARUS,
                wsc = { int_wsc = 0.6 },
                ftp = { 3.0, 3.5, 4.0 },
            },
        })

        assertCases(magic,
        {
            { id = xi.weaponskill.EARTH_CRUSHER, ftp = { 1.95, 2.6, 3.25 } },
            { id = xi.weaponskill.VIDOHUNIR, wsc = { int_wsc = 0.5 }, ftp = { 2.0, 2.5, 3.0 } },
            {
                id = xi.weaponskill.GARLAND_OF_BLISS,
                wsc = { int_wsc = 0.5, mnd_wsc = 0.5 },
                ftp = { 2.5, 3.0, 3.5 },
            },
            {
                id = xi.weaponskill.OMNISCIENCE,
                wsc = { int_wsc = 0.5, mnd_wsc = 0.5 },
                ftp = { 2.5, 3.0, 3.5 },
            },
        })
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
