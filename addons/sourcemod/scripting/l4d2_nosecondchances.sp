#pragma semicolon 1

#include <sourcemod>
#include <l4d2_direct>

new const L4D2_SI_Victim_Slots[] = {
    -1,
    13280,    // Smoker
    -1,
    16004,    // Hunter
    -1,
    16124,    // Jockey
    15972,    // Charger
    -1,
    -1,
    -1
};

public Plugin:myinfo = 
{
    name = "L4D2 No Second Chances",
    author = "Visor",
    description = "Previously human-controlled SI bots with a cap won't die",
    version = "1.0",
    url = "https://github.com/Attano/Equilibrium"
};

public OnPluginStart()
{
    HookEvent("player_bot_replace", PlayerBotReplace);
}

public PlayerBotReplace(Handle:event, const String:name[], bool:dontBroadcast)
{
    new bot = GetClientOfUserId(GetEventInt(event, "bot"));
    if (IsClientConnected(bot) && IsClientInGame(bot) && GetClientTeam(bot) == 3 && IsFakeClient(bot))
    {
        if (ShouldBeKicked(bot))
        {
            ForcePlayerSuicide(bot);
        }
    }
}

bool:ShouldBeKicked(infected)
{
    new Address:pEntity = GetEntityAddress(infected);
    if (pEntity == Address_Null)
        return false;

    new zcOffset = L4D2_SI_Victim_Slots[GetEntProp(infected, Prop_Send, "m_zombieClass")];
    if (zcOffset == -1)
        return false;
    
    new hasTarget = LoadFromAddress(pEntity + Address:zcOffset, NumberType_Int32);
    return hasTarget > 0 ? false : true;
}