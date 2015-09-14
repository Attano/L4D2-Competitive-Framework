#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include "left4downtown"

#define TEAM_INFECTED 3
#define debug 0

enum SIClasses
{
    SMOKER_CLASS=1,
    BOOMER_CLASS,
    HUNTER_CLASS,
    SPITTER_CLASS,
    JOCKEY_CLASS,
    CHARGER_CLASS,
    WITCH_CLASS,
    TANK_CLASS,
    NOTINFECTED_CLASS
}

new Handle: hCvarSurvivorCount = INVALID_HANDLE;
new PlayersCapped;
new SurvivorCount;

public Plugin:myinfo =
{
    name = "Capper Removal",
    author = "Jacob",
    description = "Better cap removal control. Supports any number of players.",
    version = "1.0",
    url = "https://github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    //Cvars and whatnot
    hCvarSurvivorCount = CreateConVar("cr_survivors_count", "2", "How many survivors are in this config?", FCVAR_PLUGIN, true, 1.0);
    SurvivorCount = GetConVarInt(hCvarSurvivorCount);
    
    //Hooks
    HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
    HookEvent("lunge_pounce", Event_Survivor_Pounced);
    HookEvent("tongue_grab", Event_Survivor_Pulled);
    HookEvent("jockey_ride", Event_Survivor_Rode);
    HookEvent("charger_pummel_start", Event_Survivor_Charged);
    HookEvent("pounce_stopped", Event_Pounce_End);
    HookEvent("tongue_release", Event_Pull_End);
    HookEvent("jockey_ride_end", Event_Ride_End);
    HookEvent("charger_pummel_end", Event_Charge_End);
    HookEvent("round_end", Event_Round_End);
}

public capStart(Handle:event)
{
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!victim) return;
    PlayersCapped++;
	if(debug)
	{
	PrintToChatAll("Players Capped: %i", PlayersCapped);
	}
}

public capEnd(Handle:event)
{
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!victim) return;
    if (--PlayersCapped < 0)
    {
        PlayersCapped = 0;
    }
	if (debug)
	{
	PrintToChatAll("Players Capped: %i", PlayersCapped);
	}
}

public Event_Survivor_Pounced (Handle:event, const String:name[], bool:dontBroadcast)
{
    capStart(event);
}

public Event_Pounce_End (Handle:event, const String:name[], bool:dontBroadcast)
{
    capEnd(event);
}

public Event_Survivor_Rode (Handle:event, const String:name[], bool:dontBroadcast)
{
    capStart(event);
}

public Event_Ride_End (Handle:event, const String:name[], bool:dontBroadcast)
{
    capEnd(event);
}

public Event_Survivor_Charged (Handle:event, const String:name[], bool:dontBroadcast)
{
    capStart(event);
}

public Event_Charge_End (Handle:event, const String:name[], bool:dontBroadcast)
{
    capEnd(event);
}

public Event_Survivor_Pulled (Handle:event, const String:name[], bool:dontBroadcast)
{
    capStart(event);
}

public Event_Pull_End (Handle:event, const String:name[], bool:dontBroadcast)
{
    capEnd(event);
}

public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
   
    if (!IsClientAndInGame(attacker))
        return;
   
    new zombie_class = GetZombieClass(attacker);
   
    if (GetClientTeam(attacker) == TEAM_INFECTED && zombie_class != _:TANK_CLASS && PlayersCapped >= SurvivorCount)
    {
        CreateTimer(3.0, PlayerSuicide, attacker, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action:PlayerSuicide(Handle:timer, any:attacker)
{
    ForcePlayerSuicide(attacker);
}

public Event_Round_End(Handle:event, const String:name[], bool:dontBroadcast)
{
    PlayersCapped = 0;
}

stock GetZombieClass(client) return GetEntProp(client, Prop_Send, "m_zombieClass");

stock GetSpecialInfectedHP(class)
{
    if (hSpecialInfectedHP[class] != INVALID_HANDLE)
        return GetConVarInt(hSpecialInfectedHP[class]);
    
    return 0;
}

stock bool:IsClientAndInGame(index)
{
    if (index > 0 && index < MaxClients)
    {
        return IsClientInGame(index);
    }
    return false;
}
