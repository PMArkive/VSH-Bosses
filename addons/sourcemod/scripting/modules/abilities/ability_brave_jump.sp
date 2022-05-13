static float g_JumpCooldownWait[TF_MAXPLAYERS];
static bool g_HoldingChargeButton[TF_MAXPLAYERS];

public void BraveJump_Create(SaxtonHaleBase boss)
{
	g_JumpCooldownWait[boss.iClient] = 0.0;
	//Default values, these can be changed if needed
	boss.SetPropInt  ("BraveJump", "JumpCharge", 0);
	boss.SetPropInt  ("BraveJump", "MaxJumpCharge", 200);
	boss.SetPropInt  ("BraveJump", "JumpChargeBuild", 4);
	boss.SetPropFloat("BraveJump", "MaxHeight", 1100.0);
	boss.SetPropFloat("BraveJump", "MaxDistance", 0.45);
	boss.SetPropFloat("BraveJump", "Cooldown", 7.0);
	boss.SetPropFloat("BraveJump", "MinCooldown", 5.5);
	boss.SetPropFloat("BraveJump", "EyeAngleRequirement", -25.0); //Min -89.0 (all the way up)
}

public void BraveJump_OnThink(SaxtonHaleBase boss)
{
	if (GameRules_GetRoundState() == RoundState_Preround)
		return;
	
	int client = boss.iClient;
	if (g_JumpCooldownWait[client] == 0.0) //Round started, start cooldown
	{
		float cooldown = boss.GetPropFloat("BraveJump", "Cooldown");
		g_JumpCooldownWait[client] = GetGameTime()+cooldown;
		boss.CallFunction("UpdateHudInfo", 1.0, cooldown); //Update every second for cooldown duration
	}
	
	int jumpcharge      = boss.GetPropInt("BraveJump", "JumpCharge");
	int jumpchargebuild = boss.GetPropInt("BraveJump", "JumpChargeBuild");
	int maxjumpcharge   = boss.GetPropInt("BraveJump", "MaxJumpCharge");
	int newjumpcharge;
	
	if (g_JumpCooldownWait[client] <= GetGameTime()
		&& g_HoldingChargeButton[client])
		newjumpcharge = jumpcharge + jumpchargebuild;
	else
		newjumpcharge = jumpcharge - jumpchargebuild * 2;
	
	if (newjumpcharge > maxjumpcharge)
		newjumpcharge = maxjumpcharge;
	else if (newjumpcharge < 0)
		newjumpcharge = 0;
	
	if (jumpcharge != newjumpcharge)
	{
		boss.SetPropInt("BraveJump", "JumpCharge", newjumpcharge);
		boss.CallFunction("UpdateHudInfo", 0.0, 0.0); //Update once
	}
}

public void BraveJump_GetHudInfo(SaxtonHaleBase boss, char[] message, int length, int color[4])
{
	int client = boss.iClient;
	if (g_JumpCooldownWait[client] != 0.0 && g_JumpCooldownWait[client] > GetGameTime())
	{
		int sec = RoundToCeil(g_JumpCooldownWait[client]-GetGameTime());
		Format(message, length, "%s\nSuper-jump cooldown %i second%s remaining!", message, sec, (sec > 1) ? "s" : "");
	}
	else if (boss.GetPropInt("BraveJump", "JumpCharge") > 0)
	{
		int jumpcharge = boss.GetPropInt("BraveJump", "JumpCharge");
		int maxjumpcharge = boss.GetPropInt("BraveJump", "MaxJumpCharge");
		Format(message, length, "%s\nJump charge: %0.2f%%. Look up and stand up to use super-jump.", message, (float(jumpcharge)/float(maxjumpcharge))*100.0);
	}
	else
	{
		Format(message, length, "%s\nHold right click to use your super-jump!", message);
	}
}

public void BraveJump_OnButton(SaxtonHaleBase boss, int &buttons)
{
	if (buttons & IN_ATTACK2)
		g_HoldingChargeButton[boss.iClient] = true;
}

public void BraveJump_OnButtonRelease(SaxtonHaleBase boss, int button)
{
	if (button == IN_ATTACK2)
	{
		int client = boss.iClient;
		if (TF2_IsPlayerInCondition(client, TFCond_Dazed)) //Can't jump if stunned
			return;
		
		g_HoldingChargeButton[client] = false;
		if (g_JumpCooldownWait[client] != 0.0 && g_JumpCooldownWait[client] > GetGameTime())
			return;
		
		float angles[3]; GetClientEyeAngles(client, angles);
		int jumpcharge = boss.GetPropInt("BraveJump", "JumpCharge");

		if ((angles[0] <= boss.GetPropFloat("BraveJump", "EyeAngleRequirement")) && (jumpcharge > 1))
		{
			int maxjumpcharge = boss.GetPropInt("BraveJump", "MaxJumpCharge");
			float maxdistance = boss.GetPropFloat("BraveJump", "MaxDistance");
			float maxheight   = boss.GetPropFloat("BraveJump", "MaxHeight");
			float cooldown    = boss.GetPropFloat("BraveJump", "Cooldown");
			float mincooldown = boss.GetPropFloat("BraveJump", "MinCooldown");
			
			float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
			vel[0] *= (1.0+Sine((float(jumpcharge)/float(maxjumpcharge)) * FLOAT_PI * maxdistance));
			vel[1] *= (1.0+Sine((float(jumpcharge)/float(maxjumpcharge)) * FLOAT_PI * maxdistance));
			vel[2] = maxheight*((float(jumpcharge)/float(maxjumpcharge)));
			
			SetEntProp(client, Prop_Send, "m_bJumping", true);
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
			
			float cooldown_time = (cooldown*(float(jumpcharge)/float(maxjumpcharge)));
			if (cooldown_time < mincooldown)
				cooldown_time = mincooldown;
			
			g_JumpCooldownWait[client] = GetGameTime()+cooldown_time;
			boss.CallFunction("UpdateHudInfo", 1.0, cooldown); //Update every second for cooldown duration

			boss.SetPropInt("BraveJump", "JumpCharge", 0);

			char sound[PLATFORM_MAX_PATH]; boss.CallFunction("GetSoundAbility", sound, sizeof(sound), "BraveJump");
			if (!StrEmpty(sound))
				EmitSoundToAll(sound, client, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
		}
	}
}