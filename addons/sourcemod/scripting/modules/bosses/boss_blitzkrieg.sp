#define BLITZKRIEG_MODEL "models/freak_fortress_2/shadow93/dmedic/d_medic.mdl"
#define BLITZKRIEG_THEME "vsh_rewrite/brutalsniper/brutalsniper_music.mp3"
#define BLITZKRIEG_MAXWEAPONS 4

#define ROCKET_LAUNCHER 18
#define DIRECT_HIT      127
#define BLACK_BOX       228
#define ORIGINAL        513

static int g_iBlitzkriegWeaponCooldown[TF_MAXPLAYERS][BLITZKRIEG_MAXWEAPONS];

static char g_strBrutalSniperRoundStart[][] = {
	"vo/sniper_specialweapon08.mp3"
};

static char g_strBrutalSniperWin[][] = {
	"vo/sniper_award09.mp3",
	"vo/sniper_award12.mp3"
};

static char g_strBrutalSniperLose[][] = {
	"vo/sniper_autodejectedtie02.mp3",
	"vo/sniper_jeers01.mp3"
};

static char g_strBrutalSniperRage[][] = {
	"vo/sniper_battlecry03.mp3"
};

static char g_strBrutalSniperJump[][] = {
	"vo/sniper_jaratetoss01.mp3",
	"vo/sniper_jaratetoss02.mp3",
	"vo/sniper_specialcompleted11.mp3",
	"vo/sniper_specialcompleted19.mp3"
};

static char g_strBrutalSniperKill[][] = {
	"vo/sniper_award01.mp3",
	"vo/sniper_award02.mp3",
	"vo/sniper_award03.mp3",
	"vo/sniper_award05.mp3",
	"vo/sniper_award07.mp3",
	"vo/sniper_positivevocalization03.mp3",
	"vo/sniper_specialcompleted04.mp3",
	"vo/taunts/sniper_taunts02.mp3"
};

static char g_strBrutalSniperKillPrimary[][] = {
	"vo/sniper_niceshot01.mp3",
	"vo/sniper_niceshot02.mp3",
	"vo/sniper_niceshot03.mp3"
};

static char g_strBrutalSniperKillMelee[][] = {
	"vo/sniper_meleedare01.mp3",
	"vo/sniper_meleedare02.mp3",
	"vo/sniper_meleedare05.mp3",
	"vo/sniper_meleedare07.mp3"
};

static char g_strBrutalSniperLastMan[][] = {
	"vo/sniper_award11.mp3",
	"vo/sniper_domination02.mp3",
	"vo/sniper_domination03.mp3",
	"vo/sniper_domination18.mp3"
};

static char g_strBrutalSniperBackStabbed[][] = {
	"vo/sniper_jeers03.mp3",
	"vo/sniper_jeers05.mp3",
	"vo/sniper_jeers08.mp3",
	"vo/sniper_negativevocalization02.mp3"
};

public void Blitzkrieg_Create(SaxtonHaleBase boss)
{
	boss.CreateClass("BraveJump");
	boss.CreateClass("ScareRage");
	boss.SetPropFloat("ScareRage", "Radius", 200.0);
	boss.iHealthPerPlayer    = 600;
	boss.flHealthExponential = 1.05;
	boss.nClass              = TFClass_Medic;
	boss.iMaxRageDamage      = 2500;
}

public void Blitzkrieg_GetBossName(SaxtonHaleBase boss, char[] name, int length)
{
	strcopy(name, length, "Blitzkrieg");
}

public void Blitzkrieg_GetBossInfo(SaxtonHaleBase boss, char[] info, int length)
{
	StrCat(info, length, "\nHealth: High");
	StrCat(info, length, "\n ");
	StrCat(info, length, "\nAbilities");
	StrCat(info, length, "\n- Brave Jump");
	StrCat(info, length, "\n ");
	StrCat(info, length, "\nRage");
	StrCat(info, length, "\n- Unknown");
}

