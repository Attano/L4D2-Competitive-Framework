#pragma semicolon 1

#define L4D2UTIL_STOCKS_ONLY

#include <sourcemod>
#include <sdktools>
#include <l4d2util>

#define STEAMID_SIZE  32

new Handle:hCvarAllowedRateChanges;
new Handle:hCvarMinRate;
new Handle:hCvarMinCmd;
new Handle:hCvarProhibitFakePing;
new Handle:hCvarProhibitedAction;
new Handle:hClientSettingsArray;

new iAllowedRateChanges;
new iMinRate;
new iMinCmd;
new iActionUponExceed;

new bool:bProhibitFakePing;
new bool:bIsMatchLive = false;

enum NetsettingsStruct {
    String:Client_SteamId[STEAMID_SIZE],
    Client_Rate,
    Client_Cmdrate,
    Client_Updaterate,
    Client_Changes
};

public Plugin:myinfo =
{
	name = "RateMonitor",
	author = "Visor",
	description = "Keep track of players' netsettings",
	version = "2.2",
	url = "https://github.com/Attano/smplugins"
};

public OnPluginStart()
{
	hCvarAllowedRateChanges = CreateConVar("rm_allowed_rate_changes", "-1", "Allowed number of rate changes during a live round(-1: no limit)", FCVAR_PLUGIN);
	hCvarMinRate = CreateConVar("rm_min_rate", "20000", "Minimum allowed value of rate(-1: none)", FCVAR_PLUGIN);
	hCvarMinCmd = CreateConVar("rm_min_cmd", "20", "Minimum allowed value of cl_cmdrate(-1: none)", FCVAR_PLUGIN);
	hCvarProhibitFakePing = CreateConVar("rm_no_fake_ping", "0", "Allow or disallow the use of + - . in netsettings, which is commonly used to hide true ping in the scoreboard.", FCVAR_PLUGIN);
	hCvarProhibitedAction = CreateConVar("rm_countermeasure", "2", "Countermeasure against illegal actions - change overlimit/forbidden netsettings(1:chat notify,2:move to spec,3:kick)", FCVAR_PLUGIN, true, 1.0, true, 3.0);
	
	iAllowedRateChanges = GetConVarInt(hCvarAllowedRateChanges);
	iMinRate = GetConVarInt(hCvarMinRate);
	iMinCmd = GetConVarInt(hCvarMinCmd);
	bProhibitFakePing = GetConVarBool(hCvarProhibitFakePing);
	iActionUponExceed = GetConVarInt(hCvarProhibitedAction);

	HookConVarChange(hCvarAllowedRateChanges, cvarChanged_AllowedRateChanges);
	HookConVarChange(hCvarMinRate, cvarChanged_MinRate);
	HookConVarChange(hCvarMinCmd, cvarChanged_MinCmd);
	HookConVarChange(hCvarProhibitFakePing, cvarChanged_ProhibitFakePing);
	HookConVarChange(hCvarProhibitedAction, cvarChanged_ExceedAction);
	
	RegConsoleCmd("sm_rates", ListRates, "List netsettings of all players in game", FCVAR_PLUGIN);
	
	HookEvent("player_team", OnTeamChange);
	
	hClientSettingsArray = CreateArray(_:NetsettingsStruct);
}

public OnRoundStart() 
{
	decl player[NetsettingsStruct];
	for (new i = 0; i < GetArraySize(hClientSettingsArray); i++) 
	{
		GetArrayArray(hClientSettingsArray, i, player[0]);
		player[Client_Changes] = _:0;
		SetArrayArray(hClientSettingsArray, i, player[0]);
	}
}

public Action:OnRoundIsLive() 
	bIsMatchLive = true;

public OnRoundEnd()
	bIsMatchLive = false;

public OnMapEnd()
	ClearArray(hClientSettingsArray);

