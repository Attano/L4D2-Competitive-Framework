#pragma semicolon 1

#include <sourcemod>
#include <l4d2_direct>
#define L4D2UTIL_STOCKS_ONLY
#include <l4d2util>

#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

new Handle:g_hVsBossBuffer;

public Plugin:myinfo =
{
    name = "L4D2 Survivor Progress",
    author = "CanadaRox, Visor",
    description = "Print survivor progress in flow percents ",
    version = "2.2",
    url = "https://github.com/Attano/ProMod"
};

public OnPluginStart()
{
	g_hVsBossBuffer = FindConVar("versus_boss_buffer");

	RegConsoleCmd("sm_cur", CurrentCmd);
	RegConsoleCmd("sm_current", CurrentCmd);
}

public Action:CurrentCmd(client, args)
{
	new boss_proximity = RoundToNearest(GetBossProximity() * 100.0);
	PrintToChat(client, "\x01<\x05Current\x01> \x05%d%%", boss_proximity);
}

stock Float:GetBossProximity()
{
	new Float:proximity = GetMaxSurvivorCompletion() + (GetConVarFloat(g_hVsBossBuffer) / L4D2Direct_GetMapMaxFlowDistance());
	return MAX(proximity, 1.0);
}

stock Float:GetMaxSurvivorCompletion()
{
	new Float:flow = 0.0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsSurvivor(i))
		{
			flow = MAX(flow, L4D2Direct_GetFlowDistance(i));
		}
	}
	return (flow / L4D2Direct_GetMapMaxFlowDistance());
}