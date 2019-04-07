#if defined _ctbans_included
    #endinput
#endif
#define _ctbans_included

public SharedPlugin __pl_ctbans = {
    name = "ctbans",
    file = "ctbans.smx",
    #if defined REQUIRE_PLUGIN
    required = 1,
    #else
    required = 0,
    #endif
};

/**
 * CTBans_AddBan
 * Adds a CT Ban to the specified player.
 */
native void CTBans_AddBan(const int client, const int admin, const int duration, const char[] reason);

/**
 * CTBans_RemoveBan
 * Removes a CT Ban from the specified player.
 */
native void CTBans_RemoveBan(const int client, const int admin);

#if !defined REQUIRE_PLUGIN
public __pl_ctbans_SetNTVOptional() {
	MarkNativeAsOptional("CTBans_AddBan");
	MarkNativeAsOptional("CTBans_RemoveBan");
}
#endif
