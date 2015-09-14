#pragma semicolon 1

#include <sourcemod>

public Plugin:myinfo = 
{
    name = "Death Cam Skip Fix",
    author = "Jacob",
    description = "Blocks players skipping their death cam",
    version = "1.0",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath);
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if(IsValidClient(client) && GetClientTeam(client) == 3)
	{
		FakeClientCommand(client, "+jump");
		FakeClientCommand(client, "+attack1");
		FakeClientCommand(client, "+attack2");
		CreateTimer(8.0, RemoveSpamBlock, client);
	}
}

public Action:RemoveSpamBlock(Handle:timer, any:client)
{
	FakeClientCommand(client, "-jump");
	FakeClientCommand(client, "-attack1");
	FakeClientCommand(client, "-attack2");
}

stock bool:IsValidClient(client, bool:nobots = true)
{ 
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
    {
        return false; 
    }
    return IsClientInGame(client); 
}