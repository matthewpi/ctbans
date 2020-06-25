//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

/**
 * IsClientValid
 *
 * Checks if a client is valid (in game, connected, isn't fake).
 *
 * @param Client Index
 * @return True if the client is valid, otherwise false.
 */
stock bool IsClientValid(const int client) {
    return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client);
}

/**
 * LogClientAction
 *
 * ?
 * 
 * @param Client Index
 * @param Target Index
 * @param Command
 * @param Extra Data
 * @param Extra Data (Format Fields)
 */
stock void LogClientAction(const int client, const int target, const char[] action, const char[] extra, any...) {
    // Get the client's name, steam id, and user id.
    char clientName[64];
    char clientSteamId[64];
    int clientUserId;
    if (IsClientValid(client)) {
        GetClientName(client, clientName, sizeof(clientName));
        GetClientAuthId(client, AuthId_Steam2, clientSteamId, sizeof(clientSteamId));
        clientUserId = GetClientUserId(client);
    } else if (client == 0) {
        clientName = "Console";
        clientSteamId = "Console";
        clientUserId = 0;
    } else {
        ThrowError("Client index %i is invalid", client);
        return;
    }

    // Check if there is no target.
    if (target == -1) {
        // Check if there were extra parameters passed to the function.
        if (strlen(extra) > 0) {
            // Format the extra parameters.
            char buffer[512];
            VFormat(buffer, sizeof(buffer), extra, 5);

            // Log the command execution.
            LogAction(client, target, "\"%s<%i><%s>\" %s %s", clientName, clientUserId, clientSteamId, action, buffer);
            return;
        }

        // Log the command execution.
        LogAction(client, target, "\"%s<%i><%s>\" %s", clientName, clientUserId, clientSteamId, action);
        return;
    }

    // Get the target's steam id.
    char targetSteamId[64];
    if (IsClientValid(target)) {
        GetClientAuthId(target, AuthId_Steam2, targetSteamId, sizeof(targetSteamId));
    } else {
        ThrowError("Client index %i is invalid", target);
        return;
    }

    // Check if there were extra parameters passed to the function.
    if (strlen(extra) > 0) {
        // Format the extra parameters.
        char buffer[512];
        VFormat(buffer, sizeof(buffer), extra, 5);

        // Log the action.
        LogAction(client, target, "\"%s<%i><%s>\" %s \"%N<%i><%s>\" %s", clientName, clientUserId, clientSteamId, action, target, GetClientUserId(target), targetSteamId, buffer);
        return;
    }

    // Log the action.
    LogAction(client, target, "\"%s<%i><%s>\" %s \"%N<%i><%s>\"", clientName, clientUserId, clientSteamId, action, target, GetClientUserId(target), targetSteamId);
    return;
}

/**
 * LogActivity
 *
 * Logs an activity to all clients on the server.
 *
 * @param Client Index
 * @param Message
 * @param Format Fields
 */
stock void LogActivity(const int client, const char[] message, any...) {
    char formattedMessage[512];
    VFormat(formattedMessage, sizeof(formattedMessage), message, 3);
    ShowActivity2(client, ACTION_PREFIX, formattedMessage);
}

/**
 * DisarmClient
 *
 * Removes a client's weapons.
 */
stock void DisarmClient(const int client) {
    for (int i = 0; i < 5; i++) {
        int weapon = GetPlayerWeaponSlot(client, i);

        while (weapon > 0) {
            RemovePlayerItem(client, weapon);
            AcceptEntityInput(weapon, "Kill");
            weapon = GetPlayerWeaponSlot(client, i);
        }
    }
}
