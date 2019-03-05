/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

// ctbans_bans - Stores all servers.
#define TABLE_BANS "\
CREATE TABLE IF NOT EXISTS `ctbans_bans` (\
    `id`        INT(11) AUTO_INCREMENT,\
    `name`      VARCHAR(128) CHARACTER SET 'utf8' DEFAULT '' NOT NULL,\
    `steamId`   VARCHAR(64) NOT NULL,\
    `ipAddress` VARCHAR(16) DEFAULT NULL NULL,\
    `duration`  INT(11) NOT NULL,\
    `reason`    VARCHAR(128) NOT NULL,\
    `admin`     VARCHAR(64) NOT NULL,\
    `removedBy` VARCHAR(64) DEFAULT NULL NULL,\
    `removedAt` TIMESTAMP DEFAULT NULL NULL,\
    `expired`   TINYINT(1) DEFAULT 0 NOT NULL,\
    `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP() NOT NULL,\
    `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP() NOT NULL ON UPDATE CURRENT_TIMESTAMP(),\
    PRIMARY KEY (`id`, `name`, `steamId`, `admin`, `ipAddress`),\
    CONSTRAINT `ctbans_bans_id_uindex` UNIQUE (`id`)\
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

// Gets a client's ban.
#define GET_BAN "\
SELECT `ctbans_bans`.`id`, `ctbans_bans`.`steamId`, `ctbans_bans`.`ipAddress`, `ctbans_bans`.`duration`,\
    `ctbans_bans`.`timeLeft`, `ctbans_bans`.`reason`, `ctbans_bans`.`admin`, `ctbans_bans`.`removedBy`, UNIX_TIMESTAMP(`ctbans_bans`.`removedAt`) AS `removedAt`,\
    `ctbans_bans`.`expired`, UNIX_TIMESTAMP(`ctbans_bans`.`createdAt`) AS `createdAt`\
FROM `ctbans_bans`\
    WHERE `ctbans_bans`.`steamId` = '%s' LIMIT 1;\
"

// Inserts a new ban.
#define INSERT_BAN "\
INSERT INTO `ctbans_bans` (`name`, `steamId`, `ipAddress`, `duration`, `timeLeft`, `reason`, `admin`) VALUES ('%s', '%s', '%s', %i, %i, '%s', '%s');\
"

// Updates a client's ban.
#define UPDATE_BAN "\
UPDATE `ctbans_bans` SET `ctbans_bans`.`timeLeft` = %i, `ctbans_bans`.`expired` = %i WHERE `ctbans_bans`.`steamId` = '%s' AND `ctbans_bans`.`removedAt` IS NULL LIMIT 1;\
"

// Updates a client's ban.
#define UPDATE_BAN_REMOVED "\
UPDATE `ctbans_bans` SET `ctbans_bans`.`removedBy` = '%s', `ctbans_bans`.`removedAt` = FROM_UNIXTIME(%i) WHERE `ctbans_bans`.`steamId` = '%s' AND `ctbans_bans`.`removedAt` IS NULL LIMIT 1;\
"
