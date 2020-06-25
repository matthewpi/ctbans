//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

// ctbans_bans - Stores all servers.
#define TABLE_BANS "\
CREATE TABLE IF NOT EXISTS `ctbans_bans` (\
    `id`        INT(11) AUTO_INCREMENT,\
    `name`      VARCHAR(128) CHARACTER SET 'utf8' DEFAULT 'unnamed' NOT NULL,\
    `steamId`   VARCHAR(64) NOT NULL,\
    `ipAddress` VARCHAR(16) DEFAULT NULL NULL,\
    `country`   VARCHAR(4) NULL,\
    `duration`  INT(11) NOT NULL,\
    `timeLeft`  INT(11) NOT NULL,\
    `reason`    VARCHAR(128) NOT NULL,\
    `admin`     VARCHAR(64) DEFAULT 'STEAM_ID_SERVER' NOT NULL,\
    `removedBy` VARCHAR(64) DEFAULT NULL NULL,\
    `removedAt` TIMESTAMP DEFAULT NULL NULL,\
    `expired`   TINYINT(1) DEFAULT 0 NOT NULL,\
    `inGame`    TINYINT(1) DEFAULT 1 NOT NULL,\
    `createdAt` TIMESTAMP NOT NULL,\
    `updatedAt` TIMESTAMP NOT NULL,\
    PRIMARY KEY (`id`, `name`, `steamId`, `ipAddress`, `admin`),\
    CONSTRAINT `ctbans_bans_id_uindex` UNIQUE (`id`)\
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

#define TABLE_BANS_INDEX "\
CREATE INDEX IF NOT EXISTS ctbans_bans_steamId_index ON ctbans_bans (steamId);\
"

// Gets a client's ban.
#define GET_BAN "\
SELECT `ctbans_bans`.`id`, `ctbans_bans`.`steamId`, `ctbans_bans`.`ipAddress`, `ctbans_bans`.`country`, `ctbans_bans`.`duration`, \
    `ctbans_bans`.`timeLeft`, `ctbans_bans`.`reason`, `ctbans_bans`.`admin`, `ctbans_bans`.`removedBy`, UNIX_TIMESTAMP(`ctbans_bans`.`removedAt`) AS `removedAt`, \
    `ctbans_bans`.`expired`, UNIX_TIMESTAMP(`ctbans_bans`.`createdAt`) AS `createdAt` \
FROM `ctbans_bans` \
    WHERE `ctbans_bans`.`steamId` = '%s' AND `ctbans_bans`.`removedAt` IS NULL AND `ctbans_bans`.`expired` = 0 LIMIT 1;\
"

// Inserts a new ban.
#define INSERT_BAN "\
INSERT INTO `ctbans_bans` (`name`, `steamId`, `ipAddress`, `country`, `duration`, `timeLeft`, `reason`, `admin`, `removedAt`, `createdAt`, `updatedAt`) VALUES ('%s', '%s', '%s', '%s', %i, %i, '%s', '%s', NULL, FROM_UNIXTIME(%i), FROM_UNIXTIME(%i));\
"

// Updates a client's ban.
#define UPDATE_BAN "\
UPDATE `ctbans_bans` SET `ctbans_bans`.`timeLeft` = %i, `ctbans_bans`.`expired` = %i WHERE `ctbans_bans`.`steamId` = '%s' AND `ctbans_bans`.`removedAt` IS NULL AND `ctbans_bans`.`expired` = 0 LIMIT 1;\
"

// Updates a client's ban.
#define UPDATE_BAN_REMOVED "\
UPDATE `ctbans_bans` SET `ctbans_bans`.`removedBy` = '%s', `ctbans_bans`.`removedAt` = FROM_UNIXTIME(%i), `ctbans_bans`.`expired` = %i WHERE `ctbans_bans`.`steamId` = '%s' AND `ctbans_bans`.`removedAt` IS NULL AND `ctbans_bans`.`expired` = 0 LIMIT 1;\
"
