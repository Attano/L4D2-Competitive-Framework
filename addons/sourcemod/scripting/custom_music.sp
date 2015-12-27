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
#include <clientprefs>

new Handle:g_hMusicCookie;

public Plugin:myinfo =
{
	name = "Clientside Custom Music",
	author = "Jacob",
	description = "Allows clients to decide what musical files they want to hear.",
	version = "0.1",
	url = "github.com/jacob404/myplugins",
}

public OnPluginStart()
{
	RegConsoleCmd("sm_mymusic", MusicFlags_Cmd, "What music does the client want to ignore?");
	g_hMusicCookie = RegClientCookie("cm_musicflags", "ClientsideCustomMusic MusicFlags", CookieAccess_Public);
}

public Action:MusicFlags_Cmd(client, args)
{
	decl String:sClientCookie[3];
	IntToString(args, sClientCookie, sizeof(sClientCookie));
	SetClientCookie(client, g_hMusicCookie, sClientCookie);
}

public OnMapStart()
{
	CreateTimer(0.1, MusicTimer, _, TIMER_REPEAT);
}

public Action:MusicTimer(Handle:timer)
{
	for (new client = 1; client <= MAXPLAYERS; client++)
	{
		if(AreClientCookiesCached(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			
			decl String:sMusicCookie[3];
			GetClientCookie(client, g_hMusicCookie, sMusicCookie, sizeof(sMusicCookie));
			new iTempClientFlags = StringToInt(sMusicCookie);

			if(iTempClientFlags >= 256) // bacteria
			{
				iTempClientFlags = iTempClientFlags - 256;
				KillMusic(client, "music/bacteria/boomerbacteria.wav");
				KillMusic(client, "music/bacteria/boomerbacterias.wav");
				KillMusic(client, "music/bacteria/chargerbacteria.wav");
				KillMusic(client, "music/bacteria/chargerbacterias.wav");
				KillMusic(client, "music/bacteria/hunterbacteria.wav");
				KillMusic(client, "music/bacteria/hunterbacterias.wav");
				KillMusic(client, "music/bacteria/jockeybacteria.wav");
				KillMusic(client, "music/bacteria/jockeybacterias.wav");
				KillMusic(client, "music/bacteria/smokerbacteria.wav");
				KillMusic(client, "music/bacteria/smokerbacterias.wav");
				KillMusic(client, "music/bacteria/spitterbacteria.wav");
				KillMusic(client, "music/bacteria/spitterbacterias.wav");
			}

			if(iTempClientFlags >= 128) // witch
			{
				iTempClientFlags = iTempClientFlags - 128;
				KillMusic(client, "music/witch/lost_little_witch_01a.wav");
				KillMusic(client, "music/witch/lost_little_witch_01b.wav");
				KillMusic(client, "music/witch/lost_little_witch_02a.wav");
				KillMusic(client, "music/witch/lost_little_witch_02b.wav");
				KillMusic(client, "music/witch/lost_little_witch_03a.wav");
				KillMusic(client, "music/witch/lost_little_witch_03b.wav");
				KillMusic(client, "music/witch/lost_little_witch_04a.wav");
				KillMusic(client, "music/witch/lost_little_witch_04b.wav");
				KillMusic(client, "music/witch/loud_angry_little_witch_01.wav");
				KillMusic(client, "music/witch/loud_angry_little_witch_02.wav");
				KillMusic(client, "music/witch/loud_angry_little_witch_03.wav");
				KillMusic(client, "music/witch/loud_angry_little_witch_04.wav");
				KillMusic(client, "music/witch/psychowitch.wav");
				KillMusic(client, "music/witch/witchencroacher.wav");
				KillMusic(client, "music/witch/witchroast.wav");
			}

			if(iTempClientFlags >= 64) // tank
			{
				iTempClientFlags = iTempClientFlags - 64;
				KillMusic(client, "music/tank/midnighttank.wav");
				KillMusic(client, "music/tank/onebadtank.wav");
				KillMusic(client, "music/tank/taank.wav");
				KillMusic(client, "music/tank/tank.wav");
			}

			if(iTempClientFlags >= 32) // game events
			{
				iTempClientFlags = iTempClientFlags - 32;
				KillMusic(client, "music/pzattack/asphyxiation.wav");
				KillMusic(client, "music/pzattack/contusion.wav");
				KillMusic(client, "music/pzattack/enzymicide.wav");
				KillMusic(client, "music/pzattack/exenteration.wav");
				KillMusic(client, "music/pzattack/mortification.wav");
				KillMusic(client, "music/pzattack/vassalation.wav");
				KillMusic(client, "music/terror/clingingtohell1.wav");
				KillMusic(client, "music/terror/clingingtohell2.wav");
				KillMusic(client, "music/terror/clingingtohell3.wav");
				KillMusic(client, "music/terror/clingingtohell4.wav");
				KillMusic(client, "music/terror/iamsocold.wav");
				KillMusic(client, "music/terror/mobrules.wav");
				KillMusic(client, "music/terror/pileobile.wav");
				KillMusic(client, "music/terror/puddleofyou.wav");
				KillMusic(client, "music/terror/pukricide.wav");
				KillMusic(client, "music/terror/theend.wav");
				KillMusic(client, "music/terror/tonguetied.wav");
				KillMusic(client, "music/tags/asphyxiationhit.wav");
				KillMusic(client, "music/tags/clingingtohellhit1.wav");
				KillMusic(client, "music/tags/clingingtohellhit2.wav");
				KillMusic(client, "music/tags/clingingtohellhit3.wav");
				KillMusic(client, "music/tags/clingingtohellhit4.wav");
				KillMusic(client, "music/tags/contusionhit.wav");
				KillMusic(client, "music/tags/exenterationhit.wav");
				KillMusic(client, "music/tags/iamsocoldhit.wav");
				KillMusic(client, "music/tags/leftfordeathhit.wav");
				KillMusic(client, "music/tags/mortificationhit.wav");
				KillMusic(client, "music/tags/puddleofyouhit.wav");
				KillMusic(client, "music/tags/pukricidehit.wav");
				KillMusic(client, "music/tags/tonguetiedhit.wav");
				KillMusic(client, "music/tags/vassalationhit.wav");
				KillMusic(client, "music/undeath/death.wav");
				KillMusic(client, "music/undeath/leftfordeath.wav");
			}

			if(iTempClientFlags >= 16) // scavenge
			{
				iTempClientFlags = iTempClientFlags - 16;
				KillMusic(client, "music/scavenge/gascanofvictory.wav");
				KillMusic(client, "music/scavenge/level_01_01.wav");
				KillMusic(client, "music/scavenge/level_02_01.wav");
				KillMusic(client, "music/scavenge/level_03_01.wav");
				KillMusic(client, "music/scavenge/level_04_01.wav");
				KillMusic(client, "music/scavenge/level_05_01.wav");
				KillMusic(client, "music/scavenge/level_06_01.wav");
				KillMusic(client, "music/scavenge/level_07_01.wav");
				KillMusic(client, "music/scavenge/level_08_01.wav");
				KillMusic(client, "music/scavenge/level_09_01.wav");
				KillMusic(client, "music/scavenge/level_10_01.wav");
			}

			if(iTempClientFlags >= 8) // escape
			{
				iTempClientFlags = iTempClientFlags - 8;
				KillMusic(client, "music/safe/themonsterswithout.wav");
				KillMusic(client, "music/safe/themonsterswithout_s.wav");
				KillMusic(client, "music/the_end/finalnail.wav");
				KillMusic(client, "music/the_end/skinonourteeth.wav");
				KillMusic(client, "music/the_end/snowballinhell.wav");
				KillMusic(client, "music/the_end/yourownfuneral.wav");
				KillMusic(client, "music/unalive/themonsterswithin.wav");
			}

			if(iTempClientFlags >= 4) // jukebox
			{
				iTempClientFlags = iTempClientFlags - 4;
				KillMusic(client, "music/flu/rocketride.wav");
				KillMusic(client, "music/flu/thesaintswillnevercome.wav");
				KillMusic(client, "music/flu/jukebox/all_i_want_for_xmas.wav");
				KillMusic(client, "music/flu/jukebox/badman.wav");
				KillMusic(client, "music/flu/jukebox/midnightride.wav");
				KillMusic(client, "music/flu/jukebox/portal_still_alive.wav");
				KillMusic(client, "music/flu/jukebox/re_your_brains.wav");
				KillMusic(client, "music/flu/jukebox/thesaintswillnevercome.wav");
				KillMusic(client, "music/flu/concert/onebadman.wav");
				KillMusic(client, "music/flu/concert/midnightride.wav");
			}

			if(iTempClientFlags >= 2) // horde
			{
				iTempClientFlags = iTempClientFlags - 2;
				KillMusic(client, "music/mob/easygerml1a.wav");
				KillMusic(client, "music/mob/easygerml1b.wav");
				KillMusic(client, "music/mob/easygerml2a.wav");
				KillMusic(client, "music/mob/easygerml2b.wav");
				KillMusic(client, "music/mob/easygermm1a.wav");
				KillMusic(client, "music/mob/easygermm1b.wav");
				KillMusic(client, "music/mob/easygermm1c.wav");
				KillMusic(client, "music/mob/easygermm1d.wav");
				KillMusic(client, "music/mob/easygermm2c.wav");
				KillMusic(client, "music/mob/easygermm2d.wav");
				KillMusic(client, "music/mob/easygerms1a.wav");
				KillMusic(client, "music/mob/easygerms1b.wav");
				KillMusic(client, "music/mob/easygermx1a.wav");
				KillMusic(client, "music/mob/easygermx1b.wav");
				KillMusic(client, "music/mob/easygermx2a.wav");
				KillMusic(client, "music/mob/easygermx2b.wav");
				KillMusic(client, "music/mob/fairgroundgerml1a.wav");
				KillMusic(client, "music/mob/fairgroundgerml1b.wav");
				KillMusic(client, "music/mob/fairgroundgerml2a.wav");
				KillMusic(client, "music/mob/fairgroundgerml2b.wav");
				KillMusic(client, "music/mob/fairgroundgermm1a.wav");
				KillMusic(client, "music/mob/fairgroundgermm1b.wav");
				KillMusic(client, "music/mob/fairgroundgermm2a.wav");
				KillMusic(client, "music/mob/fairgroundgermm2b.wav");
				KillMusic(client, "music/mob/fairgroundgermx1a.wav");
				KillMusic(client, "music/mob/fairgroundgermx1b.wav");
				KillMusic(client, "music/mob/fairgroundgermx2a.wav");
				KillMusic(client, "music/mob/fairgroundgermx2b.wav");
				KillMusic(client, "music/mob/germs1a.wav");
				KillMusic(client, "music/mob/germs1b.wav");
				KillMusic(client, "music/mob/mallgerml1a.wav");
				KillMusic(client, "music/mob/mallgerml1b.wav");
				KillMusic(client, "music/mob/mallgerml1c.wav");
				KillMusic(client, "music/mob/mallgermm1a.wav");
				KillMusic(client, "music/mob/mallgermm2a.wav");
				KillMusic(client, "music/mob/mallgermm2b.wav");
				KillMusic(client, "music/mob/mallgerms1a.wav");
				KillMusic(client, "music/mob/mallgerms1b.wav");
				KillMusic(client, "music/mob/mallgerms2a.wav");
				KillMusic(client, "music/mob/mallgerms2b.wav");
				KillMusic(client, "music/mob/milltowngerml1a.wav");
				KillMusic(client, "music/mob/milltowngerml1b.wav");
				KillMusic(client, "music/mob/milltowngerml1c.wav");
				KillMusic(client, "music/mob/milltowngerml2a.wav");
				KillMusic(client, "music/mob/milltowngerml2b.wav");
				KillMusic(client, "music/mob/milltowngerml2c.wav");
				KillMusic(client, "music/mob/milltowngermm1a.wav");
				KillMusic(client, "music/mob/milltowngermm1b.wav");
				KillMusic(client, "music/mob/milltowngermm1d.wav");
				KillMusic(client, "music/mob/milltowngermm2a.wav");
				KillMusic(client, "music/mob/milltowngermm2b.wav");
				KillMusic(client, "music/mob/milltowngermm2c.wav");
				KillMusic(client, "music/mob/milltowngermx1a.wav");
				KillMusic(client, "music/mob/milltowngermx1b.wav");
				KillMusic(client, "music/mob/milltowngermx1c.wav");
				KillMusic(client, "music/mob/milltowngermx2a.wav");
				KillMusic(client, "music/mob/milltowngermx2b.wav");
				KillMusic(client, "music/mob/parishtmptgerml1a.wav");
				KillMusic(client, "music/mob/parishtmptgerml1b.wav");
				KillMusic(client, "music/mob/parishtmptgerml2a.wav");
				KillMusic(client, "music/mob/parishtmptgerml2b.wav");
				KillMusic(client, "music/mob/parishtmptgermm1a.wav");
				KillMusic(client, "music/mob/parishtmptgermm1b.wav");
				KillMusic(client, "music/mob/parishtmptgermm2a.wav");
				KillMusic(client, "music/mob/parishtmptgermm2b.wav");
				KillMusic(client, "music/mob/parishtmptgermm2c.wav");
				KillMusic(client, "music/mob/parishtmptgermm2d.wav");
				KillMusic(client, "music/mob/parishtmptgermx1a.wav");
				KillMusic(client, "music/mob/parishtmptgermx1b.wav");
				KillMusic(client, "music/mob/parishtmptgermx1c.wav");
				KillMusic(client, "music/mob/parishtmptgermx1d.wav");
				KillMusic(client, "music/mob/parishtmptgermx2a.wav");
				KillMusic(client, "music/mob/parishtmptgermx2b.wav");
				KillMusic(client, "music/mob/parishtmptgermx2c.wav");
				KillMusic(client, "music/mob/plankgerml1a.wav");
				KillMusic(client, "music/mob/plankgerml1b.wav");
				KillMusic(client, "music/mob/plankgerml2a.wav");
				KillMusic(client, "music/mob/plankgerml2b.wav");
				KillMusic(client, "music/mob/plankgerms1a.wav");
				KillMusic(client, "music/mob/plankgerms1b.wav");
				KillMusic(client, "music/mob/plankgerms2a.wav");
				KillMusic(client, "music/mob/plankgerms2b.wav");
				KillMusic(client, "music/mob/plankgermx1a.wav");
				KillMusic(client, "music/mob/plankgermx1b.wav");
				KillMusic(client, "music/mob/plankgermx2a.wav");
				KillMusic(client, "music/mob/plankgermx2b.wav");
				KillMusic(client, "music/zombat/gatesofhell.wav");
				KillMusic(client, "music/zombat/not_a_laughing_matter.wav");
				KillMusic(client, "music/zombat/snare_horde_01_01a.wav");
				KillMusic(client, "music/zombat/snare_horde_01_01b.wav");
				KillMusic(client, "music/zombat/danger/hordedanger_01.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_01a_01.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_01a_02.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_01a_03.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_01a_04.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_01a_05.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_01a_06.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_01b_01.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_01b_03.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_01a_04.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_01.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_02.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_03.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_04.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_05.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_06.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_07.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_08.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_09.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_10.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_11.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_12.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_13.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_14.wav");
				KillMusic(client, "music/zombat/danger/banjo/banjo_02_15.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_01.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_02.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_03.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_04.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_05.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_06.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_07.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_08.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_09.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_10.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_11.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_12.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_13.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_14.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_15.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_16.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_17.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_18.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_19.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_20.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_21.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_22.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_23.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_24.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_25.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_26.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_27.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_28.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_29.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_30.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_31.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_32.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_33.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_34.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_35.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_36.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_37.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_38.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_39.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_40.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_41.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_42.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_43.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_44.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_45.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_46.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_47.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_48.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_49.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_50.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_51.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_52wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_53.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_54.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_55.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_56.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_57.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_58.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_59.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_60.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_61.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_62.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_63.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_64.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_65.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_66.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_67.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_68.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_69.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_70.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_71.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_72.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_73.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_74.wav");
				KillMusic(client, "music/zombat/danger/deviddle/deviddle_75.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_01.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_02.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_03.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_04.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_05.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_06.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_07.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_08.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_09.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_10.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_11.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_12.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_13.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_14.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_15.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_16.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_17.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_18.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_19.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_20.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_04_21.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_01.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_02.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_03.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_04.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_05.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_06.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_07.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_08.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_09.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_10.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_11.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_12.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_13.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_14.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_15.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_16.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_17.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_18.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_19.wav");
				KillMusic(client, "music/zombat/danger/dobro/dobro_danger_02_20.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_01.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_02.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_03.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_04.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_05.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_06.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_07.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_08.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_09.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_10.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_11.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_12.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_13.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_14.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_15.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_16.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_17.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_18.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_19.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_20.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_21.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_22.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_23.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_24.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_25.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_26.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_27.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_28.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_29.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_30.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_31.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_32.wav");
				KillMusic(client, "music/zombat/danger/saw/saw_danger_02_33.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_01.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_02.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_03.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_04.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_05.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_06.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_07.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_08.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_09.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_10.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_11.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_12.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_13.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_14.wav");
				KillMusic(client, "music/zombat/danger/trumpet/trumpet_danger_02_15.wav");
				KillMusic(client, "music/zombat/horde/drums01b.wav");
				KillMusic(client, "music/zombat/horde/drums01c.wav");
				KillMusic(client, "music/zombat/horde/drums01d.wav");
				KillMusic(client, "music/zombat/horde/drums02c.wav");
				KillMusic(client, "music/zombat/horde/drums02d.wav");
				KillMusic(client, "music/zombat/horde/drums03a.wav");
				KillMusic(client, "music/zombat/horde/drums03b.wav");
				KillMusic(client, "music/zombat/horde/drums3c.wav");
				KillMusic(client, "music/zombat/horde/drums3d.wav");
				KillMusic(client, "music/zombat/horde/drums3f.wav");
				KillMusic(client, "music/zombat/horde/drums5b.wav");
				KillMusic(client, "music/zombat/horde/drums5c.wav");
				KillMusic(client, "music/zombat/horde/drums5d.wav");
				KillMusic(client, "music/zombat/horde/drums5e.wav");
				KillMusic(client, "music/zombat/horde/drums7a.wav");
				KillMusic(client, "music/zombat/horde/drums7b.wav");
				KillMusic(client, "music/zombat/horde/drums7c.wav");
				KillMusic(client, "music/zombat/horde/drums08a.wav");
				KillMusic(client, "music/zombat/horde/drums08b.wav");
				KillMusic(client, "music/zombat/horde/drums08e.wav");
				KillMusic(client, "music/zombat/horde/drums08f.wav");
				KillMusic(client, "music/zombat/horde/drums8b.wav");
				KillMusic(client, "music/zombat/horde/drums8c.wav");
				KillMusic(client, "music/zombat/horde/drums09c.wav");
				KillMusic(client, "music/zombat/horde/drums09d.wav");
				KillMusic(client, "music/zombat/horde/drums10b.wav");
				KillMusic(client, "music/zombat/horde/drums10c.wav");
				KillMusic(client, "music/zombat/horde/drums11c.wav");
				KillMusic(client, "music/zombat/horde/drums11d.wav");
				KillMusic(client, "music/zombat/slayer/fiddle/violin_slayer_01_01a.wav");
				KillMusic(client, "music/zombat/slayer/fiddle/violin_slayer_01_01b.wav");
				KillMusic(client, "music/zombat/slayer/fiddle/violin_slayer_01_01c.wav");
				KillMusic(client, "music/zombat/slayer/fiddle/violin_slayer_01_01d.wav");
				KillMusic(client, "music/zombat/slayer/fiddle/violin_slayer_02_01a.wav");
				KillMusic(client, "music/zombat/slayer/fiddle/violin_slayer_02_01b.wav");
				KillMusic(client, "music/zombat/slayer/fiddle/violin_slayer_02_01c.wav");
				KillMusic(client, "music/zombat/slayer/fiddle/violin_slayer_02_01d.wav");
				KillMusic(client, "music/zombat/slayer/fiddle/violin_slayer_02_01e.wav");
				KillMusic(client, "music/zombat/slayer/lectric/slayer_01a.wav");
			}

			if(iTempClientFlags == 1) // ambient
			{
				iTempClientFlags = iTempClientFlags - 1;
				KillMusic(client, "music/contagion/c1rabies_01.wav");
				KillMusic(client, "music/contagion/c1rabies_02.wav");
				KillMusic(client, "music/contagion/c1rabies_03.wav");
				KillMusic(client, "music/contagion/c1rabies_04.wav");
				KillMusic(client, "music/contagion/c1rabies_05.wav");
				KillMusic(client, "music/contagion/c1rabies_06.wav");
				KillMusic(client, "music/contagion/c1rabies_07.wav");
				KillMusic(client, "music/contagion/c1rabies_08.wav");
				KillMusic(client, "music/contagion/c1rabies_09.wav");
				KillMusic(client, "music/contagion/c1rabies_10.wav");
				KillMusic(client, "music/contagion/c1rabies_11.wav");
				KillMusic(client, "music/contagion/c1rabies_12.wav");
				KillMusic(client, "music/contagion/c1rabies_13.wav");
				KillMusic(client, "music/contagion/c1rabies_14.wav");
				KillMusic(client, "music/contagion/c2rabies_01.wav");
				KillMusic(client, "music/contagion/c2rabies_02.wav");
				KillMusic(client, "music/contagion/c2rabies_03.wav");
				KillMusic(client, "music/contagion/c2rabies_04.wav");
				KillMusic(client, "music/contagion/c2rabies_05.wav");
				KillMusic(client, "music/contagion/c2rabies_06.wav");
				KillMusic(client, "music/contagion/c2rabies_07.wav");
				KillMusic(client, "music/contagion/c2rabies_08.wav");
				KillMusic(client, "music/contagion/c2rabies_09.wav");
				KillMusic(client, "music/contagion/c2rabies_10.wav");
				KillMusic(client, "music/contagion/c3rabies_01.wav");
				KillMusic(client, "music/contagion/c3rabies_02.wav");
				KillMusic(client, "music/contagion/c3rabies_03.wav");
				KillMusic(client, "music/contagion/c3rabies_04.wav");
				KillMusic(client, "music/contagion/c3rabies_05.wav");
				KillMusic(client, "music/contagion/c3rabies_06.wav");
				KillMusic(client, "music/contagion/c3rabies_07.wav");
				KillMusic(client, "music/contagion/c3rabies_08.wav");
				KillMusic(client, "music/contagion/c3rabies_09.wav");
				KillMusic(client, "music/contagion/c3rabies_10.wav");
				KillMusic(client, "music/contagion/c4rabies_01.wav");
				KillMusic(client, "music/contagion/c4rabies_02.wav");
				KillMusic(client, "music/contagion/c4rabies_03.wav");
				KillMusic(client, "music/contagion/c4rabies_04.wav");
				KillMusic(client, "music/contagion/c4rabies_05.wav");
				KillMusic(client, "music/contagion/c4rabies_06.wav");
				KillMusic(client, "music/contagion/c4rabies_07.wav");
				KillMusic(client, "music/contagion/c4rabies_08.wav");
				KillMusic(client, "music/contagion/c4rabies_09.wav");
				KillMusic(client, "music/contagion/c4rabies_10.wav");
				KillMusic(client, "music/contagion/c4rabies_11.wav");
				KillMusic(client, "music/contagion/c4rabies_12.wav");
				KillMusic(client, "music/contagion/c4rabies_13.wav");
				KillMusic(client, "music/contagion/c4rabies_14.wav");
				KillMusic(client, "music/contagion/c4rabies_15.wav");
				KillMusic(client, "music/contagion/c5rabies_01.wav");
				KillMusic(client, "music/contagion/c5rabies_02.wav");
				KillMusic(client, "music/contagion/c5rabies_03.wav");
				KillMusic(client, "music/contagion/c5rabies_04.wav");
				KillMusic(client, "music/contagion/c5rabies_05.wav");
				KillMusic(client, "music/contagion/c5rabies_06.wav");
				KillMusic(client, "music/contagion/c5rabies_07.wav");
				KillMusic(client, "music/contagion/c5rabies_08.wav");
				KillMusic(client, "music/contagion/c5rabies_09.wav");
				KillMusic(client, "music/contagion/c5rabies_10.wav");
				KillMusic(client, "music/contagion/c5rabies_11.wav");
				KillMusic(client, "music/contagion/c5rabies_12.wav");
				KillMusic(client, "music/contagion/c5rabies_13.wav");
				KillMusic(client, "music/contagion/c5rabies_14.wav");
				KillMusic(client, "music/contagion/c5rabies_15.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_01.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_02.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_03.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_04.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_05.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_06.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_07.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_08.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_09.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_10.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_11.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_12.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_13.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_14.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_15.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_16.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_17.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_18.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_19.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_20.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_21.wav");
				KillMusic(client, "music/contagion/l4d2_rabies_22.wav");
				KillMusic(client, "music/contagion/quarantine_01.wav");
				KillMusic(client, "music/contagion/quarantine_02.wav");
				KillMusic(client, "music/contagion/quarantine_03.wav");
				KillMusic(client, "music/zombiechoir/zombiechoir_01.wav");
				KillMusic(client, "music/zombiechoir/zombiechoir_02.wav");
				KillMusic(client, "music/zombiechoir/zombiechoir_03.wav");
				KillMusic(client, "music/zombiechoir/zombiechoir_04.wav");
				KillMusic(client, "music/zombiechoir/zombiechoir_05.wav");
				KillMusic(client, "music/zombiechoir/zombiechoir_06.wav");
				KillMusic(client, "music/zombiechoir/zombiechoir_07.wav");
				KillMusic(client, "music/l4d2/l4d2_c1.wav");
				KillMusic(client, "music/l4d2/l4d2_c1_mono.wav");
				KillMusic(client, "music/l4d2/l4d2_c1_pc.wav");
				KillMusic(client, "music/l4d2/l4d2_c2.wav");
				KillMusic(client, "music/l4d2/l4d2_c2_mono.wav");
				KillMusic(client, "music/l4d2/l4d2_c2_pc.wav");
				KillMusic(client, "music/l4d2/l4d2_c3.wav");
				KillMusic(client, "music/l4d2/l4d2_c3_mono.wav");
				KillMusic(client, "music/l4d2/l4d2_c3_pc.wav");
				KillMusic(client, "music/l4d2/l4d2_c4.wav");
				KillMusic(client, "music/l4d2/l4d2_c4_mono.wav");
				KillMusic(client, "music/l4d2/l4d2_c4_pc.wav");
				KillMusic(client, "music/l4d2/l4d2_c5.wav");
				KillMusic(client, "music/l4d2/l4d2_c5_mono.wav");
				KillMusic(client, "music/l4d2/l4d2_c5_pc.wav");
				KillMusic(client, "music/stmusic/deadeasy.wav");
				KillMusic(client, "music/stmusic/deathisacarousel.wav");
				KillMusic(client, "music/stmusic/diedonthebayou.wav");
				KillMusic(client, "music/stmusic/nohopeinhell.wav");
				KillMusic(client, "music/stmusic/osweetdeath.wav");
				KillMusic(client, "music/stmusic/southofhuman.wav");
				KillMusic(client, "music/stmusic/youhadbetterpray.wav");
				KillMusic(client, "music/glimpse/aglimpseofdeath_01.wav");
				KillMusic(client, "music/glimpse/aglimpseofdeath_02.wav");
				KillMusic(client, "music/glimpse/aglimpseofdeath_03.wav");
				KillMusic(client, "music/cpmusic/bloodharvestor.wav");
				KillMusic(client, "music/cpmusic/bloodharvestor2.wav");
				KillMusic(client, "music/cpmusic/deadairtime.wav");
				KillMusic(client, "music/cpmusic/deadairtime2.wav");
				KillMusic(client, "music/cpmusic/deathtollcollector.wav");
				KillMusic(client, "music/cpmusic/deathtollcollector2.wav");
				KillMusic(client, "music/cpmusic/nomercyforyou.wav");
				KillMusic(client, "music/cpmusic/nomercyforyou2.wav");
				KillMusic(client, "music/cpmusic/prayfordeath.wav");	
			}
		}
	}
}

public KillMusic(client, String:file[])
{
	StopSound(client, SNDCHAN_AUTO, file);
}

/*

10:48 PM - ProdigySim: functag public Action:NormalSHook(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags);

Usage:

 clientsArray of client indexes.
 numClientsNumber of clients in the array (modify this value if you add/remove elements from the client array).
 sampleSound file name relative to the "sounds" folder.
 entityEntity emitting the sound.
 channelChannel emitting the sound.
 volumeSound volume.
 levelSound level.
 pitchSound pitch.
 flagsSound flags.
10:48 PM - ProdigySim: you can hook sounds
10:49 PM - ProdigySim: and then modify the clients array
10:49 PM - ProdigySim: to have it not sent to certain players
10:49 PM - ProdigySim: and then you'd just look up the sound name in a trie


*/
