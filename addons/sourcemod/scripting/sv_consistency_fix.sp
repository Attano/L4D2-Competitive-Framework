#pragma semicolon 1
#include <sourcemod>

#define PLUGIN_VERSION "1.1"
#define PLUGIN_URL "http://step.l4dnation.com/"

#define LINE_SIZE 512

static Handle:g_whitelist;
static String:g_line[LINE_SIZE], String:g_prevline[LINE_SIZE];
static g_count, g_printcount[MAXPLAYERS];
static bool:skipped[MAXPLAYERS];

public Plugin:myinfo =
{
	name = "sv_consistency fixes",
	author = "step",
	description = "Fixes multiple sv_consistency issues.",
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public OnPluginStart()
{
	if (!FileExists("whitelist.cfg"))
	{
		SetFailState("Couldn't find whitelist.cfg");
	}
	
	
	HookEvent("player_connect_full", Event_PlayerConnectFull, EventHookMode_Post);
	HookEvent("player_first_spawn", Event_PlayerFirstSpawn, EventHookMode_Pre);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	
	RegAdminCmd("sm_consistencycheck", Command_ConsistencyCheck, ADMFLAG_RCON, "Performs a consistency check on all players.", "", FCVAR_PLUGIN);
	SetConVarInt(CreateConVar("cl_consistencycheck_interval", "180.0", "Perform a consistency check after this amount of time (seconds) has passed since the last.", FCVAR_REPLICATED|FCVAR_LAUNCHER), 999999);
	
	
	g_whitelist = CreateArray(LINE_SIZE, 1);
	
	new Handle:file = OpenFile("whitelist.cfg", "r");
	while (!IsEndOfFile(file))
	{
		ReadFileLine(file, g_line, sizeof(g_line));
		ReplaceString(g_line, sizeof(g_line), "\r\n", "", false);
		SplitString(g_line, "//", g_line, sizeof(g_line));
		
		if (!StrEqual(g_line, "") && !StrEqual(g_line, g_prevline))
		{
			Format(g_prevline, sizeof(g_prevline), "%s", g_line);
			
			if (g_count % 10 == 1)
			{
				ResizeArray(g_whitelist, g_count + 10);
			}
			SetArrayString(g_whitelist, g_count, g_line);
			
			g_count += 1;
		}
	}
	CloseHandle(file);
	
	if (g_count % 10 != 1)
	{
		ResizeArray(g_whitelist, g_count);
	}
}

public Action:Event_PlayerConnectFull(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(0.1, PrintWhitelist, GetClientOfUserId(GetEventInt(event, "userid")), TIMER_REPEAT);
	
	return Plugin_Continue;
}

public Action:PrintWhitelist(Handle:timer, any:client)
{
	if (g_printcount[client] >= g_count || !IsClientInGame(client))
	{
		g_printcount[client] = 0;
		skipped[client] = false;
		
		return Plugin_Stop;
	}
	
	while (g_printcount[client] < g_count)
	{
		if (g_printcount[client] % 10 == 9 && !skipped[client])
		{
			skipped[client] = true;
			
			break;
		}
		
		GetArrayString(g_whitelist, g_printcount[client], g_line, sizeof(g_line));
		PrintToConsole(client, "%s", g_line);
		
		g_printcount[client] += 1;
		skipped[client] = false;
	}

	return Plugin_Continue;
}

public Action:Event_PlayerFirstSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{	
	if (!GetEventBool(event, "isbot"))
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{	
	ConsistencyCheck();
	
	return Plugin_Continue;
}

public Action:Command_ConsistencyCheck(client, args)
{
	ConsistencyCheck();
	
	return Plugin_Handled;
}

public ConsistencyCheck()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			ClientCommand(client, "cl_consistencycheck");
		}
	}
}

public OnClientConnected(client)
{
	ClientCommand(client, "cl_consistencycheck");
}