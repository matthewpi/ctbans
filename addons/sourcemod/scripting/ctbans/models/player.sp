//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

methodmap Player < StringMap {
    public Player() {
        return view_as<Player>(new StringMap());
    }

    // name
    public void GetName(char[] buffer, const int maxlen) {
        this.GetString("name", buffer, maxlen);
    }

    public void SetName(const char[] name) {
        this.SetString("name", name);
    }
    // END name

    // steamId
    public void GetSteamID(char[] buffer, const int maxlen) {
        this.GetString("steamId", buffer, maxlen);
    }

    public void SetSteamID(const char[] steamId) {
        this.SetString("steamId", steamId);
    }
    // END steamId

    // ipAddress
    public void GetIpAddress(char[] buffer, int maxlen) {
        this.GetString("ipAddress", buffer, maxlen);
    }

    public void SetIpAddress(const char[] ipAddress) {
        this.SetString("ipAddress", ipAddress);
    }
    // END ipAddress
}
