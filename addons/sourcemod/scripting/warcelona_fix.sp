#include <sourcemod>
#include <sdkhooks>
#include <l4d2_direct>

#define DISTANCE_PROTECT    0.2
#define DMG_FALL    (1 << 5)

new bool:bPluginActive;

public Plugin:myinfo = 
{
    name = "Warcelona Fix aka Lazy Workaround",
    author = "raecher, alexip, Visor",
    description = "Prevents Survivors from dying during/after ready-up on Warcelona maps.",
    version = "0.3",
    url = "https://github.com/Attano/Equilibrium"
};

public OnMapStart()
{
    decl String:mapname[64];
    GetCurrentMap(mapname, sizeof(mapname));

    bPluginActive = (!strcmp(mapname, "srocchurch") || !strcmp(mapname, "mnac")) ? true : false;
}

public OnClientPutInServer(client)
{
    if (bPluginActive)
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnClientDisconnect(client)
{
    SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
    if (!IsSurvivor(victim))
        return Plugin_Continue;
           
    if (GetDistance(victim) <= DISTANCE_PROTECT && (damagetype & DMG_FALL))
        return Plugin_Handled;

    return Plugin_Continue;
}

GetDistance(client)
{
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    new Float:flow = L4D2Direct_GetTerrorNavAreaFlow(L4D2Direct_GetTerrorNavArea(pos));
    return RoundToNearest(flow / L4D2Direct_GetMapMaxFlowDistance());
}

bool:IsSurvivor(client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}