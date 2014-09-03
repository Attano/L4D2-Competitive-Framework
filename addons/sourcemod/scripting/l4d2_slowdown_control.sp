#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <left4downtown>

#define CLAMP(%0,%1,%2) (((%0) > (%2)) ? (%2) : (((%0) < (%1)) ? (%1) : (%0)))

new Handle:hCvarSdGunfireSi;
new Handle:hCvarSdGunfireTank;
new Handle:hCvarSdInwaterTank;
new Handle:hCvarSdInwaterSurvivor;

new Float:fGunfireSi;
new Float:fGunfireTank;
new Float:fInWaterTank;
new Float:fInWaterSurvivor;

public Plugin:myinfo = 
{
    name = "L4D2 Slowdown Control",
    author = "Visor",
    version = "2.1",
    description = "Manages the water/gunfire slowdown for both teams",
	url = "https://github.com/ConfoglTeam/ProMod"
};

public OnPluginStart() 
{
    hCvarSdGunfireSi = CreateConVar("l4d2_slowdown_gunfire_si", "-1", "Slowdown from gunfire for SI(-1: native slowdown; 0: no slowdown; 0.01-0.99: velocity multiplier)", FCVAR_PLUGIN);
    hCvarSdGunfireTank = CreateConVar("l4d2_slowdown_gunfire_tank", "-1", "Slowdown from gunfire for the Tank(-1: native slowdown; 0: no slowdown; 0.01-0.99: velocity multiplier)", FCVAR_PLUGIN); 
    hCvarSdInwaterTank = CreateConVar("l4d2_slowdown_water_tank", "-1", "Slowdown in the water for the Tank(-1: native slowdown; 0: no slowdown; 0.01-0.99: velocity multiplier)", FCVAR_PLUGIN); 
    hCvarSdInwaterSurvivor = CreateConVar("l4d2_slowdown_water_survivors", "-1", "Slowdown in the water for the Survivors(-1: native slowdown; 0: no slowdown; 0.0-0.99: velocity multiplier)", FCVAR_PLUGIN); 

    HookConVarChange(hCvarSdGunfireSi, OnCvarChanged);
    HookConVarChange(hCvarSdGunfireTank, OnCvarChanged);
    HookConVarChange(hCvarSdInwaterTank, OnCvarChanged);
    HookConVarChange(hCvarSdInwaterSurvivor, OnCvarChanged);
}

public OnCvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[]) 
{
    OnConfigsExecuted();
}

public OnConfigsExecuted()
{
    fGunfireSi = ProcessConVar(hCvarSdGunfireSi);
    fGunfireTank = ProcessConVar(hCvarSdGunfireTank);
    fInWaterTank = ProcessConVar(hCvarSdInwaterTank);
    fInWaterSurvivor = ProcessConVar(hCvarSdInwaterSurvivor);
}

// The old slowdown plugin's cvars weren't quite intuitive, so I'll try to fix it this time
Float:ProcessConVar(Handle:cvar)
{
    new Float:value = GetConVarFloat(cvar);
    if (value == -1.0)  // native slowdown
        return -1.0;
        
    if (value == 0.0)   // slowdown off
        return 1.0;
    
    return CLAMP(value, 0.01, 2.0); // slowdown multiplier
}

public OnClientPutInServer(client) 
{
    SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

public OnClientDisconnect(client) 
{
    SDKUnhook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

public L4D2_OnWaterMove(client)
{
    if (GetEntityFlags(client) & FL_INWATER)   // failsafe; sometimes it triggers during noclip
    {
        ApplySlowdown(client, IsSurvivor(client) ? fInWaterSurvivor : (IsInfected(client) && IsTank(client) ? fInWaterTank : -1.0));
    }
}

public Action:OnTakeDamagePost(victim, &attacker, &inflictor, &Float:damage, &damageType, &weapon, Float:damageForce[3], Float:damagePosition[3]) 
{
    if (IsInfected(victim))
    {
        ApplySlowdown(victim, IsTank(victim) ? fGunfireTank : fGunfireSi);
    }
}

ApplySlowdown(client, Float:value)
{
    if (value == -1.0)
        return;
      
    SetEntPropFloat(client, Prop_Send, "m_flVelocityModifier", value);
}

stock bool:IsSurvivor(client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}

stock bool:IsInfected(client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3;
}

stock bool:IsTank(client)
{
    return GetEntProp(client, Prop_Send, "m_zombieClass") == 8;
}