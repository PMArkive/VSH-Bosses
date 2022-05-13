static float g_flDashJumpCooldownWait[TF_MAXPLAYERS];

public void DashJump_Create(SaxtonHaleBase boss)
{
	g_flDashJumpCooldownWait[boss.iClient] = 0.0;
	//Default values, these can be changed if needed
	boss.SetPropFloat("DashJump", "Cooldown", 4.0);
	boss.SetPropFloat("DashJump", "MaxCharge", 2.0);
	boss.SetPropFloat("DashJump", "MaxForce", 700.0);
}

public void DashJump_GetHudInfo(SaxtonHaleBase boss, char[] message, int length, int color[4])
{
	int client = boss.iClient;
	float cooldown = boss.GetPropFloat("DashJump", "Cooldown");
	float maxcharge = boss.GetPropFloat("DashJump", "MaxCharge");
	int charge;

	if (g_flDashJumpCooldownWait[client] < GetGameTime())
	{
		charge = RoundToFloor(maxcharge * 100.0);
	}
	else
	{
		float percentage = (g_flDashJumpCooldownWait[client]-GetGameTime())/cooldown;
		charge = RoundToFloor((maxcharge-percentage) * 100.0);
	}
	
	if (charge >= 100)
		Format(message, length, "%s\nDash charge: %d%%%%%%%% - Press reload to use your dash!", message, charge);
	else
		Format(message, length, "%s\nDash charge: %d%%%%", message, charge);
}

public void DashJump_OnButtonPress(SaxtonHaleBase boss, int button)
{
	if (button == IN_RELOAD && GameRules_GetRoundState() != RoundState_Preround)
	{
		int client = boss.iClient;
		if (TF2_IsPlayerInCondition(client, TFCond_Dazed)) //Can't jump if stunned
			return;

		if (g_flDashJumpCooldownWait[client] < GetGameTime())
			g_flDashJumpCooldownWait[client] = GetGameTime();
		
		float cooldown   = boss.GetPropFloat("DashJump", "Cooldown");
		float maxcharge  = boss.GetPropFloat("DashJump", "MaxCharge");
		float maxforce   = boss.GetPropFloat("DashJump", "MaxForce");

		float percentage = (g_flDashJumpCooldownWait[client]-GetGameTime())/cooldown;
		float charge = maxcharge-percentage;
		if (charge < 1.0)
			return;
		
		float ang[3], vel[3]; GetClientEyeAngles(client, ang);
		vel[0] = Cosine(DegToRad(ang[0])) * Cosine(DegToRad(ang[1])) * maxforce;
		vel[1] = Cosine(DegToRad(ang[0])) * Sine(DegToRad(ang[1])) * maxforce;
		vel[2] = (((-ang[0]) * 1.5) + 90.0) * 3.0;
		
		SetEntProp(client, Prop_Send, "m_bJumping", true);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

		g_flDashJumpCooldownWait[client] += cooldown;		
		boss.CallFunction("UpdateHudInfo", 0.0, cooldown*2); //Update every frame for cooldown * 2
		
		char sound[PLATFORM_MAX_PATH]; boss.CallFunction("GetSoundAbility", sound, sizeof(sound), "DashJump");
		if (!StrEmpty(sound))
			EmitSoundToAll(sound, client, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
	}
}