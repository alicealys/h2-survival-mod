#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_specialops;
#include maps\_so_survival_code;

/*QUAKED script_struct_survivalclaymore (0.0 0.0 0.9) (-5 -5 -5) (5 5 5)
Spec Ops Survival markers that AI use as locations to plant explosives.

default:"targetname" "so_claymore_loc"
default:"angles" "0 0 0"
*/

// Tweakables: Tables
#define WAVE_TABLE "sp/survival_waves.csv" // AI and wave data tablelookup

#define TABLE_INDEX 0 // Indexing
#define TABLE_BOSS_DELAY 1 // "1" = boss spawn on aggress, "0" = boss spawns immediately
#define TABLE_WAVE 2 // Wave number
#define TABLE_SQUAD_TYPE 3 // Squad AI type ref
#define TABLE_SQUAD_SIZE 4 // Number of squad AIs total
#define TABLE_SPECIAL 5 // Special AI type
#define TABLE_SPECIAL_NUM 6 // Number of special AIs
#define TABLE_BOSS_AI 7 // Boss AIs, separated by spaces
#define TABLE_BOSS_NONAI 8 // Boss Chopper/etc...
#define TABLE_REPEAT 9 // Wave repeating pattern
#define TABLE_ARMORY_UNLOCK 10 // Armory to be unlocked at the end of this wave

#define TABLE_AI_REF 1 // AI type ref
#define TABLE_AI_NAME 2 // String name of AI
#define TABLE_AI_DESC 3 // String description of the AI
#define TABLE_AI_CLASSNAME 4 // Classname of the character without weapon
#define TABLE_AI_WEAPON 5 // Weapon type goes with Classname
#define TABLE_AI_ALT_WEAPON 6 // Alt. Weapon such as grenades or RPG
#define TABLE_AI_HEALTH 7 // Health amount int
#define TABLE_AI_SPEED 8 // AI movement speed
#define TABLE_AI_XP 9 // XP/Credit amount of AI
#define TABLE_AI_BOSS 10 // Boss flag
#define TABLE_AI_ACCURACY 11 // AI Base accuracy

#define TABLE_WAVE_DEF_INDEX_START 0 // First index for AI Waves
#define TABLE_WAVE_DEF_INDEX_END 40 // Last index for AI Waves

#define TABLE_AI_TYPE_INDEX_START 100 // First index for AI Type Table
#define TABLE_AI_TYPE_INDEX_END 120 // Last index for AI Type Table

// Tweakables: Generic
#define CONST_WEAPON_DROP_RATE					 1	// 0.0-1.0 rate of weapon drop when dead
//CONST_WEAPON_DROP_AMMO_CLIP			= 0.15;	// 0.0-1.0 rate of max ammo in clip
//CONST_WEAPON_DROP_AMMO_CLIP_MIN		= 1;	// Minimum bullet count of clip in dropped weapon
//CONST_WEAPON_DROP_AMMO_STOCK			= 0.03;	// 0.0-1.0 rate of max ammo in stock
//CONST_WEAPON_DROP_AMMO_STOCK_MIN		= 0;	// Minimum bullet count of stock in dropped weapon
#define CONST_AI_UPDATE_DELAY					 4.0	// General AI update delay passed to manage_ai_relative_to_player()
#define CONST_AI_SEARCH_PLAYER_TIME				 6.0	// Amount of time an ai will pole to see if it has reached the player before giving up
#define CONST_LONG_DEATH_REMOVE_DIST_MIN		 540	// Min distance the closest player needs to be to allow long death force kill

// Enemy spawn protection
#define CONST_ENEMY_SPAWN_PROTECTION_TIME		 1	// In seconds

// Tweakables: Repeating Wave Difficulty Adjust
#define CONST_AI_REPEAT_BOOST_HEALTH			 0.10	// 0.0-1.0 Percent health increase stacked for each repeated wave
#define CONST_AI_REPEAT_BOOST_SPEED				 0.05	// 0.0-1.0 Percent speed increase stacked for each repeated wave
#define CONST_AI_SPEED_MAX						 1.5  // No AI should ever have their speed scale greater than 1.5
#define CONST_AI_REPEAT_BOOST_ACCURACY			 0.2	// 0.0-1.0 Percent accuracy increase stacked for each repeated wave

// Tweakables: Player Closest Node Tracker
#define CONST_NODE_CLOSEST_RADIUS_MIN			 1	// Check for nodes closest to player greater than this distance away
#define CONST_NODE_CLOSEST_RADIUS_MAX			 128	// Check for nodes closest to player less than this distance away
#define CONST_NODE_CLOSEST_RADIUS_INCREASE		 64	// If a closest node check fails to find a node, increase the radius by this amount and try again
#define CONST_NODE_CLOSEST_RADIUS_INVALID		 2048	// The radius max for the check for nodes should never get this big.
#define CONST_NODE_CLOSEST_HEIGHT				 512	// Check for nodes closest to player within this height distance away
#define CONST_NODE_CLOSEST_HEIGHT_INCREASE		 128	// If a closest node check fails to find a node, increase the height by this amount and try again

// Tweakables: AI Goal Radii
#define CONST_REGULAR_GOAL_RADIUS_DEFAULT		 900
#define CONST_REGULAR_GOAL_RADIUS_AGGRESSIVE	 384
#define CONST_MARTYRDOM_GOAL_RADIUS_DEFAULT		 900
#define CONST_MARTYRDOM_GOAL_RADIUS_AGGRESSIVE	 384
#define CONST_CLAYMORE_GOAL_RADIUS_DEFAULT		 900
#define CONST_CLAYMORE_GOAL_RADIUS_AGGRESSIVE	 384
#define CONST_CHEMICAL_GOAL_RADIUS_DEFAULT		 512
#define CONST_CHEMICAL_GOAL_RADIUS_AGGRESSIVE	 384
#define CONST_ALLY_GOAL_RADIUS					 512
#define CONST_ALLY_GOAL_RADIUS_RIOTSHIELD		 448

// Tweakables: AI Aggressive Engagement Ranges
#define CONST_GENERIC_AI_ENGAGE_MIN				 88	// Engagement min dist used by regular and special AI when aggressing (not dogs or bosses)
#define CONST_GENERIC_AI_ENGAGE_MIN_FALL_OFF	 64	// Engagement min dist fall off used by regular and special AI when aggressing (not dogs or bosses)

// Tweakables: Ai Type Martyrdom
#define CONST_MARTYRDOM_C4_SOUND_TELL_LENGTH	 1.5	// length of the sound used to telegraph the c4 explosion
#define CONST_MARTYRDOM_C4_TIMER				 3	// seconds till c4 explode after dropped by martyrdom AI
#define CONST_MARTYRDOM_C4_TIMER_SUBSEQUENT		 0.4	// time delay before secondary explosions go off
#define CONST_MARTYRDOM_C4_PHYS_RADIUS			 256	// radius of physics push cylinder volume
#define CONST_MARTYRDOM_C4_PHYS_FORCE			 2	// force of the physics push
#define CONST_MARTYRDOM_C4_QUAKE_SCALE			 0.4	// earthquake scale
#define CONST_MARTYRDOM_C4_QUAKE_TIME			 0.8	// earthquake duration
#define CONST_MARTYRDOM_C4_QUAKE_RADIUS			 600	// earthquake range

#define CONST_MARTYRDOM_C4_DMG_RADIUS			 192	// c4 damage range
#define CONST_MARTYRDOM_C4_DMG_MAX				 100	// c4 max damage
#define CONST_MARTYRDOM_C4_DMG_MIN				 50	// c4 min damage
#define CONST_MARTYRDOM_C4_DANGER_RANGE			 CONST_MARTYRDOM_C4_DMG_RADIUS - 48	// c4 bad place cylinder height and radius

// Tweakables: Ai Type Claymore
#define CONST_CLAYMORE_PLACED_MAX				 6	// Maximum count of AI claymores that can be placed

#define CONST_MINE_LOC_UPDATE_DELAY				 0.5	// Location weight update delay
#define CONST_MINE_LOC_WEIGHT_MAX				 20	// Location max weight
#define CONST_MINE_LOC_WEIGHT_INC				 0.5	// Weight increase per update: Max reached in 20 updates or 10 seconds
#define CONST_MINE_LOC_WEIGHT_DECAY				 0.025// Weight decrease per update: Min reached in 800 updates or 400 seconds
#define CONST_MINE_LOC_RANGE_PLAYER				 512	// Radius from the player that causes a location to have its weight increased

#define CONST_MINE_PLANT_CHECK_DELAY			 2.0	// Time between claymore planting system checks
#define CONST_MINE_PLANT_TIME_BETWEEN			 8.0	// Minimum time between consecutive plant attempts
#define CONST_MINE_PLANT_DIST_PLAYER_MIN		 384	// Minimum distance that a claymore can be planted from player
#define CONST_MINE_PLANT_DIST_AI_MAX			 768	// Maximum distance that an AI can travel to plant
#define CONST_MINE_PLANT_HEIGHT_AI_MAX			 240	// AI won't travel half this height or above half this height to plant
#define CONST_MINE_PLANT_WEIGHT_MIN				 2.0	// Min weight for a plant to occur

#define CONST_CLAYMORE_ENT_TIMER				 0.75	// seconds till claymore explode after triggered
#define CONST_CLAYMORE_ENT_TRIG_ANGLE			 70	// Angle player has to be in to get detected
#define CONST_CLAYMORE_ENT_TRIG_DIST_MIN		 20	// Minimum claymore trig dist using player vector projected onto claymore facing
#define CONST_CLAYMORE_ENT_PHYS_RADIUS			 256	// radius of physics push cylinder volume
#define CONST_CLAYMORE_ENT_PHYS_FORCE			 2	// force of the physics push
#define CONST_CLAYMORE_ENT_QUAKE_SCALE			 0.4	// earthquake scale
#define CONST_CLAYMORE_ENT_QUAKE_TIME			 0.8	// earthquake duration
#define CONST_CLAYMORE_ENT_QUAKE_RADIUS			 600	// earthquake range
#define CONST_CLAYMORE_ENT_TRIG_RADIUS			 192  // the claymore detonation distance - mplayer is 192
#define CONST_CLAYMORE_ENT_DMG_RADIUS			 192	// claymore damage range
#define CONST_CLAYMORE_ENT_DMG_MAX				 100	// claymore max damage
#define CONST_CLAYMORE_ENT_DMG_MIN				 50	// claymore min damage

// Tweakables: Ai Type Chemical
#define CONST_CHEMBOMB_ENT_TIMER				 0.5	// seconds till chembomb explode after triggered
#define CONST_CHEMBOMB_ENT_TRIG_RADIUS			 96	// the chembomb detonation distance
#define CONST_CHEMBOMB_CLOUD_LIFE_TIME			 6.0	// how long the chemical bomb cloud remains
#define CONST_CHEMBOMB_CLOUD_BADPLACE_LIFE_TIME	 1.0	// length of time in the bad place stays around

#define CONST_CHEMICAL_TANK_PHYS_RADIUS			 256	// radius of physics push cylinder volume
#define CONST_CHEMICAL_TANK_PHYS_FORCE			 0.5	// force of the physics push
#define CONST_CHEMICAL_TANK_QUAKE_SCALE			 0.2	// earthquake scale
#define CONST_CHEMICAL_TANK_QUAKE_TIME			 0.4	// earthquake duration
#define CONST_CHEMICAL_TANK_QUAKE_RADIUS		 600	// earthquake range

#define CONST_CHEMICAL_TANK_DMG_RADIUS			 192	// tank explosion damage range
#define CONST_CHEMICAL_TANK_DMG_MAX				 20	// tank explosion max damage
#define CONST_CHEMICAL_TANK_DMG_MIN				 10	// tank explosion min damage

#define CONST_CHEMICAL_CLOUD_TRIG_RADIUS		 96	// chemical smoke cloud shock radius
#define CONST_CHEMICAL_CLOUD_LIFE_TIME			 6.0	// length of time in seconds the cloud stays around
#define CONST_CHEMICAL_CLOUD_BADPLACE_LIFE_TIME	 2.0	// length of time in seconds the badplace remains
#define CONST_CHEMICAL_CLOUD_SHOCK_TIME			 1.5	// time that the shock lasts for
#define CONST_CHEMICAL_CLOUD_SHOCK_DELAY		 1.0	// time in between shock applications from chemical cloud

// Tweakables: Ai Type Boss Juggernaut
#define CONST_JUG_POP_HELMET_HEALTH_PERCENT		 0.33	// Health percent threshold that causes the helmet to pop off
#define CONST_JUG_DROP_SHIELD_HEALTH_PERCENT	 0.50	// Health percent threshold that causes the Juggernaut to drop his shield
#define CONST_JUG_WEAKENED						 250	// at this health amount, juggernaut is weakened, ex: pain reaction
#define CONST_JUG_MIN_DAMAGE_PAIN				 350	// min amount of damage needed to have pain animations play
#define CONST_JUG_MIN_DAMAGE_PAIN_WEAK			 250	// min amount of damage needed to have pain animations play when weak
#define CONST_JUG_RUN_DIST						 1000	// runs towards player at this distance
#define CONST_JUG_WEAKENED_RUN_DIST				 500	// runs towards player at this distance when weakened and desperate
#define CONST_JUG_RIOTSHIELD_BULLET_BLOCK		 1	// riotshield jug: no reaction when bullet hits shield

// Juggernaut damage shield levels, (0-1) 0= takes no dmg, 1= taks full dmg, >1= increases damage
#define CONST_JUG_HIGH_SHIELD					 0.25	// Bullet Proof Armor
#define CONST_JUG_MED_SHIELD					 0.33	// Bullet Resistant Armor
#define CONST_JUG_LOW_SHIELD					 0.75	// Not bare skin or cloth
#define CONST_JUG_NO_SHIELD						 1.0	// Exposed area not that is not the head or splash damage with head exposed
#define CONST_JUG_KILL_ON_PAIN					 9999	// Exposed head

#define CONST_CHOPPER_SPEED						 60	// Chopper default speed
#define CONST_CHOPPER_ACCEL						 20 	// Chopper default acceleration

// Tweakables: Ai Type Ally
#define CONST_ALLY_BULLET_SHIELD_TIME			 20

// Tweakables: Ai Type Dog
#define CONST_DOG_SPAWN_OVER_TIME				 50	// Dogs will spawn over this many seconds, usually estimate of wave completion time

// Tweakables: Ai Type Dogsplode
#define CONST_DOGSPLODE_C4_TIMER_NECK_SNAP		 5	// Dog C4 timer used if the dog is killed during a neck snap. Gives the player time to escape.
#define CONST_DOG_TIME_STATIC_TO_DETONATE		 2000	// Time in milliseconds the dog needs to be stationary before auto detonating
#define CONST_DOG_DIST_TO_SENTRY_DETONATE		 40	// Distance in inches that the dog must be from a sentry to cause auto detonation
#define CONST_DOG_SAME_LOC_THRESHOLD			 10	// If the dog is within this many inches of it's original postion he hasn't moved


AI_preload()
{
	AI_preload_weapons();
	
	PrecacheHeadIcon( "headicon_delta_so" );
	PrecacheHeadIcon( "headicon_gign_so" );
	
	// AI Type: Martyrdom C4 Items
	precacheModel( "h2_weapon_c4" );
	level._effect[ "martyrdom_c4_explosion" ] 		= loadfx( "fx/explosions/grenadeexp_default" );
	level._effect[ "martyrdom_dlight_red" ] 		= loadfx( "vfx/lights/light_c4_blink" );
	level._effect[ "martyrdom_red_blink" ]			= loadfx( "vfx/lights/aircraft_light_red_blink" );
	
	// AI Type: Claymore Items
	PrecacheModel( "weapon_claymore" );
	level._effect[ "claymore_laser" ] 				= loadfx( "misc/claymore_laser" );
	level._effect[ "claymore_explosion" ] 			= loadfx( "fx/explosions/grenadeexp_default" );
	level._effect[ "claymore_disabled" ]			= loadfx( "explosions/sentry_gun_explosion" );
	
	// AI Type: Chemical Warfare
	precachemodel( "gas_canisters_backpack" );
	precachemodel( "ims_scorpion_explosive1" );
	// JC-ToDo: If chemical AI is kept, create unique shock files specifically for him
	precacheShellShock( "radiation_low" );
	precacheShellShock( "radiation_med" );
	precacheShellShock( "radiation_high" );
	level._effect[ "chemical_tank_explosion" ]		= loadfx( "smoke/so_chemical_explode_smoke" );
	level._effect[ "chemical_tank_smoke" ]			= loadfx( "smoke/so_chemical_stream_smoke" );
	level._effect[ "chemical_mine_spew" ]			= loadfx( "smoke/so_chemical_mine_spew" );
	
	// Boss dying money fx
	level._effect[ "money" ] = loadfx ("props/cash_player_drop");
	
	maps\_chopperboss::chopper_boss_load_fx();
	
	// dog needs precaching before _load
	animscripts\dog\dog_init::initDogAnimations();
}

