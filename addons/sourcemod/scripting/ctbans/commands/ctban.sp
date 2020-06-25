//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

/**
 * Command_CTBan (sm_ctban)
 *
 * Issues a ct ban to a client.
 */
public Action Command_CTBan(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_ctban";

    // Check if the client did not pass proper arguments.
    if (args < 3) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <#userid;target> <duration> <reason>", PREFIX, command);
        return Plugin_Handled;
    }

    // Get the first command argument.
    char potentialTarget[512];
    GetCmdArg(1, potentialTarget, sizeof(potentialTarget));

    // Attempt to get and target a player using the first command argument.
    int target = FindTarget(client, potentialTarget, true, true);
    if (target == -1) {
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

    // Check if the target is invalid.
    if (!IsClientValid(target)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%N\x01 is not a valid player.", PREFIX, target);
        return Plugin_Handled;
    }

    // Check if the target already has a ban.
    if (g_hBans[target] != null) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%s\x01 already has an active \x07CT Ban\x01.", PREFIX, targetName);
        return Plugin_Handled;
    }

    // Add the ct ban to the target.
    CTBans_AddBan(target, client, duration, reason);

    // Log the command execution.
    LogClientAction(client, target, "ctbanned", "(Duration: %s, Reason: \"%s\")", durationString, reason);

    return Plugin_Handled;
}
