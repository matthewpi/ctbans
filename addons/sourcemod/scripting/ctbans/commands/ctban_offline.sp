//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

/**
 * Command_CTBanOffline (sm_ctban_offline)
 *
 * Issues a ct ban to a offline client.
 */
public Action Command_CTBanOffline(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_ctban_offline";

    // Check if there are no arguments passed.
    if (args == 0) {
        CTBans_RageMenu(client);
        return Plugin_Handled;
    }

    // Check if the client did not pass proper arguments.
    if (args < 3) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <steamId> <duration> <reason>", PREFIX, command);
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
    if ((!StrEqual(durationString, "0") && duration == 0) || duration < 0) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%s\x01 is an invalid duration.", PREFIX, durationString);
        return Plugin_Handled;
    }

    // Get the ban reason.
    char reason[128] = "";
    for (int i = 3; i <= args; i++) {
        char buffer[64];
        GetCmdArg(i, buffer, sizeof(buffer));
        if (i != 3) {
            Format(buffer, sizeof(buffer), " %s", buffer);
        }
        StrCat(reason, sizeof(reason), buffer);
    }

    // Get the admin's steam id.
    char adminSteamId[64];
    if (client == 0) {
        adminSteamId = "STEAM_ID_SERVER";
    } else {
        GetClientAuthId(client, AuthId_Steam2, adminSteamId, sizeof(adminSteamId));
    }

    // Create a new ban object and set the needed values.
    Ban ban = new Ban();
    ban.SetName("");
    ban.SetSteamID(steamId);
    ban.SetIpAddress("");
    ban.SetCountry("");
    ban.SetDuration(duration);
    ban.SetTimeLeft(duration);
    ban.SetReason(reason);
    ban.SetAdmin(adminSteamId);
    ban.SetRemovedAt(-1);
    ban.SetExpired(false);
    ban.SetCreatedAt(GetTime());

    // Check if the ban's duration is indefinite
    if (duration == 0) {
        // Log the ban activity.
        LogActivity(client, "\x01Banned \x10%s\x01 indefinitely. (Reason: \"\x07%s\x01\")", steamId, reason);
    } else {
        // Log the ban activity.
        LogActivity(client, "\x01Banned \x10%s\x01 for \x07%i\x01 minutes. (Reason: \"\x07%s\x01\")", steamId, duration, reason);
    }

    // Insert the ban into the database.
    Backend_InsertBanObject(ban, 0);

    // Log the command execution.
    LogClientAction(client, -1, "ctbanned an offline player.", "(Steam ID: \"%s\", Duration: %s, Reason: \"%s\")", steamId, durationString, reason);

    return Plugin_Handled;
}