AI_preload_weapons()
{
	index_start = TABLE_AI_TYPE_INDEX_START;
	index_end 	= TABLE_AI_TYPE_INDEX_END;

	for( i = index_start; i <= index_end; i++ )
	{	
		ai_weapons = get_ai_weapons( get_ai_ref_by_index( i ) );
		foreach( w in ai_weapons )
			precacheitem( w );
	}
}

// ==========================================================================
// AI INIT AND DATA TABLE POPULATION
// ==========================================================================

AI_init()
{
	// Don't let AI drop akimbo weapons
	SetSavedDvar( "ai_dropAkimboChance", 0 );
		
	// build ai spawner arrays
	if ( !isdefined( level.wave_table ) )
		level.wave_table		= WAVE_TABLE;
		
	level.survival_ai 				= [];
	level.survival_boss				= [];
	level.survival_ai 				= ai_type_populate();	// updates level.survival_boss
	
	level.survival_repeat_wave 		= [];
	level.survival_waves_repeated 	= 0;
	level.survival_wave 			= [];
	level.survival_wave 			= wave_populate();		// updates level.survival_repeat_wave

	// threat bias
	createthreatbiasgroup( "sentry" ); 
	createthreatbiasgroup( "allies" ); 
	createthreatbiasgroup( "axis" );
	createthreatbiasgroup( "boss" );
	createthreatbiasgroup( "dogs" );
	
	setignoremegroup( "sentry", "dogs" );		// dogs ignore sentry
	setthreatbias( "sentry", "boss", 50 ); //1000 );	// make the sentry a bigger threat to boss
	setthreatbias( "sentry", "axis", 50 ); //1000 );	// make the sentry a bigger threat to enemies	
	setthreatbias( "boss", "allies", 2000 );	// make the boss a bigger threat to allies
	setthreatbias( "dogs", "allies", 1000 );	// make the dogs a big threat to allies
	setthreatbias( "axis", "allies", 0 );		// make the axis a regular threat to allies
	
	foreach ( player in level.players )
	{
		player.onlyGoodNearestNodes = true;
		player thread update_player_closest_node_think();
	}
	
	// setup AI types and run them
	level.attributes_func				= ::setup_attributes;
	level.squad_leader_behavior_func 	= ::default_ai;
	level.special_ai_behavior_func 		= ::default_ai;
	level.squad_drop_weapon_rate		= CONST_WEAPON_DROP_RATE;
	add_global_spawn_function( "axis", ::no_grenade_bag_drop );
	add_global_spawn_function( "axis", ::weapon_drop_ammo_adjustment );
	add_global_spawn_function( "axis", ::update_enemy_remaining );
	add_global_spawn_function( "axis", ::ai_on_long_death );
	add_global_spawn_function( "axis", ::kill_sentry_on_contact );
	//add_global_spawn_function( "axis", ::spawn_protection );
	
	register_xp();
	thread survival_AI_regular();
	thread survival_AI_martyrdom();
	// These are paired because they both lean on 
	// the mine (claymore) locations throughout the
	// map
	thread survival_AI_claymore_and_chemical();
	thread survival_boss_juggernaut();
	thread survival_drop_chopper_init();
	thread survival_boss_chopper();
	
	// for dogs to behave when they cant get to players
	thread dog_relocate_init();
	
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
}

/*
// protection against player plant claymores and traps at enemy spawns
spawn_protection()
{
	self endon( "death" );
	
	if ( !isAI( self ) )
		return;
	
	if ( isdefined( self.juggernaut ) && self.juggernaut )
		return;

	self deletable_magic_bullet_shield();
	
	wait CONST_ENEMY_SPAWN_PROTECTION_TIME;
	
	self stop_magic_bullet_shield();
}
*/

kill_sentry_on_contact()
{
	self endon( "death" );
	
	if ( !isAI( self ) )
		return;

	// padding for self.ridingvehicle to be set
	// does not affect regular AI being stuck as they won't move
	wait 0.5;
	if ( isdefined( self.ridingvehicle ) )
		self waittill( "jumpedout" );
	
	if ( !isdefined( level.placed_sentry ) )
		return;
	
	foreach( sentry in level.placed_sentry )
	{
		if ( !isdefined( sentry ) || !isAlive( sentry ) )
			continue;
		
		// if colliding with sentry planar within 40 units radius
		// and also not more than 64 units above
		if ( distance2d( sentry.origin, self.origin ) < 40 && distancesquared( sentry.origin, self.origin ) < 64*64 )
			sentry kill();
	}
}

wave_populate()
{
	index_start = TABLE_WAVE_DEF_INDEX_START;
	index_end 	= TABLE_WAVE_DEF_INDEX_END;
	waves 		= [];

	for ( i = index_start; i <= index_end; i++ )
	{		
		wave_num = get_wave_number_by_index( i );

		if ( !isdefined( wave_num ) || wave_num == 0 )
			continue;
		
		wave 					= spawnstruct();
		wave.idx				= i;
		wave.num				= wave_num;
		wave.squadType			= get_squad_type( wave_num );
		wave.squadArray			= get_squad_array( wave_num );
		wave.specialAI			= get_special_ai( wave_num );
		wave.specialAIquantity	= get_special_ai_quantity( wave_num );
		wave.bossDelay			= get_wave_boss_delay( wave_num );
		wave.bossAI				= get_bosses_ai( wave_num );
		wave.bossNonAI			= get_bosses_nonai( wave_num );
		wave.dogType			= get_dog_type( wave_num );
		wave.dogQuantity		= get_dog_quantity( wave_num );
		wave.repeating			= is_repeating( wave_num );
		
		// record armory unlock at end of wave
		unlock_armory_array		= get_armory_unlocked( wave_num );
		if ( isdefined( unlock_armory_array ) && unlock_armory_array.size )
		{
			if ( !isdefined( level.armory_unlock ) )
				level.armory_unlock = [];
			
			foreach ( unlock_armory in unlock_armory_array )
				level.armory_unlock[ unlock_armory ] = wave_num;
		}
		
		waves[ wave_num ] = wave;
		
		if ( wave.repeating )
			level.survival_repeat_wave[ level.survival_repeat_wave.size ] = wave;
	}
	
	assertex( isdefined( level.survival_repeat_wave ) && level.survival_repeat_wave.size, "At least one wave must be set to repeating." );
	
	return waves;
}

ai_type_add_override_class( ai_type, class_new )
{
	AssertEx( IsDefined( ai_type ) && IsString( ai_type ), "The AI type should be a string." );
	AssertEx( IsDefined( class_new ) && IsString( class_new ), "The new AI class should be a string." );
	
	if ( !IsDefined( level.survival_ai_class_overrides ) )
	{
		level.survival_ai_class_overrides = [];
	}
	
	level.survival_ai_class_overrides[ ai_type ] = class_new;
}

ai_type_add_override_weapons( ai_type, weapons_new )
{
	AssertEx( IsDefined( ai_type ) && IsString( ai_type ), "The AI type should be a string." );
	AssertEx( IsDefined( weapons_new ) && IsArray( weapons_new ) && weapons_new.size, "The new AI weapons parm should be a filled array." );
	
	if ( !IsDefined( level.survival_ai_weapon_overrides ) )
	{
		level.survival_ai_weapon_overrides = [];
	}
	
	foreach ( weapon in weapons_new )
	{
		PreCacheItem( weapon );
	}
	level.survival_ai_weapon_overrides[ ai_type ] = weapons_new;
}

ai_type_populate()
{
	index_start = TABLE_AI_TYPE_INDEX_START;
	index_end 	= TABLE_AI_TYPE_INDEX_END;
	ai_types	= [];

	for ( i = index_start; i <= index_end; i++ )
	{		
		ref = get_ai_ref_by_index( i );
		if ( !isdefined( ref ) || ref == "" )
			continue;
		
		ai 				= spawnstruct();
		ai.idx			= i;
		ai.ref			= ref;
		ai.name			= get_ai_name( ref );
		ai.desc			= get_ai_desc( ref );
		ai.classname	= get_ai_classname( ref );
		ai.weapon		= get_ai_weapons( ref );
		ai.altweapon	= get_ai_alt_weapons( ref );
		ai.health		= get_ai_health( ref );
		ai.speed		= get_ai_speed( ref );
		ai.accuracy		= get_ai_accuracy( ref );
		ai.XP			= get_ai_xp( ref );
		
		if ( is_ai_boss( ref ) )
			level.survival_boss[ ref ] = ai;

		ai_types[ ref ] = ai;
	}
	return ai_types;
}

// ==========================================================================
// REGISTER AI XP/CREDITS
// ==========================================================================

giveXp_kill( victim, XP_mod )
{
	assertex( isPlayer( self ), "Trying to give XP to non Player" );
	assertex( isdefined( victim ), "Trying to give XP reward on something that is not defined" );
	
	if (!isdefined(XP_mod))
	{
		XP_mod = 1;
	}

	XP_type = "kill";
	if ( isdefined( victim.ai_type ) )
	{
		XP_type = "survival_ai_" + victim.ai_type.ref;
	}
	
	value = undefined;
	if ( isdefined( XP_mod ) )
	{
		reward = maps\_rank::getScoreInfoValue( XP_type );
		if ( isdefined( reward ) )
			value = reward * XP_mod;
	}
	
	self givexp( XP_type, value );
}

register_xp()
{
	// Register XP/Credit reward amount for AIs defined in string table
	foreach ( ai in level.survival_ai )
	{
		maps\_rank::registerScoreInfo( "survival_ai_" + ai.ref, get_ai_xp( ai.ref ) );
	}
}

// ==========================================================================
// GLOBAL AI STUFF
// ==========================================================================

// In the function that manages AI position - manage_ai_relative_to_player() - AI
// are told to go to the closest healthy player. If that player is in a position the
// AI cannot get to, they receive a notification from code of "bad_path". This
// happens whether SetGoalPos() or SetGoalEnity() is used. The result of this
// situation is the AI do not move from their current location. To keep the AI in
// survival moving towards the player, keep track of each player's closest path node
// AI that receive a bad path notification can then grab the current closest node
// to their target player and go there. - JC

update_player_closest_node_think()
{
	AssertEx( IsPlayer( self ), "Self should be a player in update_player_closest_node_think()" );
	
	self endon( "death" );
	level endon( "special_op_terminated" );
	
	max_radius = CONST_NODE_CLOSEST_RADIUS_MAX;
	min_radius = CONST_NODE_CLOSEST_RADIUS_MIN;
	max_height = CONST_NODE_CLOSEST_HEIGHT;

	while ( 1 )
	{
		closestNode = GetClosestNodeInSight( self.origin );
		if ( IsDefined( closestNode ) )
		{	// filter out some node types that we don't want them clogging up.
			if ( closestNode.type != "Begin" && closestNode.type != "End" && closestNode.type != "Turret" )
				self.node_closest = closestNode;
		}

		wait 0.25;
		
		//nodes = GetNodesInRadiusSorted( self.origin, max_radius, min_radius, max_height );
		//if ( !IsDefined( nodes ) || !nodes.size )
		//{
		//	max_radius += CONST_NODE_CLOSEST_RADIUS_INCREASE;
		//	max_height += CONST_NODE_CLOSEST_HEIGHT_INCREASE;
		//	
		//	AssertEx( max_radius < CONST_NODE_CLOSEST_RADIUS_INVALID, "The max radius check for the close nodes should never get larger than: " + CONST_NODE_CLOSEST_RADIUS_INVALID );
		//	
		//	wait 0.1;
		//	continue;	
		//}
		//
		//self.node_closest = nodes[0];
		//
		//// Rest the test case values
		//max_radius = CONST_NODE_CLOSEST_RADIUS_MAX;
		//min_radius = CONST_NODE_CLOSEST_RADIUS_MIN;
		//max_height = CONST_NODE_CLOSEST_HEIGHT;
		//
		//wait 0.2;
	}
	
}

update_enemy_remaining()
{
	level endon( "special_op_terminated" );
	
	// Let the AI and vehicle spawn logic run so that 
	// the level.bosses array and the level.dogs array
	// are updated before grabbing the final ai count;
	waittillframeend;
	
	level.enemy_remaining = get_survival_enemies_living().size;
	level notify( "axis_spawned" );
	
	self waittill( "death" );
	
	// Again, let the level.bosses and level.dog arrays
	// get updated then update the enemy remaining
	waittillframeend;
	
	enemies_alive = get_survival_enemies_living();
	
	level.enemy_remaining = enemies_alive.size;
	level notify( "axis_died" );
	
	// If ai are done spawning and only one enemy is left 
	// and it's an AI that is not a dog stop long deaths
	if	(
		flag( "aggressive_mode" ) 
	&&	enemies_alive.size == 1
	&&	isai( enemies_alive[ 0 ] )
	&&	enemies_alive[ 0 ].type != "dog"
		)
	{
		enemies_alive[ 0 ] thread prevent_long_death();
	}
}

get_survival_enemies_living()
{
	enemy_array = getaiarray( "axis" );
	
	// Add non ai bosses, duplicates are removed by array_merge()
	if ( IsDefined( level.bosses ) && level.bosses.size )
		enemy_array = array_merge( enemy_array, level.bosses );
		
	enemy_array = array_merge( enemy_array, dog_get_living() );
		
	return enemy_array;
}

prevent_long_death()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	if ( !isdefined( self.a.doingLongDeath ) )
	{
		self disable_long_death();
		return;
	}
	
	// Once the players are far enough away / out of
	// site kill the ai so he doesn't hand around in
	// in long death delaying the round end
	while ( 1 )
	{
		safe_to_kill = true;
		
		foreach ( player in level.players )
		{
			player_too_close = Distance2D( player.origin, self.origin ) < CONST_LONG_DEATH_REMOVE_DIST_MIN;
			
			if ( player_too_close )
			{
				safe_to_kill = false;
				break;	
			}
			
			if ( self CanSee( player ) )
			{
				safe_to_kill = false;
				break;
			}
			
			// One trace per script update
			wait 0.05;
		}
		
		if ( safe_to_kill )
		{
			attacker = self get_last_attacker();
			
			if ( isdefined( attacker ) )
				self Kill( self.origin, attacker );
			else
				self Kill( self.origin );
			
			return;
		}
		
		wait 0.1;
	}
}

get_last_attacker()
{
	assertex( isdefined( self ), "Self must be defined to check for last attacker." );
	
	attacker = undefined;
	
	// use the last attacker if available
	if ( isdefined( self.attacker_list ) && self.attacker_list.size )
		attacker = self.attacker_list[ self.attacker_list.size - 1 ];
		
	return attacker;
}

weapon_drop_ammo_adjustment()
{
	if ( !isai( self ) || isdefined( self.type ) && self.type == "dog" )
		return;
		
	if ( !isdefined( level.armory ) || !isdefined( level.armory[ "weapon" ] ) )
		return;

	level endon( "special_op_terminated" );
	
	self waittill( "weapon_dropped", weapon );
	
	if ( !isdefined( weapon ) )
		return;

	weapon_name 		= GetSubStr( weapon.classname, 7 );
	wait 				( 0.05 );	// wait till anim is done and such

	weapon_struct		= level.armory[ "weapon" ][ weapon_name ];

	if ( !isdefined( weapon ) || !isdefined( weapon_struct ) )
		return;
	
	assert( isdefined( weapon_struct.dropclip ) && isdefined( weapon_struct.dropstock ) );
	
	ammo_in_clip 		= weapon_struct.dropclip;
	ammo_stock 			= weapon_struct.dropstock;
	weapon				ItemWeaponSetAmmo( ammo_in_clip, ammo_stock );
	
	// for alt mode such as m203 and shotty attachments
	// give min of 1 ammo
	alt_weapon 			= WeaponAltWeaponName( weapon_name );
	if( alt_weapon != "none" )
	{
		alt_clip 		= int( max( 1, WeaponClipSize( alt_weapon ) ) );
		alt_stock 		= int( max( 1, WeaponMaxAmmo( alt_weapon ) ) );
		weapon 			ItemWeaponSetAmmo( alt_clip, alt_stock, alt_clip, 1 );
	}
}

