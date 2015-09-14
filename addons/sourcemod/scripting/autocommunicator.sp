#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#include <colors>

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_INFECTED(%1)         (GetClientTeam(%1) == 3)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))
#define IS_VALID_INFECTED(%1)   (IS_VALID_INGAME(%1) && IS_INFECTED(%1))

new bool:isPulled[MAXPLAYERS + 1] = false;
new bool:isPulling[MAXPLAYERS + 1] = false;
new bool:isJocked[MAXPLAYERS + 1] = false;
new bool:isJocking[MAXPLAYERS + 1] = false;
new bool:isCharged[MAXPLAYERS + 1] = false;
new bool:isCharging[MAXPLAYERS + 1] = false;
new bool:isPounced[MAXPLAYERS + 1] = false;
new bool:isPouncing[MAXPLAYERS + 1] = false;
new bool:seesWeapon[MAXPLAYERS + 1] = false;
//new bool:isLowAmmo[MAXPLAYERS + 1] = false;
new bool:isReloading[MAXPLAYERS + 1] = false;
//new bool:isOutOfPosition[MAXPLAYERS + 1] = false;
//new bool:hasThrowableArmed[MAXPLAYERS + 1] = false;
//new bool:seesSurvivorArmingThrowable[MAXPLAYERS + 1] = false;
//new bool:isSpitterAvailable = false;
//new bool:isChargerAvailable = false;

new ItemType:ItemSpawn[MAXPLAYERS+1];
new ItemImportance[MAXPLAYERS + 1] = 0;

enum ItemType{
		Item_None=0,
		Item_Pills,
		Item_Ammo,
		Item_VomitJar,
		Item_SilencedUzi,
		Item_ChromeShotgun,
		Item_Smg,
		Item_PumpShotgun,
		Item_Melee
}

public Plugin:myinfo = 
{
    name = "Auto Communicator",
    author = "Jacob",
    description = "Allows players to communicate several game events with one command.",
    version = "0.1",
    url = "zzz"
}

public OnPluginStart()
{	
	// Survivor
	HookEvent("weapon_reload", Event_Reload);
	//HookEvent("ammo_pickup", Event_AmmoPickup);
	//HookEvent("item_pickup", Event_ItemPickup);
	HookEvent("weapon_spawn_visible", Event_WeaponVisible); // Used for weapon spawns.
	//HookEvent("total_ammo_below_40", Event_LowAmmo);

	// Infected
	/*
	HookEvent("infected_death", Event_InfectedDeath);
	HookEvent("player_shoved", Event_Shoved);
	HookEvent("zombie_ignited", Event_ZombieIgnited);
	HookEvent("ghost_spawn_time", Event_SpawnTime);
	HookEvent("triggered_car_alarm", Event_CarAlarm);
	HookEvent("spit_burst", Event_Spit);
	*/
	// Chargers
	HookEvent("charger_pummel_start", Event_SurvivorCharged);
	HookEvent("charger_pummel_end", Event_ChargeEnd);

	// Hunters
	HookEvent("pounce_stopped", Event_PounceEnd);
	HookEvent("lunge_pounce", Event_SurvivorPounced);
	
	// Jockeys
	HookEvent("jockey_ride_end", Event_RideEnd);
	HookEvent("jockey_ride", Event_SurvivorRode);

	// Smokers
	HookEvent("tongue_grab", Event_SurvivorPulled);
	HookEvent("tongue_release", Event_PullEnd); // FIRES TWICE
	
	/*
	// Incaps + Deaths
	HookEvent("player_incapacitated", Event_Incap);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("tank_killed", Event_TankKilled);
	HookEvent("player_ledge_grab", Event_LedgeGrab);
	HookEvent("player_falldamage", Event_FallDamage);

	// General
	HookEvent("round_end", Event_RoundEnd);
	*/
	
	// Commands
	RegConsoleCmd("sm_autocom", Command_AutoCommunicate);

}

public Action:Command_AutoCommunicate(client, args)
{
	PrioritizeMessage(client);
}

