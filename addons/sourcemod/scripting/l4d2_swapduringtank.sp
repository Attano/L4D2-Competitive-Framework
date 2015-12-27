#include <sourcemod>
#include <sdktools>
#pragma semicolon 1

/**
 *
 *
	From Visor:
	
	Be advised: this is the promod version which has critical issues, such as:
	
	- breaking natural spawn rules and order; teams will get different spawns
	- exploit: two boomers at the same time during tank (confirmed)
	- exploit: two spitters at the same time during tank (I'm not a promod player so idk
	how accurate this part is; proceed with the "presumption of innocence" at your own risk)
 *
 *
**/

public Plugin:myinfo =
{
	name = "No Spitter During Tank",
	author = "Don, epilimic, XBetaAlpha, darkid",
	// Credit to XBetaAlpha for his Zombie Character Select, used to swap between spitter and boomer.
	// Source: https://forums.alliedmods.net/showthread.php?p=1118704
	description = "Prevents the director from giving the infected team a spitter while the tank is alive",
	version = "1.8", //removed world death check, only use this version if you run tank_control and there are no natural tank passes. If you need/want tank passing then you need version 1.6 of this plugin.
	url = "https://bitbucket.org/DonSanchez/random-sourcemod-stuff"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	decl String:sGame[12];
	GetGameFolderName(sGame, sizeof(sGame));
	if (StrEqual(sGame, "left4dead2"))	// Only load the plugin if the server is running Left 4 Dead 2.
	{
		return APLRes_Success;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports L4D2");
		return APLRes_Failure;
	}
}

new bool:g_bIsTankAlive;
new Handle:g_hSpitterLimit;
new Handle:g_hBoomerLimit;
new Handle:g_hSetClass;
new Handle:g_hCreateAbility;
new g_oAbility;
new bool:in_attack2[MAXPLAYERS];

public OnPluginStart()
{
	HookEvent("tank_spawn", Event_tank_spawn_Callback);
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_disconnect", PlayerDisconnect, EventHookMode_Pre);
	HookEvent("round_end", RoundEnd);

	g_hSpitterLimit = FindConVar("z_versus_spitter_limit");
	g_hBoomerLimit = FindConVar("z_versus_boomer_limit");

	HookEvent("ghost_spawn_time", PlayerGhostTimer);
	Sub_HookGameData();
}

bool:teamHasBoomerOrSpitter(client) {
	for (new i=1; i<MaxClients; i++) {
		if (client == i) continue;
		if (!IsClientInGame(i)) continue;
		if (GetClientTeam(i) != 3) continue;
		new class = GetEntProp(i, Prop_Send, "m_zombieClass");
		if (class == 2 || class == 4) {
			return true;
		}
	}
	return false;
}

public Event_tank_spawn_Callback(Handle:event, const String:name[], bool:dontBroadcast)
{
	SetConVarInt(g_hSpitterLimit, 0);
	g_bIsTankAlive = true;
}

// Tank dies
public PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client <= 0 || client > MaxClients) return;
	new class = GetEntProp(client, Prop_Send, "m_zombieClass");
	// I set the boomer limit to 0 once someone gets one. In other words, we pretend their spitter is a boomer and don't allow anyone else to get one. Once their SI dies (spitter or boomer), we allow another player to get one.
	if (g_bIsTankAlive && (class == 4 || class == 2)) {
		SetConVarInt(g_hBoomerLimit, 1);
	} else if (class == 8) {
		g_bIsTankAlive = false;
		SetConVarInt(g_hSpitterLimit, 1);
		SetConVarInt(g_hBoomerLimit, 1);
	}
}

// Boomer/spitter disconnects
public PlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast) {
	if (!g_bIsTankAlive) return;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client <= 0 || client > MaxClients) return;
	if (GetClientTeam(client) != 3) return;
	new class = GetEntProp(client, Prop_Send, "m_zombieClass");
	if (class == 2 || class == 4) {
		SetConVarInt(g_hBoomerLimit, 1);
	}
	CreateTimer(1.0, TankDisconnect);
}

// The problem here is that when a player takes control of the tank, the game "kicks" the ai. This looks identical to an AI being actually sm_kicked. So we simply check if there *is* a tank in play, and if not, we reset the limits.
public Action:TankDisconnect(Handle:timer) {
	g_bIsTankAlive = false;
	for (new i=1; i<MaxClients; i++) {
		if (!IsClientInGame(i)) continue;
		if (GetClientTeam(i) != 3) continue;
		if (GetEntProp(i, Prop_Send, "m_zombieClass") != 8) continue;
		g_bIsTankAlive = true;
	}
	if (!g_bIsTankAlive) {
		SetConVarInt(g_hSpitterLimit, 1);
		SetConVarInt(g_hBoomerLimit, 1);
	}
}