no_grenade_bag_drop()
{
	// every axis resets this value when spawned, am forcing this here
	level.nextGrenadeDrop	= 100000;	// no grenade bag drop!	
}

// displays money FX where an AI died
money_fx_on_death()
{
	level endon( "special_op_terminated" );

	self waittill( "death" );
	
	// if self is removed instead of killed, then no money should display
	if ( !isdefined( self ) )
		return;
		
	playFx( level._effect[ "money" ], self.origin + ( 0, 0, 32 ) );
}

ai_on_long_death()
{
	if ( !isai( self ) || isdefined( self.type ) && self.type == "dog" )
		return;
		
	self endon( "death" );
	level endon( "special_op_terminated" );
	
	self waittill( "long_death" );
	
	self waittill( "flashbang", flash_origin, flash_dist, flash_angle, attacker );
	
	if ( isdefined( attacker ) && isdefined( attacker.team ) && attacker.team == "allies" )
		self kill( self.origin, attacker );
}

// get ai type ref
get_ai_type_ref()
{
	assertex( isdefined( self ) && isalive( self ), "Trying to AI type when AI is undefined or dead." );
		
	if ( isdefined( self.ai_type ) )
		return self.ai_type.ref;	
	
	if ( isdefined( level.leaders ) )
	{
		foreach( leader in level.leaders )
		{
			if ( leader == self )
				return get_squad_type( level.current_wave );
		}
	}
	
	// squad follower
	if ( isdefined( self.leader ) && isAI( self.leader ) )
		return get_squad_type( level.current_wave );

	assertex( false, "Failed to assign AI_type_ref for AI: " + self.unique_id );
	return undefined;
}

get_special_ai_array( ref )
{
	assert( isdefined( ref ) );
	
	arr_ai_type = [];
	
	if ( isdefined( level.special_ai ) && level.special_ai.size )
	{
		foreach( ai in level.special_ai )
			if ( isalive( ai ) && isdefined( ai.ai_type ) && ai.ai_type.ref == ref )
				arr_ai_type[ arr_ai_type.size ] = ai;
	}
	
	return arr_ai_type;
}

// default ai behavior director function
default_ai()
{
	assertex( isdefined( self ) && isalive( self ) && isAI( self ), "Default AI behavior func was called on nonAI or is removed/dead." );
	
	self notify( "ai_behavior_change" );
	
	self.aggressivemode = true;		// don't linger at cover when you cant see your enemy
	self.aggressing = undefined;
	ai_ref = self [[ level.attributes_func ]]();
	
	//iprintln( ai_ref + " AI behavior: default" );
	
	if ( ai_ref == "martyrdom" )
	{
		self thread behavior_special_ai_martyrdom();
		return;
	}
		
	if ( ai_ref == "claymore" )
	{
		self thread behavior_special_ai_claymore();
		return;
	}
		
	if ( ai_ref == "chemical" )
	{
		self thread behavior_special_ai_chemical();
		return;
	}
	// all special ai cases should be handled by this point
	
	if ( ai_ref == "easy" || ai_ref == "regular" || ai_ref == "hardened" || ai_ref == "veteran" || ai_ref == "elite" )
		self thread default_squad_leader();
	// juggernaut bosses use different behavior functions elsewhere
}

// aggressive ai behavior director function
aggressive_ai()
{
	assertex( isdefined( self ) && isalive( self ) && isAI( self ), "Default AI behavior func was called on nonAI or is removed/dead." );
	
	self notify( "ai_behavior_change" );
	
	self.aggressivemode = true;		// don't linger at cover when you cant see your enemy
	self.aggressing = true;
	ai_ref = self [[ level.attributes_func ]]();
	
	//iprintln( ai_ref + " AI behavior: aggressive" );
	
	if ( ai_ref == "martyrdom" )
	{
		self thread behavior_special_ai_martyrdom();
		return;
	}
		
	if ( ai_ref == "claymore" )
	{
		self thread behavior_special_ai_claymore();
		return;
	}
		
	if ( ai_ref == "chemical" )
	{
		self thread behavior_special_ai_chemical();
		return;
	}
	// all special ai cases should be handled by this point
	
	if ( ai_ref == "easy" || ai_ref == "regular" || ai_ref == "hardened" || ai_ref == "veteran" || ai_ref == "elite" )
		self thread aggressive_squad_leader();
	// juggernaut bosses use different behavior functions elsewhere
}

// setups up AI attributes from data table, such as health, speed etc...
setup_attributes()
{
	// If ai attributes already set up skip attributes
	if ( isdefined( self.attributes_set ) && isdefined( self.ai_type ) )
		return self.ai_type.ref;
	
	// self is live AI this is called on
	ai_ref = self get_ai_type_ref();

	// live AI carries info struct about his class
	if ( !isdefined( self.ai_type ) )
	{
		ai_type_struct = get_ai_struct( ai_ref );
		assertex( isdefined( ai_type_struct ), "Failed to find struct for AI type: " + ai_ref );
		self.ai_type = ai_type_struct;
	}
	
	// ================== AI attributes ====================
	is_vehicle = ( isdefined( self.code_classname ) && self.code_classname == "script_vehicle" );
	
	// ==== set health
	set_health = get_ai_health( ai_ref );
	// vehicle health is handled differently by vehicle script and requires setting
	// vehicle.script_startinghealth on the spawner, which is done in chopper_spawn_from_targetname(...)
	if ( isdefined( set_health ) && !is_vehicle )
		self.health = set_health;
	
	// ==== set movement speed scale
	speed_scale = get_ai_speed( ai_ref );
	if ( isdefined( speed_scale ) )
	{
		if ( is_vehicle )
			self Vehicle_SetSpeed( CONST_CHOPPER_SPEED * speed_scale, CONST_CHOPPER_ACCEL * speed_scale );
		else
			self.moveplaybackrate = speed_scale;
	}

	// ==== set base accuracy
	set_accuracy = get_ai_accuracy( ai_ref );
	if ( isdefined( set_accuracy ) )
		self set_baseaccuracy( set_accuracy );
	
	// ==== set second hand weapons
	alt_weapons	= get_ai_alt_weapons( ai_ref );
	foreach ( alt_weapon in alt_weapons )
	{
		if ( alt_weapon == "fraggrenade" )
		{
			self.grenadeammo = 2;
			self.grenadeweapon = "fraggrenade";
		}
		
		if ( alt_weapon == "flash_grenade" )
		{
			self.grenadeammo = 2;
			self.grenadeweapon = "flash_grenade";
		}
	}
	
	// ==== weapon drop rate
	if( isdefined( self.dropweapon ) && self.dropweapon && isdefined( level.squad_drop_weapon_rate ) )
	{
		drop_chance = randomfloat( 1 );
		if( drop_chance > level.squad_drop_weapon_rate )
			self.dropweapon = false; 	// this avoids weapon being all weird when AI dies
	}

	self.advance_regardless_of_numbers = true;
	self.reacquire_without_facing = true;
	self.minExposedGrenadeDist = 256;
	
	self.attributes_set = true;
	return ai_ref;
}

// Boss behaviors
survival_boss_behavior()
{
	self endon( "death" );
	
	msg = "Boss does not have AI_Type struct, should have been passed when spawning by AI_Type.";
	assertex( isdefined( self.ai_type ), msg );
	
	boss_ref = self [[ level.attributes_func ]]();
	
	if ( !isdefined( boss_ref ) )
		return;
	
	if ( boss_ref == "jug_regular" )
	{
		self global_jug_behavior();
		self thread boss_jug_regular();
		return;
	}
	if ( boss_ref == "jug_headshot" )
	{
		self global_jug_behavior();
		self thread boss_jug_headshot();
		return;
	}
	if ( boss_ref == "jug_explosive" )
	{
		self global_jug_behavior();
		self thread boss_jug_explosive();
		return;
	}
	if ( boss_ref == "jug_riotshield" )
	{
		self global_jug_behavior();
		self thread boss_jug_riotshield();
		return;
	}
	
	//assertex( false, "Boss type: " + boss_name + " is not valid!" );
}

// ==========================================================================
// REGULAR SQUAD AI
// ==========================================================================

// setup for regular squad AIs
survival_AI_regular()
{
	// in case we want to setup something globally in level for this type of AI
	
}

// used for default squad leader behaviors
default_squad_leader()
{
	self.goalradius = CONST_REGULAR_GOAL_RADIUS_DEFAULT;
	self.aggressing = undefined;	// this function can be called raw and .aggressing needs to be udpated
	
	//self.pathenemyfightdist = 1028;
	//self.pathenemylookahead = 1028;
	
	self setengagementmindist( 300, 200 );
	self setengagementmaxdist( 512, 768 );

	self thread manage_ai_relative_to_player( CONST_AI_UPDATE_DELAY, self.goalradius, "ai_behavior_change demotion" );
}

// used when there are a few left and we are wraping up the wave
aggressive_squad_leader()
{
	self.goalradius = CONST_REGULAR_GOAL_RADIUS_AGGRESSIVE;
	self.aggressing = true;		// this function can be called raw and .aggressing needs to be udpated
	
	//self.pathenemyfightdist = 1028;
	//self.pathenemylookahead = 1028;
	
	self enable_heat_behavior( true );
	self disable_surprise();
	
	self setengagementmindist( CONST_GENERIC_AI_ENGAGE_MIN, CONST_GENERIC_AI_ENGAGE_MIN_FALL_OFF );
	self setengagementmaxdist( 512, 768 );
	
	self thread manage_ai_relative_to_player( CONST_AI_UPDATE_DELAY, self.goalradius, "ai_behavior_change demotion" );
}


// ==========================================================================
// MARTYRDOM AI
// ==========================================================================

behavior_special_ai_martyrdom()
{
	self endon( "death" );
	self endon( "ai_behavior_change" );
	
	// setup AI martyrdom ability
	if ( !isdefined( self.special_ability ) )
		self thread martyrdom_ability();
	
	engage_min_dist				= 0;
	engage_min_dist_fall_off	= 0;
	
	if ( isdefined( self.aggressing ) && self.aggressing )
	{
		engage_min_dist 			= CONST_GENERIC_AI_ENGAGE_MIN;
		engage_min_dist_fall_off	= CONST_GENERIC_AI_ENGAGE_MIN_FALL_OFF;
		self.goalradius 			= CONST_MARTYRDOM_GOAL_RADIUS_AGGRESSIVE;	
		
		self enable_heat_behavior( true );
		self disable_surprise();
	}
	else
	{
		engage_min_dist				= 200;
		engage_min_dist_fall_off	= 100;
		self.goalradius				= CONST_MARTYRDOM_GOAL_RADIUS_DEFAULT;
	}
	
	//self.pathenemyfightdist = 1028;
	//self.pathenemylookahead = 1028;
	
	self setengagementmindist( engage_min_dist, engage_min_dist_fall_off );
	self setengagementmaxdist( 512, 768 );
	
	self thread manage_ai_relative_to_player( CONST_AI_UPDATE_DELAY, self.goalradius, "ai_behavior_change" );
}

survival_AI_martyrdom()
{
	
}

martyrdom_ability()
{
	self.special_ability = true;
	self.forceLongDeath = true;
	
	// Chest and Back c4
	self thread attach_c4( "j_spine4", (0,6,0), (0,0,-90) );
	self thread attach_c4( "tag_stowed_back", (0,1,5), (80,90,0) );
	
	self thread detonate_c4_when_dead( CONST_MARTYRDOM_C4_TIMER, CONST_MARTYRDOM_C4_TIMER_SUBSEQUENT );
}

attach_c4( tag, origin_offset, angles_offset )
{
	assertex( isdefined( tag ), "attach_c4() passed undfined tag." );
	
	if ( !isdefined( origin_offset ) )
		origin_offset = ( 0, 0, 0 );
	if ( !isdefined( angles_offset ) )
		angles_offset = ( 0, 0, 0 );
	
	c4_model = spawn( "script_model", self gettagorigin( tag ) + origin_offset );
	c4_model setmodel( "h2_weapon_c4" );
	
	c4_model linkto( self, tag, origin_offset, angles_offset );
	
	if ( !isdefined( self.c4_attachments ) )
		self.c4_attachments = [];	
	
	self.c4_attachments[ self.c4_attachments.size ] = c4_model;
}

detonate_c4_when_dead( timer, subsequent_timer )
{
	self waittill_any( "long_death", "death", "force_c4_detonate" );
	
	self notify( "c4_detonated" );
	
	if ( !isdefined( self ) || !isdefined( self.c4_attachments ) || self.c4_attachments.size == 0 )
		return;
	
	// Passed to the c4 damage call so that players can chain kill for points
	attacker = self get_last_attacker();
	
	// Doggy Hack: If the player snapped the dog's neck
	// then give the player more time to get up from the 
	// c4 blast.
	if ( isdefined( self.dog_neck_snapped ) )
	{
		timer = CONST_DOGSPLODE_C4_TIMER_NECK_SNAP;
	}
	
	// Play individual blink fx
	for ( i = 0; i < self.c4_attachments.size; i++ )
	{
		playfxontag( getfx( "martyrdom_dlight_red" ), self.c4_attachments[ i ], "tag_fx" );
		playfxontag( getfx( "martyrdom_red_blink" ), self.c4_attachments[ i ], "tag_fx" );
	}
	
	// In case self is invalid after wait grab the c4 array
	c4_array = self.c4_attachments;
	self.c4_attachments = undefined;
	
	BadPlace_Cylinder( "", timer, c4_array[ 0 ].origin, CONST_MARTYRDOM_C4_DANGER_RANGE, CONST_MARTYRDOM_C4_DANGER_RANGE, "axis", "allies" );
	
	// Start the sound telegraph so that the explosion happens
	// as the sound finishes playing
	time_before_sound = max( timer - CONST_MARTYRDOM_C4_SOUND_TELL_LENGTH, 0 );
	if ( time_before_sound > 0 )
	{
		timer -= time_before_sound;
		wait time_before_sound;	
	}
	
	c4_array[ 0 ] playsound( "semtex_warning_so" );
	
	time_left = false;
	if ( timer > 0.25 )
	{
		timer -= 0.25;
		time_left = true;
	}
	
	wait timer;
	
	// Turn off blinking fx early so they're not left hanging around
	for ( i = 0; i < c4_array.size; i++ )
	{
		if ( !isdefined( c4_array[ i ] ) )
			continue;
		
		stopfxontag( getfx( "martyrdom_red_blink" ), c4_array[ i ], "tag_fx" );
	}
	
	// Wait the 0.25 seconds left over from above the fx turn
	// off then blow the c4(s)
	if ( time_left )
		wait 0.25;
	
	// Make sure the lowest c4 explodes first
	c4_array = sortbydistance( c4_array, c4_array[0].origin + (0,0,-120) );
	
	// Blow 'em
	for ( i = 0; i < c4_array.size; i++ )
	{
		if ( !isdefined( c4_array[ i ] ) )
			continue;
		
		playfx( level._effect[ "martyrdom_c4_explosion" ], c4_array[ i ].origin );
		
		c4_array[ i ] playsound( "h1_c4_explosion_main", "sound_done" );
		PhysicsExplosionCylinder( c4_array[ i ].origin, CONST_MARTYRDOM_C4_PHYS_RADIUS, 1, CONST_MARTYRDOM_C4_PHYS_FORCE );
		earthquake( CONST_MARTYRDOM_C4_QUAKE_SCALE, CONST_MARTYRDOM_C4_QUAKE_TIME, c4_array[ i ].origin, CONST_MARTYRDOM_C4_QUAKE_RADIUS );
		
		stopfxontag( getfx( "martyrdom_dlight_red" ), c4_array[ i ], "tag_fx" );
		
		// In case the attacker is removed, make sure a removed entity
		// is not passed to radiusdamage() o_O
		if ( !isdefined( attacker ) )
			attacker = undefined;
		
		c4_array[ i ] radiusdamage( c4_array[ i ].origin, CONST_MARTYRDOM_C4_DMG_RADIUS, CONST_MARTYRDOM_C4_DMG_MAX, CONST_MARTYRDOM_C4_DMG_MIN, attacker, "MOD_EXPLOSIVE" );
		c4_array[ i ] thread ent_linked_delete();
		
		wait subsequent_timer;
	}
}

