//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

 /**
  * Event_PlayerSpawn (player_spawn)
  * This event is called whenever a player spawns.
  */
public Action Event_PlayerSpawn(Event event, const char[] name, const bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));

    // Check if the client is invalid.
    if (!IsClientValid(client)) {
        return Plugin_Continue;
    }

    if (GetClientTeam(client) != CS_TEAM_CT) {
        return Plugin_Continue;
    }

    // Get and check if the client has an active ban.
    Ban ban = g_hBans[client];
    if (ban == null) {
        return Plugin_Continue;
    }

    if (!ban.IsActive()) {
        return Plugin_Continue;
    }

    if (IsPlayerAlive(client)) {
        // Disarm the client.
        DisarmClient(client);

        // Kill the client.
        ForcePlayerSuicide(client);
    }

    // Switch the client's team.
    CS_SwitchTeam(client, CS_TEAM_T);

    return Plugin_Handled;
}
