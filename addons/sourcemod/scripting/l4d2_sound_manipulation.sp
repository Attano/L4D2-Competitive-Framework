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
#include <sdktools>

#define MAX_ROCHELLESOUND      8
#define MAX_ELLISSOUND         6
#define MAX_NICKSOUND          14
#define MAX_COACHSOUND         18

new Handle:cBlockHB;
new Handle:cSurvivorMelee;
 
public Plugin:myinfo = 
{
	name = "Sound Manipulation",
	author = "Sir",
	description = "Allows control over certain sounds",
	version = "1.0",
	url = "https://github.com/SirPlease/SirCoding"
}

new const String: sCoachSound[MAX_COACHSOUND+1][] =
{
	"player/survivor/voice/coach/meleeswing01.wav",
	"player/survivor/voice/coach/meleeswing02.wav",
	"player/survivor/voice/coach/meleeswing03.wav",
	"player/survivor/voice/coach/meleeswing04.wav",
	"player/survivor/voice/coach/meleeswing05.wav",
	"player/survivor/voice/coach/meleeswing06.wav",
	"player/survivor/voice/coach/meleeswing07.wav",
	"player/survivor/voice/coach/meleeswing08.wav",
	"player/survivor/voice/coach/meleeswing09.wav",
	"player/survivor/voice/coach/meleeswing10.wav",
	"player/survivor/voice/coach/meleeswing11.wav",
	"player/survivor/voice/coach/meleeswing12.wav",
	"player/survivor/voice/coach/meleeswing13.wav",
	"player/survivor/voice/coach/meleeswing14.wav",
	"player/survivor/voice/coach/meleeswing15.wav",
	"player/survivor/voice/coach/meleeswing16.wav",
	"player/survivor/voice/coach/meleeswing17.wav",
	"player/survivor/voice/coach/meleeswing18.wav",
	"player/survivor/voice/coach/meleeswing19.wav"
};

new const String: sRochelleSound[MAX_ROCHELLESOUND+1][] =
{
	"player/survivor/voice/producer/meleeswing01.wav",
	"player/survivor/voice/producer/meleeswing02.wav",
	"player/survivor/voice/producer/meleeswing03.wav",
	"player/survivor/voice/producer/meleeswing04.wav",
	"player/survivor/voice/producer/meleeswing05.wav",
	"player/survivor/voice/producer/meleeswing06.wav",
	"player/survivor/voice/producer/meleeswing07.wav",
	"player/survivor/voice/producer/meleeswing08.wav",
	"player/survivor/voice/producer/meleeswing09.wav"
};

new const String: sEllisSound[MAX_ELLISSOUND+1][] =
{
	"player/survivor/voice/mechanic/meleeswing01.wav",
	"player/survivor/voice/mechanic/meleeswing02.wav",
	"player/survivor/voice/mechanic/meleeswing03.wav",
	"player/survivor/voice/mechanic/meleeswing04.wav",
	"player/survivor/voice/mechanic/meleeswing05.wav",
	"player/survivor/voice/mechanic/meleeswing06.wav",
	"player/survivor/voice/mechanic/meleeswing07.wav"
};

new const String: sNickSound[MAX_NICKSOUND+1][] =
{
	"player/survivor/voice/gambler/meleeswing01.wav",
	"player/survivor/voice/gambler/meleeswing02.wav",
	"player/survivor/voice/gambler/meleeswing03.wav",
	"player/survivor/voice/gambler/meleeswing04.wav",
	"player/survivor/voice/gambler/meleeswing05.wav",
	"player/survivor/voice/gambler/meleeswing06.wav",
	"player/survivor/voice/gambler/meleeswing07.wav",
	"player/survivor/voice/gambler/meleeswing08.wav",
	"player/survivor/voice/gambler/meleeswing09.wav",
	"player/survivor/voice/gambler/meleeswing10.wav",
	"player/survivor/voice/gambler/meleeswing11.wav",
	"player/survivor/voice/gambler/meleeswing12.wav",
	"player/survivor/voice/gambler/meleeswing13.wav",
	"player/survivor/voice/gambler/meleeswing14.wav",
	"player/survivor/voice/gambler/meleeswing15.wav"
};