// ==========================================================================
// CLAYMORE AI
// ==========================================================================

behavior_special_ai_claymore()
{
	// If currently planting ignore new behavior calls from the
	// survival wave logic
	if ( isdefined( self.planting ) )
		return;

	self endon( "death" );
	self endon( "ai_behavior_change" );
	
	engage_min_dist				= 0;
	engage_min_dist_fall_off	= 0;
	
	if ( isdefined( self.aggressing ) && self.aggressing )
	{
		engage_min_dist 			= CONST_GENERIC_AI_ENGAGE_MIN;
		engage_min_dist_fall_off	= CONST_GENERIC_AI_ENGAGE_MIN_FALL_OFF;
		self.goalradius = CONST_CLAYMORE_GOAL_RADIUS_AGGRESSIVE;
		
		self enable_heat_behavior( true );
		self disable_surprise();
	}
	else
	{
		engage_min_dist				= 300;
		engage_min_dist_fall_off	= 200;
		self.goalradius = CONST_CLAYMORE_GOAL_RADIUS_DEFAULT;
	}
	
	self setengagementmindist( engage_min_dist, engage_min_dist_fall_off );
	self setengagementmaxdist( 512, 768 );
	
	self thread manage_ai_relative_to_player( CONST_AI_UPDATE_DELAY, self.goalradius, "ai_behavior_change" );
}

survival_AI_claymore_and_chemical()
{	
	mine_locs_populate();
	thread mine_locs_manage_weights();
	
	mine_ai_types = [ "claymore", "chemical" ];
	thread mine_locs_manage_planting( mine_ai_types );
}

mine_locs_populate()
{
	level.so_mine_locs = [];
	level.so_mine_locs = get_all_mine_locs();
	
	assertex( level.so_mine_locs.size, "Map has no mine location structs placed." );
	
	foreach( mine_loc in level.so_mine_locs )
	{
		mine_loc.weight = 0.0;
	}
}

mine_locs_attempt_plant( array_ai_types )
{
	if ( isdefined( level.so_mines ) && level.so_mines.size >= CONST_CLAYMORE_PLACED_MAX )
		return false;
	
	ai_mine = [];
	
	foreach ( ai_type in array_ai_types )
	{
		ai_mine = array_combine( ai_mine, get_special_ai_array( ai_type ) );
	}
	
	ai_mine = mine_ai_remove_busy( ai_mine );
	
	if ( !ai_mine.size )
		return false;
		
	valid_locs = mine_locs_get_valid( CONST_MINE_PLANT_DIST_PLAYER_MIN, CONST_MINE_PLANT_WEIGHT_MIN );
	valid_locs = mine_locs_sorted_by_weight( valid_locs );
	
	foreach( loc in valid_locs )
	{
		foreach( ai in ai_mine )
		{
			ai_mine_dist = distance2d( loc.origin, ai.origin );
			
			// Early out if outside plant cylinder
			if	( 
				ai_mine_dist > CONST_MINE_PLANT_DIST_AI_MAX ||
				loc.origin[2] < ai.origin[2] - CONST_MINE_PLANT_HEIGHT_AI_MAX * 0.5 ||
				loc.origin[2] > ai.origin[2] + CONST_MINE_PLANT_HEIGHT_AI_MAX * 0.5
				)
				continue;
			
			player_closest = getclosest( loc.origin, level.players );
			player_mine_dist = distance2d( loc.origin, player_closest.origin );
			
			if ( ai_mine_dist < player_mine_dist )
			{
				ai thread behavior_special_ai_mine_place( loc );
				return true;	
			}
		}
	}
	
	return false;
}

mine_ai_remove_busy( array_ai )
{	
	ai_not_planting = [];
	foreach( ai in 	array_ai )
	{
		if ( !isdefined( ai.planting ) )
			ai_not_planting[ ai_not_planting.size ] = ai;
	}
			
	return ai_not_planting;
}

// Exchange sort
mine_locs_sorted_by_weight( locs )
{
	for( i = 0; i < locs.size - 1; i++ )
	{
		index_small = 0;
		for ( j = i + 1; j < locs.size; j++ )
		{
			if ( locs[ j ].weight < locs[ i ].weight )
			{
				loc_ref = locs[ j ];
				locs[ j ] = locs[ i ];
				locs[ i ] = loc_ref;	
			}
		}	
	}
	
	return locs;
}

mine_locs_get_valid( dist_min, weight_min )
{
	assertex( isdefined( level.so_mine_locs ) && level.so_mine_locs.size, "Level not prepped with claymore plant locations." );
	
	locs_valid = [];
	
	foreach( loc in level.so_mine_locs )
		if ( loc mine_loc_valid_plant( dist_min, weight_min ) )
			locs_valid[ locs_valid.size ] = loc;
	
	return locs_valid;
}

mine_loc_valid_plant( dist_min, weight_min )
{
	assert( isdefined( self.weight ) );
	assert( isdefined( dist_min ) && dist_min >= 0 );
	assert( isdefined( weight_min ) );
	
	if ( isdefined( self.occupied ) || self.weight < weight_min )
		return false;
		
	foreach( player in level.players )
		if ( distance2d( self.origin, player.origin ) < dist_min )
			return false;
	
	return true;
}

mine_locs_manage_weights()
{
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		foreach( loc in level.so_mine_locs )
		{
			increased = false;
			
			foreach( player in level.players )
			{
				if ( distance2d( loc.origin, player.origin ) <= CONST_MINE_LOC_RANGE_PLAYER )
				{
					loc mine_loc_adjust_weight( true );
					increased = true;
				}
			}
			
			if ( !increased )
				loc mine_loc_adjust_weight( false );
		}
		
		wait CONST_MINE_LOC_UPDATE_DELAY;
	}
}

mine_loc_adjust_weight( increment )
{
	if ( increment )
		self.weight = min( CONST_MINE_LOC_WEIGHT_MAX, self.weight + CONST_MINE_LOC_WEIGHT_INC );	
	else
		self.weight = max( 0, self.weight - CONST_MINE_LOC_WEIGHT_DECAY );
}

mine_locs_manage_planting( array_ai_types )
{
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		if ( mine_locs_attempt_plant( array_ai_types ) )
			wait CONST_MINE_PLANT_TIME_BETWEEN;
		else
			wait CONST_MINE_PLANT_CHECK_DELAY;
			
	}
}

behavior_special_ai_mine_place( loc_struct )
{
	assertex( !isdefined( loc_struct.occupied ), "Claymore placed on already occupied location." );
	
	// Do not endon ai_behavior_change as this behavior
	// takes priority over new behavior
	self endon( "death" );
	
	self.planting = true;
	self notify( "ai_behavior_change" );
	
	loc_struct.occupied = true;
	
	self thread mine_ai_planting_death( loc_struct );
		
	goal_radius = self.goalradius;
	self.goalradius = 48;
	self.ignoreall = true;
	self.ignoreme = true;
	
	self setgoalpos( loc_struct.origin );
	
	msg = self waittill_any_timeout( 13, "goal", "bad_path" );
	
	if ( msg != "goal" )
	{
		loc_struct.occupied = undefined;
		
		if ( msg == "bad_path" )
		{
			// Remove invalid location
			level.so_mine_locs = array_remove_nokeys( level.so_mine_locs, loc_struct );
			
			// JC-ToDo: Add debug draw logic to identify invalid locations in the map
		}
	}
	else
	{
		self allowedstances( "crouch" );
		
		wait 1.0;
		
		mine = undefined;
		
		ai_ref = self get_ai_type_ref();
		if ( ai_ref == "claymore" )
		{
			mine = self claymore_create( loc_struct.origin, loc_struct.angles );
		
			mine playsound( "so_claymore_plant" );
			
			mine thread claymore_on_trigger();
			mine thread claymore_on_damage();
			mine thread claymore_on_emp();
			
			level notify( "ai_claymore_planted" );
		}
		else if ( ai_ref == "chemical" )
		{
			mine = self chembomb_create( loc_struct.origin, loc_struct.angles );
			
			mine playsound( "so_claymore_plant" );
			
			mine thread chembomb_on_trigger();
			mine thread chembomb_on_damage();
			
			level notify( "ai_chembomb_planted" );
		}
		else
		{
			AssertMsg( "Invalid AI type told to plant mine: " + ai_ref );
		}
		
		AssertEx( IsDefined( mine ), "Failed to create mine using AI Type: " + ai_ref );

		// If a mine was successfully created store it and continue
		if ( IsDefined( mine ) )
		{
			if ( !isdefined( level.so_mines ) )
				level.so_mines = [];
			level.so_mines[ level.so_mines.size ] = mine;
			
			mine thread mine_on_death( loc_struct );
			
			wait 0.25;
			
			// Drop the weight down so AI don't place at the same point
			// over and over
			loc_struct.weight *= 0.5;
		}
	}
	
	self allowedstances( "prone", "crouch", "stand" );
	self.goalradius = goal_radius;
	self.ignoreall = false;
	self.ignoreme = false;
	
	self.planting = undefined;
	self notify( "planting_done" );
	
	// Go back to basic aggressing or default behavior
	ai_ref = self get_ai_type_ref();
	if ( ai_ref == "claymore" )
	{
		self thread behavior_special_ai_claymore();
	}
	else if ( ai_ref == "chemical" )
	{
		self thread behavior_special_ai_chemical();
	}
}

mine_ai_planting_death( loc_struct )
{	
	self endon( "planting_done" );
	level endon( "special_op_terminated" );
	
	self waittill( "death" );
	
	loc_struct.occupied = undefined;
}

claymore_create( origin, angles, drop )
{
	assert( isdefined( origin ) );
	assert( isdefined( angles ) );
	
	claymore = spawn( "script_model", origin );
	claymore setmodel( "weapon_claymore" );
	
	if ( !isdefined( drop ) || drop )
		claymore.origin = drop_to_ground( origin, 12, -120 );
	
	claymore.angles = (0, angles[ 1 ], 0);
	
	playfxontag( getfx( "claymore_laser" ), claymore, "tag_fx" );
	
	if ( isdefined( self ) && isalive( self ) )
		claymore.owner = self;
	
	return claymore;
}

claymore_on_trigger()
{
	self endon( "death" );
	level endon( "special_op_terminated" );

	trig_spawn_flags = 6;	// AI_ALLIES AI_NEUTRAL & player
	
	trig_claymore = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - CONST_CLAYMORE_ENT_TRIG_RADIUS ), trig_spawn_flags, CONST_CLAYMORE_ENT_TRIG_RADIUS, CONST_CLAYMORE_ENT_TRIG_RADIUS * 2 );

	self thread mine_delete_on_death( trig_claymore );

	while ( 1 )
	{
		trig_claymore waittill( "trigger", activator );

		if ( isdefined( self.owner ) && activator == self.owner )
			continue;
		
		if ( isdefined( self.disabled ) )
		{
			self waittill( "enabled" );
			continue;	
		}
		
		if ( activator claymore_on_trigger_laser_check( self ) )
		{
			self notify( "triggered" );	
			self claymore_detonate( CONST_CLAYMORE_ENT_TIMER );
			
			return;
		}
	}
}

// Ripped right from mp/_weapons.gsc - Joe
claymore_on_trigger_laser_check( claymore )
{
	if ( isDefined( claymore.disabled ) )
		return false;

	pos = self.origin + ( 0, 0, 32 );

	dirToPos = pos - claymore.origin;
	claymoreForward = anglesToForward( claymore.angles );

	dist = vectorDot( dirToPos, claymoreForward );
	if ( dist < CONST_CLAYMORE_ENT_TRIG_DIST_MIN )
		return false;

	dirToPos = vectornormalize( dirToPos );
	
	dot = vectorDot( dirToPos, claymoreForward );
	
	if ( !isdefined( level.so_claymore_trig_dot ) )
		level.so_claymore_trig_dot = cos( CONST_CLAYMORE_ENT_TRIG_ANGLE );
	
	return( dot > level.so_claymore_trig_dot );
}

claymore_detonate( timer )
{
	assert( isdefined( self ) );
	
	if ( isdefined( self.so_claymore_activated ) )
		return;
		
	self.so_claymore_activated = true;
	
	level endon( "special_op_terminated" );
		
	self playsound( "claymore_activated_SP" );
	
	if ( isdefined( timer ) && timer > 0 )
		wait timer;

	assert( isdefined( self ) );
	
	self playsound( "detpack_explo_main", "sound_done" );
	playfx( level._effect[ "claymore_explosion" ], self.origin );
	physicsexplosioncylinder( self.origin, CONST_CLAYMORE_ENT_PHYS_RADIUS, 1, CONST_CLAYMORE_ENT_PHYS_FORCE );
	earthquake( CONST_CLAYMORE_ENT_QUAKE_SCALE, CONST_CLAYMORE_ENT_QUAKE_TIME, self.origin, CONST_CLAYMORE_ENT_QUAKE_RADIUS );
	
	stopfxontag( getfx( "claymore_laser" ), self, "tag_fx" );
	
	radiusdamage( self.origin, CONST_CLAYMORE_ENT_DMG_RADIUS, CONST_CLAYMORE_ENT_DMG_MAX, CONST_CLAYMORE_ENT_DMG_MIN, undefined, "MOD_EXPLOSIVE" );

	level.so_mine_last_detonate_time = gettime();
	
	if ( isdefined( self ) )
		self delete();	
}

mine_delete_on_death( trig )
{
	level endon( "special_op_terminated" );
	
	self waittill( "death" );

	level.so_mines = array_remove_nokeys( level.so_mines, self );
	
	wait 0.05;
	
	if ( isdefined( trig ) )
		trig delete();
}

claymore_on_damage()
{
	self endon( "death" );
	self endon( "triggered" );
	
	level endon( "special_op_terminated" );

	// Apparently health has to be set before candamage so that health can be set after... - JC
	self.health = 100;
	self setcandamage( true );
	self.maxhealth = 100000;
	self.health = self.maxhealth;
	
	self waittill( "damage", amount, attacker );
	
	timer = 0.05;
	if ( mine_so_detonated_recently() )
		timer = 0.1 + randomfloat( 0.4 );
		
	self claymore_detonate( timer );
}

mine_so_detonated_recently()
{
	return IsDefined( level.so_mine_last_detonate_time ) && gettime() - level.so_mine_last_detonate_time < 400;
}

// JC-ToDo: Currently there is no script logic managing emp_damage
// delegation like there is in multiplayer so this won't ever run.
claymore_on_emp()
{
	self endon( "death" );
	self endon( "triggered" );
	
	level endon( "special_op_terminated" );

	while( 1 )
	{
		self waittill( "emp_damage", attacker, duration );

		plaYfxOnTag( getfx( "claymore_disabled" ), self, "tag_origin" );

		self.disabled = true;
		self notify( "disabled" );

		wait( duration );

		self.disabled = undefined;
		self notify( "enabled" );
	}	
}

mine_on_death( struct_loc )
{
	assertex( isdefined( struct_loc ) && isdefined( struct_loc.occupied ), "Mine on death called on undefined entity or mine that was not occupied." );
	
	level endon( "special_op_terminated" );
	
	self waittill( "death" );
	struct_loc.occupied = undefined;
}

// ==========================================================================
// CHEMICAL WARFARE AI
// ==========================================================================

