/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

 /**
  * OnClientSayCommand (player_chat)
  * This is not exactly an event, but it is similar to the "player_chat" event.
  */
public Action OnClientSayCommand(int client, const char[] command, const char[] args) {
    // Check if the client is invalid.
    if (!IsClientValid(client)) {
        return Plugin_Continue;
    }

    // Check if we are listening for a chat input.
    if (g_hBanObject[client] != null) {
        // Check if the message's arguments have less than 3 characters.
        if (strlen(args) < 3) {
            PrintToChat(client, "%s \x10Ban Reason\x01 must be at least \x073\x01 characters.", PREFIX);
            return Plugin_Stop;
        }

        // Check if the message's arguments have more than 128 characters.
        if (strlen(args) > 128) {
            PrintToChat(client, "%s \x10Ban Reason\x01 has a limit of \x07128\x01 characters.", PREFIX);
            return Plugin_Stop;
        }

        // Get the currently selected admin id.
        int playerId = g_iMenuSelection[client];

        // Get the player object using the playerId.
        Player player = g_alDisconnected.Get(playerId);
        if (player == null) {
            PrintToChat(client, "%s Failed to find the player object.", PREFIX);
            return Plugin_Stop;
        }

        // Fetch the unfinished ban object.
        Ban ban = g_hBanObject[client];
        if (ban == null) {
            PrintToChat(client, "%s Failed to find the ban object.", PREFIX);
            return Plugin_Stop;
        }

        // Update the ban reason.
        ban.SetReason(args);

        char name[128];
        ban.GetName(name, sizeof(name));

        int duration = ban.GetDuration();

        // Check if the ban's duration is indefinite
        if (duration == 0) {
            // Log the ban activity.
            LogActivity(client, "\x01Banned \x10%s\x01 indefinitely. (Reason: \"\x07%s\x01\")", name, args);
        } else {
            // Log the ban activity.
            LogActivity(client, "\x01Banned \x10%s\x01 for \x07%i\x01 minutes. (Reason: \"\x07%s\x01\")", name, duration, args);
        }

        // Insert the ban into the database.
        Backend_InsertBanObject(ban);

        g_hBanObject[client] = null;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}
