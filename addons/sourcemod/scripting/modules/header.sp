enum
{
	COLLISION_GROUP_NONE  = 0,
	COLLISION_GROUP_DEBRIS,				// Collides with nothing but world and static stuff
	COLLISION_GROUP_DEBRIS_TRIGGER,		// Same as debris, but hits triggers
	COLLISION_GROUP_INTERACTIVE_DEBRIS,	// Collides with everything except other interactive debris or debris
	COLLISION_GROUP_INTERACTIVE,		// Collides with everything except interactive debris or debris
	COLLISION_GROUP_PLAYER,
	COLLISION_GROUP_BREAKABLE_GLASS,
	COLLISION_GROUP_VEHICLE,
	COLLISION_GROUP_PLAYER_MOVEMENT,    // For HL2, same as Collision_Group_Player, for
										// TF2, this filters out other players and CBaseObjects
	COLLISION_GROUP_NPC,				// Generic NPC group
	COLLISION_GROUP_IN_VEHICLE,			// for any entity inside a vehicle
	COLLISION_GROUP_WEAPON,				// for any weapons that need collision detection
	COLLISION_GROUP_VEHICLE_CLIP,		// vehicle clip brush to restrict vehicle movement
	COLLISION_GROUP_PROJECTILE,			// Projectiles!
	COLLISION_GROUP_DOOR_BLOCKER,		// Blocks entities not permitted to get near moving doors
	COLLISION_GROUP_PASSABLE_DOOR,		// Doors that the player shouldn't collide with
	COLLISION_GROUP_DISSOLVING,			// Things that are dissolving are in this group
	COLLISION_GROUP_PUSHAWAY,			// Nonsolid on client and server, pushaway in player code

	COLLISION_GROUP_NPC_ACTOR,			// Used so NPCs in scripts ignore the player.
	COLLISION_GROUP_NPC_SCRIPTED,		// USed for NPCs in scripts that should not collide with each other

	LAST_SHARED_COLLISION_GROUP
};

enum
{
	WeaponSlot_Primary = 0,
	WeaponSlot_Secondary,
	WeaponSlot_Melee,
	WeaponSlot_PDABuild,
	WeaponSlot_PDADisguise = 3,
	WeaponSlot_PDADestroy,
	WeaponSlot_InvisWatch = 4,
	WeaponSlot_BuilderEngie,
	WeaponSlot_Unknown1,
	WeaponSlot_Head,
	WeaponSlot_Misc1,
	WeaponSlot_Action,
	WeaponSlot_Misc2
};

enum
{
	LifeState_Alive = 0,
	LifeState_Dead = 2
};

enum // Settings for m_takedamage - from shareddefs.h
{
	DAMAGE_NO = 0,
	DAMAGE_EVENTS_ONLY,					// Call damage functions, but don't modify health
	DAMAGE_YES,
	DAMAGE_AIM,
};

enum // Entity effects
{
	EF_BONEMERGE			= (1<<0),	// Performs bone merge on client side
	EF_BRIGHTLIGHT			= (1<<1),	// DLIGHT centered at entity origin
	EF_DIMLIGHT				= (1<<2),	// player flashlight
	EF_NOINTERP				= (1<<3),	// don't interpolate the next frame
	EF_NOSHADOW				= (1<<4),	// Don't cast no shadow
	EF_NODRAW				= (1<<5),	// don't draw entity
	EF_NORECEIVESHADOW		= (1<<6),	// Don't receive no shadow
	EF_BONEMERGE_FASTCULL	= (1<<7),	// For use with EF_BONEMERGE. If this is set, then it places this ent's origin at its
										// parent and uses the parent's bbox + the max extents of the aiment.
										// Otherwise, it sets up the parent's bones every frame to figure out where to place
										// the aiment, which is inefficient because it'll setup the parent's bones even if
										// the parent is not in the PVS.
	EF_ITEM_BLINK			= (1<<8),	// blink an item so that the user notices it.
	EF_PARENT_ANIMATES		= (1<<9),	// always assume that the parent entity is animating
};


int g_iSpritesLaserbeam;
int g_iSpritesGlow;

// TF2 Class names, ordered from TFClassType
char g_strClassName[TFClassType][] = {	
	"Unknown",
	"Scout",
	"Sniper",
	"Soldier",
	"Demoman",
	"Medic",
	"Heavy",
	"Pyro",
	"Spy",
	"Engineer",
};

// TF2 Building names
char g_strBuildingName[TFObjectType][TFObjectMode][] = {
	{"Dispenser", ""},
	{"Teleporter Entrance", "Teleporter Exit"},
	{"Sentry Gun", ""},
	{"Sapper", ""},
};


const TFObjectType TFObject_Invalid = view_as<TFObjectType>(-1);
const TFObjectMode TFObjectMode_Invalid = view_as<TFObjectMode>(-1);

const TFTeam TFTeam_Boss = TFTeam_Blue;
const TFTeam TFTeam_Attack = TFTeam_Red;