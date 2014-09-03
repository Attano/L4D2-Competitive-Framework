#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <l4d2d_timers>

#define TICK_TIME       0.200072

new Handle:hCvarDamagePerTick;
new Handle:hCvarMaxTicks;
new Handle:hCvarGodframeTicks;
new Handle:hPuddles;

new Float:damagePerTick;

new maxTicks;
new godframeTicks;

new bool:bLateLoad;

public APLRes:AskPluginLoad2(Handle:plugin, bool:late, String:error[], errMax) 
{
	bLateLoad = late;
	return APLRes_Success;    
}

public Plugin:myinfo = 
{
	name = "L4D2 Uniform Spit",
	author = "Visor",
	description = "Make the spit deal static amounts of DPS under all circumstances",
	version = "1.2",
	url = "https://github.com/Attano/smplugins"
};

public OnPluginStart()
{
	hCvarDamagePerTick = CreateConVar("l4d2_spit_dmg", "-1.0", "Damage per tick the spit inflicts. -1 to skip damage adjustments");
	hCvarMaxTicks = CreateConVar("l4d2_spit_max_ticks", "28", "Maximum number of acid damage ticks");
	hCvarGodframeTicks = CreateConVar("l4d2_spit_godframe_ticks", "4", "Number of initial godframed acid ticks");

	hPuddles = CreateTrie();

	if (bLateLoad) 
	{
		for (new i = 1; i <= MaxClients; i++) 
		{
			if (IsClientInGame(i)) 
			{
				OnClientPutInServer(i);
			}
		}
	}
}

public OnConfigsExecuted()
{
	damagePerTick = GetConVarFloat(hCvarDamagePerTick);
	maxTicks = GetConVarInt(hCvarMaxTicks);
	godframeTicks = GetConVarInt(hCvarGodframeTicks);
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, "insect_swarm"))
	{
		decl String:trieKey[8];
		IndexToKey(entity, trieKey, sizeof(trieKey));

		new count[MaxClients];
		SetTrieArray(hPuddles, trieKey, count, MaxClients);
	}
}

public OnEntityDestroyed(entity)
{
	decl String:trieKey[8];
	IndexToKey(entity, trieKey, sizeof(trieKey));

	decl count[MaxClients];
	if (GetTrieArray(hPuddles, trieKey, count, MaxClients))
	{
		RemoveFromTrie(hPuddles, trieKey);
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damageType, &weapon, Float:damageForce[3], Float:damagePosition[3]) 
{
	if (victim <= 0 || victim > MaxClients || GetClientTeam(victim) != 2 || !IsValidEdict(inflictor))
	{
		return Plugin_Continue;
	}

	decl String:classname[64];
	GetEdictClassname(inflictor, classname, sizeof(classname));
	if (StrEqual(classname, "insect_swarm"))
	{
		decl String:trieKey[8];
		IndexToKey(inflictor, trieKey, sizeof(trieKey));

		decl count[MaxClients];
		if (GetTrieArray(hPuddles, trieKey, count, MaxClients))
		{
			count[victim]++;

			// Check to see if it's a godframed tick
			if (GetPuddleLifetime(inflictor) >= godframeTicks * TICK_TIME && count[victim] < godframeTicks)
			{
				count[victim] = godframeTicks + 1;
			}

			// Update the array with stored tickcounts
			SetTrieArray(hPuddles, trieKey, count, MaxClients);

			// Let's see what do we have here
			if (damagePerTick > -1.0)
			{
				damage = damagePerTick;
			}
			if (godframeTicks >= count[victim] || count[victim] > maxTicks)
			{
				damage = 0.0;
			}
			if (count[victim] > maxTicks)
			{
				AcceptEntityInput(inflictor, "Kill");
			}
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;	
}

Float:GetPuddleLifetime(puddle)
{
	return ITimer_GetElapsedTime(IntervalTimer:(GetEntityAddress(puddle) + Address:2968));
}

IndexToKey(index, String:str[], maxlength)
{
	Format(str, maxlength, "%x", index);
}