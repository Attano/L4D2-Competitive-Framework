#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <l4d2util>

new     Handle:g_hHunterSubtitles          = INVALID_HANDLE;

public Plugin:myinfo = 
{
    name = "Hunter Call-out Blocker",
    author = "High Cookie",
    description = "Stops Survivors from saying 'Hunter!'",
    version = "0.1",
    url = ""
}

public OnPluginStart()
{
	PrepareSubtitleArray();
	AddNormalSoundHook(NormalSHook:sound_hook);
	HookUserMessage(GetUserMessageId("CloseCaption"), OnCloseCaption, true);
	HookUserMessage(GetUserMessageId("CloseCaptionDirect"), OnCloseCaption, true);
}

public Action:sound_hook(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if (StrContains(sample, "WarnHunter")!=-1)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:OnCloseCaption(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	new id = BfReadNum(bf);
	if (FindValueInArray(g_hHunterSubtitles, id) != -1)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

PrepareSubtitleArray()
{
	g_hHunterSubtitles = CreateArray(23);
	PushArrayCell(g_hHunterSubtitles,-497131336);
	PushArrayCell(g_hHunterSubtitles,-1789308882);
	PushArrayCell(g_hHunterSubtitles,2069311746);
	PushArrayCell(g_hHunterSubtitles,1662540365);
	PushArrayCell(g_hHunterSubtitles,337603291);
	PushArrayCell(g_hHunterSubtitles,-1927922847);
	PushArrayCell(g_hHunterSubtitles,455051715);
	PushArrayCell(g_hHunterSubtitles,-183375633);
	PushArrayCell(g_hHunterSubtitles,-2055529376);
	PushArrayCell(g_hHunterSubtitles,815841183);
	PushArrayCell(g_hHunterSubtitles,1086999312);
	PushArrayCell(g_hHunterSubtitles,-1362875844);
	PushArrayCell(g_hHunterSubtitles,-641525078);
	PushArrayCell(g_hHunterSubtitles,1813559637);
	PushArrayCell(g_hHunterSubtitles,-2116245366);
	PushArrayCell(g_hHunterSubtitles,1876085158);
	PushArrayCell(g_hHunterSubtitles,-153380836);
	PushArrayCell(g_hHunterSubtitles,1733309612);
	PushArrayCell(g_hHunterSubtitles,-27695850);
	PushArrayCell(g_hHunterSubtitles,-1990306432);
	PushArrayCell(g_hHunterSubtitles,1715646612);
	PushArrayCell(g_hHunterSubtitles,-2008231496);
	PushArrayCell(g_hHunterSubtitles,-11804370);
}

//COACH:  -497131336, -1789308882, 2069311746
//ROCHELLE: 1662540365, 337603291, -1927922847 
//NICK: 455051715, -183375633, -2055529376, 1813559637
//ELLIS: 815841183, 1086999312, -1362875844, -641525078
//FRANCIS: -2116245366, 1876085158, -153380836
//LOUIS: 1733309612, -27695850, -1990306432
//ZOEY: 1715646612, -2008231496, -11804370