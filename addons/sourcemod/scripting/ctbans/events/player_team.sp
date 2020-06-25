//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

 /**
  * Event_PlayerTeam (player_team)
  * This event is called whenever a player selects a team.
  */
public Action Event_PlayerTeam(Event event, const char[] name, const bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));

    // Check if the client is invalid.
    if (!IsClientValid(client)) {
        return Plugin_Continue;
    }

    if (event.GetInt("team") != CS_TEAM_CT) {
        return Plugin_Continue;
    }

    // Get and check if the client has a ban.
    Ban ban = g_hBans[client];
    if (ban == null) {
        return Plugin_Continue;
    }

    // Check if the ban is active.
    if (!ban.IsActive()) {
        return Plugin_Continue;
    }

    char reason[128];
    ban.GetReason(reason, sizeof(reason));

    // Check if the ban is indefinite.
    if (ban.GetDuration() == 0) {
        PrintToChat(client, "%s You are indefinitely banned from CT.", PREFIX);
    } else {
        PrintToChat(client, "%s You are temporarily banned from CT for \x07%i\x01 more minutes.", PREFIX, ban.GetTimeLeft());
    }

    PrintToChat(client, " - \x06Reason: \x07%s", reason);

    // Initiate a delayed swap timer.
    CreateTimer(0.1, Timer_DelayedSwap, client, TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Continue;
}

static Action Timer_DelayedSwap(Handle timer, int client) {
    if (!IsClientInGame(client) || GetClientTeam(client) != CS_TEAM_CT) {
        return Plugin_Handled;
    }

    // Get and check if the client has a ban.
    Ban ban = g_hBans[client];
    if (ban == null) {
        return Plugin_Continue;
    }

    // Check if the ban is active.
    if (!ban.IsActive()) {
        return Plugin_Continue;
    }

    // Check if the client is alive.
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
