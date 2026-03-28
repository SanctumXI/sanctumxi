-- --------------------------------------------------------
-- Guild Point Rewards - RoV Adjustment
-- --------------------------------------------------------
-- Dividing Max Values by 2 due to guild points being tripled in 11/08/2016.
-- Patch Notes: The maximum number of points that may be earned from delivering guild point items has been increased.
-- Patch Notes Link: https://forum.square-enix.com/ffxi/threads/51624
-- --------------------------------------------------------

-- Divide all max_points by 2 for LSB adjustment
UPDATE `guild_item_points`
SET `max_points` = `max_points` / 2;
