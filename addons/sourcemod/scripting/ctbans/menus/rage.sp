/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * CTBans_RageMenu
 * ?
 */
void CTBans_RageMenu(const int client, const int position = -1) {
    Menu menu = CreateMenu(Callback_RageMenu);
    menu.SetTitle("CT Bans | Rage Ban");

    if(g_alDisconnected.Length < 1) {
        PrintToChat(client, "%s There have been no recently disconnected players.", PREFIX);
        return;
    }

    char info[32];
    char display[128];
    for(int i = 0; i < g_alDisconnected.Length; i++) {
        Player player = g_alDisconnected.Get(i);
        if(player == null) {
            continue;
        }

        Format(info, sizeof(info), "%i", i);
        player.GetName(display, sizeof(display));
        menu.AddItem(info, display);
    }

    // Display the menu to the client.
    if(position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_RageMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch(action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            int playerId = StringToInt(info);

            Player player = g_alDisconnected.Get(playerId);
            if(player == null) {
                CTBans_RageMenu(client, GetMenuSelectionPosition());
                return;
            }

            CTBans_RageTimeMenu(client, playerId);
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}

/**
 * CTBans_RageTimeMenu
 * ?
 */
void CTBans_RageTimeMenu(const int client, const int playerId, const int position = -1) {
    Menu menu = CreateMenu(Callback_RageTimeMenu);
    menu.SetTitle("CT Bans | Rage Ban");

    Player player = g_alDisconnected.Get(playerId);
    if(player == null) {
        CTBans_RageMenu(client);
        return;
    }
    g_iMenuSelection[client] = playerId;

    menu.AddItem("0", "Permanent");

    menu.AddItem("5", "5 minutes");
    menu.AddItem("10", "10 minutes");
    menu.AddItem("15", "15 minutes");
    menu.AddItem("30", "30 minutes");
    menu.AddItem("45", "45 minutes");

    menu.AddItem("60", "1 hour");
    menu.AddItem("120", "2 hours");
    menu.AddItem("180", "3 hours");
    menu.AddItem("240", "4 hours");
    menu.AddItem("480", "8 hours");
    menu.AddItem("720", "12 hours");

    menu.AddItem("1440", "1 day");
    menu.AddItem("2880", "2 days");
    menu.AddItem("4320", "3 days");
    menu.AddItem("5760", "4 days");
    menu.AddItem("7200", "5 days");
    menu.AddItem("8640", "6 days");

    menu.AddItem("10080", "1 week");
    menu.AddItem("20160", "2 weeks");

    // Enable the menu exit back button.
    menu.ExitBackButton = true;

    // Display the menu to the client.
    if(position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_RageTimeMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch(action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            int duration = StringToInt(info);
            int playerId = g_iMenuSelection[client];

            Player player = g_alDisconnected.Get(playerId);
            if(player == null) {
                CTBans_RageMenu(client);
                return;
            }

            // Get the player's name.
            char name[64];
            player.GetName(name, sizeof(name));

            // Get the player's steamId.
            char steamId[64];
            player.GetSteamID(steamId, sizeof(steamId));

            // Get the player's ipAddress.
            char ipAddress[64];
            player.GetIpAddress(ipAddress, sizeof(ipAddress));

            // Get the admin's steam id.
            char adminSteamId[64];
            GetClientAuthId(client, AuthId_Steam2, adminSteamId, sizeof(adminSteamId));

            // Get the client's country.
            char country[4];
            GeoipCode2(ipAddress, country);

            Ban ban = new Ban();
            ban.SetName(name);
            ban.SetSteamID(steamId);
            ban.SetIpAddress(ipAddress);
            ban.SetCountry(country);
            ban.SetDuration(duration);
            ban.SetTimeLeft(duration);
            ban.SetReason("");
            ban.SetAdmin(adminSteamId);
            ban.SetRemovedAt(-1);
            ban.SetExpired(false);
            ban.SetCreatedAt(GetTime());
            g_hBanObject[client] = ban;

            PrintToChat(client, "%s Please enter a \x10Ban Reason\x01.", PREFIX);
        }

        case MenuAction_Cancel: {
            if(itemNum == MenuCancel_ExitBack) {
                CTBans_RageMenu(client);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
