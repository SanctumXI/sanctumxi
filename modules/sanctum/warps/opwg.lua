return LQS.outpostTeleporter({
    name = "Outpost Liaison",
    zone = "Aht_Urhgan_Whitegate",
    pos  = { -80.738, 0.000, -80.494, 128 }, -- !pos -80.738 0.000 -80.494 50
    look = 1415, -- Hume Uncle model

    -- Apply Signet before teleport (optional)
    -- Uses rank-based duration calculation
    -- preTeleportEffects = { LQS.signetEffect() },

    -- Optional overrides (uncomment to customize)
    -- greeting       = "Welcome to the Outpost Warp Service!",
    -- itemsPerPage   = 5,
    teleportDelay          = 1500,
    hideLockedDestinations = true,
    addonMenu              = true,

    -- Override specific outpost costs (optional)
    -- outpostOverrides = {
    --     [xi.region.RONFAURE] = { gil = 50, cp = 5 },
    -- },

    -- No pre-teleport effects (omit preTeleportEffects or set to {})
    preTeleportEffects = {},

    -- Custom animation (optional)
    -- animation = { actionID = 6, animID = 600 },
})
