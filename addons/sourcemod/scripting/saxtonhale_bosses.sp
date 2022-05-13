#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <tf_econ_data>
#include <tf2attributes>
#include <saxtonhale>
#include <dhooks>
#include <updater>

#pragma newdecls required

#define PLUGIN_VERSION                "1.0.0"
#define UPDATE_URL                    "https://raw.githubusercontent.com/TheRefuge/VSH-Bosses/main/updater.txt"

#define TF_MAXPLAYERS                 34 // 32 clients + 1 for 0/world/console + 1 for replay/SourceTV
#define MAX_ATTRIBUTES_SENT           20
#define ATTRIB_MELEE_RANGE_MULTIPLIER 264

#define PARTICLE_GHOST                "ghost_appearation"

#define SOUND_ALERT                   "ui/system_message_alert.wav"
#define SOUND_BACKSTAB                "player/spy_shield_break.wav"
#define SOUND_NULL                    "vo/null.mp3"


public Plugin myinfo =
{
	name        = "TheRefuge VSH-Rewrite bosses subplugin",
	author      = "TheRefuge Community",
	description = "Open-Source bosses",
	version     = PLUGIN_VERSION,
	url         = "https://github.com/TheRefuge/VSH-Bosses"
};


#include "modules/header.sp"
#include "modules/sdk.sp"
#include "modules/stocks.sp"
#include "modules/bosses.sp"


public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "updater"))
		Updater_AddPlugin(UPDATE_URL);
	
	if (StrEqual(name, "saxtonhale"))
	{
		SaxtonHale_RegisterClass("Announcer",       VSHClassType_Boss);
		SaxtonHale_RegisterClass("Blitzkrieg",      VSHClassType_Boss);
		SaxtonHale_RegisterClass("Blutarch",        VSHClassType_Boss);
		SaxtonHale_RegisterClass("BonkBoy",         VSHClassType_Boss);
		SaxtonHale_RegisterClass("BrutalSniper",    VSHClassType_Boss);
		SaxtonHale_RegisterClass("DemoPan",         VSHClassType_Boss);
		SaxtonHale_RegisterClass("DemoRobot",       VSHClassType_Boss);
		SaxtonHale_RegisterClass("SaxtonHale",      VSHClassType_Boss);
		SaxtonHale_RegisterClass("Horsemann",       VSHClassType_Boss);
		SaxtonHale_RegisterClass("Merasmus",        VSHClassType_Boss);
		SaxtonHale_RegisterClass("PainisCupcake",   VSHClassType_Boss);
		SaxtonHale_RegisterClass("Redmond",         VSHClassType_Boss);
		SaxtonHale_RegisterClass("Vagineer",        VSHClassType_Boss);
		SaxtonHale_RegisterClass("Yeti",            VSHClassType_Boss);

		SaxtonHale_RegisterClass("AnnouncerMinion", VSHClassType_Boss);

		SaxtonHale_RegisterClass("BodyEat",         VSHClassType_Ability);
		SaxtonHale_RegisterClass("Bomb",            VSHClassType_Ability);
		SaxtonHale_RegisterClass("BombProjectile",  VSHClassType_Ability);
		SaxtonHale_RegisterClass("BraveJump",       VSHClassType_Ability);
		SaxtonHale_RegisterClass("DashJump",        VSHClassType_Ability);
		SaxtonHale_RegisterClass("GroundPound",     VSHClassType_Ability);
		SaxtonHale_RegisterClass("RageAddCond",     VSHClassType_Ability);
		SaxtonHale_RegisterClass("RageFreeze",      VSHClassType_Ability);
		SaxtonHale_RegisterClass("RageGas",         VSHClassType_Ability);
		SaxtonHale_RegisterClass("RageGhost",       VSHClassType_Ability);
		SaxtonHale_RegisterClass("LightRage",       VSHClassType_Ability);
		SaxtonHale_RegisterClass("ScareRage",       VSHClassType_Ability);
		SaxtonHale_RegisterClass("TeleportSwap",    VSHClassType_Ability);
		SaxtonHale_RegisterClass("TeleportView",    VSHClassType_Ability);
		SaxtonHale_RegisterClass("WallClimb",       VSHClassType_Ability);
		SaxtonHale_RegisterClass("WeaponBall",      VSHClassType_Ability);
		SaxtonHale_RegisterClass("WeaponCharge",    VSHClassType_Ability);
		SaxtonHale_RegisterClass("WeaponFists",     VSHClassType_Ability);
		SaxtonHale_RegisterClass("WeaponSpells",    VSHClassType_Ability);
	}
}

public void OnPluginStart()
{
	SDK_Init();
}

public void OnPluginEnd()
{
	for (int client=1; client <= MaxClients; client++)
	{
		if (SaxtonHale_IsValidBoss(client))
		{
			SaxtonHaleBase boss = SaxtonHaleBase(client);
			boss.DestroyAllClass();
		}
	}
}

public void OnMapStart()
{
	g_iSpritesLaserbeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_iSpritesGlow = PrecacheModel("materials/sprites/glow01.vmt", true);

	PrecacheSound(SOUND_ALERT);
	PrecacheSound(SOUND_BACKSTAB);
}

/**
 * Updater
 */
public void OnAllPluginsLoaded()
{
	if (LibraryExists("updater"))
		Updater_AddPlugin(UPDATE_URL);
}

public void Updater_OnPluginUpdated()
{
	char filename[64]; GetPluginFilename(null, filename, sizeof(filename));
	ServerCommand("sm plugins unload %s", filename);
	ServerCommand("sm plugins load %s", filename);
}