behavior_special_ai_chemical()
{
	// If currently planting ignore new behavior calls from the
	// survival wave logic
	if ( isdefined( self.planting ) )
		return;
		
	self endon( "death" );
	self endon( "ai_behavior_change" );
	
	// setup AI chemical ability
	if ( !isdefined( self.special_ability ) )
		self thread chemical_ability();
	
	engage_min_dist				= 0;
	engage_min_dist_fall_off	= 0;
	
	if ( isdefined( self.aggressing ) && self.aggressing )
	{
		engage_min_dist 			= CONST_GENERIC_AI_ENGAGE_MIN;
		engage_min_dist_fall_off	= CONST_GENERIC_AI_ENGAGE_MIN_FALL_OFF;
		self.goalradius = CONST_CHEMICAL_GOAL_RADIUS_AGGRESSIVE;
		
		self enable_heat_behavior( true );
		self disable_surprise();
	}
	else
	{
		engage_min_dist				= 120;
		engage_min_dist_fall_off	= 60;
		self.goalradius = CONST_CHEMICAL_GOAL_RADIUS_DEFAULT;
	}
	
	self setengagementmindist( engage_min_dist, engage_min_dist_fall_off );
	self setengagementmaxdist( 512, 768 );
	
	self thread manage_ai_relative_to_player( CONST_AI_UPDATE_DELAY, self.goalradius, "ai_behavior_change" );
}

chemical_ability()
{
	self.special_ability = true;
	
	self.ignoresuppression 				= true;
	self.no_pistol_switch 				= true;
	self.noRunNGun 						= true;
	self.disableExits 					= true;
	self.disableArrivals 				= true;
	self.disableBulletWhizbyReaction 	= true;
	self.combatMode 					= "no_cover";
	self.neverSprintForVariation 		= true;
	
	// Prevent laying down with tank
	self disable_long_death();
	
	self disable_surprise();
	
	tank = self chemical_ability_attach_tank( "tag_shield_back", (0,0,0), (0,90,0) );
	
	self thread chemical_ability_tank_spew( tank );
	self thread chemical_ability_on_tank_damage( tank );
	self thread chemical_ability_on_death( tank );
}

chemical_ability_attach_tank( tag, origin_offset, angle_offset )
{	
	tank = spawn( "script_model", self gettagorigin( tag ) + origin_offset );
	tank setmodel( "gas_canisters_backpack" );
	tank.health = 99999;
	tank setcandamage( true );
	
	tank linkto( self, tag, origin_offset, angle_offset );
	
	return tank;
}

chemical_ability_tank_spew( tank )
{
	self endon( "death" );
	tank endon( "death" );
	
	while( 1 )
	{
		playfxontag( getfx( "chemical_tank_smoke" ), self, "tag_shield_back" );
		wait 0.05;
	}
}

chemical_ability_on_tank_damage( tank )
{
	self endon( "death" );
	self endon( "tank_detonated" );
	
	level endon( "special_op_terminated" );

	while( 1 )
	{
		tank waittill( "damage", damage, attacker, dir, point, dmg_type, model, tag, part, dFlags, weapon );
		
		if	( 
			isPlayer( attacker ) 
		||	dmg_type == "MOD_EXPLOSIVE"
		||	dmg_type == "MOD_GRENADE" 
		||	dmg_type == "MOD_GRENADE_SPLASH"
			)
		{
			// Thread because this function ends on death
			self thread so_survival_kill_ai( attacker, dmg_type, weapon );
			return;
		}
	}
}

chemical_ability_on_death( tank )
{
	self endon( "tank_detonated" );
	
	level endon( "special_op_terminated" );
	
	self waittill( "death", attacker );
	
	if ( !isdefined( self ) )
	{
		if ( isdefined( tank ) )
		{
			wait 0.05;
			tank delete();
		}
		return;
	}
	
	self thread chemical_ability_detonate( tank, attacker );
}

chemical_ability_detonate( tank, attacker )
{
	if ( !isdefined( tank ) || isdefined( tank.detonated ) )
		return;
		
	tank.detonated = true;
	
	//Assert( isdefined( self ), "Self not valid after death for tank detonation. This shouldn't happen." );
	if ( !isdefined( self ) )
		return;
	
	self notify( "tank_detonated" );
	explode_origin = self.origin;
	
	tank playsound( "detpack_explo_main", "sound_done" );
	PhysicsExplosionCylinder( explode_origin, CONST_CHEMICAL_TANK_PHYS_RADIUS, 1, CONST_CHEMICAL_TANK_PHYS_FORCE );
	earthquake( CONST_CHEMICAL_TANK_QUAKE_SCALE, CONST_CHEMICAL_TANK_QUAKE_TIME, explode_origin, CONST_CHEMICAL_TANK_QUAKE_RADIUS );
	
	// Clear removed attacker reference
	attacker = ter_op( isdefined( attacker ), attacker, undefined );
	
	// Trying not having the tank do damage so tanks don't chain react
	//tank radiusdamage( tank.origin, CONST_CHEMICAL_TANK_DMG_RADIUS, CONST_CHEMICAL_TANK_DMG_MAX, CONST_CHEMICAL_TANK_DMG_MIN, attacker, "MOD_GRENADE_SPLASH" );
	
	// Smoke
	playfx( getfx( "chemical_tank_explosion" ), explode_origin );
	
	thread chemical_ability_gas_cloud( explode_origin, CONST_CHEMICAL_CLOUD_LIFE_TIME, CONST_CHEMICAL_CLOUD_BADPLACE_LIFE_TIME );
	
	tank unlink();
	// Wait at least 0.05 to avoid error: cannot delete during think :-/
	wait 0.05;
	tank delete();
}

chemical_ability_gas_cloud( cloud_origin, cloud_time, bad_place_time )
{
	level endon( "special_op_terminated" );
	
	trig_spawn_flags = 7;	// AI_AXIS AI_ALLIES AI_NEUTRAL player	
	trig_smoke = spawn( "trigger_radius", cloud_origin + ( 0, 0, 0 - CONST_CHEMICAL_CLOUD_TRIG_RADIUS ), trig_spawn_flags, CONST_CHEMICAL_CLOUD_TRIG_RADIUS, CONST_CHEMICAL_CLOUD_TRIG_RADIUS * 2 );
	BadPlace_Cylinder( "", bad_place_time, cloud_origin, CONST_CHEMICAL_CLOUD_TRIG_RADIUS, CONST_CHEMICAL_CLOUD_TRIG_RADIUS, "axis", "allies" );
	
	trig_smoke endon( "smoke_done" );
	trig_smoke thread do_in_order( ::_wait, cloud_time, ::send_notify, "smoke_done" );
	
	while ( 1 )
	{
		trig_smoke waittill( "trigger", activator );
		
		if ( !isdefined( activator ) || !isalive( activator ) )
			continue;
		
		// If the player isn't currently gassed, gas them
		// with the appropriate shell shock
		if ( isplayer( activator ) )
		{
			// If player is down don't stomp the laststand shocks
			if ( is_player_down( activator ) || is_player_down_and_out( activator ) )
				continue;
				
			// Don't gas if player is already gassed
			if ( isdefined( activator.gassed ) )
				continue;
			
			shock_type = "";
			current_time = gettime();
			
			if	(
				!isdefined( activator.gassed_before )
			||	( isdefined( activator.gas_time ) && current_time - activator.gas_time > CONST_CHEMICAL_CLOUD_SHOCK_TIME * 1000 )
				)
			{
				shock_type = "radiation_low";
			}
			else
			{
				if ( activator.gas_shock == "radiation_low" )
					shock_type = "radiation_med";
				else
					shock_type = "radiation_high";
			}
			
			activator.gassed_before = true;
			activator.gas_shock = shock_type;
			activator.gas_time = current_time;
			activator shellshock( shock_type, CONST_CHEMICAL_CLOUD_SHOCK_TIME );
			
			activator.gassed = true;
			activator thread chemical_ability_remove_gas_flag( CONST_CHEMICAL_CLOUD_SHOCK_DELAY );
		}
		
		if ( isAI( activator ) )
		{
			// JC-ToDo: Add AI gas functionality, vomitting, running away, etc.	
		}
	}
}

chemical_ability_remove_gas_flag( delay )
{
	assertex( isdefined( self ) && isdefined( self.gassed ), "Invalid self or missing gas flag to remove" );
	self endon( "death" );
	wait delay;
	self.gassed = undefined;
}

chembomb_create( origin, angles, drop )
{
	assert( isdefined( origin ) );
	assert( isdefined( angles ) );
	
	chembomb = spawn( "script_model", origin );
	chembomb setmodel( "ims_scorpion_explosive1" );
	
	if ( !isdefined( drop ) || drop )
	{
		// Drop to the ground with an offset since
		// the model origin is lower than the claymore
		chembomb.origin = drop_to_ground( origin, 12, -120 ) + ( 0, 0, 5 );
	}

	chembomb.angles = (0, angles[ 1 ], 0);
	
	chembomb.tag_origin = chembomb spawn_tag_origin();
	
	chembomb.tag_origin LinkTo( chembomb, "tag_explosive1", (0,0,6), (-90, 0, 0) );
	
	PlayFXOnTag( getfx( "chemical_mine_spew" ), chembomb.tag_origin, "tag_origin" );
	
	if ( isdefined( self ) && isalive( self ) )
		chembomb.owner = self;
	
	return chembomb;
}

chembomb_on_trigger()
{
	self endon( "death" );
	level endon( "special_op_terminated" );

	trig_spawn_flags = 6;	// AI_ALLIES AI_NEUTRAL & player
	
	trig_mine = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - CONST_CHEMBOMB_ENT_TRIG_RADIUS ), trig_spawn_flags, CONST_CHEMBOMB_ENT_TRIG_RADIUS, CONST_CHEMBOMB_ENT_TRIG_RADIUS * 2 );

	self thread mine_delete_on_death( trig_mine );
	
	while ( 1 )
	{
		trig_mine waittill( "trigger", activator );

		if ( isdefined( self.owner ) && activator == self.owner )
			continue;
		
		if ( isdefined( self.disabled ) )
		{
			self waittill( "enabled" );
			continue;	
		}
		
		self notify( "triggered" );	
		self chembomb_detonate( CONST_CHEMBOMB_ENT_TIMER );
		return;
	}
}

chembomb_on_damage()
{
	self endon( "death" );
	self endon( "triggered" );
	
	level endon( "special_op_terminated" );

	// Apparently health has to be set before candamage so that health can be set after... - JC
	self.health = 100;
	self setcandamage( true );
	self.maxhealth = 100000;
	self.health = self.maxhealth;
	
	self waittill( "damage", amount, attacker );
	
	timer = 0.05;
	if ( mine_so_detonated_recently() )
		timer = 0.1 + randomfloat( 0.4 );
		
	self chembomb_detonate( timer );
}

chembomb_detonate( timer )
{
	Assert( IsDefined( self ) );
	
	if ( IsDefined( self.chembomb_activated ) )
		return;
		
	self.chembomb_activated = true;
	
	level endon( "special_op_terminated" );
		
	self PlaySound( "claymore_activated_SP" );
	
	if ( IsDefined( timer ) && timer > 0 )
		wait timer;

	Assert( IsDefined( self ) );
	
	level.so_mine_last_detonate_time = GetTime();
	
	self PlaySound( "detpack_explo_main", "sound_done" );
	PhysicsExplosionCylinder( self.origin, CONST_CHEMICAL_TANK_PHYS_RADIUS, 1, CONST_CHEMICAL_TANK_PHYS_FORCE );
	Earthquake( CONST_CHEMICAL_TANK_QUAKE_SCALE, CONST_CHEMICAL_TANK_QUAKE_TIME, self.origin, CONST_CHEMICAL_TANK_QUAKE_RADIUS );
	
	// Smoke
	PlayFX( getfx( "chemical_tank_explosion" ), self.origin );
	
	// Turn off spew
	StopFXOnTag( getfx( "chemical_mine_spew" ), self.tag_origin, "tag_origin" );
	
	thread chemical_ability_gas_cloud( self.origin, CONST_CHEMBOMB_CLOUD_LIFE_TIME, CONST_CHEMBOMB_CLOUD_BADPLACE_LIFE_TIME );
	
	self.tag_origin Delete();
	
	// Prevent cannot delete during think error though may not
	// be necessary because it's not linked... -JC
	wait 0.05;
	
	if ( IsDefined( self ) )
		self Delete();
}

// ==========================================================================
// DOG TEST
// ==========================================================================

dog_relocate_init()
{
	level.dog_reloc_trig_array = getentarray( "dog_relocate", "targetname" );
	
	if ( !isdefined( level.dog_reloc_trig_array ) || level.dog_reloc_trig_array.size == 0 )
		return;
		
	foreach ( loc_trig in level.dog_reloc_trig_array )
	{
		assert( isdefined( loc_trig.target ) );
		reloc_struct = getstruct( loc_trig.target, "targetname" );
		loc_trig.reloc_origin = reloc_struct.origin;
		loc_trig thread dog_reloc_monitor();
	}
}

dog_reloc_monitor()
{
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		self waittill( "trigger", player );
		while ( player istouching( self ) )
		{
			player.dog_reloc = self.reloc_origin;
			wait 0.05;
		}
		player.dog_reloc = undefined;
	}
}

spawn_dogs( dog_type, quantity )
{
	level endon( "special_op_terminated" );
	level endon( "wave_ended" );
	
	if ( !isdefined( dog_type ) || dog_type == "" || !isdefined( quantity ) || !quantity )
		return;
	
	level.dogs = [];
	
	// spawn far away from both players
	avoid_locs = [];
	foreach ( player in level.players )
		avoid_locs[ avoid_locs.size ] = player;

	dog_spawner			= getentarray( "dog_spawner", "targetname" )[ 0 ];
	assertex( isdefined( dog_spawner ), "No dog spawner while trying to spawn dog; targetname = dog_spawner" );
	
	// dog_setup() will gives dogs c4 if this is true
	level.dogs_attach_c4 = isdefined( dog_type ) && dog_type == "dog_splode";
	
	// doggy go!
	dog_spawner add_spawn_function( ::dog_setup );
	dog_spawner add_spawn_function( ::dog_seek_player );
	dog_spawner add_spawn_function( ::dog_register_death );	
	
	for ( i = 0; i < quantity; i ++ )
	{	
		spawn_loc 			= get_furthest_from_these( level.wave_spawn_locs, avoid_locs, 4 );
		dog_spawner.count 	= 1;
		dog_spawner.origin 	= spawn_loc.origin;
		dog_spawner.angles 	= spawn_loc.angles;
		wait_between_spawn 	= int ( ( (CONST_DOG_SPAWN_OVER_TIME-10) + randomint(10) )/quantity );
		
		// Let get_dog_count() know a dog is on the way
		level.survival_dog_spawning = true;
		
		doggy = dog_spawner spawn_ai( true );
		
		doggy.ai_type = get_ai_struct( dog_type );
		doggy setthreatbiasgroup( "dogs" );
		doggy [[ level.attributes_func ]](); // dog gets: health and speed from this func

		doggy.canclimbladders = false;

		//assertex( isdefined( doggy ), "Doggy failed to spawn even though it was forced spawned." );
		level.dogs[ level.dogs.size ] = doggy;
		
		// Dog has now been spawned and is in the level.dogs array
		level.survival_dog_spawning = undefined;
		
		// if aggressive, then send out all dogs
		if ( !flag( "aggressive_mode" ) )
			waittill_any_timeout( wait_between_spawn, "aggressive_mode" );
		
		wait 0.05; // in case aggressive_mode is triggered in the same frame
	}
}

dog_setup()
{
	// Make dogs ignore other dogs c4. I mean c'mon, they're dogs. They don't know any better.
	// ... or do they? DON DON DONGGG!
	self.badplaceawareness = 0;
	self.grenadeawareness = 0;
	
	if ( isdefined( level.dogs_attach_c4 ) && level.dogs_attach_c4 )
	{
		self thread attach_c4( "j_hip_base_ri", (6,6,-3), (0,0,0) );
		self thread attach_c4( "j_hip_base_le", (-6,-6,3), (0,0,0) );
		
		// Keep c4 time consistent with martyrdom c4. If the dog
		// is killed during pin this function adjustst the time
		self thread detonate_c4_when_dead( CONST_MARTYRDOM_C4_TIMER, CONST_MARTYRDOM_C4_TIMER_SUBSEQUENT );
		
		// Make sure dogs do not get stuck behind sentry guns
		self thread dog_detonate_c4_near_sentry();
	}
}