public OnTeamChange(Handle:event, String:name[], bool:dontBroadcast)
{
    if (L4D2_Team:GetEventInt(event, "team") != L4D2Team_Spectator)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (client > 0)
		{
			if (IsClientInGame(client) && !IsFakeClient(client))
				CreateTimer(0.1, OnTeamChangeDelay, client, TIMER_FLAG_NO_MAPCHANGE);
		}
    }
}

public Action:OnTeamChangeDelay(Handle:timer, any:client)
{
	RegisterSettings(client);
	return Plugin_Handled;
}

public OnClientSettingsChanged(client) 
{
	RegisterSettings(client);
}

public Action:ListRates(client, args) 
{
	decl player[NetsettingsStruct];
	new iClient;
	
	ReplyToCommand(client, "\x01[RateMonitor] List of player netsettings(\x03cmd\x01/\x04upd\x01/\x05rate\x01):");
	
	for (new i = 0; i < GetArraySize(hClientSettingsArray); i++) 
	{
		GetArrayArray(hClientSettingsArray, i, player[0]);
		
		iClient = GetClientBySteamId(player[Client_SteamId]);
		if (iClient < 0) continue;
		
		if (IsClientConnected(iClient) && !IsSpectator(iClient)) 
		{
			ReplyToCommand(client, "\x03%N\x01 : %d/%d/%d", iClient, player[Client_Cmdrate], player[Client_Updaterate], player[Client_Rate]);
		}
	}
	
	return Plugin_Handled;
}

