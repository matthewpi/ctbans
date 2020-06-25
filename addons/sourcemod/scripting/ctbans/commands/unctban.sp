//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

/**
 * Command_UnCTBan (sm_unctban)
 *
 * Revokes a CT Ban on a client.
 */
public Action Command_UnCTBan(const int client, const int args) {
    // Variable to hold the command name.
    char command[64] = "sm_unctban";

    // Check if the client did not pass proper arguments.
    if (args != 1) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x07Usage: \x01%s <#userid;target>", PREFIX, command);
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

    // Check if the target is invalid.
    if (!IsClientValid(target)) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%N\x01 is not a valid player.", PREFIX, target);
        return Plugin_Handled;
    }

    // Check if the target already has a ban.
    if (g_hBans[target] == null) {
        // Send a message to the client.
        ReplyToCommand(client, "%s \x10%s\x01 does not have a \x07CT Ban\x01.", PREFIX, targetName);
        return Plugin_Handled;
    }

    // Add the ct ban to the target.
    CTBans_RemoveBan(target, client);

    // Log the command execution.
    //LogCommand(client, target, command, "(Target: '%s')", targetName);
    LogClientAction(client, target, "removed a ctban for", "");

    return Plugin_Handled;
}