public OnPluginStart()
{
	cBlockHB = CreateConVar("sound_block_hb", "0", "Block the Heartbeat Sound, very useful for 1v1 matchmodes");
	cSurvivorMelee = CreateConVar("sound_survivor_melee", "1", "Let the Survivors actually use their melee swing grunts");
	
	//Event
	HookEvent("player_hurt", PlayerHurt);
	
	//Sound Hook
	AddNormalSoundHook(NormalSHook:SoundHook);
}

public OnMapStart()
{
	for (new i = 0; i <= MAX_ROCHELLESOUND; i++)
	{
		PrefetchSound(sRochelleSound[i]);
		PrecacheSound(sRochelleSound[i], true);
	}
	
	for (new i = 0; i <= MAX_NICKSOUND; i++)
	{
		PrefetchSound(sNickSound[i]);
		PrecacheSound(sNickSound[i], true);
	}
	
	for (new i = 0; i <= MAX_ELLISSOUND; i++)
	{
		PrefetchSound(sEllisSound[i]);
		PrecacheSound(sEllisSound[i], true);
	}
	
	for (new i = 0; i <= MAX_COACHSOUND; i++)
	{
		PrefetchSound(sCoachSound[i]);
		PrecacheSound(sCoachSound[i], true);
	}
}

public Action:SoundHook(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity)
{
	if (StrEqual(sample, "player/heartbeatloop.wav", false) && GetConVarBool(cBlockHB))
	{
		numClients = 0;
		
		return Plugin_Changed;
	}
	return Plugin_Continue;
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
		// SI Died
		if (health <= 0 && GetConVarBool(cSurvivorMelee))
		{
			if (attacker <= 0 || attacker > MaxClients) return Plugin_Handled;
			new String:clientModel[42];
			GetClientModel(attacker, clientModel, sizeof(clientModel));
			
			//
			//Make sure the Survivors have their Melee Sounds!
			//
			
			//Coach
			if (StrEqual(clientModel, "models/survivors/survivor_coach.mdl"))
			{
				new rndPick = GetRandomInt(0, MAX_COACHSOUND);
				EmitSoundToAll(sCoachSound[rndPick], attacker, SNDCHAN_VOICE);
			}
			//Nick
			else if (StrEqual(clientModel, "models/survivors/survivor_gambler.mdl"))
			{	
				new rndPick = GetRandomInt(0, MAX_NICKSOUND);
				EmitSoundToAll(sNickSound[rndPick], attacker, SNDCHAN_VOICE);
			}
			//Rochelle
			else if (StrEqual(clientModel, "models/survivors/survivor_producer.mdl"))
			{
				new rndPick = GetRandomInt(0, MAX_ROCHELLESOUND);
				EmitSoundToAll(sRochelleSound[rndPick], attacker, SNDCHAN_VOICE);
			}
			//Ellis
			else if (StrEqual(clientModel, "models/survivors/survivor_mechanic.mdl")) 
			{	
				new rndPick = GetRandomInt(0, MAX_ELLISSOUND);
				EmitSoundToAll(sEllisSound[rndPick], attacker, SNDCHAN_VOICE);
			}
			//No Matching Survivors
			else return Plugin_Continue;
				
			//L4D1 Survivor.. No Files yet
			//else if (StrEqual(clientModel, "models/survivors/survivor_manager.mdl")) 
			//else if (StrEqual(clientModel, "models/survivors/survivor_teenangst.mdl"))
			//else if (StrEqual(clientModel, "models/survivors/survivor_namvet.mdl"))
			//else if (StrEqual(clientModel, "models/survivors/survivor_biker.mdl"))
		}    
	}
	return Plugin_Continue;
}	

bool:IsSi(client) 
{
	if (IsClientConnected(client)
	&& IsClientInGame(client)
	&& GetClientTeam(client) == 3) 
	{
		return true;
	}
	
	return false;}
