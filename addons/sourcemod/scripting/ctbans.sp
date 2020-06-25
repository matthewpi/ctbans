//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

#include <cstrike>
#include <ctbans>
#include <geoip>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

// Definitions
// CTBans
#define CTBANS_AUTHOR  "Matthew \"MP\" Penner"
#define CTBANS_VERSION "0.1.0"

// Prefixes
#define PREFIX         "[\x06CT Bans\x01]"
#define ACTION_PREFIX  "[\x06CT Bans\x01]\x08 "
#define CONSOLE_PREFIX "[CT Bans]"
// END Definitions

// Project Models
#include "ctbans/models/ban.sp"
#include "ctbans/models/player.sp"
// END Project Models

// Globals
// sm_ctbans_database - "Sets what database the plugin should use." (Default: "ctbans")
ConVar g_cvDatabase;

// g_dbCTBans Stores the active database connection.
Database g_dbCTBans;

// g_hBans stores an array of Bans.
Ban g_hBans[MAXPLAYERS + 1];

// g_alDisconnected stores a list of recently disconnected clients.
ArrayList g_alDisconnected;

// g_iMenuSelection stores an array of active menu selections.
int g_iMenuSelection[MAXPLAYERS + 1];

// g_hBanObject stores an array of processing bans.
Ban g_hBanObject[MAXPLAYERS + 1];
// END Globals

// Project Files
#include "ctbans/natives.sp"
#include "ctbans/utils.sp"

// Backend
#include "ctbans/backend/queries.sp"
#include "ctbans/backend/ban.sp"
#include "ctbans/backend/backend.sp"

// Commands
#include "ctbans/commands/ctban.sp"
#include "ctbans/commands/ctban_offline.sp"
#include "ctbans/commands/isbanned.sp"
#include "ctbans/commands/unctban.sp"

// Events
//#include "ctbans/events/jointeam_failed.sp"
#include "ctbans/events/player_chat.sp"
#include "ctbans/events/player_spawn.sp"
#include "ctbans/events/player_team.sp"

// Menus
#include "ctbans/menus/rage.sp"
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
    g_cvDatabase = CreateConVar("sm_ctbans_database", "ctbans", "Sets what database the plugin should use.", FCVAR_PROTECTED);

    // Generate and load our plugin convar config.
    AutoExecConfig(true, "ctbans");

    // Commands
    // ctbans/commands/ctban.sp
    RegAdminCmd("sm_ctban", Command_CTBan, ADMFLAG_BAN, "Bans a player from the Counter-Terrorist team.");
    // ctbans/commands/ctban_offline.sp
    RegAdminCmd("sm_ctban_offline", Command_CTBanOffline, ADMFLAG_BAN, "Bans an offline player from the Counter-Terrorist team.");
    // ctbans/commands/ctban.sp
    RegAdminCmd("sm_unctban", Command_UnCTBan, ADMFLAG_BAN, "Revokes a CT Ban from a client.");
    // ctbans/commands/isbanned.sp
    RegConsoleCmd("sm_isbanned", Command_IsBanned, "Check a player's CT Ban information.");
    // END Commands

    // Events
    // ctbans/events/jointeam_failed.sp
    /*if (!HookEventEx("jointeam_failed", Event_JoinTeamFailed, EventHookMode_Pre)) {
        SetFailState("%s Failed to hook \"jointeam_failed\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }*/
    // ctbans/events/player_spawn.sp
    if (!HookEventEx("player_spawn", Event_PlayerSpawn)) {
        SetFailState("%s Failed to hook \"player_spawn\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // ctbans/events/player_team.sp
    if (!HookEventEx("player_team", Event_PlayerTeam)) {
        SetFailState("%s Failed to hook \"player_team\" event, disabling plugin..", CONSOLE_PREFIX);
        return;
    }
    // END Events

    // Initialize the arraylist.
    g_alDisconnected = CreateArray();

    // Create the ban reduce timer.
    CreateTimer(60.0, Timer_BanReduce, _, TIMER_REPEAT);
}

/**
 * OnConfigsExecuted
 * Connects to the database using the configured convar.
 */
public void OnConfigsExecuted() {
    // Get the database name from the g_cvDatabase convar.
    char databaseName[64];
    g_cvDatabase.GetString(databaseName, sizeof(databaseName));

    // Attempt connection to the database.
    Database.Connect(Backend_Connnection, databaseName);
}

/**
 * OnPluginEnd
 * ?
 */
public void OnPluginEnd() {
    // Loop through all online clients.
    for (int i = 1; i <= MaxClients; i++) {
        // Check if the client is invalid.
        if (!IsClientValid(i)) {
            continue;
        }

        Backend_UpdateBan(i);
    }
}

/**
 * OnClientAuthorized
 * Loads client's ban data.
 */
public void OnClientAuthorized(int client, const char[] auth) {
    // Ignore bot users.
    if (StrEqual(auth, "BOT", true)) {
        return;
    }

    g_hBans[client] = null;
    g_iMenuSelection[client] = -1;
    g_hBanObject[client] = null;

    // Attempt to load user's ban information.
    Backend_GetBan(client, auth);
}

/**
 * OnClientDisconnect
 * Prints a disconnect chat message.
 */
public void OnClientDisconnect(int client) {
    // Get the client's steam id.
    char auth[64];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));

    // Ignore bot users.
    if (StrEqual(auth, "BOT", true)) {
        return;
    }

    char buffer[64];
    for (int i = 0; i < g_alDisconnected.Length-1; i++) {
        Player player = g_alDisconnected.Get(i);
        if (player == null) {
            continue;
        }

        player.GetSteamID(buffer, sizeof(buffer));

        if (StrEqual(buffer, auth, true)) {
            g_alDisconnected.Erase(i);
            break;
        }
    }

    Player player = new Player();
    player.SetSteamID(auth);

    char name[128];
    GetClientName(client, name, sizeof(name));
    player.SetName(name);

    char ipAddress[32];
    GetClientIP(client, ipAddress, sizeof(ipAddress));
    player.SetIpAddress(ipAddress);

    g_alDisconnected.Push(player);

    // Save the users's ban information.
    Backend_UpdateBan(client);

    // Unallocate memory for user ban storage.
    delete g_hBans[client];
}

/**
 * OnMapEnd
 * Called whenever the current map ends.
 */
public void OnMapEnd() {
    // Clear the recently disconnected players list to prevent it from overflowing.
    g_alDisconnected = CreateArray();
}

static Action Timer_BanReduce(Handle timer) {
    // Loop through all online clients.
    for (int client = 1; client <= MaxClients; client++) {
        // Check if the client is invalid.
        if (!IsClientValid(client)) {
            continue;
        }

        // Check if the player is dead.
        if (!IsPlayerAlive(client)) {
            continue;
        }

        Ban ban = g_hBans[client];
        if (ban == null) {
            continue;
        }

        // Check if the ban duration is indefinite.
        if (ban.GetDuration() == 0) {
            continue;
        }

        // Update the ban timeLeft.
        ban.SetTimeLeft(ban.GetTimeLeft() - 1);

        // Check if the ban's timeLeft is lower than 1
        if (ban.GetTimeLeft() < 1) {
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
