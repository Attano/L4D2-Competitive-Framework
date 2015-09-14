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
#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <left4downtown>
#include <l4d2_direct>
#include <l4d2lib>

#define EQSM_DEBUG    0

/** 
	Bibliography:
	'l4d2_scoremod' by CanadaRox, ProdigySim
	'damage_bonus' by CanadaRox, Stabby
	'l4d2_scoringwip' by ProdigySim
	'srs.scoringsystem' by AtomicStryker
**/

new Handle:hCvarBonusPerSurvivorMultiplier;
new Handle:hCvarPermanentHealthProportion;
new Handle:hCvarSurvivalBonus;
new Handle:hCvarTieBreaker;

new Float:fMapBonus;
new Float:fMapHealthBonus;
new Float:fMapDamageBonus;
new Float:fMapTempHealthBonus;
new Float:fPermHpWorth;
new Float:fTempHpWorth;
new Float:fSurvivorBonus[2];

new iMapDistance;
new iTeamSize;
new iLostTempHealth[2];
new iTempHealth[MAXPLAYERS + 1];

new String:sSurvivorState[2][32];

new bool:bLateLoad;
new bool:bRoundOver;

public Plugin:myinfo =
{
	name = "L4D2 Equilibrium Scoring System",
	author = "Visor",
	description = "Custom scoring system, designed for Equilibrium 2.0",
	version = "1.5.1",
	url = "https://github.com/Attano/Equilibrium"
};

public APLRes:AskPluginLoad2(Handle:plugin, bool:late, String:error[], errMax) 
{
	bLateLoad = late;
	return APLRes_Success;
}

