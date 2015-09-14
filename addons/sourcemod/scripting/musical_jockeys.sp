#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>

new bool:isJockey[MAXPLAYERS + 1] = false;

public Plugin:myinfo = 
{
    name = "Musical Jockeys",
    author = "Jacob",
    description = "Prevents jockeys being able to spawn without making any noise.",
    version = "1.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public OnMapStart()
{
	PrecacheSound("music/bacteria/jockeybacterias.wav");
}

public L4D_OnEnterGhostState(client)
{
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 5)
    {
        isJockey[client] = true;
    }
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (IsValidPlayer(client) && GetClientTeam(client) == 3 && isJockey[client])
    {
        EmitSoundToAll("music/bacteria/jockeybacterias.wav", _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
    }
    isJockey[client] = false;
}

bool:IsValidPlayer(client)
{
    if (client <= 0 || client > MaxClients) return false;
    if (!IsClientInGame(client)) return false;
    if (IsFakeClient(client)) return false;
    return true;
}