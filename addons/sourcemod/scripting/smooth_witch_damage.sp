/*
	SourcePawn is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2015 ITB CompuPhase.
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
#include <sdkhooks>
#pragma semicolon 1

public Plugin:myinfo =
{
	name = "Smooth witch damage",
	author = "Darkid",
	description = "Smooths out the damage taken from a witch while incapped.",
	version = "1.7",
	url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
}

new const bool:DEBUG = false;

new Float:witchDamage;
new Handle:deadWitches;
new Handle:engagedWitches;
new Float:startTick;
new bool:lateLoad = false;

public APLRes:AskPluginLoad2(Handle:plugin, bool:late, String:error[], errMax) {
	lateLoad = late;
	return APLRes_Success;
}

public OnPluginStart() {
	if (lateLoad) {
		for (new client=1; client<=MaxClients; client++) {
			if (!IsClientInGame(client)) continue;
			OnClientPostAdminCheck(client);
		}
	}

	decl String:witchDamageString[64];
	GetConVarString(FindConVar("z_witch_damage_per_kill_hit"), witchDamageString, sizeof(witchDamageString));
	HookConVarChange(FindConVar("z_witch_damage_per_kill_hit"), OnWitchDamageChange);
	witchDamage = 1.0*StringToInt(witchDamageString);

	deadWitches = CreateArray(64);
	engagedWitches = CreateArray(64);

	HookEvent("round_start", round_start);
	HookEvent("witch_killed", witch_killed);
	startTick = 0.0;
}

public OnWitchDamageChange(Handle:cvar, const String:oldVal[], const String:newVal[]) {
	witchDamage = 1.0*StringToInt(newVal);
}

public OnClientPostAdminCheck(client) {
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public round_start(Handle:event, const String:name[], bool:dontBroadcast) {
	ClearArray(deadWitches);
	ClearArray(engagedWitches);
}

bool:IsWitch(entity) {
	if (entity <= 0 || !IsValidEntity(entity) || !IsValidEdict(entity)) return false;
	decl String:className[8];
	GetEdictClassname(entity, className, sizeof(className));
	return strcmp(className, "witch") == 0;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damageType) {
	if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return Plugin_Continue;
	if (!IsWitch(attacker)) return Plugin_Continue;
	// A hack. We assume the first scratch isn't the same damage as an incap scratch.
	// It's also worth noting that this prevents infinite recursion, since WitchScratch reduces the damage dealt.
	if (damage != witchDamage) return Plugin_Continue;
	if (FindValueInArray(engagedWitches, attacker) != -1) return Plugin_Stop;
	startTick = GetEngineTime();
	PushArrayCell(engagedWitches, attacker);
	new Handle:data = CreateArray(64);
	PushArrayCell(data, victim);
	PushArrayCell(data, attacker);
	PushArrayCell(data, inflictor);
	PushArrayCell(data, damageType);
	// The witch scratch animation is every 1/4 second. Repeat until survivor DIES.
	CreateTimer(0.25, WitchScratch, data, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	damage = witchDamage/2.5;
	if (DEBUG) PrintToChatAll("[%02.3f] Player %d took %3f damage from witch %d/%d.", GetEngineTime()-startTick, victim, witchDamage/2.5, attacker, inflictor);
	return Plugin_Continue;
}

public Action:WitchScratch(Handle:timer, any:data) {
	new victim = GetArrayCell(data, 0);
	// If defibrillator_use_time is less than .25, this may bug out.
	new attacker = GetArrayCell(data, 1);
	if (!IsPlayerAlive(victim)) {
		new index = FindValueInArray(engagedWitches, attacker);
		RemoveFromArray(engagedWitches, index);
		return Plugin_Stop;
	}
	new index = FindValueInArray(deadWitches, attacker);
	if (index != -1) {
		RemoveFromArray(deadWitches, index);
		index = FindValueInArray(engagedWitches, attacker);
		if (index != -1) RemoveFromArray(engagedWitches, index);
		return Plugin_Stop;
	}
	new inflictor = GetArrayCell(data, 2);
	new damageType = GetArrayCell(data, 3);
	SDKHooks_TakeDamage(victim, attacker, inflictor, witchDamage/2.5, damageType);
	if (DEBUG) PrintToChatAll("[%02.3f] Player %d took %3f damage from witch %d/%d", GetEngineTime()-startTick, victim, witchDamage/2.5, attacker, inflictor);
	return Plugin_Continue;
}

public witch_killed(Handle:event, const String:name[], bool:dontBroadcast) {
	new witch = GetEventInt(event, "witchid");
	PushArrayCell(deadWitches, witch);
}
