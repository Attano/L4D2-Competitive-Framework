#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

new Handle:hCvarMotdTitle;
new Handle:hCvarMotdUrl;
new Handle:hCvarCfgName;
new Handle:hInfoTimer;

public Plugin:myinfo =
{
	name = "Config Description",
	author = "Visor",
	description = "Displays a descriptive MOTD on desire",
	version = "0.2",
	url = "https://github.com/Attano/smplugins"
};

public OnPluginStart()
{
    hCvarMotdTitle = CreateConVar("sm_cfgmotd_title", "Confogl Nexus", "Custom MOTD title", FCVAR_PLUGIN);
    hCvarMotdUrl = CreateConVar("sm_cfgmotd_url", "http://shantisbitches.ru/confogl-nexus/", "Custom MOTD url", FCVAR_PLUGIN);
    hCvarCfgName = FindConVar("sbhm_cfgname");

    RegConsoleCmd("sm_cfg", ShowMOTD, "Show a MOTD describing the current config", FCVAR_PLUGIN);

    HookEvent("round_start", RoundStartEvent, EventHookMode_PostNoCopy);
}

public Action:RoundStartEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (hInfoTimer == INVALID_HANDLE)
		hInfoTimer = CreateTimer(90.0, InfoTimer, _, TIMER_REPEAT);
}
    
public OnRoundIsLive() 
{
	if (hInfoTimer != INVALID_HANDLE)
    {
        KillTimer(hInfoTimer);
        hInfoTimer = INVALID_HANDLE;
    }
}

public Action:InfoTimer(Handle:timer)
{
    decl String:config[64];
    if (hCvarCfgName != INVALID_HANDLE)
        GetConVarString(hCvarCfgName, config, sizeof(config));
    else 
        GetConVarString(FindConVar("l4d_ready_cfg_name"), config, sizeof(config));

    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientConnected(i))
        {
            PrintToChat(i, "\x04[Info]\x01 Type \x03!cfg\x01 in chat to view details about \x05%s\x01.", config);
        }
    }
}

public Action:ShowMOTD(client, args) 
{
    decl String:title[64], String:url[192];
    
    GetConVarString(hCvarMotdTitle, title, sizeof(title));
    GetConVarString(hCvarMotdUrl, url, sizeof(url));
    
    ShowMOTDPanel(client, title, url, MOTDPANEL_TYPE_URL);
}