dog_detonate_c4_near_sentry()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	self endon( "c4_detonated" );
	
	pos_saved		= self.origin;
	pos_curr		= self.origin;
	loc_new_time	= GetTime();
	
	while ( 1 )
	{
		wait 0.2;
		
		// Adjust the time for the new location
		// if the dog moved or if the dog is meleeing.
		// Resetting the time if the dog is meleeing
		// prevents the dog from prematurely detonating
		// if he's on top of the player near a sentry
		pos_curr	= self.origin;
		time_curr	= GetTime();
		
		if ( DistanceSquared( pos_curr, pos_saved ) > squared( CONST_DOG_SAME_LOC_THRESHOLD ) || self animscripts\dog\dog_combat::inSyncMeleeWithTarget() )
		{
			pos_saved		= pos_curr;
			loc_new_time	= time_curr;
		}
		
		// Early out if there are not sentries to worry about
		if ( !IsDefined( level.placed_sentry ) || !level.placed_sentry.size )
			continue;
		
		// Early out if the dog has moved recently
		if ( time_curr - loc_new_time < CONST_DOG_TIME_STATIC_TO_DETONATE )
			continue;
		
		// See if the dog is near a sentry
		close_to_sentry = false;
		foreach ( sentry in level.placed_sentry )
		{
			if ( IsDefined( sentry.carrier ) )
				continue;
	
			if ( DistanceSquared( pos_curr, sentry.origin ) < squared( CONST_DOG_DIST_TO_SENTRY_DETONATE ) )
			{
				close_to_sentry = true;
				break;
			}
		}
		
		// If we've gotten here the dog hasn't moved recently. If the dog is 
		// close to a sentry break out of the loop so the dog can force detonate
		// Else the dog is not close to a sentry so reset the dog's last time moved 
		// because his current location doesn't count.
		if ( close_to_sentry )
		{
			break;
		}
		else
		{
			pos_saved = pos_curr;
			loc_new_time = time_curr;
		}
			
	}
	
	// Stop the dog from moving and or attacking
	// as the detonate starts
	self notify( "stop_dog_seek_player" );
	self.ignoreall 	= true;
	self SetGoalPos( self.origin );
	
	self notify( "force_c4_detonate" );
}

dog_register_death()
{
	self waittill( "death" );
	
	level.dogs = dog_get_living();
}

dog_seek_player()
{
	level endon( "special_op_terminated" );
	level endon( "wave_ended" );
	self endon( "death" );
	self endon( "stop_dog_seek_player" );
	
	// TO DO: Tweak
	self.moveplaybackrate	= 0.75;
	self.goalheight			= 80;
	self.goalradius			= 300;
	
	update_delay = 1.0;
	
	while ( 1 )
	{
		closest_player = get_closest_player_healthy( self.origin );
		if ( !IsDefined( closest_player ) )
		{
			closest_player = get_closest_player( self.origin );
		}
		
		if ( IsDefined( closest_player ) )
		{
			bCanSee = self canSee( closest_player );
			meToPlayerSq = DistanceSquared( self.origin, closest_player.origin );

			if ( IsDefined( closest_player.dog_reloc ) )
			{
				self SetGoalPos( closest_player.dog_reloc );
			}
			else if ( (!bCanSee || meToPlayerSq > 1024*1024) && IsDefined( closest_player.node_closest ) )
			{
				// apparently our dogs are bred for moving straight to the player whenever
				// they can, regardless of what goal pos you suggest to them.  if the player
				// is within the goal radius to the goal pos, the dog will path to the player
				// instead of the goal pos.  therefore, set the goal radius to something
				// miniscule to short circuit that logic in code.
				self SetGoalPos( closest_player.node_closest.origin );
				self.goalradius = 24;
			}
			else
			{
				// reset goal radius
				self SetGoalPos( closest_player.origin );
				self.goalradius = 384;
			}
		}
		
		wait update_delay;
	}
}

// This function returns the count of dogs currently alive
// as well as any dog that is currently getting spawned
// this frame. This is to handle the frame delay that happens
// when spawn_ai() is called in the threaded spawn_dogs() func
dog_get_count()
{
	dog_count = dog_get_living().size;
	
	if ( isdefined( level.survival_dog_spawning ) )
		dog_count++;
	
	return dog_count;
}

// Returns all living dogs not including a dog that
// has spawned but is in spawn_failed() phase of
// spawn_ai()
dog_get_living()
{
	if ( !isdefined( level.dogs ) )
	{
		level.dogs = [];
		return level.dogs;
	}
	
	dog_array = [];
	foreach( dog in level.dogs )
	{
		if ( isdefined( dog ) && isalive( dog ) )
			dog_array[ dog_array.size ] = dog;
	}
	
	return dog_array;	
}

// ==========================================================================
// JUGGERNAUT BOSSES
// ==========================================================================

survival_boss_juggernaut()
{
	// juggernaut currently is handled by _so_survival.gsc
}

is_juggernaut_used( AI_bosses )
{
	foreach( boss_ref in AI_bosses )
		if ( issubstr( boss_ref, "jug_" ) )	
			return true;
			
	return false;
}

spawn_juggernaut( boss_ref, path_start )
{
	//iprintlnbold( "Boss: Juggernaut!" );
	level endon( "special_op_terminated" );
	
	// there is a wait in drop_jug_by_chopper
	boss = drop_jug_by_chopper( boss_ref, path_start );
	
	if ( !isdefined( boss ) )
		return;

	// keeps track of boss type on boss AI
	boss.ai_type = get_ai_struct( boss_ref );
	
	// setup custom assist xp
	boss.kill_assist_xp = int( get_ai_xp( boss_ref ) * 0.2 );
	
	// give juggernaut loot if any is available
	boss maps\_so_survival_loot::loot_roll( 0.0 );
	
	level.bosses[ level.bosses.size ] = boss;
	
	// Wait till the vehicle is done with the Juggernaut before
	// setting him up
	boss waittill( "jumpedout" );
	level notify( "juggernaut_jumpedout" );
	
	boss thread survival_boss_behavior();
	boss thread clear_from_boss_array_when_dead();
}

// spawn juggernaut by spawner_type and dropped in by chopper
drop_jug_by_chopper( spawner_type, chopper_path )
{
	spawner = get_spawners_by_targetname( spawner_type )[ 0 ];
	assertex( isdefined( spawner ), "Type: " + spawner_type + " does not have a spawner present in level." );
	
	// plays money FX when dead
	spawner add_spawn_function( ::money_fx_on_death );

	// This flags the desired path as in use before a potential wait occurs
	// because a chopper spawner is in use
	chopper = chopper_spawn_from_targetname_and_drive( "jug_drop_chopper", chopper_path.origin, chopper_path );
	chopper thread maps\_chopperboss::chopper_path_release(  "reached_dynamic_path_end death deathspin" );
	
	// Juggernaut choppers should not get shot down.
	chopper godon();
	
	// removed from remote missile targeting due to this chopper being in godon mode
	//chopper thread maps\_remotemissile_utility::setup_remote_missile_target();
	
	chopper.script_vehicle_selfremove = true;
	chopper Vehicle_SetSpeed( 60 + randomint(15), 30, 30 );
	chopper thread chopper_drop_smoke_at_unloading();
	
	// load pilot and the Juggernaut
	chopper chopper_spawn_pilot_from_targetname( "jug_drop_chopper_pilot" );
	boss = chopper chopper_spawn_passenger( spawner );
	
	boss deletable_magic_bullet_shield();
	boss thread do_in_order( ::waittill_any, "jumpedout", ::stop_magic_bullet_shield );
	boss setthreatbiasgroup( "boss" );

	return boss;
}

// progressively behave or look different when damaged
progressive_damaged()
{
	self endon( "death" );
	self endon( "new_jug_behavior" );
	
	while ( 1 )
	{
		if ( self.health <= CONST_JUG_WEAKENED )
		{
			self.walkDist 				= CONST_JUG_WEAKENED_RUN_DIST;
			self.walkDistFacingMotion 	= CONST_JUG_WEAKENED_RUN_DIST;
		}
		else
		{
			self.walkDist 				= CONST_JUG_RUN_DIST; //500;
			self.walkDistFacingMotion 	= CONST_JUG_RUN_DIST; //500;
		}

		// TO DO: armor plate falling and different behaviors
		wait 0.05;
	}	
}

// AI damage factors, amount of damage taken per damage type and hit location
damage_factor()
{
/*  "MOD_UNKNOWN"
	"MOD_PISTOL_BULLET"
	"MOD_RIFLE_BULLET"
	"MOD_GRENADE"
	"MOD_GRENADE_SPLASH"
	"MOD_PROJECTILE"	
	"MOD_PROJECTILE_SPLASH"
	"MOD_MELEE"
	"MOD_HEAD_SHOT"
	"MOD_CRUSH"
	"MOD_TELEFRAG"	
	"MOD_FALLING"
	"MOD_SUICIDE"
	"MOD_TRIGGER_HURT"
	"MOD_EXPLOSIVE"
	"MOD_IMPACT"		*/	

	self endon( "death" );
	self endon( "new_jug_behavior" );
	
	// need this so we dont have anything else increasing its health when hit
	self.bullet_resistance = 0;
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );
		
		// No damage modification when bullet shield is on
		if ( isdefined( self.magic_bullet_shield ) )
			continue;
		
		// damage types:
		damage_heal = 0;
		headshot = false;
		
		if ( IsDefined( attacker ) && IsAI( attacker ) && self.team != attacker.team )
		{
			damage_heal = self dmg_factor_calc( amount, self.dmg_factor[ "ai_damage" ] );
		}
		else if( type == "MOD_MELEE" )
		{
			if ( isdefined( attacker ) && isplayer( attacker ) && isdefined( weapon ) && IsSubStr( weapon, "iw5_riotshield_so" ) )
				damage_heal = self dmg_factor_calc( amount, self.dmg_factor[ "melee_riotshield" ] );
			else
				damage_heal = self dmg_factor_calc( amount, self.dmg_factor[ "melee" ] );
		}
		else if	(	
			   type == "MOD_EXPLOSIVE"
			|| type == "MOD_GRENADE" 
			|| type == "MOD_GRENADE_SPLASH" 
			|| type == "MOD_PROJECTILE" 
			|| type == "MOD_PROJECTILE_SPLASH" 
				)
		{
			damage_heal = self dmg_factor_calc( amount, self.dmg_factor[ "explosive" ] );
		}
		else
		{
			// damage locations:
			if(	self was_headshot() )
			{
				damage_heal = self dmg_factor_calc( amount, self.dmg_factor[ "headshot" ] );
				headshot = true;
			}
			else
				damage_heal = self dmg_factor_calc( amount, self.dmg_factor[ "bodyshot" ] );
		}
		
		damage_heal = int( damage_heal );
		
		if ( damage_heal < 0 && abs( damage_heal ) >= self.health )
		{
			// If we're force killing the AI make sure to flag that it was a headshot
			// so that the was_headshot() function in survival code can return correctly.
			if ( headshot )
				self.died_of_headshot = true;
					
			// Thread because this function ends on death
			self thread so_survival_kill_ai( attacker, type, weapon );
		}
		else
		{
			self.health += damage_heal;
		}
		
		self notify( "dmg_factored" );
	}
}

dmg_factor_calc( amount, dmg_factor )
{
	damage_heal = 0;
	
	if ( isdefined( dmg_factor ) && dmg_factor )
		damage_heal = int( amount * ( 1 - dmg_factor ) );
		
	return damage_heal;
}

// global juggernaut behavior
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
global_jug_behavior()
{
	// damge taken: (0-1) 1 = full damage - no shield; 0 = no damage - full shield
	self.dmg_factor[ "headshot" ] 			= 1;	// 100% damage to head
	self.dmg_factor[ "bodyshot" ] 			= 1;	// 100% damage to rest of body
	self.dmg_factor[ "melee" ] 				= 1;	// 100% damage by melee
	self.dmg_factor[ "melee_riotshield" ] 	= 1;	// 100% damage by riotshield
	self.dmg_factor[ "explosive" ] 			= 1;	// 100% damage by explosives
	self.dmg_factor[ "ai_damage" ]			= 1;	// 100% damage by other AI

	self.dropweapon = false;
	self.minPainDamage = CONST_JUG_MIN_DAMAGE_PAIN;
	self set_battlechatter( false );
	self.aggressing = true;
	self.dontMelee = undefined;
	self.meleeAlwaysWin	= true;
	
	self thread damage_factor();
	self thread progressive_damaged();
}

boss_jug_helmet_pop( health_percent, arr_dmg_factor )
{
	assertex( isdefined( self.dmg_factor ) && self.dmg_factor.size, "Juggernaut passed without dmg_factor array filled." );
	
	self endon( "death" );
	
	health_original = self.health;
	if ( isdefined( self.ai_type ) )
		health_original = self get_ai_health( self.ai_type.ref );
	
	while ( 1 )
	{
		if ( self.health / health_original <= health_percent )
		{
			self animscripts\death::helmetpop();
			
			dmg_factor_size = self.dmg_factor.size;
			self.dmg_factor = array_combine_keys( self.dmg_factor, arr_dmg_factor );
			assertex( self.dmg_factor.size == dmg_factor_size, "Damage factor array size changed, passed factor array had invalid keys." );
			
			return;
		}
		
		self waittill( "dmg_factored" );
	}
}

// regular juggernaut behavior
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
boss_jug_regular()
{
	self.dmg_factor[ "headshot" ] 			= CONST_JUG_LOW_SHIELD;
	self.dmg_factor[ "bodyshot" ] 			= CONST_JUG_MED_SHIELD;
	self.dmg_factor[ "melee" ] 				= CONST_JUG_HIGH_SHIELD;
	self.dmg_factor[ "melee_riotshield" ] 	= CONST_JUG_HIGH_SHIELD;
	self.dmg_factor[ "explosive" ] 			= CONST_JUG_MED_SHIELD;
	self.dmg_factor[ "ai_damage" ]			= CONST_JUG_MED_SHIELD;
	
	self setengagementmindist( 100, 60 );
	self setengagementmaxdist( 512, 768 );

	// Pulled from Juggernaut Hunting logic
	self.goalradius = 128;
	self.goalheight = 81;
	
//	Jug Does not currently have a helmet that can be popped
	// Pop helmet and adjust damage factor
//	arr_dmg_adjust = [];
//	arr_dmg_adjust[ "headshot" ] = CONST_JUG_KILL_ON_PAIN;
//	arr_dmg_adjust[ "explosive" ] = CONST_JUG_NO_SHIELD;
//	self thread boss_jug_helmet_pop( CONST_JUG_POP_HELMET_HEALTH_PERCENT, arr_dmg_adjust );
	
	// Hunt player
	self thread manage_ai_relative_to_player( 2.0, self.goalradius, "new_jug_behavior", "stop_hunting" );
}

// juggernaut headshot only behavior
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

boss_jug_headshot()
{
	// strong against all by the head
	self.dmg_factor[ "headshot" ] 			= CONST_JUG_NO_SHIELD;
	self.dmg_factor[ "bodyshot" ] 			= CONST_JUG_MED_SHIELD;
	self.dmg_factor[ "melee" ] 				= CONST_JUG_HIGH_SHIELD;
	self.dmg_factor[ "melee_riotshield" ] 	= CONST_JUG_HIGH_SHIELD;
	self.dmg_factor[ "explosive" ] 			= CONST_JUG_NO_SHIELD;
	self.dmg_factor[ "ai_damage" ]			= CONST_JUG_HIGH_SHIELD;
	
	self setengagementmindist( 100, 60 );
	self setengagementmaxdist( 512, 768 );
	
	// Pulled from Juggernaut Hunting logic
	self.goalradius = 128;
	self.goalheight = 81;
	
	// Hunt player
	self thread manage_ai_relative_to_player( 2.0, self.goalradius, "new_jug_behavior", "stop_hunting" );
}

