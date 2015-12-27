/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <sourcemod>
#include <builtinvotes>
#include <socket>
#include <l4d2_direct>
#define REQUIRE_PLUGIN
#include <bosspercent>
#include <readyup>

#define DEBUG   0

/** 
	[!] Tested on Linux only
	Might not work on Windows. Check the offset for CDirector::m_iMapNumber
**/

#define DB_HOST "31.186.250.11"
#define DB_PATH "bosspercentdb.php"

#define CDIRECTOR__MAPNUMBER 864

new Handle:hVote;

new Float:fTankSpawns[5];
new Float:fWitchSpawns[5];

new bool:bStaticSpawnsActive;

public Plugin:myinfo =
{
	name = "L4D2 Boss Percents Standardizer",
	author = "Visor",
	version = "1.0.1",
	description = "Sets predefined boss spawn coordinates from a shared database. Intended for use in cups.",
	url = "https://github.com/Attano/Equilibrium"
};

public OnPluginStart()
{
	HookEvent("round_start", EventHook:OnRoundStart, EventHookMode_PostNoCopy);
	RegConsoleCmd("sm_cup", Vote);
}

public Action:Vote(client, args) 
{
	if (bStaticSpawnsActive)
	{
		PrintToChat(client, "\x01[\x04BossEQ\x01] Static spawns already applied! If it's a new game, reload the config by typing \x03!rmatch\x01");
		return Plugin_Handled;
	}

	if (IsSpectator(client) || L4D2_GetMapNumber() > 0 || !IsInReady() || InSecondHalfOfRound())
	{
		PrintToChat(client, "\x01[\x04BossEQ\x01] Vote can only be started by a player during ready-up @ first round, first map!");
		return Plugin_Handled;
	}

	if (StartVote(client, "Apply static boss spawns for this match?"))
		FakeClientCommand(client, "Vote Yes");

	return Plugin_Handled; 
}

bool:StartVote(client, const String:sVoteHeader[])
{
	if (IsNewBuiltinVoteAllowed())
	{
		new iNumPlayers;
		decl players[MaxClients];
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientConnected(i) || !IsClientInGame(i)) continue;
			if (IsSpectator(i) || IsFakeClient(i)) continue;
			
			players[iNumPlayers++] = i;
		}
		
		hVote = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
		SetBuiltinVoteArgument(hVote, sVoteHeader);
		SetBuiltinVoteInitiator(hVote, client);
		SetBuiltinVoteResultCallback(hVote, VoteResultHandler);
		DisplayBuiltinVote(hVote, players, iNumPlayers, 20);
		return true;
	}

	PrintToChat(client, "\x01[\x04BossEQ\x01] Vote cannot be started now.");
	return false;
}

public VoteActionHandler(Handle:vote, BuiltinVoteAction:action, param1, param2)
{
	switch (action)
	{
		case BuiltinVoteAction_End:
		{
			hVote = INVALID_HANDLE;
			CloseHandle(vote);
		}
		case BuiltinVoteAction_Cancel:
		{
			DisplayBuiltinVoteFail(vote, BuiltinVoteFailReason:param1);
		}
	}
}

public VoteResultHandler(Handle:vote, num_votes, num_clients, const client_info[][2], num_items, const item_info[][2])
{
	for (new i = 0; i < num_items; i++)
	{
		if (item_info[i][BUILTINVOTEINFO_ITEM_INDEX] == BUILTINVOTES_VOTE_YES)
		{
			if (item_info[i][BUILTINVOTEINFO_ITEM_VOTES] > (num_clients / 2))
			{
				DisplayBuiltinVotePass(vote, "Applying custom boss spawns...");
				PrintToChatAll("\x01[\x04BossEQ\x01] Vote passed! Applying custom boss spawns...");
				DownloadAndSaveStaticSpawns();
				return;
			}
		}
	}
	DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Loses);
}

public OnRoundStart()
{
	CreateTimer(5.5, RewriteBossFlows);
}

public Action:RewriteBossFlows(Handle:timer)
{
	if (bStaticSpawnsActive && !InSecondHalfOfRound())
	{
		SetTankSpawn(fTankSpawns[L4D2_GetMapNumber()]);
		SetWitchSpawn(fWitchSpawns[L4D2_GetMapNumber()]);
		UpdateBossPercents();
	}
}