RegisterSettings(client) 
{	
    if (!IsClientInGame(client) || IsSpectator(client) || IsFakeClient(client)) 
        return;

    decl player[NetsettingsStruct];
    decl String:sCmdRate[32], String:sUpdateRate[32], String:sRate[32];
    decl String:sSteamId[STEAMID_SIZE];
    decl String:sCounter[32] = "";
    new iCmdRate, iUpdateRate, iRate;
    
    GetClientAuthString(client, sSteamId, STEAMID_SIZE);
    new iIndex = FindStringInArray(hClientSettingsArray, sSteamId);

    // rate
    iRate = GetClientDataRate(client);
    // cl_cmdrate
    GetClientInfo(client, "cl_cmdrate", sCmdRate, sizeof(sCmdRate));
    iCmdRate = StringToInt(sCmdRate);
    // cl_updaterate
    GetClientInfo(client, "cl_updaterate", sUpdateRate, sizeof(sUpdateRate));
    iUpdateRate = StringToInt(sUpdateRate);
   
    // Punish for fake ping or other unallowed symbols in rate settings
    if (bProhibitFakePing)
    {
        new bool:bIsCmdRateClean, bIsUpdateRateClean;
        
        bIsCmdRateClean = IsNatural(sCmdRate);
        bIsUpdateRateClean = IsNatural(sUpdateRate);

        if (!bIsCmdRateClean || !bIsUpdateRateClean) 
        {
            sCounter = " [\x03bad cmd/upd\x01]";
            Format(sCmdRate, sizeof(sCmdRate), "%s%s%s", !bIsCmdRateClean ? "\x03(\x04" : "\x04", sCmdRate, !bIsCmdRateClean ? "\x03)\x01" : "\x01");
            Format(sUpdateRate, sizeof(sUpdateRate), "%s%s%s", !bIsUpdateRateClean ? "\x03(\x04" : "\x04", sUpdateRate, !bIsUpdateRateClean ? "\x03)\x01" : "\x01");
            Format(sRate, sizeof(sRate), "\x05%d\x01", iRate);
            
            PunishPlayer(client, sCmdRate, sUpdateRate, sRate, sCounter, iIndex);
            return;
        }
    }
    
     // Punish for low rate settings(if we're good on previous check)
    if ((iCmdRate < iMinCmd && iMinCmd > -1) 
        || (iRate < iMinRate && iRate > -1)
    ) {
        sCounter = " [\x03low cmd/rate\x01]";
        Format(sCmdRate, sizeof(sCmdRate), "%s%d%s", iCmdRate < iMinCmd ? "\x05>\x04" : "\x04", iCmdRate, iCmdRate < iMinCmd ? "\x05<\x01" : "\x01");
        Format(sUpdateRate, sizeof(sUpdateRate), "\x04%d\x01", iUpdateRate);
        Format(sRate, sizeof(sRate), "%s%d%s", iRate < iMinRate ? "\x04>\x05" : "\x05", iRate, iRate < iMinRate ? "\x04<\x01" : "\x01");
        
        PunishPlayer(client, sCmdRate, sUpdateRate, sRate, sCounter, iIndex);
        return;
    }

    if (iIndex > -1) 
    {
        GetArrayArray(hClientSettingsArray, iIndex, player[0]);
        
        if (iRate == player[Client_Rate] && 
            iCmdRate == player[Client_Cmdrate] && 
            iUpdateRate == player[Client_Updaterate]
            )	return;	// No change

        if (bIsMatchLive && iAllowedRateChanges > -1)
        {
            player[Client_Changes] += 1;
            Format(sCounter, sizeof(sCounter), " [%s%d\x01/%d]", (player[Client_Changes] > iAllowedRateChanges ? "\x04" : "\x01"), player[Client_Changes], iAllowedRateChanges);
            
            // If not punished for bad rate settings yet, punish for overlimit rate change(if any)
            if (player[Client_Changes] > iAllowedRateChanges)
            {
                Format(sCmdRate, sizeof(sCmdRate), "%s%d\x01", iCmdRate != player[Client_Cmdrate] ? "\x05*\x04" : "\x04", iCmdRate);
                Format(sUpdateRate, sizeof(sUpdateRate), "%s%d\x01", iUpdateRate != player[Client_Updaterate] ? "\x05*\x04" : "\x04", iUpdateRate);
                Format(sRate, sizeof(sRate), "%s%d\x01", iRate != player[Client_Rate] ? "\x04*\x05" : "\x05", iRate);
            
                PunishPlayer(client, sCmdRate, sUpdateRate, sRate, sCounter, iIndex);
                return;
            }
        }
        
        PrintToChatAll("\x03%N's\x01 netsettings changed from \x04%d\x01/\x04%d\x01/\x05%d\x01 to \x04%d\x01/\x04%d\x01/\x05%d\x01%s", 
                        client, 
                        player[Client_Cmdrate], player[Client_Updaterate], player[Client_Rate], 
                        iCmdRate, iUpdateRate, iRate,
                        sCounter);
                        
        player[Client_Cmdrate] = _:iCmdRate;
        player[Client_Updaterate] = _:iUpdateRate;
        player[Client_Rate] = _:iRate;
        
        SetArrayArray(hClientSettingsArray, iIndex, player[0]);
    }
    else
    {
        strcopy(player[Client_SteamId], STEAMID_SIZE, sSteamId);
        player[Client_Cmdrate] = _:iCmdRate;
        player[Client_Updaterate] = _:iUpdateRate;
        player[Client_Rate] = _:iRate;
        player[Client_Changes] = _:0;
        
        PushArrayArray(hClientSettingsArray, player[0]);
        PrintToChatAll("\x03%N's\x01 netsettings set to \x04%d\x01/\x04%d\x01/\x05%d\x01", client, player[Client_Cmdrate], player[Client_Updaterate], player[Client_Rate]);
    }
}