// juggernaut explosive only behavior
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
boss_jug_explosive()
{
	// explosives best, defense against
	self.dmg_factor[ "headshot" ] 			= CONST_JUG_MED_SHIELD;
	self.dmg_factor[ "bodyshot" ] 			= CONST_JUG_HIGH_SHIELD;
	self.dmg_factor[ "melee" ] 				= CONST_JUG_HIGH_SHIELD;
	self.dmg_factor[ "melee_riotshield" ] 	= CONST_JUG_HIGH_SHIELD;
	self.dmg_factor[ "explosive" ] 			= CONST_JUG_MED_SHIELD;
	self.dmg_factor[ "ai_damage" ]			= CONST_JUG_HIGH_SHIELD;

	self setengagementmindist( 100, 60 );
	self setengagementmaxdist( 512, 768 );
	
	// Pulled from Juggernaut Hunting logic
	self.goalradius = 128;
	self.goalheight = 81;
	
	// Hunt player
	self thread manage_ai_relative_to_player( 2.0, self.goalradius, "new_jug_behavior", "stop_hunting" );
}

// juggernaut riotshield behavior
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
boss_jug_riotshield()
{
	self endon( "death" );
	self endon( "riotshield_damaged" );
	
	// weak against all but it has a riot shield
	self.dmg_factor[ "headshot" ] 			= CONST_JUG_LOW_SHIELD;
	self.dmg_factor[ "bodyshot" ] 			= CONST_JUG_LOW_SHIELD;
	self.dmg_factor[ "melee" ] 				= CONST_JUG_MED_SHIELD;
	self.dmg_factor[ "melee_riotshield" ] 	= CONST_JUG_MED_SHIELD;
	self.dmg_factor[ "explosive" ] 			= CONST_JUG_NO_SHIELD;
	self.dmg_factor[ "ai_damage" ]			= CONST_JUG_HIGH_SHIELD;
	
	self.dropRiotshield = true;
	
	// NOTE: Since subclass_riotshield() is called instead of subclass_juggernaut()
	//       We must take what is in subclass_juggernaut() that doesn't conflict with riotshield
	//		 and place it here for correct juggernaut behavior while using riotshield.
	self subclass_juggernaut_riotshield();
	
	// Drop the shield when damaged or when health low
	self thread juggernaut_abandon_shield();
	
	if ( CONST_JUG_RIOTSHIELD_BULLET_BLOCK )
		self.shieldBulletBlockLimit = 9999; // no reaction to bullet hits on shield

	self setengagementmindist( 100, 60 );
	self setengagementmaxdist( 512, 768 );
	
	// Pulled from Juggernaut Hunting logic
	self.goalradius = 128;
	self.goalheight = 81;
	self.usechokepoints = false;
	
	// Hunt player
	self thread manage_ai_relative_to_player( 2.0, self.goalradius, "new_jug_behavior", "stop_hunting" );
	
	thread juggernaut_manage_min_pain_damage();
	
}

// This needs to be set over and over because riotshield
// logic sets the min pain damage at certain points. Even
// once the juggernaut has transitioned to from riotshield
// to regular residual riotshield logic waiting for animations
// to finish can then change this field back. For this reason
// don't endon riotshield_damaged
juggernaut_manage_min_pain_damage()
{
	self endon( "death" );
	
	while ( 1 )
	{
		if ( self.health <= CONST_JUG_WEAKENED )
			self.minPainDamage = CONST_JUG_MIN_DAMAGE_PAIN_WEAK;
		else
			self.minPainDamage = CONST_JUG_MIN_DAMAGE_PAIN;
		wait 0.05;
	}
}

subclass_juggernaut_riotshield()
{
	self.juggernaut 					= true;

	//self.grenadeAmmo 					= 0;
	self.doorFlashChance 				= .05;
	self.aggressivemode 				= true;
	self.ignoresuppression 				= true;
	self.no_pistol_switch 				= true;
	self.noRunNGun 						= true;
	//self.dontMelee 					= true;
	
	// This breaks sprint functionality in _riotshield.gsc
	//self.disableExits 				= true;
	
	self.disableArrivals 				= true;
	self.disableBulletWhizbyReaction 	= true;
	self.combatMode 					= "no_cover";
	self.neverSprintForVariation 		= true;
	self.a.disableLongDeath 			= true;
	self.pathEnemyFightDist 			= 128;
	self.pathenemylookahead 			= 128;
	
	self disable_turnAnims();
	self disable_surprise();
	
	// Riotshield Juggernauts always win melee
	self.meleeAlwaysWin					= true;
	
	if( !self isBadGuy() )
		return;
	
	// we already have looping music
	//self thread maps\_juggernaut::juggernaut_sound_when_player_close();
	
	level notify( "juggernaut_spawned" );
	self thread subclass_juggernaut_death();
}

juggernaut_abandon_shield()
{
	self endon( "death" );
	
	self thread juggernaut_abandon_shield_low_health( CONST_JUG_DROP_SHIELD_HEALTH_PERCENT );
	
	self waittill( "riotshield_damaged" );
	wait 0.05; // waittill variant riotshield model is set up
	
	self AI_drop_riotshield();

	if ( !isAlive( self ) )
		return;
	
	self animscripts\riotshield\riotshield::riotshield_turn_into_regular_ai();
	
	// turn regular AI into juggernaut again
	self thread maps\_juggernaut::subclass_juggernaut();	// restore regular juggernaut settings
	
	// End existing manage_ai() and damage_factor() threads
	self notify( "new_jug_behavior" );
	
	// run regular juggernaut behavior
	self global_jug_behavior();
	self thread boss_jug_regular();
}

juggernaut_abandon_shield_low_health( health_percent )
{
	self endon( "death" );
	self endon( "riotshield_damaged" );
	
	health_original = self.health;
	if ( isdefined( self.ai_type ) )
	{
		health_original = self get_ai_health( self.ai_type.ref );
	}
	
	while ( 1 )
	{
		self waittill( "damage" );
		
		if ( self.health / health_original <= health_percent )
		{
			// Drop shield
			self notify( "riotshield_damaged" );
			return;
		}
	}
}

subclass_juggernaut_death()
{
	self endon( "new_jug_behavior" );
	self waittill( "death", attacker );
	
	// if riotshield, we drop shield
	self AI_drop_riotshield();	
	
	level notify( "juggernaut_died" );
	
	if ( ! isdefined( self ) )
		return;// deleted
	if ( ! isdefined( attacker ) )
		return;
	if ( ! isplayer( attacker ) )
		return;

	//attacker player_giveachievement_wrapper( "IM_THE_JUGGERNAUT" );
}

// ==========================================================================
// ENEMY CHOPPER BOSS
// ==========================================================================

survival_boss_chopper()
{
	level.chopper_boss_min_dist2D = 128;
	maps\_chopperboss::chopper_boss_locs_populate( "script_noteworthy", "so_chopper_boss_path_struct" );
}

survival_drop_chopper_init()
{
	// precalculating ground drop positions for drop choppers 
	// this avoids traces that could lead to drop chopper dropping in mid air
	start_array = getstructarray( "drop_path_start", "targetname" );
	foreach ( start_node in start_array )
	{
		cur_node = start_node;
		while( isdefined( cur_node ) )
		{
			if ( isdefined( cur_node.script_unload ) )
			{
				cur_node.ground_pos = groundpos( cur_node.origin );
				break;
			}
			
			if ( isdefined( cur_node.target ) )
			{
				cur_node = getstruct( cur_node.target, "targetname" );
			}
			else
			{
				assertmsg( "Drop chopper path is missing .script_unload on an unload struct." );
				break;
			}
		}
	}
}

spawn_chopper_boss( boss_ref, path_start )
{		
	//iprintlnbold( "Boss: " + boss_ref );
	level endon( "special_op_terminated" );
	
	// chopper health defined from string table is set by chopper_spawn_from_targetname(...)
	chopper_boss = chopper_spawn_from_targetname( boss_ref, path_start.origin );
	chopper_boss chopper_spawn_pilot_from_targetname( "jug_drop_chopper_pilot" );

	chopper_boss thread maps\_remotemissile_utility::setup_remote_missile_target();

	// sets ai_type attribute struct
	chopper_boss.ai_type = get_ai_struct( boss_ref );
	chopper_boss [[ level.attributes_func ]](); // chopper gets speed set in this func
	
	// xp reward init for this vehicle - AIs spawned with _spawner.gsc run this already
	if ( isdefined( level.xp_enable ) && level.xp_enable )
		chopper_boss thread maps\_rank::AI_xp_init();
	
	// setup custom assist xp
	chopper_boss.kill_assist_xp = int( get_ai_xp( boss_ref ) * 0.2 );
	
	level.bosses[ level.bosses.size ] = chopper_boss;
	
	// Chopper uses its own behavior function vs other AIs
	chopper_boss thread maps\_chopperboss::chopper_boss_behavior_little_bird( path_start );
	chopper_boss thread maps\_chopperboss::chopper_path_release( "death deathspin" );
	chopper_boss thread clear_from_boss_array_when_dead();

	chopper_boss setthreatbiasgroup( "boss" );
	setthreatbias( "sentry", "boss", 1500 );// make the boss a bigger threat to allies
	
	// Increase the turret aim down arc
	foreach ( turret in chopper_boss.mgturret )
	{
		turret setbottomarc( 90 );
	}

	return chopper_boss;
}



// ==========================================================================
// ALLY AI
// ==========================================================================

spawn_ally_team( ally_ref, count, path_start, owner )
{
	ally_team = [];
	
	ally_spawner = get_spawners_by_targetname( ally_ref )[ 0 ];
	assertex( isdefined( ally_spawner ), "No ally spawner with targetname: " + ally_ref );
	
	if ( !isdefined( ally_spawner ) )
		return ally_team;
	
	chopper = chopper_spawn_from_targetname_and_drive( "ally_drop_chopper", path_start.origin, path_start );
	chopper thread maps\_chopperboss::chopper_path_release( "reached_dynamic_path_end death deathspin" );
	
	chopper godon();
	chopper Vehicle_SetSpeed( 60 + randomint(15), 30, 30 );	
	chopper.script_vehicle_selfremove = true;
	
	// In case the chopper can be killed
	chopper endon( "death" );
	
	chopper chopper_spawn_pilot_from_targetname( "friendly_support_delta" );
	
	for ( i = 0; i < count; i++ )
	{
		ally = chopper chopper_spawn_passenger( ally_spawner, i + 2 );
		ally set_battlechatter( false );
		ally deletable_magic_bullet_shield();
		ally thread ally_remove_bullet_shield( CONST_ALLY_BULLET_SHIELD_TIME, "jumpedout" );
		ally setthreatbiasgroup( "allies" );
		ally.ignoreme = true;
		
		// Setup Ally stats such as speed, health and accuracy
		ally.ai_type = get_ai_struct( ally_ref );
		ally [[ level.attributes_func ]]();
		
		// Give Ally weapons
		ally thread setup_AI_weapon();
		
		// Attach owner to be used in XP distribution
		ally.owner = owner;
		
		ally_team[ ally_team.size ] = ally;
		
		ally.headiconteam 	= "allies";
		if ( ally_ref == "friendly_support_delta" )
		{
			ally.headicon 	= "headicon_delta_so";
		}
		if ( ally_ref == "friendly_support_riotshield" )
		{
			ally.headicon 	= "headicon_gign_so";
		}
		
		ally.drawoncompass = false;
		
		wait 0.05;
	}
	
	// Additional Ally Setup to happen post unload
	chopper thread ally_team_setup( ally_team );
	
	return ally_team;
}

_GetEye()
{
	// self is AI or player
	if ( isdefined( self ) && isalive( self ) )
		return self geteye();
	
	return undefined;
}

ally_team_setup( allies )
{
	assertex( isdefined( self ), "Chopper not passed as self so unloaded cannot be waited for." );
	assertex( isdefined( allies ) && allies.size, "Invalid or empty ally array." );
	
	self endon( "death" );
	
	self waittill( "unloaded" );
	
	array_thread( allies, ::ally_setup );
}

ally_setup()
{
	if ( !isdefined( self ) || !isalive( self ) )
		return;
	
	self setengagementmindist( 300, 200 );
	self setengagementmaxdist( 512, 768 );
	
	self.goalradius = CONST_ALLY_GOAL_RADIUS;
	if ( isdefined( self.ai_type ) && IsSubStr( self.ai_type.ref, "riotshield" ) )
	{
		self.goalradius = CONST_ALLY_GOAL_RADIUS_RIOTSHIELD;
		self setengagementmindist( 200, 100 );
		self setengagementmaxdist( 512, 768 );
		
		self thread drop_riotshield_think();
		
		//self set_ai_bcvoice( "american" );
		//self maps\_names::get_name();
		
		// riotshield ally
		self thread ally_manage_min_pain_damage( 300 );
	}
	else
	{
		// regular ally
		self thread ally_manage_min_pain_damage( 150 );
	}

	self.ignoreme 			= false;
	self.fixednode 			= false;
	self.dropweapon 		= false;
	self.dropRiotshield 	= true;
	self.drawoncompass 		= true;
	
	self set_battlechatter( true );
	self PushPlayer( false );
	
	self.bullet_resistance = 30;
	//self remove_damage_function( maps\_spawner::bullet_resistance );
	
	self thread ally_on_death();
	self thread manage_ai_relative_to_player( CONST_AI_UPDATE_DELAY, self.goalradius );
}

ally_manage_min_pain_damage( minPainDamage )
{
	self endon( "death" );
	
	while ( 1 )
	{
		self.minPainDamage = minPainDamage;
		wait 0.05;
	}
}


drop_riotshield_think()
{
	self endon( "death" );
	
	self waittill_any_return( "riotshield_damaged", "dog_attacks_ai" );
	wait 0.05; // waittill variant riotshield model is set up
	
	self AI_drop_riotshield();

	if ( !isAlive( self ) )
		return;
	
	self animscripts\riotshield\riotshield::riotshield_turn_into_regular_ai();
}

ally_remove_bullet_shield( timer, wait_before_timer )
{
	assertex( isdefined( timer ), "Timer undefined." );
	self endon( "death" );
	
	if ( isdefined( wait_before_timer )	)
		self waittill( wait_before_timer );
	
	wait timer;
	
	self stop_magic_bullet_shield();
}

ally_on_death()
{
	self waittill( "death" );
	
	if( isdefined( self.owner ) && isalive( self.owner ) )
		self.owner notify( "ally_died" );
		
	// if riotshield, we drop shield
	self AI_drop_riotshield();
}

// ==========================================================================
// UTILITY FUNCTIONS
// ==========================================================================

setup_AI_weapon()
{
	// self is AI
	waittillframeend;
	assertex( isdefined( self.ai_type ), "AI attributes aren't set correctly, or function call too early" );
	
	// Only give loot to axis
	if ( isdefined( self.team ) && self.team == "axis" )
	{
		self maps\_so_survival_loot::loot_roll();
	}
	
	assertex( isdefined( level.coop_incap_weapon ), "Default secondary weapon should be defined." );
	
	if ( isdefined( level.coop_incap_weapon ) )
	{
		self.sidearm = level.coop_incap_weapon;
		place_weapon_on( self.sidearm, "none" );
		
		//self forceUseWeapon( level.coop_incap_weapon, "sidearm" );
	}
	
	forced_weapon = get_ai_weapons( self.ai_type.ref )[ 0 ];
	
	assertex( isdefined( forced_weapon ), "Regular or Special AI did not return a weapon which could cause them to use their SP weapon." );
	
	if ( !isdefined( forced_weapon ) || forced_weapon == self.weapon )
		return;
	
	self forceUseWeapon( forced_weapon, "primary" );
	
	assertex( self.weapon == forced_weapon, "Force weapon failed to set " + forced_weapon + "as the primary weapon." );
	assertex( self.primaryweapon == forced_weapon, "Force weapon failed to set " + forced_weapon + "as the primary weapon." );
}

get_all_mine_locs()
{
	claymore_locs = getstructarray( "so_claymore_loc", "targetname" );
	return claymore_locs;
}

// AI Management Utils ==============================================================

