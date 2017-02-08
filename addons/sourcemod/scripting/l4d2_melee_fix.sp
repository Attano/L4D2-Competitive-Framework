#include <sourcemod>
#include <sdkhooks>

public Plugin:myinfo = 
{
    name = "Fix Melee Weapons",
    author = "Sir",
    description = "Fix those darn Melee Weapons not applying correct damage values",
    version = "1.0",
    url = "https://github.com/SirPlease/SirCoding"
}

public OnPluginStart()
{
    //Player Hurt is more fun to play with than SDK_Hook OnTakeDamage or OnTakeDamagePost.
    HookEvent("player_hurt", PlayerHurt);
}

public Action:PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
    new String:weapon[64];
    GetEventString(event, "weapon", weapon, sizeof(weapon));
    
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    new health = GetEventInt(event, "health");
    
    if (StrEqual(weapon, "melee") && IsSi(victim))
    {
        new class = GetEntProp(victim, Prop_Send, "m_zombieClass");
        
        //Testing showed that only the L4D1 SI; Hunter, Smoker and Boomer have issues with correct Melee Damage values being applied, check for Spitter and Jockey anyway!
        if(class <= 5 && health > 0)
        {
            //Award damage to Attacker accordingly.
            SDKHooks_TakeDamage(victim, 0, attacker, float(health));
        }    
    }
}	

bool:IsSi(client) 
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3) 
    {
        return true;
    }
    
    return false;
}