/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

// My wonderful attempt at adding support for colored translations. :)
static char _colorNames[][] = {
    "{NORMAL}", "{DARK_RED}", "{PINK}", "{LIME_GREEN}", "{GREEN}",
    "{LIGHT_GREEN}", "{RED}", "{GRAY}", "{YELLOW}", "{ORANGE}",
    "{LIGHT_BLUE}", "{DARK_BLUE}", "{PURPLE}", "{LIGHT_RED}"
};
static char _colorCodes[][] = {
    "\x01", "\x02", "\x03", "\x04", "\x05",
    "\x06", "\x07", "\x08", "\x09", "\x10",
    "\x0B", "\x0C", "\x0E", "\x0F"
};

/*
 * IsClientValid
 * Returns true if the client is valid. (in game, connected, isn't fake)
 */
bool IsClientValid(const int client, bool fake = false) {
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || !IsClientInGame(client)) {
        return false;
    }

    if (!fake && IsFakeClient(client)) {
        return false;
    }

    return true;
}

/*
 * LogCommand
 * Logs a command execution.
 */
public void LogCommand(const int client, const int target, const char[] command, const char[] extra, any...) {
    // Check if there were extra parameters passed to the function.
    if (strlen(extra) > 0) {
        // Format the extra parameters.
        char buffer[512];
        VFormat(buffer, sizeof(buffer), extra, 5);

        // Log the command execution.
        LogAction(client, target, "%s '%N' executed command '%s' %s", CONSOLE_PREFIX, client, command, buffer);
    } else {
        // Log the command execution.
        LogAction(client, target, "%s '%N' executed command '%s'", CONSOLE_PREFIX, client, command);
    }
}

/**
 * LogActivity
 */
public void LogActivity(const int client, const char[] message, any...) {
    char formattedMessage[512];
    // TODO: Add space before message to fix spacing issue?
    VFormat(formattedMessage, sizeof(formattedMessage), message, 3);
    ShowActivity2(client, ACTION_PREFIX, formattedMessage);
}

/*
 * Colorize
 * Colorizes a message.
 */
public void Colorize(char[] message, const int maxlen) {
    // Loop through the _colorNames array.
    for(int i = 0; i < sizeof(_colorNames); i++) {
        // Replace all color codes in the message.
        ReplaceString(message, maxlen, _colorNames[i], _colorCodes[i]);
    }
}

/**
 * DisarmClient
 * Removes a player's weapons.
 */
public void DisarmClient(const int client) {
    for (int i = 0; i < 5; i++) {
        int weapon = GetPlayerWeaponSlot(client, i);

        while (weapon > 0) {
            RemovePlayerItem(client, weapon);
            AcceptEntityInput(weapon, "Kill");
            weapon = GetPlayerWeaponSlot(client, i);
        }
    }
}