public PrioritizeMessage(client)
{
	if(GetClientTeam(client) == 2)
	{
		if(isPulled[client])
		{
			PrintToSurvivors("(Survivor) {blue}%N {default}:  I'm pulled!");
		}
		else if(isJocked[client])
		{
			PrintToSurvivors("(Survivor) {blue}%N {default}:  I'm jocked!");
		}
		else if(isCharged[client])
		{
			PrintToSurvivors("(Survivor) {blue}%N {default}:  I'm charged!");
		}
		else if(isPounced[client])
		{
			PrintToSurvivors("(Survivor) {blue}%N {default}:  I'm pounced!");
		}
		else if(seesWeapon[client])
		{
			TalkAboutPlayerItem(client);
		}
		/*else if(isLowAmmo[client])
		{
			PrintToSurvivors("(Survivor) {blue}%N {default}:  I need ammo.");
		}*/
		else if(isReloading[client])
		{
			PrintToSurvivors("(Survivor) {blue}%N {default}:  I'm reloading.", client);
		}
		else
		{
			CPrintToChat(client, "{green}[{lightgreen}ACB{green}] {default}Couldn't find anything to communicate. More will be added soon!");
		}
	}
	else if(GetClientTeam(client) == 3)
	{
		if(isPulling[client])
		{
			PrintToInfected("(Infected) {red}%N {default}:  Cover me! I've got a pull!", client);
		}
		else if(isJocking[client])
		{
			PrintToInfected("(Infected) {red}%N {default}:  Cover me! I jockeyed one!", client);
		}
		else if(isCharging[client])
		{
			/*if(isSpitterAvailable)
			{
				PrintToInfected("(Infected) {red}%N {default}:  Spit on this!", client);
			}*/
				PrintToInfected("(Infected) {red}%N {default}:  Cover me! I landed my charge!", client);
		}
		else if(isPouncing[client])
		{
			/*if(isSpitterAvailable)
			{
				PrintToInfected("(Infected) {red}%N {default}:  Spit on this!", client);
			}*/
				PrintToInfected("(Infected) {red}%N {default}:  Cover me! I pounced one!", client);
		}
		else
		{
			CPrintToChat(client, "{green}[{lightgreen}ACB{green}] {default}Couldn't find anything to communicate. More will be added soon!");
		}
	}
	else
	{
		CPrintToChat(client, "{green}[{lightgreen}ACB{green}] You can not use the auto communicator as a spectator.");
	}
}


// Spawn Detection
/*public L4D_OnEnterGhostState(client)
{
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 4)
    {
        isSpitterAvailable = true;
    }
	else if(GetEntProp(client, Prop_Send, "m_zombieClass") == 6)
	{
		isChargerAvailable = true;
	}
}*/

// Chargers
public Event_SurvivorCharged(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	new charger = GetClientOfUserId(GetEventInt(event, "userid"));
	isCharging[charger] = true;
	isCharged[victim] = true;
}

public Event_ChargeEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	new charger = GetClientOfUserId(GetEventInt(event, "userid"));
	isCharging[charger] = true;
	isCharged[victim] = false;
}


// Hunters
public Event_SurvivorPounced(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	new hunter = GetClientOfUserId(GetEventInt(event, "userid"));
	isPouncing[hunter] = true;
	isPounced[victim] = true;
}

public Event_PounceEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	isPounced[victim] = false;
	for (new infected = 1; infected <= MaxClients; infected++)
	{
		if(IS_VALID_INFECTED(infected))
		{
			isPouncing[infected] = false;
		}
	}
}

// Jockeys
public Event_SurvivorRode(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	new jockey = GetClientOfUserId(GetEventInt(event, "userid"));
	isJocking[jockey] = true;
	isJocked[victim] = true;
}

public Event_RideEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	new jockey = GetClientOfUserId(GetEventInt(event, "userid"));
	isJocking[jockey] = false;
	isJocked[victim] = false;
}

// Smokers
public Event_SurvivorPulled(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	new smoker = GetClientOfUserId(GetEventInt(event, "userid"));
	isPulling[smoker] = true;
	isPulled[victim] = true;
}

public Event_PullEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));
	new smoker = GetClientOfUserId(GetEventInt(event, "userid"));
	isPulling[smoker] = false;
	isPulled[victim] = false;
}

/*public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new player = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IS_VALID_INFECTED(player))
	{
		if(GetEntProp(player, Prop_Send, "m_zombieClass") == 4)
		{
			isSpitterAvailable = false;
		}
	}
}*/

// Ammo
//public Event_LowAmmo(Handle:event, const String:name[], bool:dontBroadcast)
//{
//	new player = GetClientOfUserId(GetEventInt(event, "userid"));
//	isLowAmmo[player] = true;
//}
//
//public Event_AmmoPickup(Handle:event, const String:name[], bool:dontBroadcast)
//{
//	new player = GetClientOfUserId(GetEventInt(event, "userid"));
//	isLowAmmo[player] = false;
//}

