#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>

new bool:IsPlantation = false;

public Plugin:myinfo =
{
        name = "Swamp Finale Fix",
        author = "Jacob",
        description = "Fix swamp finale breaking for 2nd team",
        version = "0.1"
}

public OnPluginStart()
{
		HookEvent("round_end", Event_RoundEnd);
}

public OnMapStart()
{
    decl String:mapname[64];
    GetCurrentMap(mapname, sizeof(mapname));
    if(StrEqual(mapname, "c3m4_plantation"))
    {
        IsPlantation = true;
    }
    else
    {
        IsPlantation = false;
    }
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new FinaleEntity;
	while ((FinaleEntity = FindEntityByClassname(FinaleEntity, "trigger_finale")) != -1)
	{
		if(!IsValidEdict(FinaleEntity) || !IsValidEntity(FinaleEntity) || !IsPlantation) continue;
		AcceptEntityInput(FinaleEntity, "ForceFinaleStart");
	}
}
