/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

#include <cstrike>
#include <ctbans>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

// Definitions
// CTBans
#define CTBANS_AUTHOR  "Matthew \"MP\" Penner"
#define CTBANS_VERSION "0.0.1-BETA"

// Prefixes
#define PREFIX         "[\x06CT Bans\x01]"
#define ACTION_PREFIX  "[\x06CT Bans\x01]\x08 "
#define CONSOLE_PREFIX "[CT Bans]"

// Limits
#define GROUP_MAX 16
// END Definitions

// Project Models
#include "ctbans/models/ban.sp"
// END Project Models

// Globals
// sm_ctbans_database - "Sets what database the plugin should use." (Default: "ctbans")
ConVar g_cvDatabase;

// g_dbCTBans Stores the active database connection.
Database g_dbCTBans;

// g_hBans stores an array of Bans.
Ban g_hBans[MAXPLAYERS + 1];
// END Globals

// Project Files
#include "ctbans/natives.sp"
#include "ctbans/utils.sp"

// Backend
#include "ctbans/backend/queries.sp"
#include "ctbans/backend/ban.sp"
#include "ctbans/backend/backend.sp"

// Events
#include "ctbans/events/player_team.sp"
// END Project Files

// Plugin Information
public Plugin myinfo = {
    name = "CT Bans",
    author = CTBANS_AUTHOR,
    description = "Ban naughty players from playing on the Counter-Terrorist team.",
    version = CTBANS_VERSION,
    url = "https://matthewp.io"
};
// END Plugin Information

/**
 * OnPluginStart
 * Initiates plugin, registers convars, registers commands, connects to database.
 */
public void OnPluginStart() {
    // Load translations
    LoadTranslations("common.phrases");

    // Create custom convars for the plugin.
    g_cvDatabase = CreateConVar("sm_ctbans_database", "ctbans", "Sets what database the plugin should use.");

    // Generate and load our plugin convar config.
    AutoExecConfig(true, "ctbans");

    // Get the database name from the g_cvDatabase convar.
    char databaseName[64];
    g_cvDatabase.GetString(databaseName, sizeof(databaseName));

    // Attempt connection to the database.
    Database.Connect(Backend_Connnection, databaseName);

    // Events
    // ctbans/events/player_team.sp
    if(!HookEventEx("player_team", Event_PlayerTeamPre, EventHookMode_Pre)) {
        SetFailState("%s Failed to hook \"player_team\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // END Events

    // Create the ban reduce timer.
    CreateTimer(60.0, Timer_BanReduce, _, TIMER_REPEAT);
}

/**
 * OnClientAuthorized
 * Loads client's ban data.
 */
public void OnClientAuthorized(int client, const char[] auth) {
    // Ignore bot users.
    if(StrEqual(auth, "BOT", true)) {
        return;
    }

    g_hBans[client] = null;

    // Attempt to load user's ban information.
    Backend_GetBan(client, auth);
}

/**
 * OnClientDisconnect
 * Prints a disconnect chat message.
 */
public void OnClientDisconnect(int client) {
    // Check if user has a ban.
    if(g_hBans[client] == null) {
        return;
    }

    // Save the users's ban information.
    Backend_UpdateBan(client);

    // Unallocate memory for user ban storage.
    delete g_hBans[client];
}

static Action Timer_BanReduce(Handle timer) {
    // Loop through all online clients.
    for(int client = 1; client <= MaxClients; client++) {
        // Check if the client is invalid.
        if(!IsClientValid(client)) {
            continue;
        }

        // Check if the player is dead.
        if(!IsPlayerAlive(client)) {
            continue;
        }

        Ban ban = g_hBans[client];
        if(ban == null) {
            continue;
        }

        // Check if the ban duration is indefinite.
        if(ban.GetDuration() == 0) {
            continue;
        }

        // Update the ban timeLeft.
        ban.SetTimeLeft(ban.GetTimeLeft() - 1);

        // Check if the ban's timeLeft is lower than 1
        if(ban.GetTimeLeft() < 1) {
            // Make sure the ban's timeLeft is set to 0.
            ban.SetTimeLeft(0);
            ban.SetExpired(true);

            // Update the database.
            Backend_UpdateBan(client);

            // Log the ban removal.
            LogActivity(0, "\x01Removed expired \x07CT Ban\x01 from \x10%N\x01", client);

            // Unallocate the ban's memory.
            delete g_hBans[client];
        }
    }
}
