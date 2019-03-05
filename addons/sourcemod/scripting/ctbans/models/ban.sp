/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

methodmap Ban < StringMap {
    public Ban() {
        return view_as<Ban>(new StringMap());
    }

    // id
    public int GetID() {
        int id;
        this.GetValue("id", id);
        return id;
    }

    public void SetID(int id) {
        this.SetValue("id", id);
    }
    // END id

    // name
    public void GetName(char[] buffer, int maxlen) {
        this.GetString("name", buffer, maxlen);
    }

    public void SetName(const char[] name) {
        this.SetString("name", name);
    }
    // END name

    // steamId
    public void GetSteamID(char[] buffer, int maxlen) {
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

    // duration
    public int GetDuration() {
        int duration;
        this.GetValue("duration", duration);
        return duration;
    }

    public void SetDuration(int duration) {
        this.SetValue("duration", duration);
    }
    // END duration

    // timeLeft
    public int GetTimeLeft() {
        int timeLeft;
        this.GetValue("timeLeft", timeLeft);
        return timeLeft;
    }

    public void SetTimeLeft(int timeLeft) {
        this.SetValue("timeLeft", timeLeft);
    }
    // END timeLeft

    // reason
    public void GetReason(char[] buffer, int maxlen) {
        this.GetString("reason", buffer, maxlen);
    }

    public void SetReason(const char[] reason) {
        this.SetString("reason", reason);
    }
    // END reason

    // admin
    public void GetAdmin(char[] buffer, int maxlen) {
        this.GetString("admin", buffer, maxlen);
    }

    public void SetAdmin(const char[] admin) {
        this.SetString("admin", admin);
    }
    // END admin

    // removedBy
    public void GetRemovedBy(char[] buffer, int maxlen) {
        this.GetString("removedBy", buffer, maxlen);
    }

    public void SetRemovedBy(const char[] removedBy) {
        this.SetString("removedBy", removedBy);
    }
    // END removedBy

    // removedAt
    public int GetRemovedAt() {
        int removedAt;
        this.GetValue("removedAt", removedAt);
        return removedAt;
    }

    public void SetRemovedAt(int removedAt) {
        this.SetValue("removedAt", removedAt);
    }
    // END removedAt

    // expired
    public bool IsExpired() {
        bool expired;
        this.GetValue("expired", expired);
        return expired;
    }

    public void SetExpired(bool expired) {
        this.SetValue("expired", expired);
    }
    // END expired

    // createdAt
    public int GetCreatedAt() {
        int createdAt;
        this.GetValue("createdAt", createdAt);
        return createdAt;
    }

    public void SetCreatedAt(int createdAt) {
        this.SetValue("createdAt", createdAt);
    }
    // END createdAt

    public bool IsActive() {
        // Check if the ban is indefinite.
        if(this.GetDuration() == 0) {
            if(this.GetRemovedAt() != -1) {
                return false;
            } else {
                return true;
            }
        }

        // Check if the ban has expired.
        if(this.IsExpired()) {
            return false;
        }

        // Check if removedAt is not equal to -1
        if(this.GetRemovedAt() != -1) {
            return false;
        }

        // Check if the ban is expired.
        if(this.GetTimeLeft() < 1) {
            return false;
        }

        return true;
    }
}
