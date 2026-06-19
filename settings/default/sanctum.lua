-----------------------------------
-- SANCTUM SETTINGS
-----------------------------------
-- Custom Sanctum-specific server settings.
-- Attached to `xi.settings.sanctum`; readable from C++ via settings::get("sanctum.KEY") and from any script.
-----------------------------------

xi = xi or {}
xi.settings = xi.settings or {}

xi.settings.sanctum =
{
    -- Skillchain / Magic Burst EXP Bonus
    SCMB_EXP_BONUS     = 2.0,  -- Percentage of Skillchain and Magic Burst damage used as a multiplier for the EXP bonus.
    SCMB_EXP_BONUS_CAP = 5000, -- Maximum EXP bonus granted from Skillchain and Magic Burst. Default 5000.
}
