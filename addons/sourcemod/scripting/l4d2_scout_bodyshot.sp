#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <l4d2weapons>

#define HITGROUP_STOMACH	3

new bool:bLateLoad;

public APLRes:AskPluginLoad2( Handle:plugin, bool:late, String:error[], errMax )
{
	bLateLoad = late;
	return APLRes_Success;
}

public Plugin:myinfo =
{
	name = "L4D2 Scout Hunter Bodyshot",
	author = "Visor",
	description = "Remove Scout's stomach hitgroup multiplier against hunters",
	version = "1.0",
	url = "https://github.com/Attano/L4D2-Competitive-Framework"
};

public OnPluginStart()
{
	if (bLateLoad)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientConnected(i) && IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_TraceAttack, TraceAttack);
}

public Action:TraceAttack(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
	if (!IsHunter(victim) || !IsSurvivor(attacker) || IsFakeClient(attacker))
		return Plugin_Continue;

	if (!IsScout(GetClientActiveWeapon(attacker)))
		return Plugin_Continue;
	
	if (hitgroup == HITGROUP_STOMACH)
	{
		damage = GetScoutDamageValue() / 1.25;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

GetClientActiveWeapon(client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

GetScoutDamageValue()
{
	return L4D2_GetIntWeaponAttribute("weapon_sniper_scout", L4D2IntWeaponAttributes:L4D2IWA_Damage);
}

bool:IsScout(weapon)
{
	decl String:classname[64];
	GetEdictClassname(weapon, classname, sizeof(classname));
	return StrEqual(classname, "weapon_sniper_scout");
}

bool:IsSurvivor(client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

bool:IsHunter(client)
{
	return (client > 0
		&& client <= MaxClients
		&& IsClientInGame(client)
		&& GetClientTeam(client) == 3
		&& GetEntProp(client, Prop_Send, "m_zombieClass") == 3
		&& GetEntProp(client, Prop_Send, "m_isGhost") != 1);
}