public void Blitzkrieg_OnSpawn(SaxtonHaleBase boss)
{
	int client = boss.iClient;
	int weapon;
	char attribs[128];

	g_iBlitzkriegWeaponCooldown[client][0] = BLITZKRIEG_MAXWEAPONS - 2;
	Format(attribs, sizeof(attribs), "2 ; 2.1 ; 6 ; 0.01 ; 551 ; 1.0");
	weapon = boss.CallFunction("CreateWeapon", ROCKET_LAUNCHER, "tf_weapon_rocketlauncher", 100, TFQual_Collectors, attribs);
	if (IsValidEntity(weapon))
	{
		int iAmmo = GetEntProp(client, Prop_Send, "m_iAmmo", _, 1);
		iAmmo += 500;
		SetEntProp(client, Prop_Send, "m_iAmmo", iAmmo, _, 1);
		SetEntProp(weapon, Prop_Send, "m_iClip1", 500);
	}

	Format(attribs, sizeof(attribs), "2 ; 2.80 ; 252 ; 0.5 ; 259 ; 1.0");
	weapon = boss.CallFunction("CreateWeapon", 37, "tf_weapon_bonesaw", 100, TFQual_Collectors, "");
	if (weapon > MaxClients)
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);

	//weapon = boss.CallFunction("CreateWeapon", 1101, "tf_weapon_parachute", 100, TFQual_Collectors, "");
	//weapon = boss.CallFunction("CreateWeapon", 37, "tf_weapon_bonesaw", 100, TFQual_Collectors, "");
	//if (weapon > MaxClients)
	//SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
}

public void Blitzkrieg_OnPlayerKilled(SaxtonHaleBase boss, Event event, int victim)
{
	int client = boss.iClient;

	char weapon[64]; event.GetString("weapon", weapon, sizeof(weapon));
	if (StrContains(weapon, "tf_weapon_rocketlauncher", false) != -1)
	{
		if (SaxtonHale_IsValidAttack(victim))
		{
			TF2_RemoveItemInSlot(client, WeaponSlot_Primary);

			int random = -1;
			int index;

			while (random == -1)
			{
				random = GetRandomInt(0, (BLITZKRIEG_MAXWEAPONS - 1));
				if (g_iBlitzkriegWeaponCooldown[client][random] == 0)
					g_iBlitzkriegWeaponCooldown[client][random] = BLITZKRIEG_MAXWEAPONS - 1;
				else
					random = -1;
			}

			for (int i = 0; i < BLITZKRIEG_MAXWEAPONS; i++)
				if (g_iBlitzkriegWeaponCooldown[client][i] > 0)
					g_iBlitzkriegWeaponCooldown[client][i]--;
				
			char attributes[128];
			Format(attributes, sizeof(attributes), "");
			switch (random)
			{
				case 0: index = ROCKET_LAUNCHER;
				case 1: index = DIRECT_HIT;
				case 2: index = BLACK_BOX;
				case 3: index = ORIGINAL;
			}

			if (index <= 0)
				return;
			
			int launcher = boss.CallFunction("CreateWeapon", index, "tf_weapon_rocketlauncher", 100, TFQual_Unusual, attributes);
			if (launcher > MaxClients)
			{
				int activeweapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if (!(IsValidEntity(activeweapon)))
				{
					SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, 500);
					SetEntProp(launcher, Prop_Send, "m_iClip1", 500);
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", launcher);
				}
			}
		}
	}
}

public void Blitzkrieg_OnRage(SaxtonHaleBase boss)
{
	int client = boss.iClient;
	TF2_AddCondition(client, TFCond_CritOnDamage, 1.05);
}

public void Blitzkrieg_GetModel(SaxtonHaleBase boss, char[] sModel, int length)
{
	strcopy(sModel, length, BLITZKRIEG_MODEL);
}

public void Blitzkrieg_GetSound(SaxtonHaleBase boss, char[] sSound, int length, SaxtonHaleSound iSoundType)
{
	switch (iSoundType)
	{
		case VSHSound_RoundStart: strcopy(sSound, length, g_strBrutalSniperRoundStart[GetRandomInt(0,sizeof(g_strBrutalSniperRoundStart)-1)]);
		case VSHSound_Win: strcopy(sSound, length, g_strBrutalSniperWin[GetRandomInt(0,sizeof(g_strBrutalSniperWin)-1)]);
		case VSHSound_Lose: strcopy(sSound, length, g_strBrutalSniperLose[GetRandomInt(0,sizeof(g_strBrutalSniperLose)-1)]);
		case VSHSound_Rage: strcopy(sSound, length, g_strBrutalSniperRage[GetRandomInt(0,sizeof(g_strBrutalSniperRage)-1)]);
		case VSHSound_Lastman: strcopy(sSound, length, g_strBrutalSniperLastMan[GetRandomInt(0,sizeof(g_strBrutalSniperLastMan)-1)]);
		case VSHSound_Backstab: strcopy(sSound, length, g_strBrutalSniperBackStabbed[GetRandomInt(0,sizeof(g_strBrutalSniperBackStabbed)-1)]);
	}
}

