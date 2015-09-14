#pragma semicolon 1

#include <sourcemod>

#define JBE_REL8_OPCODE 0x76
#define JMP_REL8_OPCODE 0xEB
// NOP; JMP (rel32)
new NOP_JMP[2] = {0x90, 0xE9};
new NOP_6[6] = {0x66,0x0f,0x1f,0x44,0x00,0x00};
new ORIGINAL_BYTES_LINUX_SHORTCHK[2];
new ORIGINAL_BYTES_LINUX_SLAMCHK[6];
new Address:g_pShortPatchTarget;
new Address:g_pSlamPatchTarget;
new bool:g_bIsPatched;
new bool:g_bIsLinux;

public Plugin:myinfo =
{
	name = "Charger Chest Bump Fix",
	author = "Jacob, ProdigySim",
	description = "Fixes chargers getting random stumbles when attempting to charge a survivor",
	version = "1.0",
	url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
	new Handle:hGamedata = LoadGameConfigFile("charger_chestbump");
	if (!hGamedata)
		SetFailState("Gamedata 'charger_chestbump.txt' missing or corrupt");

	FindPatchTargets(hGamedata);
	CloseHandle(hGamedata);
	
	new Handle:cvar = CreateConVar("l4d2_charger_chestbump_fix", "0", "Fix chargers stumbling when charging too close to a survivor");
	HookConVarChange(cvar, OnCvarChange);
	CheckCvarAndPatch(cvar);
}

public OnPluginEnd()
{
	Unpatch();
}

public OnCvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	CheckCvarAndPatch(convar);
}

CheckCvarAndPatch(Handle:convar)
{
	if(GetConVarBool(convar))
	{
		Patch();
	}
	else 
	{
		Unpatch();
	}
}

bool:IsPatched()
{
	return g_bIsPatched;
}

Patch()
{
	if(!IsPatched())
	{
		if(g_bIsLinux)
		{
			for(new i =0; i < sizeof(NOP_JMP); i++)
			{
				StoreToAddress(g_pShortPatchTarget + Address:i, NOP_JMP[i], NumberType_Int8);
			}
			for(new i =0; i < sizeof(NOP_6); i++)
			{
				StoreToAddress(g_pSlamPatchTarget + Address:i, NOP_6[i], NumberType_Int8);
			}
		}
		else
		{
			StoreToAddress(g_pShortPatchTarget, JMP_REL8_OPCODE, NumberType_Int8);
			StoreToAddress(g_pSlamPatchTarget, JMP_REL8_OPCODE, NumberType_Int8);
		}
		g_bIsPatched = true;
	}
}

Unpatch()
{
	if(IsPatched())
	{
		if(g_bIsLinux)
		{
			for(new i =0; i < sizeof(ORIGINAL_BYTES_LINUX_SHORTCHK); i++)
			{
				StoreToAddress(g_pShortPatchTarget + Address:i, ORIGINAL_BYTES_LINUX_SHORTCHK[i], NumberType_Int8);
			}
			for(new i =0; i < sizeof(ORIGINAL_BYTES_LINUX_SLAMCHK); i++)
			{
				StoreToAddress(g_pSlamPatchTarget + Address:i, ORIGINAL_BYTES_LINUX_SLAMCHK[i], NumberType_Int8);
			}
		}
		else
		{
			StoreToAddress(g_pShortPatchTarget, JBE_REL8_OPCODE, NumberType_Int8);
			StoreToAddress(g_pSlamPatchTarget, JBE_REL8_OPCODE, NumberType_Int8);
		}
		g_bIsPatched = false;
	}
}

FindPatchTargets(Handle:hGamedata)
{
	new Address:pChargerCollision = GameConfGetAddress(hGamedata, "ChargerCollision_Sig");
	if (!pChargerCollision)
		SetFailState("Couldn't find the 'ChargerCollision_Sig' address");
	
	new iOffset = GameConfGetOffset(hGamedata, "HandleCustomCollision_TooShortCheck");
	
	g_pShortPatchTarget = pChargerCollision + (Address:iOffset);
	
	iOffset = GameConfGetOffset(hGamedata, "HandleCustomCollision_SlamCheck");
	
	g_pSlamPatchTarget = pChargerCollision + (Address:iOffset);
	
	new FirstByte = LoadFromAddress(g_pShortPatchTarget, NumberType_Int8);
	
	switch(FirstByte)
	{
		case 0x0F: //Linux
		{
			for(new i =0; i < sizeof(ORIGINAL_BYTES_LINUX_SHORTCHK); i++)
			{
				ORIGINAL_BYTES_LINUX_SHORTCHK[i] = LoadFromAddress(g_pShortPatchTarget + Address:i, NumberType_Int8);
			}
			for(new i =0; i < sizeof(ORIGINAL_BYTES_LINUX_SLAMCHK); i++)
			{
				ORIGINAL_BYTES_LINUX_SLAMCHK[i] = LoadFromAddress(g_pSlamPatchTarget + Address:i, NumberType_Int8);
			}
			if(ORIGINAL_BYTES_LINUX_SLAMCHK[0] != 0x0F)
			{
				SetFailState("Charger Chest Bump Slam Offset seems incorrect");
			}
			g_bIsLinux = true;
		}
		case JBE_REL8_OPCODE: //Windows
		{
			g_bIsLinux = false;
			if(LoadFromAddress(g_pSlamPatchTarget, NumberType_Int8) != JBE_REL8_OPCODE)
			{
				SetFailState("Charger Chest Bump Slam Offset seems incorrect");
			}
		}
		default:
		{
			SetFailState("Charger Chest Bump Offset or signature seems incorrect");
		}
	}
}
