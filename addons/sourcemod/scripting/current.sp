#pragma semicolon 1

#include <sourcemod>
#include <l4d2_direct>
#define L4D2UTIL_STOCKS_ONLY
#include <l4d2util>

#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

new Handle:hCvarPrintToEveryone;
new Handle:survivor_limit;
new Handle:z_max_player_zombies;
new Handle:g_hVsBossBuffer;

public Plugin:myinfo =
{
    name = "L4D2 Survivor Progress",
    author = "CanadaRox, Visor",
    description = "Print survivor progress in flow percents ",
    version = "2.0.1",
    url = "https://github.com/Attano/ProMod"
};

public OnPluginStart()
{
	g_hVsBossBuffer = FindConVar("versus_boss_buffer");

	hCvarPrintToEveryone =
		CreateConVar("l4d_global_percent", "1",
				"Display boss percentages to entire team when using commands",
				FCVAR_PLUGIN);

	RegConsoleCmd("sm_cur", CurrentCmd);
	RegConsoleCmd("sm_current", CurrentCmd);

	survivor_limit = FindConVar("survivor_limit");
	z_max_player_zombies = FindConVar("z_max_player_zombies");
}

public Action:CurrentCmd(client, args)
{
	new L4D2_Team:team = L4D2_Team:GetClientTeam(client);
	if (team == L4D2Team_Spectator)
	{
		PrintCurrentToClient(client);
	}
	else
	{
		if (GetConVarBool(hCvarPrintToEveryone))
		{
			PrintCurrentToTeam(team);
		}
		else
		{
			PrintCurrentToClient(client);
		}
	}
}

stock PrintCurrentToClient(client)
{
	new boss_proximity = RoundToNearest(GetBossProximity() * 100.0);
	PrintToChat(client, "\x01Current: \x04%d%%", boss_proximity);
}

stock PrintCurrentToTeam(L4D2_Team:team)
{
	new members_found;
	new team_max = GetTeamMaxHumans(team);
	new boss_proximity = RoundToNearest(GetBossProximity() * 100.0);
	for (new client = 1;
			client <= MaxClients && members_found < team_max;
			client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client) &&
				L4D2_Team:GetClientTeam(client) == team)
		{
			members_found++;
			PrintToChat(client, "\x01Current: \x04%d%%", boss_proximity);
		}
	}
}

stock Float:GetBossProximity()
{
	new Float:proximity = GetMaxSurvivorCompletion() + (GetConVarFloat(g_hVsBossBuffer) / L4D2Direct_GetMapMaxFlowDistance());
	return MAX(proximity, 1.0);
}

stock Float:GetMaxSurvivorCompletion()
{
	new Float:flow = 0.0;
	decl Float:tmp_flow;
	decl Float:origin[3];
	decl Address:pNavArea;
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) &&
			L4D2_Team:GetClientTeam(client) == L4D2Team_Survivor)
		{
			GetClientAbsOrigin(client, origin);
			pNavArea = L4D2Direct_GetTerrorNavArea(origin);
			if (pNavArea != Address_Null)
			{
				tmp_flow = L4D2Direct_GetTerrorNavAreaFlow(pNavArea);
				flow = MAX(flow, tmp_flow);
			}
		}
	}
	return (flow / L4D2Direct_GetMapMaxFlowDistance());
}

stock GetTeamMaxHumans(L4D2_Team:team)
{
	if (team == L4D2Team_Survivor)
	{
		return GetConVarInt(survivor_limit);
	}
	else if (team == L4D2Team_Infected)
	{
		return GetConVarInt(z_max_player_zombies);
	}
	return MaxClients;
}
