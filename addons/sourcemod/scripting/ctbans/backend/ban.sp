//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

/**
 * Backend_GetBan
 * Loads a user's ban information.
 */
public void Backend_GetBan(const int client, const char[] steamId) {
    int bufferLength = strlen(steamId) * 2 + 1;
    char[] escapedSteamId = new char[bufferLength];
    g_dbCTBans.Escape(steamId, escapedSteamId, bufferLength);

    // Create and format the query.
    char query[1024];
    Format(query, sizeof(query), GET_BAN, escapedSteamId);

    // Execute the query.
    g_dbCTBans.Query(Callback_GetBan, query, client);
}

/**
 * Callback_GetBan
 * Backend callback for Backend_GetBan(int, char[])
 */
static void Callback_GetBan(Database database, DBResultSet results, const char[] error, int client) {
    // Handle query error.
    if (results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_GetBan", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Get table column indexes.
    int idIndex;
    int steamIdIndex;
    int ipAddressIndex;
    int countryIndex;
    int durationIndex;
    int timeLeftIndex;
    int reasonIndex;
    int adminIndex;
    int removedByIndex;
    int removedAtIndex;
    int expiredIndex;
    int createdAtIndex;

    if (!results.FieldNameToNum("id", idIndex)) { LogError("%s Failed to locate \"id\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("steamId", steamIdIndex)) { LogError("%s Failed to locate \"steamId\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("ipAddress", ipAddressIndex)) { LogError("%s Failed to locate \"ipAddress\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("country", countryIndex)) { LogError("%s Failed to locate \"country\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("duration", durationIndex)) { LogError("%s Failed to locate \"duration\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("timeLeft", timeLeftIndex)) { LogError("%s Failed to locate \"timeLeft\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("reason", reasonIndex)) { LogError("%s Failed to locate \"reason\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("admin", adminIndex)) { LogError("%s Failed to locate \"admin\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("removedBy", removedByIndex)) { LogError("%s Failed to locate \"removedBy\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("removedAt", removedAtIndex)) { LogError("%s Failed to locate \"removedAt\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("expired", expiredIndex)) { LogError("%s Failed to locate \"expired\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    if (!results.FieldNameToNum("createdAt", createdAtIndex)) { LogError("%s Failed to locate \"createdAt\" field in table \"ctbans_bans\".", CONSOLE_PREFIX); return; }
    // END Get table column indexes.

    // Loop through query results.
    while (results.FetchRow()) {
        // Pull row information.
        int id = results.FetchInt(idIndex);
        char steamId[64];
        char ipAddress[16];
        char country[4];
        int duration = results.FetchInt(durationIndex);
        int timeLeft = results.FetchInt(timeLeftIndex);
        char reason[128];
        char admin[64];
        char removedBy[64];
        int removedAt = -1;
        bool expired = false;
        int createdAt = results.FetchInt(createdAtIndex);

        if (!results.IsFieldNull(removedAtIndex)) {
            removedAt = results.FetchInt(removedAtIndex);
            LogMessage("%s Removed At is not null. (%i)", CONSOLE_PREFIX, removedAt);
        }

        if (!results.IsFieldNull(removedByIndex)) {
            results.FetchString(removedByIndex, removedBy, sizeof(removedBy));
        }

        if (results.FetchInt(expiredIndex) == 1) {
            expired = true;
        }

        results.FetchString(steamIdIndex, steamId, sizeof(steamId));
        results.FetchString(ipAddressIndex, ipAddress, sizeof(ipAddress));
        results.FetchString(countryIndex, country, sizeof(country));
        results.FetchString(reasonIndex, reason, sizeof(reason));
        results.FetchString(adminIndex, admin, sizeof(admin));
        // END Pull row information.

        // Create admin object and set properties.
        Ban ban = new Ban();
        ban.SetID(id);
        ban.SetSteamID(steamId);
        ban.SetIpAddress(ipAddress);
        ban.SetCountry(country);
        ban.SetDuration(duration);
        ban.SetTimeLeft(timeLeft);
        ban.SetReason(reason);
        ban.SetAdmin(admin);
        ban.SetRemovedBy(removedBy);
        ban.SetRemovedAt(removedAt);
        ban.SetExpired(expired);
        ban.SetCreatedAt(createdAt);

        // Check if the ban is active.
        if (!ban.IsActive()) {
            // Log that we found an admin.
            LogMessage("%s Found ban for '%N' but it is inactive (Steam ID: '%s')", CONSOLE_PREFIX, client, steamId);
            delete ban;
            continue;
        }

        // TODO: Check if the client is connected and is on the CT team, then swap them to T.  (Bans might take time to load and the player might have enough time to select a team)

        // Log that we found an admin.
        LogMessage("%s Found ban for '%N' (Steam ID: '%s')", CONSOLE_PREFIX, client, steamId);

        // Add admin to the admins array.
        g_hBans[client] = ban;
    }
}

/**
 * Backend_InsertBan
 * Updates a ban.
 */
public void Backend_InsertBan(const int client) {
    Ban ban = g_hBans[client];
    if (ban == null) {
        return;
    }

    Backend_InsertBanObject(ban, client);
}

/**
 * Backend_InsertBanObject
 * Updates a ban.
 */
public void Backend_InsertBanObject(Ban ban, const int client) {
    // Get client's name.
    char clientName[128];
    ban.GetName(clientName, sizeof(clientName));

    int bufferLength = strlen(clientName) * 2 + 1;
    char[] escapedClientName = new char[bufferLength];
    g_dbCTBans.Escape(clientName, escapedClientName, bufferLength);

    // Get the client's steam id.
    char clientSteamId[64];
    ban.GetSteamID(clientSteamId, sizeof(clientSteamId));

    bufferLength = strlen(clientSteamId) * 2 + 1;
    char[] escapedClientSteamId = new char[bufferLength];
    g_dbCTBans.Escape(clientSteamId, escapedClientSteamId, bufferLength);

    // Get the client's ip address.
    char clientIpAddress[16];
    ban.GetIpAddress(clientIpAddress, sizeof(clientIpAddress));

    bufferLength = strlen(clientIpAddress) * 2 + 1;
    char[] escapedClientIpAddress = new char[bufferLength];
    g_dbCTBans.Escape(clientIpAddress, escapedClientIpAddress, bufferLength);

    // Get the client's country.
    char clientCountry[4];
    ban.GetCountry(clientCountry, sizeof(clientCountry));

    bufferLength = strlen(clientCountry) * 2 + 1;
    char[] escapedClientCountry = new char[bufferLength];
    g_dbCTBans.Escape(clientCountry, escapedClientCountry, bufferLength);

    // Get the admin's steam id.
    char reason[128];
    ban.GetReason(reason, sizeof(reason));

    bufferLength = strlen(reason) * 2 + 1;
    char[] escapedReason = new char[bufferLength];
    g_dbCTBans.Escape(reason, escapedReason, bufferLength);

    // Get the admin's steam id.
    char adminSteamId[64];
    ban.GetAdmin(adminSteamId, sizeof(adminSteamId));

    bufferLength = strlen(adminSteamId) * 2 + 1;
    char[] escapedAdminSteamId = new char[bufferLength];
    g_dbCTBans.Escape(adminSteamId, escapedAdminSteamId, bufferLength);

    int time = GetTime();

    // Create and format the query.
    char query[1024];
    Format(query, sizeof(query), INSERT_BAN, escapedClientName, escapedClientSteamId, escapedClientIpAddress, escapedClientCountry, ban.GetDuration(), ban.GetTimeLeft(), escapedReason, escapedAdminSteamId, time, time);

    // Execute the query.
    g_dbCTBans.Query(Callback_InsertBan, query, client);
}

/**
 * Callback_InsertBan
 * Backend callback for Backend_InsertBan(int)
 */
static void Callback_InsertBan(Database database, DBResultSet results, const char[] error, int client) {
    // Handle query error.
    if (results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_InsertBan", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Check if a valid client index was passed.
    if (client != 0) {
        LogMessage("%s Inserted CT Ban for '%N'", CONSOLE_PREFIX, client);
    }
}

/**
 * Backend_UpdateBan
 * Updates a ban.
 */
public void Backend_UpdateBan(const int client) {
    Ban ban = g_hBans[client];
    if (ban == null) {
        return;
    }

    // Get the client's steamId.
    char steamId[64];
    ban.GetSteamID(steamId, sizeof(steamId));

    int bufferLength = strlen(steamId) * 2 + 1;
    char[] escapedSteamId = new char[bufferLength];
    g_dbCTBans.Escape(steamId, escapedSteamId, bufferLength);

    // Create and format the query.
    char query[1024];
    Format(query, sizeof(query), UPDATE_BAN, ban.GetTimeLeft(), ban.IsExpired() ? 1 : 0, escapedSteamId);

    // Execute the query.
    g_dbCTBans.Query(Callback_UpdateBan, query, client);
}

/**
 * Callback_GetBan
 * Backend callback for Backend_UpdateBan(int)
 */
static void Callback_UpdateBan(Database database, DBResultSet results, const char[] error, int client) {
    // Handle query error.
    if (results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_UpdateBan", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    if (IsClientConnected(client)) {
        LogMessage("%s Updated CT Ban for '%N'", CONSOLE_PREFIX, client);
    } else {
        LogMessage("%s Updated CT Ban for %i", CONSOLE_PREFIX, client);
    }
}

/**
 * Backend_UpdateBanRemoved
 * Updates a ban.
 */
public void Backend_UpdateBanRemoved(const int client) {
    Ban ban = g_hBans[client];
    if (ban == null) {
        return;
    }

    // Get the ban's "removedBy".
    char removedBy[64];
    ban.GetRemovedBy(removedBy, sizeof(removedBy));

    int bufferLength = strlen(removedBy) * 2 + 1;
    char[] escapedRemovedBy = new char[bufferLength];
    g_dbCTBans.Escape(removedBy, escapedRemovedBy, bufferLength);

    // Get the ban's steam id.
    char steamId[64];
    ban.GetSteamID(steamId, sizeof(steamId));

    bufferLength = strlen(steamId) * 2 + 1;
    char[] escapedSteamId = new char[bufferLength];
    g_dbCTBans.Escape(steamId, escapedSteamId, bufferLength);

    // Create and format the query.
    char query[1024];
    Format(query, sizeof(query), UPDATE_BAN_REMOVED, escapedRemovedBy, ban.GetRemovedAt(), ban.IsExpired() ? 1 : 0, escapedSteamId);

    // Execute the query.
    g_dbCTBans.Query(Callback_UpdateBanRemoved, query, client);
}

/**
 * Callback_UpdateBanRemoved
 * Backend callback for Backend_UpdateBanRemoved(int)
 */
static void Callback_UpdateBanRemoved(Database database, DBResultSet results, const char[] error, int client) {
    // Handle query error.
    if (results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_UpdateBanRemoved", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    LogMessage("%s Updated CT Ban for '%N' (removed)", CONSOLE_PREFIX, client);
}
