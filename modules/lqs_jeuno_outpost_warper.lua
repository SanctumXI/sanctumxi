-----------------------------------
-- LQS Example: Outpost Warper
-----------------------------------
-- This example demonstrates the LQS.outpostTeleporter() function
-- which creates a fully-featured outpost teleporter NPC with:
-- - Paginated destination menu
-- - Gil and CP payment options
-- - Optional pre-teleport effects (Signet, etc.)
-- - Level and outpost unlock requirements
-----------------------------------
return LQS.outpostTeleporter({
    name = "Houtzuma TheAFK",
    zone = "Lower_Jeuno",
    pos  = { 28.502, -1.000, 49.313, 122 }, -- !pos 28.502 -1.000 49.313 245,
    look = 1415, -- Hume Uncle model

    -- Apply Signet before teleport (uses rank-based duration)
    preTeleportEffects = { LQS.signetEffect() },

    -- Other defaults:
    -- greeting       = "Welcome to the Outpost Warp Service!"
    -- itemsPerPage   = 5
    teleportDelay  = 1500
    -- animation      = { actionID = 6, animID = 600 }
})