public OnPluginStart()
{
	hCvarBonusPerSurvivorMultiplier = CreateConVar("eqsm_bonus_per_survivor_multiplier", "0.5", "Total Survivor Bonus = this * Number of Survivors * Map Distance", FCVAR_PLUGIN, true, 0.25);
	hCvarPermanentHealthProportion = CreateConVar("eqsm_permament_health_proportion", "0.75", "Permanent Health Bonus = this * Map Bonus; rest goes for Temporary Health Bonus", FCVAR_PLUGIN);
	hCvarSurvivalBonus = FindConVar("vs_survival_bonus");
	hCvarTieBreaker = FindConVar("vs_tiebreak_bonus");

	HookConVarChange(hCvarBonusPerSurvivorMultiplier, CvarChanged);
	HookConVarChange(hCvarPermanentHealthProportion, CvarChanged);

	HookEvent("round_start", EventHook:OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_ledge_grab", OnPlayerLedgeGrab);

	RegConsoleCmd("sm_health", CmdBonus);
	RegConsoleCmd("sm_damage", CmdBonus);
	RegConsoleCmd("sm_bonus", CmdBonus);
	RegConsoleCmd("sm_mapinfo", CmdMapInfo);

	if (bLateLoad) 
	{
		for (new i = 1; i <= MaxClients; i++) 
		{
			if (!IsClientInGame(i))
				continue;

			OnClientPutInServer(i);
		}
	}
}

public OnPluginEnd()
{
	ResetConVar(hCvarSurvivalBonus);
	ResetConVar(hCvarTieBreaker);
}

public OnConfigsExecuted()
{
	iTeamSize = GetConVarInt(FindConVar("survivor_limit"));
	SetConVarInt(hCvarTieBreaker, 0);

	iMapDistance = L4D2_GetMapValueInt("max_distance", L4D_GetVersusMaxCompletionScore());
	L4D_SetVersusMaxCompletionScore(iMapDistance);

	new Float:fPermHealthProportion = GetConVarFloat(hCvarPermanentHealthProportion);
	new Float:fTempHealthProportion = 1.0 - fPermHealthProportion;
	fMapBonus = iMapDistance * (GetConVarFloat(hCvarBonusPerSurvivorMultiplier) * iTeamSize);
	fMapHealthBonus = fMapBonus * fPermHealthProportion;
	fMapDamageBonus = fMapBonus * fTempHealthProportion;
	fMapTempHealthBonus = iTeamSize * 100/* HP */ / fPermHealthProportion * fTempHealthProportion;
	fPermHpWorth = fMapBonus / iTeamSize / 100 * fPermHealthProportion;
	fTempHpWorth = fMapBonus * fTempHealthProportion / fMapTempHealthBonus; // this should be almost equal to the perm hp worth, but for accuracy we'll keep it separately
#if EQSM_DEBUG
	PrintToChatAll("\x01Map health bonus: \x05%.1f\x01, temp health bonus: \x05%.1f\x01, perm hp worth: \x03%.1f\x01, temp hp worth: \x03%.1f\x01", fMapBonus, fMapTempHealthBonus, fPermHpWorth, fTempHpWorth);
#endif
}

public OnMapStart()
{
	OnConfigsExecuted();

	iLostTempHealth[0] = 0;
	iLostTempHealth[1] = 0;
}

public CvarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	OnConfigsExecuted();
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

public OnRoundStart()
{
	for (new i = 0; i < MAXPLAYERS; i++)
	{
		iTempHealth[i] = 0;
	}
	bRoundOver = false;
}

public Action:CmdBonus(client, args)
{
	if (bRoundOver || !client)
		return Plugin_Handled;

	decl String:sCmdType[64];
	GetCmdArg(1, sCmdType, sizeof(sCmdType));

	new Float:fHealthBonus = GetSurvivorHealthBonus();
	new Float:fDamageBonus = GetSurvivorDamageBonus();
	if (StrEqual(sCmdType, "full"))
	{
		if (InSecondHalfOfRound())
		{
			PrintToChat(client, "\x01[\x04EQSM\x01 :: R\x03#1\x01] Bonus: \x05%d\x01/\x05%d\x01 <\x03%.1f%%\x01> [%s]", RoundToFloor(fSurvivorBonus[0]), RoundToFloor(fMapBonus), CalculateBonusPercent(fSurvivorBonus[0]), sSurvivorState[0]);
		}
		PrintToChat(client, "\x01[\x04EQSM\x01 :: R\x03#%i\x01] Bonus: \x05%d\x01 <\x03%.1f%%\x01> [HB: \x05%d\x01 <\x03%.1f%%\x01> | DB: \x05%d\x01 <\x03%.1f%%\x01>]", InSecondHalfOfRound() + 1, RoundToFloor(fHealthBonus + fDamageBonus), CalculateBonusPercent(fHealthBonus + fDamageBonus, fMapHealthBonus + fMapDamageBonus), RoundToFloor(fHealthBonus), CalculateBonusPercent(fHealthBonus, fMapHealthBonus), RoundToFloor(fDamageBonus), CalculateBonusPercent(fDamageBonus, fMapDamageBonus));
		// [EQSM :: R#1] Bonus: 556 <69.5%> [HB: 439 <73.1%> | DB: 117 <58.5%>]
	}
	else if (StrEqual(sCmdType, "lite"))
	{
		PrintToChat(client, "\x01[\x04EQSM\x01 :: R\x03#%i\x01] Bonus: \x05%d\x01 <\x03%.1f%%\x01>", InSecondHalfOfRound() + 1, RoundToFloor(fHealthBonus + fDamageBonus), CalculateBonusPercent(fHealthBonus + fDamageBonus, fMapHealthBonus + fMapDamageBonus));
		// [EQSM :: R#1] Bonus: 556 <69.5%>
	}
	else
	{
		if (InSecondHalfOfRound())
		{
			PrintToChat(client, "\x01[\x04EQSM\x01 :: R\x03#1\x01] Bonus: \x05%d\x01 <\x03%.1f%%\x01>", RoundToFloor(fSurvivorBonus[0]), CalculateBonusPercent(fSurvivorBonus[0]));
		}
		PrintToChat(client, "\x01[\x04EQSM\x01 :: R\x03#%i\x01] Bonus: \x05%d\x01 <\x03%.1f%%\x01> [HB: \x03%.0f%%\x01 | DB: \x03%.0f%%\x01]", InSecondHalfOfRound() + 1, RoundToFloor(fHealthBonus + fDamageBonus), CalculateBonusPercent(fHealthBonus + fDamageBonus, fMapHealthBonus + fMapDamageBonus), CalculateBonusPercent(fHealthBonus, fMapHealthBonus), CalculateBonusPercent(fDamageBonus, fMapDamageBonus));
		// [EQSM :: R#1] Bonus: 556 <69.5%> [HB: 73% | DB: 58%]
	}
	return Plugin_Handled;
}

public Action:CmdMapInfo(client, args)
{
	PrintToChat(client, "\x01[\x04EQSM\x01 :: \x03%iv%i\x01] Map Info", iTeamSize, iTeamSize);
	PrintToChat(client, "\x01Distance: \x05%d\x01", iMapDistance);
	PrintToChat(client, "\x01Bonus: \x05%d\x01 <\x03100.0%%\x01>", RoundToFloor(fMapBonus));
	PrintToChat(client, "\x01Health Bonus: \x05%d\x01 <\x03%.1f%%\x01>", RoundToFloor(fMapHealthBonus), CalculateBonusPercent(fMapHealthBonus));
	PrintToChat(client, "\x01Damage Bonus: \x05%d\x01 <\x03%.1f%%\x01>", RoundToFloor(fMapDamageBonus), CalculateBonusPercent(fMapDamageBonus));
	// [EQSM :: 4v4] Map Info
	// Distance: 400
	// Bonus: 800 <100.0%>
	// Health Bonus: 600 <75.0%>
	// Damage Bonus: 200 <25.0%>
	return Plugin_Handled;
}

// OnTakeDamage() only provides correct argument values when they're reference pointers
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (!IsSurvivor(victim) || !IsAnyInfected(attacker) || IsPlayerIncap(victim))
		return Plugin_Continue;

#if EQSM_DEBUG
	if (GetSurvivorTemporaryHealth(victim) > 0) PrintToChatAll("\x04%N\x01 has \x05%d\x01 temp HP now(damage: \x03%.1f\x01)", victim, GetSurvivorTemporaryHealth(victim), damage);
#endif
	iTempHealth[victim] = GetSurvivorTemporaryHealth(victim);

	return Plugin_Continue;
}

