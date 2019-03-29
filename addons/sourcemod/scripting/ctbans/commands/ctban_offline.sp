/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_CTBanOffline (sm_ctban_offline)
 * Issues a ct ban to a client.
 */
public Action Command_CTBanOffline(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_ctban_offline";

    // Check if there are no arguments passed.
    if(args == 0) {
        // Send a message to the client.
        ReplyToCommand(client, "%s Rage Ban menu is not implemented yet. :/", PREFIX);

        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Check if the client did not pass proper arguments.
    if(args < 3) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <steamId> <duration> <reason>", PREFIX, command);

        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Get the first command argument.
    char steamId[64];
    GetCmdArg(1, steamId, sizeof(steamId));

    // Get the second command argument.
    char durationString[64];
    GetCmdArg(2, durationString, sizeof(durationString));

    int duration = StringToInt(durationString);

    // Check if duration is not a valid integer.
    if(!StrEqual(durationString, "0") && duration == 0) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%s\x01 is not a valid ban duration.", PREFIX, durationString);

        // Log the command execution.
        LogCommand(client, -1, command, "(Invalid duration)");
        return Plugin_Handled;
    }

    char reason[128] = "";
    for(int i = 3; i <= args; i++) {
        char buffer[64];
        GetCmdArg(i, buffer, sizeof(buffer));
        if(i != 3) {
            Format(buffer, sizeof(buffer), " %s", buffer);
        }
        StrCat(reason, sizeof(reason), buffer);
    }

    // Get the admin's steam id.
    char adminSteamId[64];
    GetClientAuthId(client, AuthId_Steam2, adminSteamId, sizeof(adminSteamId));

    // Create a new ban object and set the needed values.
    Ban ban = new Ban();
    ban.SetName("");
    ban.SetSteamID(steamId);
    ban.SetIpAddress("");
    ban.SetDuration(duration);
    ban.SetTimeLeft(duration);
    ban.SetReason(reason);
    ban.SetAdmin(adminSteamId);
    ban.SetRemovedAt(-1);
    ban.SetExpired(false);
    ban.SetCreatedAt(GetTime());

    // Check if the ban's duration is indefinite
    if(duration == 0) {
        // Log the ban activity.
        LogActivity(client, "\x01Banned \x10%s\x01 indefinitely. (Reason: \"\x07%s\x01\")", steamId, reason);
    } else {
        // Log the ban activity.
        LogActivity(client, "\x01Banned \x10%s\x01 for \x07%i\x01 minutes. (Reason: \"\x07%s\x01\")", steamId, duration, reason);
    }

    // Insert the ban into the database.
    Backend_InsertBanObject(ban);

    // Log the command execution.
    LogCommand(client, -1, command, "(Target: '%s')", steamId);

    return Plugin_Handled;
}