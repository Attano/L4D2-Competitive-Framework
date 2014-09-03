#pragma semicolon 1

#include <sourcemod>

public Plugin:myinfo =
{
	name = "No Spitter During Tank",
	author = "Don, epilimic",
	description = "Prevents the director from giving the infected team a spitter while the tank is alive",
	version = "1.7", //removed world death check, only use this version if you run tank_control and there are no natural tank passes. If you need/want tank passing then you need version 1.6 of this plugin.
	url = "https://bitbucket.org/DonSanchez/random-sourcemod-stuff"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	decl String:sGame[12];
	GetGameFolderName(sGame, sizeof(sGame));
	if (StrEqual(sGame, "left4dead2"))	// Only load the plugin if the server is running Left 4 Dead 2.
	{
		return APLRes_Success;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports L4D2");
		return APLRes_Failure;
	}
}

new bool:g_bIsTankAlive;
new Handle:g_hSpitterLimit;
new g_iOldSpitterLimit;

public OnPluginStart()
{
	HookEvent("tank_spawn", Event_tank_spawn_Callback);
	HookEvent("player_death", Event_player_death_Callback);
	HookEvent("round_end", Event_round_end_Callback);
	g_hSpitterLimit = FindConVar("z_versus_spitter_limit");
}

public Event_tank_spawn_Callback(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bIsTankAlive)
	{
		g_iOldSpitterLimit = GetConVarInt(g_hSpitterLimit);
		SetConVarInt(g_hSpitterLimit, 0);
		g_bIsTankAlive = true;
	}
}

public Event_player_death_Callback(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bIsTankAlive)
	{
		new String:sVictimName[8];
		GetEventString(event, "victimname", sVictimName, sizeof(sVictimName));
		if (StrEqual(sVictimName, "Tank"))
		{
			SetConVarInt(g_hSpitterLimit, g_iOldSpitterLimit);
			g_bIsTankAlive = false;
		}
	}
}

public Event_round_end_Callback(Handle:event, const String:name[], bool:dontBroadcast)		// Needed for when the round ends without the tank dying.
{
	if (g_bIsTankAlive)
	{
		SetConVarInt(g_hSpitterLimit, g_iOldSpitterLimit);
		g_bIsTankAlive = false;
	}
}

public OnPluginEnd()
{
	if (g_bIsTankAlive)
	{
		SetConVarInt(g_hSpitterLimit, g_iOldSpitterLimit);
	}
}