public Event_Reload(Handle:event, const String:name[], bool:dontBroadcast)
{
	new player = GetClientOfUserId(GetEventInt(event, "userid"));
	if(GetEventBool(event, "manual") == false)
	{
		isReloading[player] = true;
		CreateTimer(3.0, ReloadTimer, player);
	}
}

public Action:ReloadTimer(Handle:timer, any:player)
{
	isReloading[player] = false;
}

// Items
public Event_WeaponVisible(Handle:event, const String:name[], bool:dontBroadcast)
{
	new player	= GetClientOfUserId(GetEventInt(event, "userid"));
	seesWeapon[player] = true;
	
	decl String:weapon[32];
	GetEventString(event, "weaponname", weapon, sizeof(weapon));

	if (StrEqual(weapon, "pain_pills"))
	{
		ItemSpawn[player] = Item_Pills;
	}
	else if (StrEqual(weapon, "ammo") && ItemImportance[player] <= 7)
	{
		ItemSpawn[player] = Item_Ammo;
		ItemImportance[player] = 7;
	}
	else if (StrEqual(weapon, "vomitjar") && ItemImportance[player] <= 6)
	{
		ItemSpawn[player] = Item_VomitJar;
		ItemImportance[player] = 6;
	}
	else if (StrEqual(weapon, "smg_silenced") && ItemImportance[player] <= 5)
	{
		ItemSpawn[player] = Item_SilencedUzi;
		ItemImportance[player] = 5;
	}
	else if (StrEqual(weapon, "shotgun_chrome") && ItemImportance[player] <= 4)
	{
		ItemSpawn[player] = Item_ChromeShotgun;
		ItemImportance[player] = 4;
	}
	else if (StrEqual(weapon, "smg") && ItemImportance[player] <= 3)
	{
		ItemSpawn[player] = Item_Smg;
		ItemImportance[player] = 3;
	}
	else if (StrEqual(weapon, "pumpshotgun") && ItemImportance[player] <= 2)
	{
		ItemSpawn[player] = Item_PumpShotgun;
		ItemImportance[player] = 2;
	}
	else if (StrEqual(weapon, "melee"))
	{
		ItemSpawn[player] = Item_Melee;
		ItemImportance[player] = 1;
		//decl String:melee[32];
		//GetEventString(event, "subtype", melee, sizeof(melee));
		//PrintToChatAll("Melee: %s", melee);
	}
	
	CreateTimer(5.0, WeaponReset, player);
}

TalkAboutPlayerItem(player)
{
		switch(ItemSpawn[player])
		{
				case Item_Pills:
				{
						PrintItem(player, "Pills");
				}
				case Item_Ammo:
				{
						PrintItem(player, "Ammo");
				}
				case Item_VomitJar:
				{
						PrintItem(player, "Bile Bomb");
				}
				case Item_SilencedUzi:
				{
						PrintItem(player, "Silenced Uzi");
				}
				case Item_ChromeShotgun:
				{
						PrintItem(player, "Chrome Shotgun");
				}
				case Item_Smg:
				{
						PrintItem(player, "Uzi");
				}
				case Item_PumpShotgun:
				{
						PrintItem(player, "Pump Shotgun");
				}
				case Item_Melee:
				{
						PrintItem(player, "Melee Weapon");
				}
				case Item_None:
				{
						PrintToChat(player, "ERROR: Undefined Entity");
				}
        }
}
 
PrintItem(player, const String:itemName[])
{
        PrintToSurvivors("(Survivor) {blue}%N {default}:  %s over here.", player, itemName);
}

public Action:WeaponReset(Handle:timer, any:player)
{
	seesWeapon[player] = false;
	ItemImportance[player] = 0;
	ItemSpawn[player] = Item_None;
}

stock PrintToSurvivors(const String:Message[], any:... )
{
    decl String:sPrint[256];
    VFormat(sPrint, sizeof(sPrint), Message, 2);

    for (new i = 1; i <= MaxClients; i++) {
        if (!IS_VALID_SURVIVOR(i)) { continue; }

        CPrintToChat(i, "\x01%s", sPrint);
    }
}

stock PrintToInfected(const String:Message[], any:... )
{
    decl String:sPrint[256];
    VFormat(sPrint, sizeof(sPrint), Message, 2);

    for (new i = 1; i <= MaxClients; i++) {
        if (!IS_VALID_INFECTED(i)) { continue; }

        CPrintToChat(i, "\x01%s", sPrint);
    }
}