/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

 /**
  * Event_PlayerTeamPre (player_team)
  * This event is called whenever a player selects a team.
  */
public Action Event_PlayerTeamPre(Event event, const char[] name, const bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
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

    char reason[128];
    ban.GetReason(reason, sizeof(reason));

    if(ban.GetDuration() == 0) {
        PrintToChat(client, "%s You are is indefinitely banned from CT.", PREFIX);
    } else {
        PrintToChat(client, "%s You are temporarily banned from CT for \x07%i\x01 minutes.", PREFIX, ban.GetTimeLeft());
    }

    PrintToChat(client, " - \x04Reason: \x07%s", reason);

    return Plugin_Handled;
}
