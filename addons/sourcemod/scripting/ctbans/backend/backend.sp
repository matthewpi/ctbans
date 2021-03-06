//
// Copyright (c) 2020 Matthew Penner
//
// This repository is licensed under the MIT License.
// https://github.com/matthewpi/ctbans/blob/master/LICENSE.md
//

/**
 * Backend_Connnection
 * Handles the database connection callback.
 */
public void Backend_Connnection(Database database, const char[] error, any data) {
    // Handle the connection error.
    if (database == null) {
        SetFailState("%s Failed to connect to server.  Error: %s", CONSOLE_PREFIX, error);
        return;
    }

    // Set the global database object.
    g_dbCTBans = database;

    // Log our successful connection.
    LogMessage("%s Connected to database.", CONSOLE_PREFIX);

    // Prepare a SQL transaction.
    Transaction transaction = new Transaction();

    // Add create table if not exists queries.
    transaction.AddQuery(TABLE_BANS);
    //transaction.AddQuery(TABLE_BANS_INDEX);

    // Execute the transaction.
    SQL_ExecuteTransaction(g_dbCTBans, transaction, Callback_SuccessTableTransaction, Callback_ErrorTableTransaction);

    // Loop through all online clients.
    for (int i = 1; i <= MaxClients; i++) {
        // Check if the client is invalid.
        if (!IsClientValid(i)) {
            continue;
        }

        // Get the client's steam id.
        char steamId[64];
        GetClientAuthId(i, AuthId_Steam2, steamId, sizeof(steamId));

        // Load the client's ban.
        // TODO: Use a transaction per 5-10 Backend_GetBan queries.
        Backend_GetBan(i, steamId);
    }
}

/**
 * Callback_SuccessTableTransaction
 * Successful backend callback for the table layout.
 */
static void Callback_SuccessTableTransaction(Database database, any data, int numQueries, Handle[] results, any[] queryData) {
    LogMessage("%s Created database tables successfully.", CONSOLE_PREFIX);
}

/**
 * Callback_ErrorTableTransaction
 * Failed backend callback for the table layout.
 */
static void Callback_ErrorTableTransaction(Database database, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
    // Handle query error.
    LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_ErrorTableTransaction", (strlen(error) > 0 ? error : "Unknown."));
}