DownloadAndSaveStaticSpawns()
{
	decl String:sCurrentMap[64];
	new Handle:hMap = CreateDataPack();
	GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));
	WritePackString(hMap, sCurrentMap);

	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketSetArg(socket, hMap);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, DB_HOST, 80);
}

public OnSocketConnected(Handle:socket, any:map) 
{
#if DEBUG
	PrintToChatAll("\x01Socket successfully connected, continuing...");
#endif
	decl String:sCurrentMap[64];
	ResetPack(map);
	ReadPackString(map, sCurrentMap, sizeof(sCurrentMap));

	decl String:sRequestStr[256];
	Format(sRequestStr, sizeof(sRequestStr), "GET /%s?%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", DB_PATH, sCurrentMap, DB_HOST);
	SocketSend(socket, sRequestStr);
}

public OnSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:map) 
{
#if DEBUG
	PrintToChatAll("\x01Received data: \x04%s\x01 (size \x05%d\x01)", receiveData, dataSize);
#endif
	// Strip headers, get to the data
	decl String:buffer[2][128];
	ExplodeString(receiveData, "\r\n\r\n", buffer, 2, 128);

	if (buffer[1][0] == EOS)
	{
		PrintToChatAll("\x01[\x04BossEQ\x01] No predefined spawns could be found for this campaign.");
		return;
	}

	// Split tank & witch spawn coordinates for this campaign into two separate strings
	decl String:sBossSpawns[2][64];
	ExplodeString(buffer[1], "||", sBossSpawns, 2, 64);

	// Now each of them per map
	decl String:sMapsBuffer[5][8];

	// Tank
	ExplodeString(sBossSpawns[0], "|", sMapsBuffer, 5, 8);
	for (new i = 0; i < 5; i++) fTankSpawns[i] = StringToFloat(sMapsBuffer[i]) / 100.0;

	// Witch
	ExplodeString(sBossSpawns[1], "|", sMapsBuffer, 5, 8);
	for (new i = 0; i < 5; i++) fWitchSpawns[i] = StringToFloat(sMapsBuffer[i]) / 100.0;
#if DEBUG
	for (new i = 0; i < 5; i++) PrintToChatAll("\x01Map \x05%i\x01 -- Tank: \x05%f\x01, Witch: \x05%f\x01", (i + 1), fTankSpawns[i], fWitchSpawns[i]);
#endif

	bStaticSpawnsActive = true;
	OnRoundStart(); // apply new spawns for the current map without restarting it
}

public OnSocketDisconnected(Handle:socket, any:map) 
{
	CloseHandle(socket);
}

public OnSocketError(Handle:socket, const errorType, const errorNum, any:map) 
{
#if DEBUG
	PrintToChatAll("\x01Socket error \x05%d\x01 (errno \x05%d\x01)", errorType, errorNum);
#endif
	LogError("socket error %d (errno %d)", errorType, errorNum);
	CloseHandle(socket);
}

SetTankSpawn(Float:flow)
{
	for (new i = 0; i <= 1; i++)
	{
		if (flow != 0)
		{
			L4D2Direct_SetVSTankToSpawnThisRound(i, true);
			L4D2Direct_SetVSTankFlowPercent(i, flow);
		}
		else
		{
			L4D2Direct_SetVSTankToSpawnThisRound(i, false);
		}
	}
}

SetWitchSpawn(Float:flow)
{
	for (new i = 0; i <= 1; i++)
	{
		if (flow != 0)
		{
			L4D2Direct_SetVSWitchToSpawnThisRound(i, true);
			L4D2Direct_SetVSWitchFlowPercent(i, flow);
		}
		else
		{
			L4D2Direct_SetVSWitchToSpawnThisRound(i, false);
		}
	}
}

L4D2_GetMapNumber()
{
	return LoadFromAddress(L4D2Direct_GetCDirector() + Address:CDIRECTOR__MAPNUMBER, NumberType_Int8);
}

stock bool:IsSpectator(client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 1;
}

stock InSecondHalfOfRound()
{
	return GameRules_GetProp("m_bInSecondHalfOfRound");
}