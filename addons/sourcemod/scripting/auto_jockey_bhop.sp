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
#include <l4d2util>

#define CVAR_FLAGS			FCVAR_PLUGIN|FCVAR_NOTIFY

public Plugin:myinfo = 
{
    name = "Jockey Bunny Hop Grace Period",
    author = "Standalone (aka Manu)",
    description = "Extends the window where a Jockey can bunny hop",
    version = "1.0",
    url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"
};

new Handle:autoBunnyCooldown        = INVALID_HANDLE;
new Handle:autoBunnyDuration        = INVALID_HANDLE;
new Handle:autoBunnyGhostEnabled    = INVALID_HANDLE;
new Handle:autoBunnyEnabled         = INVALID_HANDLE;

new bool:jumpButtonDown[MAXPLAYERS + 1];
new Float:lastAutoBunnyTime[MAXPLAYERS + 1];

public OnPluginStart()
{
    autoBunnyCooldown       = CreateConVar("jockey_bunny_cooldown", "0.5", "Time between auto bunny hop grace periods", CVAR_FLAGS, true, 0.0);
    autoBunnyDuration       = CreateConVar("jockey_bunny_duration", "0.1", "Time allowed for automatic bunny hop periods", CVAR_FLAGS, true, 0.0);
    autoBunnyGhostEnabled   = CreateConVar("jockey_bunny_ghost_enabled", "1.0", "Set whether auto Jockey bunny hops are enabled while in ghost mode. 1 = Enabled", CVAR_FLAGS);
    autoBunnyEnabled        = CreateConVar("jockey_bunny_enabled", "1.0", "Set whether auto Jockey bunny hops are enabled. 1 = Enabled", CVAR_FLAGS);
    
    HookEvent("round_start", Event_RoundStart);
}

public OnPluginEnd()
{
    PrintToChatAll("Disposing of CVAR Handles");
    CloseHandle(autoBunnyCooldown);
    CloseHandle(autoBunnyDuration);
    CloseHandle(autoBunnyGhostEnabled);
    CloseHandle(autoBunnyEnabled);
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
    if (GetConVarBool(autoBunnyEnabled))
    {
        //If client is infected and a Jockey
        if (IsInfected(client) && GetInfectedClass(client) == L4D2Infected_Jockey)
        {
            //If jockey is currently ghosted and ghosted bunny hops are disabled then return
            if (!GetConVarBool(autoBunnyGhostEnabled) && IsInfectedGhost(client))
                return;
                
            new Float:cooldown = GetConVarFloat(autoBunnyCooldown);
            new Float:duration = GetConVarFloat(autoBunnyDuration);
            new Float:currentTime = GetGameTime();
            
            //Keep track of when the jump button is initially pressed down
            if (buttons & IN_JUMP)
            {
                //On Jump Button Down
                if (jumpButtonDown[client] == false)
                {
                    jumpButtonDown[client] = true;
                    //If we are out of the auto bunny cooldown time, update the last auto bunny period
                    if (currentTime > lastAutoBunnyTime[client] + cooldown)
                    {
                        lastAutoBunnyTime[client] = currentTime;
                    }
                }
                else //jump button being held down, but this is not the first frame it was pressed
                {
                    //if player is on a ladder and the jump button is held down
                    if (GetEntityMoveType(client) & MOVETYPE_LADDER)
                    {
                        //remove the jump input
                        //this fixes the issue where you jump onto a ladder while holding down IN_JUMP and when the grace period ends you jump off the ladder
                        buttons &= ~IN_JUMP;
                    }
                }
            } 
            else
            {
                jumpButtonDown[client] = false;
            }
            
            //Do auto bunny hop if in grace period
            if (currentTime < lastAutoBunnyTime[client] + duration)
            {
                //if currently holding the jump button down
                if (buttons & IN_JUMP)
                { 
                    //if player is currently in the air & not on a ladder
                    if (!(GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1)
                    {
                        //remove IN_JUMP from the buttons pressed
                        buttons &= ~IN_JUMP;
                    }
                }
                else //if jump button not held down
                {
                    //if player lands on the ground during the grace period
                    if ((GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1)
                    {
                        //add IN_JUMP to the buttons
                        buttons = buttons + IN_JUMP;
                    }
                }
            }
        }
    }
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{
    for (new i = 0; i < MAXPLAYERS + 1; i++)
    {
        jumpButtonDown[i] = false;
        lastAutoBunnyTime[i] = 0.0;
    }
}
