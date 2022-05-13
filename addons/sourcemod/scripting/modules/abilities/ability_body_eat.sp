#define BODY_CLASSNAME  "prop_ragdoll"
#define BODY_EAT        "vo/sandwicheat09.mp3"
#define BODY_ENTITY_MAX 6

static bool g_bBodyBlockRagdoll;
static ArrayList g_aBodyEntity;

public void BodyEat_Create(SaxtonHaleBase boss)
{
	//Default values, these can be changed if needed
	boss.SetPropInt  ("BodyEat", "MaxHeal", 500);
	boss.SetPropFloat("BodyEat", "MaxEatDistance", 100.0);
	boss.SetPropFloat("BodyEat", "EatRageRadius", 450.0);
	boss.SetPropFloat("BodyEat", "EatRageDuration", 10.0);
	
	//Create body arraylist if not already done yet
	if (g_aBodyEntity == null)
		g_aBodyEntity = new ArrayList();
}

public void BodyEat_OnPlayerKilled(SaxtonHaleBase boss, Event event, int victim)
{
	if (g_bBodyBlockRagdoll)
		return;
	
	if (!SaxtonHale_IsValidAttack(victim))
		return;
	
	g_bBodyBlockRagdoll = true;
	bool isfake = view_as<bool>(event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER);
	
	//Check how many bodies in map
	int length = g_aBodyEntity.Length;
	if (length > 0)
	{
		//We want to go from max to 0, due to erase shifting above down by one
		for (int i=length-1; i >= 0; i--)
		{
			int entity = EntRefToEntIndex(g_aBodyEntity.Get(i));
			//If invalid entity, remove in arraylist
			if (!IsValidEdict(entity))
				g_aBodyEntity.Erase(i);
		}
		
		//if arraylist is above max of allowed bodies in map, kill the oldest in list
		if (length >= BODY_ENTITY_MAX)
		{
			int entity = EntRefToEntIndex(g_aBodyEntity.Get(0));
			AcceptEntityInput(entity, "Kill");
			g_aBodyEntity.Erase(0);
		}
	}
	
	// Any players killed by a boss with this ability will see their client side ragdoll
	// removed and replaced with this server side ragdoll
	// Collect their damage and convert
	int maxheal = boss.GetPropInt("BodyEat", "MaxHeal");
	int heal = RoundToNearest(float(SaxtonHale_GetDamage(victim))*0.4) + 50;
	if (heal > maxheal)
		heal = maxheal;
	
	int color[4];
	color[0] = 255;
	color[1] = 255;
	color[2] = 0;
	color[3] = 255;

	float flheal = float(heal);
	float flmaxheal = float (maxheal);
	if (flheal <= flmaxheal/2.0)
	{
		float value = flheal/(flmaxheal/2.0);
		color[1] = RoundToNearest(float(color[1])*value);
	}
	else
	{
		float value = 1.0-((flheal-(flmaxheal/2.0))/(flmaxheal/2.0));
		color[0] = RoundToNearest(float(color[0])*value);
	}

	// Create Ragdoll
	int ragdoll = CreateEntityByName(BODY_CLASSNAME);
	SetEntProp(ragdoll, Prop_Data, "m_iMaxHealth", (isfake) ? 0 : heal);
	SetEntProp(ragdoll, Prop_Data, "m_iHealth", (isfake) ? 0 : heal);
	
	// Set Model
	char model[PLATFORM_MAX_PATH];
	GetEntPropString(victim, Prop_Data, "m_ModelName", model, sizeof(model));
	DispatchKeyValue(ragdoll, "model", model);
	
	// Teleport body to player
	float pos[3]; GetClientEyePosition(victim, pos);
	DispatchSpawn(ragdoll);
	TeleportEntity(ragdoll, pos, NULL_VECTOR, NULL_VECTOR);

	// Add body to arraylist
	g_aBodyEntity.Push(EntIndexToEntRef(ragdoll));

	// Create glow to body
	TF2_CreateEntityGlow(ragdoll, model, color);
	SetEntProp(ragdoll, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_DEBRIS_TRIGGER);
	SDK_AlwaysTransmitEntity(ragdoll);

	// Kill body from timer
	CreateTimer(30.0, Timer_EntityCleanup, EntIndexToEntRef(ragdoll));
}

