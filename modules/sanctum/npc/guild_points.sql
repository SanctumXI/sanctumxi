-- ------------------------------
-- Sanctum Guild Point Cap Reduction
-- Reduces max guild point caps to 75%
-- ------------------------------

UPDATE `guild_item_points`
SET `max_points` = FLOOR(`max_points` * 0.75);