public OnPlayerLedgeGrab(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	iLostTempHealth[InSecondHalfOfRound()] += L4D2Direct_GetPreIncapHealthBuffer(client);
}

public Action:L4D2_OnRevived(client)
{
	iLostTempHealth[InSecondHalfOfRound()] -= GetSurvivorTemporaryHealth(client);
}

// OnTakeDamagePost() does the opposite: it messes up pointer arguments but works fine with the normal ones
// SDKHooks probably treats OTD() args as "by-ref" and OTDP() as normal ones
// Pawn gets confused and we end up with wrong values
public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype)
{
	if (!IsSurvivor(victim) || !IsAnyInfected(attacker))
		return;
		
#if EQSM_DEBUG
	PrintToChatAll("\x03%N\x01\x05 lost %i\x01 temp HP after being attacked(arg damage: \x03%.1f\x01)", victim, iTempHealth[victim] - (IsPlayerAlive(victim) ? GetSurvivorTemporaryHealth(victim) : 0), damage);
#endif
	if (!IsPlayerAlive(victim) || (IsPlayerIncap(victim) && !IsPlayerLedged(victim)))
	{
		iLostTempHealth[InSecondHalfOfRound()] += iTempHealth[victim];
	}
	else if (!IsPlayerLedged(victim))
	{
		iLostTempHealth[InSecondHalfOfRound()] += iTempHealth[victim] ? (iTempHealth[victim] - GetSurvivorTemporaryHealth(victim)) : 0;
	}
	iTempHealth[victim] = IsPlayerIncap(victim) ? 0 : GetSurvivorTemporaryHealth(victim);
}

public Action:L4D2_OnEndVersusModeRound(bool:countSurvivors)
{
#if EQSM_DEBUG
	PrintToChatAll("CDirector::OnEndVersusModeRound() called. InSecondHalfOfRound(): %d, countSurvivors: %d", InSecondHalfOfRound(), countSurvivors);
#endif
	if (bRoundOver)
		return Plugin_Continue;

	new team = InSecondHalfOfRound();
	new iSurvivalMultiplier = GetUprightSurvivors();    // I don't know how reliable countSurvivors is and I'm too lazy to test
	fSurvivorBonus[team] = GetSurvivorHealthBonus() + GetSurvivorDamageBonus();
	if (iSurvivalMultiplier > 0 && RoundToFloor(fSurvivorBonus[team] / iSurvivalMultiplier) >= 1.0)
	{
		SetConVarInt(hCvarSurvivalBonus, RoundToFloor(fSurvivorBonus[team] / iSurvivalMultiplier));
		fSurvivorBonus[team] = float(GetConVarInt(hCvarSurvivalBonus) * iSurvivalMultiplier);    // workaround for the discrepancy caused by RoundToFloor()
		Format(sSurvivorState[team], 32, "%s%i\x01/\x05%i\x01", (iSurvivalMultiplier == iTeamSize ? "\x05" : "\x04"), iSurvivalMultiplier, iTeamSize);
	#if EQSM_DEBUG
		PrintToChatAll("\x01Survival bonus cvar updated. Value: \x05%i\x01 [multiplier: \x05%i\x01]", GetConVarInt(hCvarSurvivalBonus), iSurvivalMultiplier);
	#endif
	}
	else
	{
		SetConVarInt(hCvarSurvivalBonus, 0);
		Format(sSurvivorState[team], 32, "\x04%s\x01", (iSurvivalMultiplier == 0 ? "wiped out" : "bonus depleted"));
	}

	// Scores print
	CreateTimer(3.0, PrintRoundEndStats, _, TIMER_FLAG_NO_MAPCHANGE);

	bRoundOver = true;
	return Plugin_Continue;
}