public void BodyEat_EatBody(SaxtonHaleBase boss, int ent)
{
	if (0 < GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") <= MaxClients)
		return;
	
	int client = boss.iClient;
	
	float last_rage_time = boss.flRageLastTime;
	float eat_duration = boss.GetPropFloat("BodyEat", "EatRageDuration");
	if (boss.bSuperRage)
		eat_duration *= 2.0;
	
	if (last_rage_time == 0.0 || (GetGameTime()-last_rage_time) > eat_duration)
	{
		TF2_StunPlayer(client, 2.0, 1.0, 35);
		TF2_AddCondition(client, TFCond_DefenseBuffed, 2.0);
		EmitSoundToAll(BODY_EAT, client, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
	}
	
	int dissolve = CreateEntityByName("env_entity_dissolver");
	if (dissolve > 0)
	{
		char name[32]; Format(name, sizeof(name), "Ref_%d_Ent_%d", EntIndexToEntRef(ent), ent);
		DispatchKeyValue(ent, "targetname", name);
		DispatchKeyValue(dissolve, "target", name);
		DispatchKeyValue(dissolve, "dissolvetype", "2");
		DispatchKeyValue(dissolve, "magnitude", "15.0");
		AcceptEntityInput(dissolve, "Dissolve");
		AcceptEntityInput(dissolve, "Kill");
		Client_AddHealth(client, GetEntProp(ent, Prop_Data, "m_iHealth"), 0);
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	}
}

public void BodyEat_OnButton(SaxtonHaleBase boss, int &buttons)
{
	if (!(buttons & IN_RELOAD))
		return;
	
	int client = boss.iClient;

	float pos[3], ang[3], endpos[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	Handle hTrace = TR_TraceRayFilterEx(pos,
										ang,
										MASK_VISIBLE,
										RayType_Infinite,
										TraceRay_DontHitPlayersAndObjects);
	int entity = TR_GetEntityIndex(hTrace);
	TR_GetEndPosition(endpos, hTrace);
	delete hTrace;

	if (GetVectorDistance(endpos, pos) > boss.GetPropFloat("BodyEat", "MaxEatDistance"))
		return;

	char classname[32];
	if (entity > 0)
		GetEdictClassname(entity, classname, sizeof(classname));
	if (strcmp(classname, BODY_CLASSNAME) == 0)
		BodyEat_EatBody(boss, entity);
}

public void BodyEat_OnThink(SaxtonHaleBase boss)
{
	int client = boss.iClient;
	
	float last_rage_time = boss.flRageLastTime;
	float eat_duration = boss.GetPropFloat("BodyEat", "EatRageDuration");
	if (boss.bSuperRage)
		eat_duration *= 2.0;
	
	if (last_rage_time != 0.0 && ((GetGameTime()-last_rage_time) <= eat_duration))
	{
		float pos[3], bodypos[3];
		GetClientEyePosition(client, pos);

		int ent = MaxClients+1;
		while ((ent = FindEntityByClassname(ent, "prop_ragdoll")) > MaxClients)
		{
			GetEntPropVector(ent, Prop_Send, "m_ragPos", bodypos);
			if (GetVectorDistance(pos, bodypos) > boss.GetPropFloat("BodyEat", "EatRageRadius"))
				continue;
			
			BodyEat_EatBody(boss, ent);
		}
	}
}

public void BodyEat_GetHudInfo(SaxtonHaleBase boss, char[] sMessage, int iLength, int iColor[4])
{
	StrCat(sMessage, iLength, "\nAim at dead bodies and press reload to heal up!");
}

public void BodyEat_OnEntityCreated(SaxtonHaleBase boss, int iEntity, const char[] sClassname)
{
	if (g_bBodyBlockRagdoll && strcmp(sClassname, "tf_ragdoll") == 0)
	{
		AcceptEntityInput(iEntity, "Kill");
		g_bBodyBlockRagdoll = false;
	}
}

public void BodyEat_Precache(SaxtonHaleBase boss)
{
	PrecacheSound(BODY_EAT);
}
