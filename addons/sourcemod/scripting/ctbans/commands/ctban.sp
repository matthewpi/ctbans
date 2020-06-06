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
    if (args < 3) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <#userid;target> <duration> <reason>", PREFIX, command);

        // Log the command execution.
        LogCommand(client, -1, command, "");
        return Plugin_Handled;
    }

    // Get the first command argument.
    char potentialTarget[512];
    GetCmdArg(1, potentialTarget, sizeof(potentialTarget));

    // Attempt to get and target a player using the first command argument.
    int target = FindTarget(client, potentialTarget, true, true);
    if (target == -1) {
        // Log the command execution.
        LogCommand(client, -1, command, "(Targetting error)");
        return Plugin_Handled;
    }

    // Get the target's name.
    char targetName[128];
    GetClientName(target, targetName, sizeof(targetName));

    // Get the second command argument.
    char durationString[64];
    GetCmdArg(2, durationString, sizeof(durationString));

    int duration = StringToInt(durationString);

    // Check if duration is not a valid integer.
    if (!StrEqual(durationString, "0") && duration == 0) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%s\x01 is not a valid ban duration.", PREFIX, durationString);

        // Log the command execution.
        LogCommand(client, -1, command, "(Invalid duration)");
        return Plugin_Handled;
    }

    char reason[128] = "";
    for (int i = 3; i <= args; i++) {
        char buffer[64];
        GetCmdArg(i, buffer, sizeof(buffer));
        if (i != 3) {
            Format(buffer, sizeof(buffer), " %s", buffer);
        }
        StrCat(reason, sizeof(reason), buffer);
    }

    // Check if the target is invalid.
    if (!IsClientValid(target)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%N\x01 is not a valid player.", CONSOLE_PREFIX, target);

        // Log the command execution.
        LogCommand(client, -1, command, "(Invalid target)");
        return Plugin_Handled;
    }

    // Check if the target already has a ban.
    if (g_hBans[target] != null) {
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