public Action:PrintRoundEndStats(Handle:timer) 
{
	for (new i = 0; i <= InSecondHalfOfRound(); i++)
	{
		PrintToChatAll("\x01[\x04EQSM\x01 :: Round \x03%i\x01] Bonus: \x05%d\x01/\x05%d\x01 <\x03%.1f%%\x01> [%s]", (i + 1), RoundToFloor(fSurvivorBonus[i]), RoundToFloor(fMapBonus), CalculateBonusPercent(fSurvivorBonus[i]), sSurvivorState[i]);
		// [EQSM :: Round 1] Bonus: 487/1200 <42.7%> [3/4]
	}
}

GetUprightSurvivors()
{
	new aliveCount;
	new survivorCount;
	for (new i = 1; i <= MaxClients && survivorCount < iTeamSize; i++)
	{
		if (IsSurvivor(i))
		{
			survivorCount++;
			if (IsPlayerAlive(i) && !IsPlayerIncap(i) && !IsPlayerLedged(i))
			{
				aliveCount++;
			}
		}
	}
	return aliveCount;
}

Float:GetSurvivorHealthBonus()
{
	new Float:fHealthBonus;
	new survivorCount;
	new survivalMultiplier;
	for (new i = 1; i <= MaxClients && survivorCount < iTeamSize; i++)
	{
		if (IsSurvivor(i))
		{
			survivorCount++;
			if (IsPlayerAlive(i) && !IsPlayerIncap(i) && !IsPlayerLedged(i))
			{
				survivalMultiplier++;
				fHealthBonus += GetSurvivorPermanentHealth(i) * fPermHpWorth;
			#if EQSM_DEBUG
				PrintToChatAll("\x01Adding \x05%N's\x01 perm hp bonus contribution: \x05%d\x01 perm HP -> \x03%.1f\x01 bonus; new total: \x05%.1f\x01", i, GetSurvivorPermanentHealth(i), GetSurvivorPermanentHealth(i) * fPermHpWorth, fHealthBonus);
			#endif
			}
		}
	}
	return (fHealthBonus / iTeamSize * survivalMultiplier);
}

Float:GetSurvivorDamageBonus()
{
	new survivalMultiplier = GetUprightSurvivors();
	new Float:fDamageBonus = (fMapTempHealthBonus - float(iLostTempHealth[InSecondHalfOfRound()])) * fTempHpWorth / iTeamSize * survivalMultiplier;
#if EQSM_DEBUG
	PrintToChatAll("\x01Adding temp hp bonus: \x05%.1f\x01 (eligible survivors: \x05%d\x01)", fDamageBonus, survivalMultiplier);
#endif
	return (fDamageBonus > 0.0 && survivalMultiplier > 0) ? fDamageBonus : 0.0;
}

Float:CalculateBonusPercent(Float:score, Float:maxbonus = -1.0)
{
	return score / (maxbonus == -1.0 ? fMapBonus : maxbonus) * 100;
}

/************/
/** Stocks **/
/************/

InSecondHalfOfRound()
{
	return GameRules_GetProp("m_bInSecondHalfOfRound");
}

bool:IsSurvivor(client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}

bool:IsAnyInfected(entity)
{
	if (entity > 0 && entity <= MaxClients)
	{
		return IsClientInGame(entity) && GetClientTeam(entity) == 3;
	}
	else if (entity > MaxClients)
	{
		decl String:classname[64];
		GetEdictClassname(entity, classname, sizeof(classname));
		if (StrEqual(classname, "infected") || StrEqual(classname, "witch")) 
		{
			return true;
		}
	}
	return false;
}

bool:IsPlayerIncap(client)
{
	return bool:GetEntProp(client, Prop_Send, "m_isIncapacitated");
}

bool:IsPlayerLedged(client)
{
	return bool:(GetEntProp(client, Prop_Send, "m_isHangingFromLedge") | GetEntProp(client, Prop_Send, "m_isFallingFromLedge"));
}

GetSurvivorTemporaryHealth(client)
{
	new temphp = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * GetConVarFloat(FindConVar("pain_pills_decay_rate")))) - 1;
	return (temphp > 0 ? temphp : 0);
}

GetSurvivorPermanentHealth(client)
{
	// Survivors always have minimum 1 permanent hp
	// so that they don't faint in place just like that when all temp hp run out
	// We'll use a workaround for the sake of fair calculations
	// Edit 2: "Incapped HP" are stored in m_iHealth too; we heard you like workarounds, dawg, so we've added a workaround in a workaround
	return GetEntProp(client, Prop_Send, "m_currentReviveCount") > 0 ? 0 : (GetEntProp(client, Prop_Send, "m_iHealth") > 0 ? GetEntProp(client, Prop_Send, "m_iHealth") : 0);
}