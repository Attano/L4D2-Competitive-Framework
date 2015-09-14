#pragma semicolon 1

#include <sourcemod>
#include <dhooks>

#define CLEAP_ONTOUCH_OFFSET    215

new Handle:hCLeap_OnTouch;

public Plugin:myinfo =
{
	name = "L4D2 Jockey Jump-Cap Patch",
	author = "Visor",
	description = "Prevent Jockeys from being able to land caps with non-ability jumps",
	version = "1.1",
	url = "https://github.com/Attano/L4D2-Competitive-Framework"
};

public OnPluginStart()
{
	hCLeap_OnTouch = DHookCreate(CLEAP_ONTOUCH_OFFSET, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, CLeap_OnTouch);
	DHookAddParam(hCLeap_OnTouch, HookParamType_CBaseEntity);
	DHookAddEntityListener(ListenType_Created, OnEntityCreated);
}

public OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, "ability_leap"))
	{
		DHookEntity(hCLeap_OnTouch, false, entity); 
	}
}

public MRESReturn:CLeap_OnTouch(ability, Handle:hParams)
{
	new jockey = GetEntPropEnt(ability, Prop_Send, "m_owner");
	new survivor = DHookGetParam(hParams, 1);
	if (IsJockey(jockey) && !IsFakeClient(jockey) && IsSurvivor(survivor))
	{
		if (!IsAbilityActive(ability))
		{
			return MRES_Supercede;
		}
	}
	return MRES_Ignored;
}

bool:IsAbilityActive(ability)
{
	return bool:GetEntData(ability, 1148);
}

bool:IsJockey(client)
{
	return (client > 0 
		&& client <= MaxClients 
		&& IsClientInGame(client) 
		&& GetClientTeam(client) == 3 
		&& GetEntProp(client, Prop_Send, "m_zombieClass") == 5);
}

bool:IsSurvivor(client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}