/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

void CTBans_Menu(const int client) {
    Menu menu = CreateMenu(Callback_CTBansMenu);
    menu.SetTitle("Rage Ban");



    menu.Display(client, 0);
}

static int Callback_CTBansMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch(action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));


        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
