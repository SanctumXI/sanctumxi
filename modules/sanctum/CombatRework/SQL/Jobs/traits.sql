-- Sanctum trait progression. Complete current rows and retired keys are module-owned.
DELETE FROM `traits`
WHERE (`traitid`,`job`,`level`,`rank`,`modifier`) IN
(
    (9,3,75,2,370),
    (9,3,76,2,370),
    (13,16,75,1,0),
    (17,2,50,2,291),
    (17,2,81,2,291),
    (18,6,40,1,259),
    (18,6,76,2,259),
    (18,6,83,1,259),
    (18,6,90,2,259),
    (18,19,20,1,259),
    (18,19,40,2,259),
    (18,19,60,3,259),
    (25,1,35,1,485),
    (25,1,60,2,485),
    (25,1,75,3,485),
    (25,1,80,1,485),
    (25,1,87,2,485),
    (25,1,94,3,485),
    (25,7,60,3,485),
    (25,7,75,3,485),
    (25,7,75,4,485),
    (25,7,96,4,485),
    (67,2,75,5,289),
    (67,2,91,5,289),
    (67,19,15,1,289),
    (67,19,25,1,289),
    (67,19,35,2,289),
    (67,19,45,2,289),
    (67,19,55,3,289),
    (67,19,65,3,289),
    (67,19,70,4,289),
    (67,19,86,4,289),
    (68,6,45,1,0),
    (68,6,60,1,0),
    (79,8,75,1,0),
    (84,11,20,1,305),
    (84,11,35,2,305),
    (84,11,50,3,305),
    (84,17,35,1,305),
    (84,17,65,2,305),
    (84,17,95,3,305),
    (101,2,45,1,899),
    (101,2,75,2,899),
    (101,2,77,1,899),
    (101,2,87,2,899),
    (107,1,45,1,903),
    (107,1,58,2,903),
    (107,1,71,3,903),
    (107,5,12,1,903),
    (107,5,37,2,903),
    (107,5,65,3,903),
    (107,9,80,1,903),
    (107,9,87,2,903),
    (107,9,94,3,903),
    (107,10,85,1,903),
    (107,10,95,2,903),
    (108,19,50,1,944),
    (108,19,77,1,944),
    (109,4,50,1,902),
    (109,4,75,2,902),
    (109,4,85,1,902),
    (109,4,95,2,902),
    (109,8,75,4,902),
    (109,8,84,4,902),
    (123,13,25,1,911),
    (123,13,40,2,911),
    (132,10,75,1,454),
    (133,7,75,1,25),
    (138,9,40,1,272),
    (138,9,60,2,272),
    (138,9,75,3,272),
    (138,9,80,3,272),
    (138,18,45,1,272),
    (138,18,65,2,272),
    (139,11,75,1,0)
);

INSERT INTO `traits` VALUES (9,'auto regen',3,75,2,370,2,'ABYSSEA',0);
INSERT INTO `traits` VALUES (13,'conserve mp',16,75,1,0,0,'WOTG',1346);
INSERT INTO `traits` VALUES (17,'counter',2,50,2,291,12,'ABYSSEA',0);
INSERT INTO `traits` VALUES (18,'dual wield',6,40,1,259,10,NULL,0);
INSERT INTO `traits` VALUES (18,'dual wield',6,76,2,259,15,'ABYSSEA',0);
INSERT INTO `traits` VALUES (18,'dual wield',19,20,1,259,10,NULL,0);
INSERT INTO `traits` VALUES (18,'dual wield',19,40,2,259,15,NULL,0);
INSERT INTO `traits` VALUES (18,'dual wield',19,60,3,259,25,NULL,0);
INSERT INTO `traits` VALUES (25,'shield mastery',1,35,1,485,10,'ABYSSEA',0);
INSERT INTO `traits` VALUES (25,'shield mastery',1,60,2,485,20,'ABYSSEA',0);
INSERT INTO `traits` VALUES (25,'shield mastery',1,75,3,485,30,'ABYSSEA',0);
INSERT INTO `traits` VALUES (25,'shield mastery',7,60,3,485,30,'TOAU',0);
INSERT INTO `traits` VALUES (25,'shield mastery',7,75,4,485,40,'ABYSSEA',0);
INSERT INTO `traits` VALUES (67,'subtle blow',2,75,5,289,25,'ABYSSEA',0);
INSERT INTO `traits` VALUES (67,'subtle blow',19,15,1,289,5,'WOTG',0);
INSERT INTO `traits` VALUES (67,'subtle blow',19,35,2,289,10,'WOTG',0);
INSERT INTO `traits` VALUES (67,'subtle blow',19,55,3,289,15,'WOTG',0);
INSERT INTO `traits` VALUES (67,'subtle blow',19,70,4,289,20,'ABYSSEA',0);
INSERT INTO `traits` VALUES (68,'assassin',6,45,1,0,0,'COP',0);
INSERT INTO `traits` VALUES (79,'blood_discipline',8,75,1,0,0,'TOAU',2500);
INSERT INTO `traits` VALUES (84,'recycle',11,20,1,305,10,NULL,0);
INSERT INTO `traits` VALUES (84,'recycle',11,35,2,305,20,NULL,0);
INSERT INTO `traits` VALUES (84,'recycle',11,50,3,305,30,NULL,0);
INSERT INTO `traits` VALUES (84,'recycle',17,35,1,305,10,NULL,0);
INSERT INTO `traits` VALUES (84,'recycle',17,65,2,305,20,NULL,0);
INSERT INTO `traits` VALUES (84,'recycle',17,95,3,305,30,NULL,0);
INSERT INTO `traits` VALUES (101,'tactical guard',2,45,1,899,30,'ABYSSEA',0);
INSERT INTO `traits` VALUES (101,'tactical guard',2,75,2,899,45,'ABYSSEA',0);
INSERT INTO `traits` VALUES (107,'fencer',5,12,1,903,200,'ABYSSEA',0);
INSERT INTO `traits` VALUES (107,'fencer',5,37,2,903,300,'ABYSSEA',0);
INSERT INTO `traits` VALUES (107,'fencer',5,65,3,903,400,'ABYSSEA',0);
INSERT INTO `traits` VALUES (108,'conserve tp',19,50,1,944,15,'ABYSSEA',0);
INSERT INTO `traits` VALUES (109,'occult acumen',4,50,1,902,25,'ABYSSEA',0);
INSERT INTO `traits` VALUES (109,'occult acumen',4,75,2,902,50,'ABYSSEA',0);
INSERT INTO `traits` VALUES (109,'occult acumen',8,75,4,902,100,'ABYSSEA',0);
INSERT INTO `traits` VALUES (123,'daken',13,25,1,911,20,NULL,0);
INSERT INTO `traits` VALUES (123,'daken',13,40,2,911,25,NULL,0);
INSERT INTO `traits` VALUES (132,'eloquence',10,75,1,454,6,NULL,2634);
INSERT INTO `traits` VALUES (133,'challenge',7,75,1,25,3,NULL,770);
INSERT INTO `traits` VALUES (138,'tandem blow',9,40,1,272,5,NULL,0);
INSERT INTO `traits` VALUES (138,'tandem blow',9,60,2,272,10,NULL,0);
INSERT INTO `traits` VALUES (138,'tandem blow',9,75,3,272,15,NULL,0);
INSERT INTO `traits` VALUES (138,'tandem blow',18,45,1,272,5,NULL,0);
INSERT INTO `traits` VALUES (138,'tandem blow',18,65,2,272,10,NULL,0);
INSERT INTO `traits` VALUES (139,'vision',11,75,1,0,0,NULL,2694);