PunishPlayer(client, const String:sCmdRate[], const String:sUpdateRate[], const String:sRate[], const String:sCounter[], iIndex)
{
    new bool:bInitialRegister = iIndex > -1 ? false : true;
    
    switch (iActionUponExceed)
    {
        case 1:	// Just notify all players(zero punishment)
        {
            if (bInitialRegister) {
                PrintToChatAll("\x03%N's\x01 netsettings set to illegal values: %s/%s/%s%s", 
                                client, 
                                sCmdRate, sUpdateRate, sRate, 
                                sCounter);
            }
            else {
                PrintToChatAll("\x03%N's\x01 illegaly changed netsettings midgame: %s/%s/%s%s", 
                                client, 
                                sCmdRate, sUpdateRate, sRate, 
                                sCounter);
            }
        }
        case 2:	// Move to spec
        {
            ChangeClientTeam(client, _:L4D2Team_Spectator);
            
            if (bInitialRegister) {
                PrintToChatAll("\x03%N's\x01 was moved to spectators for illegal netsettings: %s/%s/%s%s", 
                            client, 
                            sCmdRate, sUpdateRate, sRate, 
                            sCounter);
                PrintToChat(client, "\x01Please adjust your rates to values higher than \x04%d\x01/\x05%d\x01%s", iMinCmd, iMinRate, bProhibitFakePing ? " and remove any \x03non-digital characters" : "");
            }
            else {
                decl player[NetsettingsStruct];
                GetArrayArray(hClientSettingsArray, iIndex, player[0]);
                
                PrintToChatAll("\x03%N's\x01 was moved to spectators for illegal netsettings change: %s/%s/%s%s", 
                            client, 
                            sCmdRate, sUpdateRate, sRate, 
                            sCounter);
                PrintToChat(client, "\x01Change your netsettings back to: \x04%d\x01/\x04%d\x01/\x05%d", player[Client_Cmdrate], player[Client_Updaterate], player[Client_Rate]);
            }
        }
        case 3:	// Kick
        {
            if (bInitialRegister) {
                KickClient(client, "Please use rates higher than %d/%d%s", iMinCmd, iMinRate, bProhibitFakePing ? " and remove any non-digits" : "");
                PrintToChatAll("\x03%N's\x01 was kicked due to illegal netsettings: %s/%s/%s%s", 
                            client, 
                            sCmdRate, sUpdateRate, sRate, 
                            sCounter);
            }
            else {
                decl player[NetsettingsStruct];
                GetArrayArray(hClientSettingsArray, iIndex, player[0]);
                
                KickClient(client, "Change your rates to previous values and remove non-digits: %d/%d/%d", player[Client_Cmdrate], player[Client_Updaterate], player[Client_Rate]);
                PrintToChatAll("\x03%N's\x01 was kicked due to illegal netsettings change: %s/%s/%s%s", 
                            client, 
                            sCmdRate, sUpdateRate, sRate, 
                            sCounter);
            }
        }
    }
    return;
}

stock GetClientBySteamId(const String:steamID[]) 
{
	decl String:tempSteamID[STEAMID_SIZE];
	
	for (new client = 1; client <= MaxClients; client++) 
	{
		if (!IsClientInGame(client)) continue;
		
		GetClientAuthString(client, tempSteamID, STEAMID_SIZE);
		if (StrEqual(steamID, tempSteamID))
			return client;
	}
	
	return -1;
}

bool:IsSpectator(client) {
	new L4D2_Team:team = L4D2_Team:GetClientTeam(client);
	if (team != L4D2Team_Survivor && team != L4D2Team_Infected)
		return true;
	return false;
}

stock bool:IsNatural(const String:str[])
{	
    new x = 0;
    while (str[x] != '\0') 
    {
        if (!IsCharNumeric(str[x])) {
            return false;
        }
        x++;
    }

    return true;
}

public cvarChanged_AllowedRateChanges(Handle:cvar, const String:oldValue[], const String:newValue[])
    iAllowedRateChanges = GetConVarInt(hCvarAllowedRateChanges);

public cvarChanged_MinRate(Handle:cvar, const String:oldValue[], const String:newValue[])
    iMinRate = GetConVarInt(hCvarMinRate);
	
public cvarChanged_MinCmd(Handle:cvar, const String:oldValue[], const String:newValue[])
    iMinCmd = GetConVarInt(hCvarMinCmd);

public cvarChanged_ProhibitFakePing(Handle:cvar, const String:oldValue[], const String:newValue[])
    bProhibitFakePing = GetConVarBool(hCvarProhibitFakePing);
	
public cvarChanged_ExceedAction(Handle:cvar, const String:oldValue[], const String:newValue[])
    iActionUponExceed = GetConVarInt(hCvarProhibitedAction);
