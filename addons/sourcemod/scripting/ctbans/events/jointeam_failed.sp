/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

 /**
  * Event_JoinTeamFailed (jointeam_failed)
  * This event is called whenever a player spawns.
  */
public Action Event_JoinTeamFailed(Event event, const char[] name, const bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    int reason = event.GetInt("reason");

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        return Plugin_Continue;
    }

    if(reason != 0) {
        return Plugin_Continue;
    }

    // Get and check if the client has an active ban.
    Ban ban = g_hBans[client];
    if(ban == null) {
        return Plugin_Continue;
    }

    if(!ban.IsActive()) {
        return Plugin_Continue;
    }

    // Switch the client's team.
    CS_SwitchTeam(client, CS_TEAM_T);

    return Plugin_Handled;
}
