#include <sourcemod>
#include <sdkhooks>
#include <sdktools>



#define SEQ_COACH_NICK    		  630
#define SEQ_ELLIS				  635
#define SEQ_ROCHELLE     		  638
#define SEQ_BILL_LOUIS	  	      538
#define SEQ_FRANCIS               541
#define SEQ_ZOEY                  547


new lastAnimSequence[MAXPLAYERS + 1];
//Should initialise array as all false
new bool:giveWeapon[MAXPLAYERS + 1];             
new iTick = 0;

public Plugin:myinfo =
{
    name = "L4D2 Melee and Shove Shenanigans",
    author = "Sir, High Cookie and Standalone",
    description = "Stops Shoves slowing the Tank and stops survivors keeping melee out after tank punch",
    version = "1.ʕ•ᴥ•ʔ",
    url = ""
}

public OnPluginStart()
{
    HookEvent("player_hurt", PlayerHit);
}
 
public Action:PlayerHit(Handle:event, String:event_name[], bool:dontBroadcast)
{
    new PlayerID = GetClientOfUserId(GetEventInt(event, "userid"));
    new String:Weapon[256];  
    GetEventString(event, "weapon", Weapon, 256);
    if (IsSurvivor(PlayerID) && StrEqual(Weapon, "tank_claw"))
    {
        new activeweapon = GetEntPropEnt(PlayerID, Prop_Send, "m_hActiveWeapon");
        if (IsValidEdict(activeweapon))
		{
			decl String:weaponname[64];
			GetEdictClassname(activeweapon, weaponname, sizeof(weaponname));	
			
			if (StrEqual(weaponname, "weapon_melee", false) && GetPlayerWeaponSlot(PlayerID, 0) != -1)
			{
				SDKHook(PlayerID, SDKHook_PostThink, OnThink);
			}
		}
    }
}

public OnThink(client)
{
	if(iTick > 300)
	{ 
		iTick = 0;
		SDKUnhook(client, SDKHook_PostThink, OnThink);
	}
	iTick = 1 + iTick;

	new sequence = GetEntProp(client, Prop_Send, "m_nSequence");

	if (!giveWeapon[client])
	{
		if ((lastAnimSequence[client] == SEQ_COACH_NICK && sequence != SEQ_COACH_NICK) || (lastAnimSequence[client] == SEQ_ELLIS && sequence != SEQ_ELLIS) || (lastAnimSequence[client] == SEQ_ROCHELLE   && sequence != SEQ_ROCHELLE)|| (lastAnimSequence[client] == SEQ_BILL_LOUIS   && sequence != SEQ_BILL_LOUIS)|| (lastAnimSequence[client] == SEQ_FRANCIS   && sequence != SEQ_FRANCIS)|| (lastAnimSequence[client] == SEQ_ZOEY   && sequence != SEQ_ZOEY))
		{
			giveWeapon[client] = true;
		}
	}
	else
	{
		SwapToGun(client)
		giveWeapon[client] = false;
		iTick = 0;
		SDKUnhook(client, SDKHook_PostThink, OnThink);
	}
	lastAnimSequence[client] = sequence;
}

stock GetWeaponAmmo(client, slot)
{
    new ammoOffset = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
    return GetEntData(client, ammoOffset+(slot*4));
}
stock SetWeaponAmmo(client, slot, ammo)
{
	new ammoOffset = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
	return SetEntData(client, ammoOffset+(slot*4), ammo);
}

public Action: SwapToGun(any:client)
{
	//What Gun did they have?
	decl String:weaponname[64];
	new weaponindex = GetPlayerWeaponSlot(client, 0);
	GetEdictClassname(weaponindex, weaponname, sizeof(weaponname));
	
	//How much ammo in their clip?
	new ammoclip = GetEntProp(weaponindex, Prop_Send, "m_iClip1");
	
	//How much ammo reserve did they have?
	new ammotype = GetEntProp(weaponindex, Prop_Send, "m_iPrimaryAmmoType");
	new reserveammo = GetWeaponAmmo(client, ammotype);
	
	//Delete their Gun	
	AcceptEntityInput(weaponindex, "kill");
	
	new Handle:hData;
	CreateDataTimer(0.01, TimedSwap, hData);
	WritePackCell(hData, client);
	WritePackString(hData, weaponname);
	WritePackCell(hData, ammoclip);
	WritePackCell(hData, ammotype);
	WritePackCell(hData, reserveammo);
	
	return
}

public Action:TimedSwap(Handle:Timer, Handle:hData)
{
    new client, ammoclip, ammotype, reserveammo, weaponindex;
    decl String:weaponname[64];
    
    ResetPack(hData);
    client = ReadPackCell(hData);
    ReadPackString(hData, weaponname, sizeof(weaponname));
    ammoclip = ReadPackCell(hData);
    ammotype = ReadPackCell(hData);
    reserveammo = ReadPackCell(hData);
	
    //Give them a new Gun of the same type
    new flagsgive = GetCommandFlags("give");
    SetCommandFlags("give", flagsgive & ~FCVAR_CHEAT);
    FakeClientCommand(client, "give %s", weaponname);
    SetCommandFlags("give", flagsgive|FCVAR_CHEAT);
    
    //Set the ammo to the correct number
    weaponindex = GetPlayerWeaponSlot(client, 0);		
    SetEntProp(weaponindex, Prop_Send, "m_iClip1", ammoclip);
    SetWeaponAmmo(client, ammotype, reserveammo);
    return
}
 
public Action:L4D_OnShovedBySurvivor(shover, shovee, const Float:vector[3])
{
    if (!IsSurvivor(shover) || !IsInfected(shovee)) return Plugin_Continue;
    if (IsTankOrCharger(shovee)) return Plugin_Handled;
    return Plugin_Continue;
}
 
public Action:L4D2_OnEntityShoved(shover, shovee_ent, weapon, Float:vector[3], bool:bIsHunterDeadstop)
{
    if (!IsSurvivor(shover) || !IsInfected(shovee_ent)) return Plugin_Continue;
    if (IsTankOrCharger(shovee_ent)) return Plugin_Handled;
    return Plugin_Continue;
}
 
stock bool:IsSurvivor(client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}
 
stock bool:IsInfected(client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3;
}
 
bool:IsTankOrCharger(client)  
{
    if (!IsPlayerAlive(client))
        return false;
 
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 8)
        return true;
 
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 6)
        return true;
 
    return false;
}
