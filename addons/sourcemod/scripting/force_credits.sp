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
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>


public Plugin:myinfo = 
{
    name = "Force Credits",
    author = "Jacob",
    description = "Forces the credits / stats to display at the end of a game.",
    version = "0.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
        RegAdminCmd("sm_forcecredits", ForceCredits_Cmd, ADMFLAG_BAN, "Forces the outro credits to roll.");
        RegAdminCmd("sm_forcestats", ForceStats_Cmd, ADMFLAG_BAN, "Forces the stats crawl to roll.");
}

public Action:ForceStats_Cmd(client, args)
{
    ModifyEntity("env_outtro_stats", "RollStatsCrawl");
    PrintToChatAll("Stats should be crawling.");
}

public Action:ForceCredits_Cmd(client, args)
{
    ModifyEntity("env_outtro_stats", "RollCredits");
    PrintToChatAll("Credits should be rolling.");
}


ModifyEntity(String:className[], String:inputName[])
{ 
    new iEntity;

    while ( (iEntity = FindEntityByClassname(iEntity, className)) != -1 )
    {
        if ( !IsValidEdict(iEntity) || !IsValidEntity(iEntity) )
        {
            continue;
        }
        AcceptEntityInput(iEntity, inputName);
    }
}
