/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_IsBanned (sm_isbanned)
 * Issues a ct ban to a client.
 */
public Action Command_IsBanned(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_isbanned";

    // Check if the client passed no arguments.
    if(args == 0) {
        Ban ban = g_hBans[client];

        if(ban == null) {
            // Send a message to the client.
            ReplyToCommand(client, "%s You don't have an active \x07CT Ban\x01.", PREFIX);
        } else {
            // Check if the ban is indefinite.
            if(ban.GetDuration() == 0) {
                // Send a message to the client.
                ReplyToCommand(client, "%s You are is indefinitely banned from CT.", PREFIX);
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

        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Check if the client passed too many arguments.
    if(args > 1) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <#userid;target>", PREFIX, command);

        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Get the first command argument.
    char potentialTarget[64];
    GetCmdArg(1, potentialTarget, sizeof(potentialTarget));

    // Define variables to store target information.
    char targetName[MAX_TARGET_LENGTH];
    int targets[MAXPLAYERS + 1];
    bool tnIsMl;

    // Process the target string.
    int targetCount = ProcessTargetString(potentialTarget, client, targets, MAXPLAYERS, COMMAND_FILTER_CONNECTED, targetName, sizeof(targetName), tnIsMl);

    // Check if no clients were found.
    if(targetCount < 1) {
        // Send a message to the client.
        ReplyToTargetError(client, targetCount);

        // Log the command execution.
        LogCommand(client, -1, command, "(Targetting error)");
        return Plugin_Handled;
    }

    // Check if more than one target was found.
    if(targetCount > 2) {
        // Send a message to the client.
        ReplyToCommand(client, "%s Too many clients were matched.", PREFIX);

        // Log the command execution.
        LogCommand(client, -1, command, "(Too many clients found)");
        return Plugin_Handled;
    }

    int target = targets[0];
    Ban ban = g_hBans[target];

    if(ban == null) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%s\x01 does not have an active \x07CT Ban\x01.", PREFIX, targetName);
    } else {
        // Check if the ban is indefinite.
        if(ban.GetDuration() == 0) {
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

    // Log the command execution.
    LogCommand(client, target, command, "(Target: '%s')", targetName);

    return Plugin_Handled;
}
