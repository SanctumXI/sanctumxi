UPDATE `abilities`
SET `level` = 1
WHERE (`abilityId` = 199 AND `name` = 'steps')
   OR (`abilityId` = 201 AND `name` = 'quickstep');

UPDATE `abilities`
SET `level` = 10
WHERE (`abilityId` = 200 AND `name` = 'flourishes_i')
   OR (`abilityId` = 204 AND `name` = 'animated_flourish');

UPDATE `abilities`
SET `isAOE` = 1, `radius` = 10
WHERE `abilityId` = 197 AND `name` = 'chocobo_jig';
