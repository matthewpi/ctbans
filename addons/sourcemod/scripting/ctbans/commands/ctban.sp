/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_CTBan (sm_ctban)
 * Issues a ct ban to a client.
 */
public Action Command_CTBan(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_ctban";

    // Check if the client did not pass proper arguments.
    if(args < 3) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <#userid;target> <duration> <reason>", PREFIX, command);

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

    int target = targets[0];

    // Check if the target is invalid.
    if(!IsClientValid(target)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%N\x01 is not a valid player.", CONSOLE_PREFIX, target);

        // Log the command execution.
        LogCommand(client, -1, command, "(Invalid target)");
        return Plugin_Handled;
    }

    // Check if the target already has a ban.
    if(g_hBans[target] != null) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%s\x01 already has an active \x07CT Ban\x01.", CONSOLE_PREFIX, targetName);

        // Log the command execution.
        LogCommand(client, -1, command, "(Target already has a ban)");
        return Plugin_Handled;
    }

    // Add the ct ban to the target.
    CTBans_AddBan(target, client, duration, reason);

    // Log the command execution.
    LogCommand(client, target, command, "(Target: '%s')", targetName);

    return Plugin_Handled;
}
