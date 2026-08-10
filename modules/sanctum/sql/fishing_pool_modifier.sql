-- Fishing pool increase, adjust as needed for population

UPDATE fishing_group
SET pool_size = FLOOR(pool_size * 1.5)
