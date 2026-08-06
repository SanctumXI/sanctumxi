-- Sanctum Blue Magic trait thresholds. Complete current rows and retired keys are module-owned.
DELETE FROM `blue_traits`
WHERE (`trait_category`,`trait_points_needed`,`modifier`,`tier`) IN
(
    (14,2,369,1),
    (14,8,369,1)
);

INSERT INTO `blue_traits` VALUES (14,8,10,369,1,1,0); -- Auto Refresh (1) -- Only tier available to BLU

