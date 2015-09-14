#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new Handle:hCanRespawnTime;

public Plugin:myinfo =
{
        name = "Scavenge Gascan Respawn Fix",
        author = "Jacob",
        description = "Sets cans to not respawn other than on scavenge finales.",
        version = "1.0",
        url = "nope"
}

public OnPluginStart()
{
	hCanRespawnTime = FindConVar("scavenge_item_respawn_delay");
}

public OnMapStart()
{
	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	if(StrEqual(mapname, "c6m3_port"))
	{
		SetConVarInt(hCanRespawnTime, 20);
	}
	else if(StrEqual(mapname, "c1m4_atrium"))
	{
		SetConVarInt(hCanRespawnTime, 20);
	}
	else
	{
		SetConVarInt(hCanRespawnTime, 9999);
	}
}

public OnPluginEnd()
{
	ResetConVar(hCanRespawnTime);
}
