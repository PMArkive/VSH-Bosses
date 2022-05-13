#include "abilities/ability_body_eat.sp"
#include "abilities/ability_brave_jump.sp"
#include "abilities/ability_dash_jump.sp"
#include "abilities/ability_groundpound.sp"
#include "abilities/ability_rage_bomb.sp"
#include "abilities/ability_rage_bomb_projectile.sp"
#include "abilities/ability_rage_conditions.sp"
#include "abilities/ability_rage_freeze.sp"
#include "abilities/ability_rage_gas.sp"
#include "abilities/ability_rage_ghost.sp"
#include "abilities/ability_rage_light.sp"
#include "abilities/ability_rage_scare.sp"
#include "abilities/ability_teleport_swap.sp"
#include "abilities/ability_teleport_view.sp"
#include "abilities/ability_wallclimb.sp"
#include "abilities/ability_weapon_ball.sp"
#include "abilities/ability_weapon_charge.sp"
#include "abilities/ability_weapon_fists.sp"
#include "abilities/ability_weapon_spells.sp"

#include "bosses/boss_announcer.sp"
#include "bosses/boss_blitzkrieg.sp"
#include "bosses/boss_blutarch.sp"
#include "bosses/boss_bonkboy.sp"
#include "bosses/boss_brutalsniper.sp"
#include "bosses/boss_demopan.sp"
#include "bosses/boss_demorobot.sp"
#include "bosses/boss_hale.sp"
#include "bosses/boss_horsemann.sp"
#include "bosses/boss_merasmus.sp"
#include "bosses/boss_painiscupcakes.sp"
#include "bosses/boss_redmond.sp"
#include "bosses/boss_vagineer.sp"
#include "bosses/boss_yeti.sp"

/**
 * General Boss related functions.
 */

public Action Timer_EntityCleanup(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (ent > MaxClients)
		AcceptEntityInput(ent, "Kill");
	return Plugin_Handled;
}

public void ApplyBossModel(int client)
{
	SaxtonHaleBase boss = SaxtonHaleBase(client);
	if (!boss.bValid)
		return;
    
	char model[255];
	boss.CallFunction("GetModel", model, sizeof(model));
	SetVariantString(model);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", true);
}

public Action Timer_DestroyLight(Handle timer, int ref)
{
	int light = EntRefToEntIndex(ref);
	if (light > MaxClients)
	{
		AcceptEntityInput(light, "TurnOff");
		RequestFrame(Frame_KillLight, ref);
	}
	return Plugin_Continue;
}

void Frame_KillLight(int ref)
{
	int light = EntRefToEntIndex(ref);
	if (light > MaxClients)
		AcceptEntityInput(light, "Kill");
}