// Round ends without tank death
public RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bIsTankAlive = false;
	SetConVarInt(g_hSpitterLimit, 1);
	SetConVarInt(g_hBoomerLimit, 1);
}

// Map changed via changelevel, sm_map
public OnMapChange() {
	g_bIsTankAlive = false;
	SetConVarInt(g_hSpitterLimit, 1);
	SetConVarInt(g_hBoomerLimit, 1);
}

// Plugin unloaded
public OnPluginEnd()
{
	SetConVarInt(g_hSpitterLimit, 1);
	SetConVarInt(g_hBoomerLimit, 1);
}

// When a player pushes a button, if:
// Tank is alive
// They're infected, as ghost, spitter or boomer
// They press mouse2
// Then change them to the other class.
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!g_bIsTankAlive) return;
	if (client <= 0 || client > MaxClients) return;
	if (!IsClientInGame(client)) return;
	if (IsFakeClient(client)) return;
	if (GetClientTeam(client) != 3) return;
	if (!GetEntProp(client, Prop_Send, "m_isGhost")) return;
	if (teamHasBoomerOrSpitter(client)) return;
	// Player was holding m2, and now isn't. (Released)
	if (buttons & IN_ATTACK2 != IN_ATTACK2 && in_attack2[client]) {
		in_attack2[client] = false;
	}
	// Player was not holding m2, and now is. (Pressed)
	if (buttons & IN_ATTACK2 == IN_ATTACK2 && !in_attack2[client]) {
		in_attack2[client] = true;
		new class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (class == 4) { // Is spitter
			Sub_DetermineClass(client, 2);
			PrintHintText(client, "Press <Mouse2> to change back to spitter.");
		} else if (class == 2) { // Is boomer
			Sub_DetermineClass(client, 4);
			PrintHintText(client, "Press <Mouse2> to change back to boomer.");
		}
	}
}

// Called when an SI respawns, so they know how long until they become a ghost.
public PlayerGhostTimer(Handle:event, const String:name[], bool:dontBroadcast)  {
	if (!g_bIsTankAlive) return;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client <= 0 || client > MaxClients) return;
	if (!IsClientInGame(client)) return;
	if (IsFakeClient(client)) return;
	if (GetClientTeam(client) != 3) return;
	// We don't know what their class is until they spawn. We wait an extra .1 sec for safety. Players can still change classes at that time, only the hint text is delayed.
	new Float:spawntime = 0.1+1.0*GetEventInt(event, "spawntime");
	CreateTimer(spawntime, PlayerBecameGhost, client);
}
public Action:PlayerBecameGhost(Handle:timer, any:client) {
	if (GetEntProp(client, Prop_Send, "m_zombieClass") != 2) return;
	if (teamHasBoomerOrSpitter(client)) return;
	SetConVarInt(g_hBoomerLimit, 0);
	PrintHintText(client, "Press <Mouse2> to change to spitter.");
}

// Loads gamedata, preps SDK calls.
public Sub_HookGameData()
{
	new Handle:g_hGameConf = LoadGameConfigFile("l4d2_zcs");

	if (g_hGameConf != INVALID_HANDLE)
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "SetClass");
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hSetClass = EndPrepSDKCall();

		if (g_hSetClass == INVALID_HANDLE)
			SetFailState("Unable to find SetClass signature.");

		StartPrepSDKCall(SDKCall_Static);
		PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CreateAbility");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
		g_hCreateAbility = EndPrepSDKCall();

		if (g_hCreateAbility == INVALID_HANDLE)
			SetFailState("Unable to find CreateAbility signature.");

		g_oAbility = GameConfGetOffset(g_hGameConf, "oAbility");

		CloseHandle(g_hGameConf);
	}

	else
		SetFailState("Unable to load l4d2_zcs.txt");
}

// Sets the class of a client.
public Sub_DetermineClass(any:Client, any:ZClass)
{
	new WeaponIndex;
	while ((WeaponIndex = GetPlayerWeaponSlot(Client, 0)) != -1)
	{
		RemovePlayerItem(Client, WeaponIndex);
		RemoveEdict(WeaponIndex);
	}

	SDKCall(g_hSetClass, Client, ZClass);
	AcceptEntityInput(MakeCompatEntRef(GetEntProp(Client, Prop_Send, "m_customAbility")), "Kill");
	SetEntProp(Client, Prop_Send, "m_customAbility", GetEntData(SDKCall(g_hCreateAbility, Client), g_oAbility));
}