public void Blitzkrieg_GetSoundAbility(SaxtonHaleBase boss, char[] sSound, int length, const char[] sType)
{
	if (strcmp(sType, "BraveJump") == 0)
		strcopy(sSound, length, g_strBrutalSniperJump[GetRandomInt(0,sizeof(g_strBrutalSniperJump)-1)]);
}

public void Blitzkrieg_GetSoundKill(SaxtonHaleBase boss, char[] sSound, int length, TFClassType nClass)
{
	int iClient = boss.iClient;
	int iPrimary = GetPlayerWeaponSlot(iClient, WeaponSlot_Primary);
	int iMelee = GetPlayerWeaponSlot(iClient, WeaponSlot_Melee);
	int iActiveWep = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
	
	if (iActiveWep == iPrimary && GetRandomInt(0, 1))
		strcopy(sSound, length, g_strBrutalSniperKillPrimary[GetRandomInt(0,sizeof(g_strBrutalSniperKillPrimary)-1)]);
	else if (iActiveWep == iMelee && GetRandomInt(0, 3))
		strcopy(sSound, length, g_strBrutalSniperKillMelee[GetRandomInt(0,sizeof(g_strBrutalSniperKillMelee)-1)]);
	else
		strcopy(sSound, length, g_strBrutalSniperKill[GetRandomInt(0,sizeof(g_strBrutalSniperKill)-1)]);
}

public void Blitzkrieg_GetMusicInfo(SaxtonHaleBase boss, char[] sSound, int length, float &time)
{
	strcopy(sSound, length, BLITZKRIEG_THEME);
	time = 132.0;
}

public void Blitzkrieg_Precache(SaxtonHaleBase boss)
{
	PrecacheModel(BLITZKRIEG_MODEL);
	PrepareSound(BLITZKRIEG_THEME);
	
	for (int i = 0; i < sizeof(g_strBrutalSniperRoundStart); i++) PrecacheSound(g_strBrutalSniperRoundStart[i]);
	for (int i = 0; i < sizeof(g_strBrutalSniperWin); i++) PrecacheSound(g_strBrutalSniperWin[i]);
	for (int i = 0; i < sizeof(g_strBrutalSniperLose); i++) PrecacheSound(g_strBrutalSniperLose[i]);
	for (int i = 0; i < sizeof(g_strBrutalSniperRage); i++) PrecacheSound(g_strBrutalSniperRage[i]);
	for (int i = 0; i < sizeof(g_strBrutalSniperJump); i++) PrecacheSound(g_strBrutalSniperJump[i]);
	for (int i = 0; i < sizeof(g_strBrutalSniperKill); i++) PrecacheSound(g_strBrutalSniperKill[i]);
	for (int i = 0; i < sizeof(g_strBrutalSniperKillPrimary); i++) PrecacheSound(g_strBrutalSniperKillPrimary[i]);
	for (int i = 0; i < sizeof(g_strBrutalSniperKillMelee); i++) PrecacheSound(g_strBrutalSniperKillMelee[i]);
	for (int i = 0; i < sizeof(g_strBrutalSniperLastMan); i++) PrecacheSound(g_strBrutalSniperLastMan[i]);
	for (int i = 0; i < sizeof(g_strBrutalSniperBackStabbed); i++) PrecacheSound(g_strBrutalSniperBackStabbed[i]);
	
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/eyeball_invun.vmt");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/eyeball_l.vmt");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/eyeball_r.vmt");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/invulnfx_red.vmt");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/medic_backpack_red.vmt");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/medic_head_red_invun.vmt");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/medic_head_red.vmt");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/medic_head_red.vtf");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/medic_red_invun.vmt");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/medic_red.vmt");
	AddFileToDownloadsTable("materials/freak_fortress_2/shadow93/dmedic/medic_red.vtf");

	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic.dx80.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic.dx90.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic.mdl");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic.phy");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic.sw.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic.vvd");
	/*
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic2.dx80.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic2.dx90.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic2.mdl");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic2.phy");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic2.sw.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_medic2.vvd");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_soldier.dx80.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_soldier.dx90.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_soldier.mdl");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_soldier.phy");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_soldier.sw.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/d_soldier.vvd");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/rocket.dx80.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/rocket.dx90.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/rocket.mdl");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/rocket.sw.vtx");
	AddFileToDownloadsTable("models/freak_fortress_2/shadow93/dmedic/rocket.vvd");
	*/
}

public bool Blitzkrieg_IsBossHidden(SaxtonHaleBase boss)
{
	return true;
}
