#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#define MIN(%0,%1) (((%0) < (%1)) ? (%0) : (%1))
#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

new Handle:hCvarModifier;
new Handle:hCvarMinFF;
new Handle:hCvarMaxFF;
new Handle:buckshotTimer;

new pelletsShot[MAXPLAYERS][MAXPLAYERS];

new bool:bLateLoad;

public APLRes:AskPluginLoad2( Handle:plugin, bool:late, String:error[], errMax )
{
	bLateLoad = late;
	return APLRes_Success;
}

public Plugin:myinfo =
{
	name = "L4D2 Shotgun Friendly Fire Control",
	author = "Visor",
	description = "Apply damage modifier to shotgun friendly fire",
	version = "1.3",
	url = "https://github.com/Attano/L4D2-Competitive-Framework"
};

public OnPluginStart()
{
	hCvarModifier = CreateConVar("l4d2_shotgun_ff_multi", "1.0", "Shotgun FF damage modifier value", FCVAR_PLUGIN, true, 0.0, true, 5.0);
	hCvarMinFF = CreateConVar("l4d2_shotgun_ff_min", "0", "Minimum allowed shotgun FF damage; 0 for no limit", FCVAR_PLUGIN, true, 0.0);
	hCvarMaxFF = CreateConVar("l4d2_shotgun_ff_max", "0", "Maximum allowed shotgun FF damage; 0 for no limit", FCVAR_PLUGIN, true, 0.0);
	
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
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if (!IsSurvivor(victim) || !IsSurvivor(attacker) || IsFakeClient(attacker))
		return Plugin_Continue;

	if (!IsT1Shotgun(weapon))
		return Plugin_Continue;

	/**
		#define DMG_PLASMA	(1 << 24)	// < Shot by Cremator
		
		Special case -- let this function know that we've manually applied damage
		I am expecting some info about HL3 at GDC in March, so I felt like choosing this
		exotic damage flag that stands for a cut enemy from HL2
	**/
	if (damagetype == DMG_PLASMA) 
		return Plugin_Continue;
		
	pelletsShot[victim][attacker]++;

	if (buckshotTimer == INVALID_HANDLE)
	{
		new Handle:stack = CreateStack(3);
		PushStackCell(stack, weapon);
		PushStackCell(stack, attacker);
		PushStackCell(stack, victim);
		buckshotTimer = CreateTimer(0.1, ProcessShot, stack);
	}
	return Plugin_Handled;
}

public Action:ProcessShot(Handle:timer, any:stack)
{
	static victim, attacker, weapon;
	if (!IsStackEmpty(stack))
	{
		PopStackCell(stack, victim);
		PopStackCell(stack, attacker);
		PopStackCell(stack, weapon);
	}
	
	// Replicate natural behaviour
	new Float:minFF = GetConVarFloat(hCvarMinFF);
	new Float:maxFF = GetConVarFloat(hCvarMaxFF) <= 0.0 ? 99999.0 : GetConVarFloat(hCvarMaxFF);
	new Float:damage = MAX(minFF, MIN((pelletsShot[victim][attacker] * GetConVarFloat(hCvarModifier)), maxFF));
	new newPelletCount = RoundFloat(damage);
	pelletsShot[victim][attacker] = 0;
	for (new i = 0; i < newPelletCount; i++)
	{
		SDKHooks_TakeDamage(victim, attacker, attacker, 1.0, DMG_PLASMA, weapon, NULL_VECTOR, NULL_VECTOR);
	}
	
	ClearTimer(buckshotTimer);
}

bool:IsT1Shotgun(weapon)
{
	decl String:classname[64];
	GetEdictClassname(weapon, classname, sizeof(classname));
	return (StrEqual(classname, "weapon_pumpshotgun") || StrEqual(classname, "weapon_shotgun_chrome"));
}

bool:IsSurvivor(client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

ClearTimer(&Handle:timer)
{
	if (timer != INVALID_HANDLE)
	{
		KillTimer(timer);
		timer = INVALID_HANDLE;
	}     
}