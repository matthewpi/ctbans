//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

/**
 * Command_IsBanned (sm_isbanned)
 *
 * Check if a client is currently banned from the Counter-Terrorist team.
 */
public Action Command_IsBanned(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_isbanned";

    if (args == 0 && client == 0) {
        ReplyToCommand(client, "%s Because you are the console, you are indefinitely banned from CT.", PREFIX);
        return Plugin_Handled;
    }

    // Check if the client passed no arguments.
    if (args == 0) {
        Ban ban = g_hBans[client];

        if(ban == null) {
            // Send a message to the client.
            ReplyToCommand(client, "%s You don't have an active \x07CT Ban\x01.", PREFIX);
        } else {
            // Check if the ban is indefinite.
            if (ban.GetDuration() == 0) {
                // Send a message to the client.
                ReplyToCommand(client, "%s You are indefinitely banned from CT.", PREFIX);
            } else {
                // Send a message to the client.
                ReplyToCommand(client, "%s You are temporarily banned from CT for \x07%i\x01 more minutes.", PREFIX, ban.GetTimeLeft());
            }

            char createdAt[32];
            FormatTime(createdAt, sizeof(createdAt), "%Y-%m-%d %r", ban.GetCreatedAt());

            char reason[128];
            ban.GetReason(reason, sizeof(reason));

            PrintToChat(client, " - \x06Issued On: \x07%s", createdAt);
            PrintToChat(client, " - \x06Reason: \x07%s", reason);
        }
        return Plugin_Handled;
    }

    // Check if the client passed too many arguments.
    if (args > 1) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <#userid;target>", PREFIX, command);
        return Plugin_Handled;
    }

    // Get the first command argument.
    char potentialTarget[512];
    GetCmdArg(1, potentialTarget, sizeof(potentialTarget));

    // Attempt to get and target a player using the first command argument.
    int target = FindTarget(client, potentialTarget, true, false);
    if (target == -1) {
        return Plugin_Handled;
    }

    // Get the target's name.
    char targetName[128];
    GetClientName(target, targetName, sizeof(targetName));

    // Get the target's existing ban if there is one.
    Ban ban = g_hBans[target];

    // Check if the target has a ban.
    if (ban == null) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%s\x01 does not have an active \x07CT Ban\x01.", PREFIX, targetName);
    } else {
        // Check if the ban is indefinite.
        if (ban.GetDuration() == 0) {
            // Send a message to the client.
            ReplyToCommand(client, "%s \x10%s\x01 is indefinitely banned from CT.", PREFIX, targetName);
        } else {
            // Send a message to the client.
            ReplyToCommand(client, "%s \x10%s\x01 is temporarily banned from CT for \x07%i\x01 more minutes.", PREFIX, targetName, ban.GetTimeLeft());
        }

        char createdAt[32];
        FormatTime(createdAt, sizeof(createdAt), "%Y-%m-%d %r", ban.GetCreatedAt());

        char reason[128];
        ban.GetReason(reason, sizeof(reason));

        PrintToChat(client, " - \x06Issued On: \x07%s", createdAt);
        PrintToChat(client, " - \x06Reason: \x07%s", reason);
    }

    return Plugin_Handled;
}