AI_drop_riotshield()
{	
	// If AI was deleted, we don't drop shield.
	if ( !isdefined( self ) )
		return;
	
	// if riotshield, we drop shield
	if ( isdefined( self.weaponInfo[ "iw5_riotshield_so" ] ) )
	{
		position = self.weaponInfo[ "iw5_riotshield_so" ].position;
		
		if ( isdefined( self.dropriotshield ) && self.dropriotshield && position != "none" )
			self thread animscripts\shared::DropWeaponWrapper( "iw5_riotshield_so", position );
			
		self animscripts\shared::detachWeapon( "iw5_riotshield_so" );
		
		self.weaponInfo[ "iw5_riotshield_so" ].position = "none";
		self.a.weaponPos[ position ] = "none";
	}	
}

manage_ai_relative_to_player( update_delay, goal_radius, endons, notifies )
{
	assert( isdefined( update_delay ) );

	level endon( "special_op_terminated" );
	self endon( "death" );
	
	self.goalradius = ter_op( isdefined( goal_radius ), goal_radius, self.goalradius );
	self.goalheight = 80;
	if ( isdefined( endons ) )
	{
		arr_endons = strtok( endons, " " );
		foreach ( e in arr_endons )
			self endon( e );
	}
	
	if ( isdefined( notifies ) )
	{	
		arr_notifies = strtok( notifies, " " );
		foreach ( n in arr_notifies )
			self notify( n );
	}

	// JC-ToDo: Currently this cleanup from data being potentially
	// left changed from a previous behavior is minimal and manageable.
	// At the same time it's super ugly and error prone. Each behavior
	// should have specific logic called or that it calls on endon to
	// clean up any AI data left changed such as sprint, goal radius,
	// move play back, etc. Currently it's only sprint.
	
	// In case the sprint / fast walk was left on when a thread was ended
	self survival_disable_sprint();
	
	first_update = true;
	last_target = undefined;
	
	while ( 1 )
	{
		close_player = get_closest_player_healthy( self.origin );
		if ( !IsDefined( close_player ) )
		{
			close_player = get_closest_player( self.origin );
		}
		
		if ( !isdefined( close_player ) )
		{
			wait update_delay;
			continue;
		}

		if ( self.team == "allies" )
		{
			if ( distancesquared( self.origin, close_player.origin ) > self.goalradius * self.goalradius )
			{
				self setgoalentity( close_player );
				wait 2;
				continue;
			}
		}
		else
		{
			// filthy dirty stand-in for a real hunt behavior.
			// if i'm reasonably close to the enemy, just know where he is.
			if ( distancesquared( self.origin, close_player.origin ) < self.goalradius * self.goalradius )
				self GetEnemyInfo( close_player );
		}

		if ( !isdefined(last_target) || last_target != close_player )
		{
			last_target = close_player;
			self SetGoalEntity( close_player );

			self notify( "target_reset" );
			self thread bad_path_listener( close_player );
		}

		if ( first_update )
		{	
			first_update = false;
			
			// On the first update give the AI the enemy info 
			// of each player. This fixes a bug where AI
			// that spawn within their goalradius of the
			// closest player never would get their goal entity
			// set causing them to sit in their idle animation
			// until the player comes into view
			if ( self.team == "axis" )
			{
				self GetEnemyInfo( close_player );
			}
		}
		self survival_disable_sprint();
		
		if ( self.team == "allies" )
		{
			// Only have friendlies reset their goal pos,
			// enemies should continue to head to the player
			self SetGoalPos( self.origin );
			
			// Riotshield guys don't like to stop so
			// shrink their goalradius briefly to force
			// a stop
			if ( IsDefined( self.subclass )	&& self.subclass == "riotshield" )
			{
				wait( RandomFloatRange( 0.2, 2.0 ) );
				curr_radius = self.goalradius;
				self.goalradius = 1.0;
				wait 0.1;
				self.goalradius = curr_radius;
			}
		}
		

		
		wait update_delay;
	}
}

bad_path_listener( target )
{
	self endon( "target_reset" );
	self endon( "death" );

	assert( isdefined( target ) );

	while ( true )
	{
		// listen for if the actor gets a bad_path notification while attempting
		// to path to the player, his goal entity.
		self waittill( "bad_path" );

		if ( isdefined( target.node_closest ) )
		{
			// boo, we can't get to the player!  luckily, he's been leaving us
			// a trail of breadcrumbs to follow.  try heading for the last one.
			self SetGoalPos( target.node_closest.origin );

			last_player_pos = target.origin;

			// we want to try pathing to the player again eventually.
			// wait for the player to move from the position that caused us
			// to fail.
			while ( distanceSquared( last_player_pos, target.origin ) < 144 )
				wait( 0.5 );

			// try again!
			self SetGoalEntity( target );
		}
	}
}

manage_ai_poll_player_state( close_player )
{
	self endon( "death" );
	self endon( "manage_ai_stop_polling_player_state" );
	
	while ( 1 )
	{
		wait 0.1;
		
		if	(	
			!isdefined( close_player )
		||	!isalive( close_player )
		||	is_player_down( close_player )
			)
		{
			self notify( "manage_ai_player_invalid" );
			return;
		}
		else if ( distancesquared( self.origin, close_player.origin ) <= self.goalradius * self.goalradius )
		{
			self notify( "manage_ai_player_found" );
			return;
		}
	}
}

manage_ai_go_to_player_node( player )
{
	AssertEx( IsDefined( player.node_closest ), "Player did not have closest_node defined, this should always be defined." );
	if ( IsDefined( player.node_closest ) )
	{
		// Use SetGoalPos because multiple AI cannot be told
		// to go to the same node
		self SetGoalPos( player.node_closest.origin );
	}
}

survival_enable_sprint()
{
	if ( isdefined( self.subclass ) && self.subclass == "riotshield" )
	{
		if ( isdefined( self.juggernaut ) )
		{
			//self maps\_riotshield::riotshield_fastwalk_on();
		}
		else
		{
			//self maps\_riotshield::riotshield_sprint_on();
		}
	}
	else
	{
		// Juggernauts have the sprint field turned on and
		// regular AI stop using cover. Sprint is not
		// turned on for regular AI because it causes them
		// to not play transition animations properly
		if ( isdefined( self.juggernaut ) )
			self enable_sprint();
		else
			self.combatMode = "no_cover";
	}
}

survival_disable_sprint()
{
	if ( isdefined( self.subclass ) && self.subclass == "riotshield" )
	{
		if ( isdefined( self.juggernaut ) )
		{
			//self maps\_riotshield::riotshield_fastwalk_off();
		}
		else
		{
			//self maps\_riotshield::riotshield_sprint_off();
		}
	}
	else
	{
		// Juggernauts have the sprint field turned off and
		// regular AI go back to using cover. Sprint was 
		// not turned on for regular AI because it causes
		// them to not play transition animations properly
		if ( isdefined( self.juggernaut ) )
			self disable_sprint();
		else
			self.combatMode = "cover";
	}
}

// AI TYPE HOOKS ==============================================================
// tablelookup( stringtable path, search column, search value, return value at column );

ai_exist( ref )
{
	return isdefined( level.survival_ai ) && isdefined( level.survival_ai[ ref ] );
}

get_ai_index( ref )
{
	if ( ai_exist( ref ) )
		return level.survival_ai[ ref ].idx;
	
	return int( tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_INDEX ) );	
}

get_ai_ref_by_index( idx )
{
	return tablelookup( WAVE_TABLE, TABLE_INDEX, idx, TABLE_AI_REF );
}

get_ai_struct( ref )
{
	msg = "Trying to get survival AI_type struct before stringtable is ready, or type doesnt exist.";
	assertex( ai_exist( ref ), msg );
	
	return level.survival_ai[ ref ];
}

get_ai_classname( ref )
{
	if ( IsDefined( level.survival_ai_class_overrides ) && IsDefined( level.survival_ai_class_overrides[ ref ] ) )
		return level.survival_ai_class_overrides[ ref ];
	
	if ( ai_exist( ref ) )
		return level.survival_ai[ ref ].classname;
		
	return tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_CLASSNAME );
}

get_ai_weapons( ref )
{
	if ( IsDefined( level.survival_ai_weapon_overrides ) && IsDefined( level.survival_ai_weapon_overrides[ ref ] ) )
		return level.survival_ai_weapon_overrides[ ref ];
	
	if ( ai_exist( ref ) )
		return level.survival_ai[ ref ].weapon;
		
	weapons = tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_WEAPON );
	return strtok( weapons, " " );
}

get_ai_alt_weapons( ref )
{
	if ( ai_exist( ref ) )
		return level.survival_ai[ ref ].altweapon;
		
	weapons = tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_ALT_WEAPON );
	return strtok( weapons, " " );
}

get_ai_name( ref )
{
	if ( ai_exist( ref ) )
		return level.survival_ai[ ref ].name;
		
	return tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_NAME );
}

get_ai_desc( ref )
{
	if ( ai_exist( ref ) )
		return level.survival_ai[ ref ].desc;
		
	return tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_DESC );
}

get_ai_health( ref )
{
	// Scale health as waves repeat to increase difficulty
	if ( isdefined( level.survival_waves_repeated ) )
		repeat_scale_health = 1.0 + level.survival_waves_repeated * CONST_AI_REPEAT_BOOST_HEALTH;
	else
		repeat_scale_health = 1.0;
	
	if ( ai_exist( ref ) )
		return int( level.survival_ai[ ref ].health * repeat_scale_health );
	
	health = tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_HEALTH );
	if ( health == "" )
		return undefined;
		
	return int ( int( health ) * repeat_scale_health );
}

get_ai_speed( ref )
{
	// Scale speed as waves repeat to increase difficulty
	if ( isdefined( level.survival_waves_repeated ) )
		repeat_scale_speed = 1.0 + level.survival_waves_repeated * CONST_AI_REPEAT_BOOST_SPEED;
	else
		repeat_scale_speed = 1.0;
	
	if ( ai_exist( ref ) )
		return Min( level.survival_ai[ ref ].speed * repeat_scale_speed, CONST_AI_SPEED_MAX );
	
	speed = tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_SPEED );
	if ( speed == "" )
		return undefined;
			
	return Min( float( speed ) * repeat_scale_speed, CONST_AI_SPEED_MAX );
}

get_ai_accuracy( ref )
{
	// Scale accuracy as waves repeat to increase difficulty
	if ( isdefined( level.survival_waves_repeated ) )
		repeat_scale_accuracy = 1.0 + level.survival_waves_repeated * CONST_AI_REPEAT_BOOST_ACCURACY;
	else
		repeat_scale_accuracy = 1.0;
	
	if ( ai_exist( ref ) )
	{
		if ( isdefined( level.survival_ai[ ref ].accuracy ) )
			return level.survival_ai[ ref ].accuracy * repeat_scale_accuracy;
		else
			return level.survival_ai[ ref ].accuracy;
	}
	
	accuracy = tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_ACCURACY );
	if ( accuracy == "" )
		return undefined;
	
	return float( accuracy ) * repeat_scale_accuracy;	
}

get_ai_xp( ref )
{
	if ( ai_exist( ref ) )
		return level.survival_ai[ ref ].xp;
	
	XP_reward = tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_XP );
	if ( XP_reward == "" )
		return undefined;	
	
	return int( XP_reward );
}

is_ai_boss( ref )
{
	if ( ai_exist( ref ) && isdefined( level.survival_boss ) )
		return isdefined( level.survival_boss[ ref ] );
		
	Var1 = tablelookup( WAVE_TABLE, TABLE_AI_REF, ref, TABLE_AI_BOSS );
	
	if ( !isdefined( Var1 ) || Var1 == "" )
		return false;

	return true;
}

// WAVE HOOKS ==============================================================
// tablelookup( stringtable path, search column, search value, return value at column );
// level.wave_table can be overriden per level

wave_exist( wave_num )
{
	return isdefined( level.survival_wave ) && isdefined( level.survival_wave[ wave_num ] );
}

get_wave_boss_delay( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].bossDelay;
	
	return int( tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_BOSS_DELAY ) );	
}

get_wave_index( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].idx;
	
	return int( tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_INDEX ) );
}

get_wave_number_by_index( index )
{
	return int( tablelookup( level.wave_table, TABLE_INDEX, index, TABLE_WAVE ) );	
}


get_squad_type( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].squadType;
	
	return tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_SQUAD_TYPE );	
}

// breaks down the squad AI count into groups of 3s and 2s
get_squad_array( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].squadArray;
	
	// logic to convert single squad ai count number into an array of squads of 2-4 per
	squad_array = [];
	ai_count = int( tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_SQUAD_SIZE ) );
	
	if ( ai_count <= 3 )
	{
		squad_array[ 0 ] = ai_count;
	}
	else
	{
		remainder 	= ai_count % 3;
		squad_count = int( ai_count / 3 );
		
		// if remainder is 0
		for ( i=0; i<squad_count; i++ )
			squad_array[ i ] = 3;
		
		if ( remainder == 1 )
		{
			if ( level.merge_squad_member_max == 4 )
			{
				// if merge happens at max 4, then avoid 2 squads of 2 and joining up right after spawn
				// exchange ( ex: 3,3,3,1 -> 3,3,4 )
				squad_array[ squad_array.size - 1 ] += remainder;
			}
			else
			{
				// exchange ( ex: 3,3,3,1 -> 3,3,2,2 )
				exchange = 1;
				squad_array[ squad_array.size - 1 ] -= ( exchange );
				squad_array[ squad_array.size ] = remainder + ( exchange );
			}
		}
		else if ( remainder == 2 )
		{
			squad_array[ squad_array.size ] = remainder;
		}
	}
	
	return squad_array;
}

// string[] - array of special ais
get_special_ai( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].specialAI;

	specials = tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_SPECIAL );
	
	if ( isdefined( specials ) && specials != "" )
		return strtok( specials, " " );

	return undefined;
}

// int[] - array of quantities per special ai type, synced with get_special_ai( wave_num )'s array by index
get_special_ai_quantity( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].specialAIquantity;
	
	special_nums = tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_SPECIAL_NUM );
	
	// convert to array of ints
	special_num_array = [];
	if ( isdefined( special_nums ) && special_nums != "" )
	{
		special_nums = strtok( special_nums, " " );
		for( i=0; i<special_nums.size; i++ )
			special_num_array[ i ] = int( special_nums[ i ] );
		
		return special_num_array;
	}
	
	return undefined;
}

// int - get special ai quantity by type
get_special_ai_type_quantity( wave_num, ai_type )
{
	assertex( isdefined( ai_type ), "ai_type is not defined while trying to get quantity for type." );
	
	special_ai_array 			= get_special_ai( wave_num );
	special_ai_quantity_array 	= get_special_ai_quantity( wave_num );
	
	if ( isdefined( special_ai_array ) 
		&& isdefined( special_ai_quantity_array )
		&& special_ai_array.size 
		&& special_ai_quantity_array.size 
	)
	{
		foreach( index, special in special_ai_array )
		{
			if ( ai_type == special )
				return special_ai_quantity_array[ index ];
		}
	}
	
	// if none specified, then dont spawn
	return 0;
}

get_bosses_ai( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].bossAI;

	bosses = tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_BOSS_AI );

	if ( isdefined( bosses ) && bosses != "" )
		return strtok( bosses, " " );

	return undefined;
}

get_bosses_nonai( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].bossNonAI;
		
	bosses = tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_BOSS_NONAI );

	if ( isdefined( bosses ) && bosses != "" )
		return strtok( bosses, " " );
		
	return undefined;
}

is_repeating( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].repeating;
		
	return int( tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_REPEAT ) );	
}

// returns armory type if armory is unlocked at the end of this wave
get_armory_unlocked( wave_num )
{
	armory_unlock_array = tablelookup( level.wave_table, TABLE_WAVE, wave_num, TABLE_ARMORY_UNLOCK );	
	armory_unlock_array = strtok( armory_unlock_array, " " );
	return armory_unlock_array;
}

get_dog_type( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].dogType;
	
	special_array = get_special_ai( wave_num );
	if ( !isdefined( special_array ) || !special_array.size )
		return "";
	
	foreach ( special in special_array )
	{
		if ( issubstr( special, "dog" ) )
			return special;
	}
	
	return "";
}

get_dog_quantity( wave_num )
{
	if ( wave_exist( wave_num ) )
		return level.survival_wave[ wave_num ].dogQuantity;
	
	dog_type = get_dog_type( wave_num );
	if ( !isdefined( dog_type ) )
		return 0;
	
	return get_special_ai_type_quantity( wave_num, dog_type );
}
