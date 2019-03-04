/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * AskPluginLoad2
 * Registers ctbans as a plugin library and registers our natives.
 */
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    RegPluginLibrary("ctbans");
    CreateNative("CTBans_AddBan", Native_AddBan);
    CreateNative("CTBans_RemoveBan", Native_RemoveBan);
    return APLRes_Success;
}

/**
 * Native_AddBan
 * Issues a ban to a client.
 */
public int Native_AddBan(Handle plugin, int params) {
    // Get all the function arguments.
    int client = GetNativeCell(1);
    int admin = GetNativeCell(2);
    int duration = GetNativeCell(3);
    char reason[128];
    GetNativeString(4, reason, sizeof(reason));

    // Get if the client already has a ban.
    if(g_hBans[client] != null) {
        return;
    }

    // Get the client's name.
    char clientName[64];
    GetClientName(client, clientName, sizeof(clientName));

    // Get the client's steam id.
    char clientSteamId[64];
    GetClientAuthId(client, AuthId_Steam2, clientSteamId, sizeof(clientSteamId));

    // Get the client's ip address.
    char clientIpAddress[16];
    GetClientIP(client, clientIpAddress, sizeof(clientIpAddress));

    // Get the admin's steam id.
    char adminSteamId[64];
    GetClientAuthId(admin, AuthId_Steam2, adminSteamId, sizeof(adminSteamId));

    // Create a new ban object and set the needed values.
    Ban ban = new Ban();
    ban.SetName(clientName);
    ban.SetSteamID(clientSteamId);
    ban.SetIpAddress(clientIpAddress);
    ban.SetDuration(duration);
    ban.SetTimeLeft(duration);
    ban.SetReason(reason);
    ban.SetAdmin(adminSteamId);
    ban.SetCreatedAt(GetTime());

    // Add the ban to the "g_hBans" array.
    g_hBans[client] = ban;


    // Check if the ban's duration is indefinite
    if(duration == 0) {
        // Log the ban activity.
        LogActivity(admin, "\x01Banned \x10%N\x01 indefinitely. (Reason: \"%s\")", client, reason);
    } else {
        // Log the ban activity.
        LogActivity(admin, "\x01Banned \x10%N\x01 for \x07%i\x01 minutes. (Reason: \"%s\")", client, duration, reason);
    }

    // Switch the client to the terrorist team.
    if(GetClientTeam(client) == CS_TEAM_CT) {
        ChangeClientTeam(client, CS_TEAM_T);
    }

    // Insert the ban into the database.
    Backend_InsertBan(client);
}

/**
 * Native_RemoveBan
 * Removes a client's ban forcefully.
 */
public int Native_RemoveBan(Handle plugin, int params) {
    int client = GetNativeCell(1);
    int admin = GetNativeCell(2);

    Ban ban = g_hBans[client];
    if(ban == null) {
        return;
    }

    // Check if the ban is inactive.
    if(!ban.IsActive()) {
        return;
    }

    // Get the admin's steam id.
    char adminSteamId[64];
    GetClientAuthId(admin, AuthId_Steam2, adminSteamId, sizeof(adminSteamId));

    // Update the ban's removedBy steam id.
    ban.SetRemovedBy(adminSteamId);

    // Get the current UNIX time.
    int time = GetTime();

    // Update the ban's removedAt date.
    ban.SetRemovedAt(time);

    // Update the database.
    Backend_UpdateBanRemoved(client);

    // Unallocate the ban's memory.
    delete g_hBans[client];
}
