#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_so_survival_code;
#include maps\_specialops;
#include maps\_so_survival_AI;
#include maps\_so_survival_dialog;
#include maps\_hud_util;

// ======================================================================
//	Special Ops Mode: Survival
// ======================================================================

#define CONST_DEATH_FAIL_WAVE				 0	//if dead in this wave, player fails
#define CONST_CONGRAT_MIN_WAVE				 5	//past this wave #, we congrat player when dead with dialog

#define CONST_START_REV_TIMER				 120	//seconds for revivinG coop partner
#define CONST_MIN_REV_TIMER					 30	//min time for reviving coop partner
#define CONST_REV_TIMER_DECREASE			 8	//seconds decreased for reviving coop partner

#define CONST_WAVE_START_TIMEOUT			 5	//timeout that will trigger first wave if player didn't
#define CONST_WAVE_DELAY_TOTAL				 35	//total delay between waves. other delays are subtracted from this
#define CONST_WAVE_DELAY_BEFORE_READY_UP	 5	//delay before players are prompted to ready up
#define CONST_WAVE_DELAY_COUNTDOWN			 5	//time remaining when when the large countdown shows up in the center of the screen
#define CONST_WAVE_ENDED_TIMER_FADE_DELAY	 1.75	//time after a wave ending before the wave timer fades
#define CONST_WAVE_AI_LEFT_TILL_NEXT_WAVE	 0	//if only this many AIs left, next wave starts
#define CONST_WAVE_AI_LEFT_TILL_AGGRO		 4	//if only this many AIs left, AIs become aggressive

#define CONST_WAVE_REENFORCEMENT_SQUAD		 1	//number of squads to re-enforce
#define CONST_WAVE_REENFORCEMENT_SPECIAL_AI  2	//number of special AIs to re-enforce

#define CONST_CAMP_RESPONSE_INTERVAL		 8	//enemies respond to player camping every X seconds

#define CONST_ARMOR_INITIAL_DISPLAY_TIME	 14	//seconds to display armor HP when level starts
#define CONST_ARMOR_DISPLAY_TIME			 6	//seconds to display armor HP when damaged

#define CONST_DELAYED_ENEMY_PING			 7	//seconds delay before enemies show up in minimap, protect spawn locations

#define CONST_EQUIPMENT_C4_MAX				 20
#define CONST_EQUIPMENT_CLAYMORE_MAX		 20
		
// Player load out from table
#define LOADOUT_TABLE "sp/survival_waves.csv" // loadout is in waves table for now
#define TABLE_INDEX 0 // Indexing
#define TABLE_SLOT 1 // Load out slot, such as primary weapon, grenades etc...
#define TABLE_REF 2 // Reference string of the item
#define TABLE_AMMO 3 // Ammo for weapon or equipments

// Number of waves per star
#define CONST_1_STAR_REQ					 5	// survival 5 waves to earn 1 star
#define CONST_2_STAR_REQ					 10	// survival 10 waves to earn 2 stars
#define CONST_3_STAR_REQ					 20	// survival 20 waves to earn 3 stars

// get load out item reference string via slot type
get_loadout_item_ref( slot )		{ return tablelookup( level.loadout_table, TABLE_SLOT, slot, TABLE_REF ); }

// get load out item ammo if it has ammo
get_loadout_item_ammo( ref )		{ return tablelookup( level.loadout_table, TABLE_REF, ref, TABLE_AMMO ); }

// ==========================================================================
// SURVIVAL INITS
// ==========================================================================

survival_preload()
{
	maps\_so_survival_h2mod::main();

	// survival precache
	maps\so_survival_precache::main();
	
	// build ai spawner arrays
	if ( !isdefined( level.loadout_table ) )
		level.loadout_table	= LOADOUT_TABLE;
	
	level.uav_missile_override = "remote_missile_survival";
	
	level.giveXp_kill_func = maps\_so_survival_AI::giveXp_kill;
	maps\_so_survival_armory::armory_preload();
	//maps\_so_survival_loot::loot_preload(); // precached systematically
	maps\_so_survival_AI::AI_preload();
	maps\_so_survival_perks::perks_preload();
	maps\_so_survival_challenge::Precache_Challenge_Strings();
	
	PrecacheItem( "smoke_grenade_fast" );
	
	precacherumble( "damage_light" );
	
	// Minimap items
	PrecacheMinimapSentryCodeAssets();
	
	// HUD items
	PrecacheString( &"SO_SURVIVAL_SURVIVAL_OBJECTIVE" );
	PrecacheString( &"SO_SURVIVAL_WAVE_TITLE" );
	PrecacheString( &"SO_SURVIVAL_WAVE_SUCCESS_TITLE" );
	PrecacheString( &"SO_SURVIVAL_SURVIVE_TIME" );
	PrecacheString( &"SO_SURVIVAL_WAVE_TIME" );
	PrecacheString( &"SO_SURVIVAL_PARTNER_READY" );
	PrecacheString( &"SO_SURVIVAL_READY_UP_WAIT" );
	PrecacheString( &"SO_SURVIVAL_READY_UP" );
	
	// Stagger bar background shader
	PrecacheShader( "gradient_inset_rect" );
	PrecacheShader( "teamperk_blast_shield" );
	PrecacheShader( "specialty_self_revive" );
	
	// Precache weapon loadouts
	//Precache_loadout_item( get_loadout_item_ref( "weapon_1" ) );
	//Precache_loadout_item( get_loadout_item_ref( "weapon_2" ) );
	//Precache_loadout_item( get_loadout_item_ref( "weapon_3" ) );

    precachemodel("viewmodel_base_viewhands");
	precachemodel("viewhands_airport");
	precachemodel("viewhands_arctic");
	precachemodel("viewhands_marine_sniper");
	precachemodel("viewhands_player_arctic_wind");
	precachemodel("viewhands_player_iss");
	precachemodel("viewhands_player_marines");
	precachemodel("viewhands_player_tf141");
	precachemodel("viewhands_player_tf141_favela");
	precachemodel("viewhands_player_udt");
	precachemodel("viewhands_player_us_army");
	precachemodel("viewhands_player_us_army_bloody");
	precachemodel("viewhands_sas_woodland");
	precachemodel("viewhands_tf141");
	precachemodel("viewhands_tf141_favela");
	precachemodel("viewhands_udt");
	precachemodel("viewhands_udt_wet");
	precachemodel("viewhands_us_army");
	precachemodel("viewhands_us_army_dmg");

	precachemodel("viewhands_h1_usmc_desert_mp_camo");
	precachemodel("viewhands_h1_arab_desert_mp_camo");
	precachemodel("viewhands_h1_sas_ct");
	precachemodel("viewhands_h1_sas_woodland");
	precachemodel("viewhands_h1_spetsnaz");
	precachemodel("viewhands_h1_usmc_ghillie");
	
    maps\_load::set_player_viewhand_model(maps\_playerdata::get("viewhands_player"));

	// Must be threaded, there is a debug
	// wait in this call.
	thread MP_ents_cleanup();
	
	// Clean up old survival start triggers
	thread so_start_trigger_delete();
	
	level.cheap_air_strobe_fx = 1;
	
	setdvar("ui_current_score", 0);
}

get_player_viewhand_model()
{
	viewhands = maps\_playerdata::get("viewhands");

}

so_start_trigger_delete()
{
	// Some maps have triggers that set the survival start
	// flag. Find these triggers and delete them so that
	// each survival starts consistently. This is safer then
	// going through each map and deleting the triggers at this
	// point
	triggers = getentarray( "trigger_multiple_flag_set", "classname" );
	foreach ( trigger in triggers )
	{
		if ( IsDefined( trigger.script_flag ) && trigger.script_flag == "start_survival" )
			trigger trigger_off();
	}
}

hurtPlayersThink( trig )
{
	level endon( "special_op_terminated" );
	
	// self is Player
	while ( 1 ) 
	{
		trig waittill( "trigger", player );
		if ( isdefined( player ) && isplayer( player ) && player == self )
			break;
	}
	
	// ends specops due to real player death
	self kill_wrapper();
}

survival_postload()
{
	maps\_so_survival_armory::armory_postload();
	maps\_so_survival_loot::loot_postload();
}

// main survial start
survival_init()
{
	// survival flag init
	flag_init( "bosses_spawned" );
	flag_init( "aggressive_mode" );
	flag_init( "boss_music" );
	flag_init( "slamzoom_finished" );
	
	flag_set( "so_player_death_nofail" );
	
	level.custom_eog_no_defaults			= true;
	level.eog_summary_callback 				= ::custom_eog_summary;
	level.suppress_challenge_success_print 	= true;
	level.congrat_min_wave					= CONST_CONGRAT_MIN_WAVE;
	level.so_survival_score_func			= ::Survival_Leaderboard_Score_Func;
	level.so_survival_wave_func				= ::survival_leaderboard_wave_func;
	level.skip_pilot_kill_count				= true; // not counting enemy pilot kills
	
	level.uav_missle_start_forward_distance = 128.0;
	level.uav_missle_start_right_distance 	= 0.0;
	
	// this allows enemies to see player inside foliage clips!
	setsaveddvar( "ai_foliageSeeThroughDist", 50000 );
	
	// Spec Ops default is 2.0. Turn down friendly fire in Survival
	SetSavedDvar( "g_friendlyfireDamageScale", 0.5 );

	// This enables base weapons on the ground contribute ammo stock 
	// to player holding upgrade version of the same base weapon.
	// We do this becuase we are using MP weapon assets and they dont have 
	// ammo sharing setup like SP, this is to override it.
	forcesharedammo();
	
	// SpecOps inits
	thread enable_challenge_timer( "start_survival", "win_survival", undefined, true );
	thread fade_challenge_in( undefined, false );
	thread fade_challenge_out( "win_survival" );
	
	// must be before waves table setup
	level.wave_spawn_locs = maps\_squad_enemies::squad_setup( true );
	
	// inits for AI wave spawning and armory
	// these must run first due to populating string tables required
	maps\_drone_ai::init();
	maps\_so_survival_armory::armory_init();
	maps\_so_survival_loot::loot_init();
	maps\_so_survival_AI::AI_init();
	maps\_so_survival_perks::perks_init();
	maps\_so_survival_challenge::challenge_init();
	maps\_so_survival_dialog::survival_dialog_init();
	
	// Turn off deaths door audio because survival levels do
	// not support this.
	//maps\_audio::aud_disable_deathsdoor_audio();
	
	// setup player funcs on spawn
	thread setup_players();
	
	// survival logics
	thread survival_logic();
}

// calculates and sets leaderboard data for survival mode
// Player Name, Teammate Name, Score, Waves, Time Played
survival_leaderboard_wave_func()
{
	assert( isdefined( level.current_wave ) );
	return level.current_wave;
}

survival_leaderboard_score_func()
{
	assert( isdefined( level.challenge_start_time ) );
	assert( isdefined( level.challenge_end_time ) );
	assert( isdefined( level.current_wave ) );
	assert( isdefined( level.performance_bonus ) );
	
	foreach ( player in level.players )
		assert( isdefined( player.game_performance ) );

	// ================================ LEADERBOARD STATS ================================
	// write player stats data for leaderboard to use

	session_time 			= ( level.challenge_end_time - level.challenge_start_time ) / 1000;
	/*stat*/session_wave 	= level.current_wave;
		
	session_credit 			= 0;
	foreach ( player in level.players ){ session_credit += player.game_performance[ "credits" ]; }

	// 10000c per wave is target best credits
	session_credits_score 	= 999 * min( session_credit/( session_wave * 10000 ), 1.0 );
	
	// do not give wave score unless survived a wave
	if ( session_wave == 1 )
		return int( session_credits_score );
	
	session_wavescore 		= session_wave * 1000;
	/*stat*/session_score	= int( session_wavescore + session_credits_score );
	
	return session_score;
}

other_player_performance( player, ref )
{
	if ( is_coop() )
	{
		return get_other_player( player ).game_performance[ ref ];
	}
	else
	{
		return undefined;
	}
}

custom_eog_summary()
{
	// lua handler
	level notify("show_eog_summary");
}

// run the survival logic after the game loads
survival_logic()
{
	// need to wait until the first frame of the game before calling getPlayerData or setPlayerData
	// this is because we may not have our coop player stats until the game is running
	wait( 0.05 ); 
	
	// Turned off challenges for now so that people aren't getting a ton of money from completing them.
	// Need to make money and XP not exactly 1 to 1 (certain things should not give money)
	//maps\_missions::monitor_challenges();

	// player armory
	maps\_so_survival_armory::armory_setup_players();

	thread survival_music();

	thread survival_objective();
	thread survival_completion();
	//thread survival_success_or_fail();
	thread survival_wave();
	thread survival_hud();
	thread survival_credits();
	thread survival_armory_hint();
}

survival_objective()
{
	wait 2; // wait till after intro
	Objective_Add( 1, "active", &"SO_SURVIVAL_SURVIVAL_OBJECTIVE" );
	Objective_Current_NoMessage( 1 );
}

// when player dies, mission completes
survival_completion()
{
	level waittill( "so_player_has_died" );
	
	if ( !flag( "start_survival" ) )
		flag_wait( "start_survival" );
	
	// If spec ops isn't ignoring death don't set the
	// win_survival flag
	if ( !flag( "so_player_death_nofail" ) )
		return;
		
	// Record the end time for the custom end of game summary
	//level.challenge_end_time = gettime(); 
	
	// Let challenge fade out logic know that survival was a success
	flag_set( "win_survival" );
}

// Monitor player progress to catch when they've beat
// enough waves for success.
survival_success_or_fail()
{
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		level waittill( "wave_ended", wave_num );
		
		if ( wave_num >= CONST_DEATH_FAIL_WAVE )
		{
			// Tell regular spec ops logic to ignore death and
			// allow fade_challenge_out() to handle success
			flag_set( "so_player_death_nofail" );
			return;
		}
	}	
}

waittill_survival_start()
{
	flag_wait_or_timeout( "start_survival", CONST_WAVE_START_TIMEOUT );
}

// ==========================================================================
// SETUP PLAYERS
// ==========================================================================

setup_players()
{
	// setup like mplayer with no auto aim with aim assist
	if ( level.console )
	{
		SetSavedDvar( "aim_aimAssistRangeScale", "1" );
		SetSavedDvar( "aim_autoAimRangeScale", "0" );
	}
	
	hurtTriggers = getentarray( "trigger_hurt", "classname" );
	foreach( player in level.players )
	{
		player thread do_slamzoom();
		player thread give_loadout();
		
		// hurt triggers in MP maps
		foreach ( hurtTrigger in hurtTriggers )
			player thread hurtPlayersThink( hurtTrigger );
	}
	
	// player performance tracking
	thread player_performance_init();
	
	// waves spawn after this wait
	waittill_survival_start();
	
	level.so_c4_array 		= [];
	level.so_claymore_array = [];
	
	foreach( player in level.players )
	{
		player thread camping_think();
		player thread decrease_rev_time();
		player thread weapon_collect_ammo_adjust();
		player thread watch_grenade_usage();
	}
}

watch_grenade_usage()
{
	self endon( "death" );
	self endon( "disconnect" );

	self thread watch_c4_usage();
	self thread watch_claymore_usage();
}

watch_c4_usage()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for ( ; ; )
	{
		self waittill( "grenade_fire", c4, weapname );
		
		if ( IsDefined( c4 ) && IsDefined( weapname ) && 
			 IsDefined( WeaponInventoryType( weapname ) ) && WeaponInventoryType( weapname ) == "item" && 
			 IsSubStr( weapname, "c4" ) )
		{
			if ( level.so_c4_array.size )
			{
				level.so_c4_array = array_removeundefined( level.so_c4_array  );
				
				if ( level.so_c4_array.size >= CONST_EQUIPMENT_C4_MAX )
					level.so_c4_array[ 0 ] Detonate();
			}
			level.so_c4_array[ level.so_c4_array.size ] = c4;
		}
	}
}

watch_claymore_usage()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for ( ; ; )
	{
		self waittill( "grenade_fire", claymore, weapname );
		
		if ( IsDefined( claymore ) && IsDefined( weapname ) && 
			 IsDefined( WeaponInventoryType( weapname ) ) && WeaponInventoryType( weapname ) == "item" &&
			 IsSubStr( weapname, "claymore" ) )
		{
			if ( level.so_claymore_array.size )
			{
				level.so_claymore_array = array_removeundefined( level.so_claymore_array  );
				
				if ( level.so_claymore_array.size >= CONST_EQUIPMENT_CLAYMORE_MAX )
					level.so_claymore_array[ 0 ] Detonate();
			}
			level.so_claymore_array[ level.so_claymore_array.size ] = claymore;
		}
	}
}

give_loadout()
{
	// because giving equipments perks etc call setplayerdata which requires a delay
	wait 0.05;

	self endon( "death" );
	
	self setviewmodel(maps\_playerdata::get("viewhands"));

	// load out stuff
	self takeallweapons();
	
	self give_player_weapon( "weapon_1" );
	self give_player_weapon( "weapon_2" );
	self give_player_weapon( "weapon_3" );
	
	self give_player_grenade( "grenade_1" );
	self give_player_grenade( "grenade_2" );

	// armor setup and give
	self give_player_armor( "armor_1" );
	
	self give_player_equipment( "equipment_1" );
	self give_player_equipment( "equipment_2" );
	self give_player_equipment( "equipment_3" );
	
	self give_player_airsupport( "airsupport_1" );
	self give_player_airsupport( "airsupport_2" );
	self give_player_airsupport( "airsupport_3" );
	
	self give_player_perk( "perk_1" );
	self give_player_perk( "perk_2" );
	self give_player_perk( "perk_3" );

	self setactionslot(3, "altmode");
}

give_player_weapon( slot )
{
	weapon 	= get_loadout_item_ref( slot );
	ammo	= get_loadout_item_ammo( weapon );

	if (slot == "weapon_1")
	{
		custom = maps\_playerdata::get("starting_pistol");
		if (assetexists("weapon", custom))
		{
			weapon = custom;
		}
	}

	if ( weapon != "" )
	{		
		self giveweapon( weapon );
		
		// override last stand pistol weapon
		weapon_class = weaponclass( weapon );
		assert( isdefined( weapon_class ) );
		if ( weapon_class == "pistol" )
			level.coop_incap_weapon = weapon;
		
		if ( ammo == "max" )
		{
			self setweaponammostock( weapon, weaponmaxammo( weapon ) );
		}
		else
		{
			self setweaponammostock( weapon, int( ammo ) );
		}
			
		// weapon slot 1 is default switched to weapon
		if ( slot == "weapon_1" )
			self switchToWeapon( weapon );
	}
}

give_player_grenade(slot)
{
	grenade = get_loadout_item_ref(slot);
	ammo = get_loadout_item_ammo(grenade);
	
	if (grenade != "")
	{
		if (slot == "grenade_2")
		{
			self setoffhandsecondaryclass(grenade);
		}
		else
		{
			self setoffhandprimaryclass(grenade);
		}

		self giveweapon(grenade);

		if (ammo == "max")
		{
			self setweaponammostock(grenade, weaponmaxammo(grenade));

		}
		else
		{
			self setweaponammostock(grenade, int(ammo));
		}
	}
}

give_player_armor( slot )
{
	armor_type 		= get_loadout_item_ref( slot );
	armor_points 	= int( get_loadout_item_ammo( armor_type ) );
	
	if ( armor_type != "" )
	{
		self maps\_so_survival_armory::give_armor_amount( armor_type, armor_points );
	}	
}

give_player_equipment( slot )
{
	equipment = get_loadout_item_ref( slot );

	if ( equipment != "" )
	{
		give_func = self maps\_so_survival_armory::get_func_give( "equipment", equipment );
		self thread [[ give_func ]]( equipment );
	}
}

give_player_airsupport( slot )
{
	airsupport = get_loadout_item_ref( slot );

	if ( airsupport != "" )
	{
		give_func = self maps\_so_survival_armory::get_func_give( "airsupport", airsupport );
		self thread [[ give_func ]]( airsupport );
	}	
}

give_player_perk( slot )
{
	perk_ref = get_loadout_item_ref( slot );
	
	if ( perk_ref != "" )
	{
		// run perk function
		self thread maps\_so_survival_perks::give_perk( perk_ref );
	}
}

decrease_rev_time()
{
	if ( !is_coop() )
		return;
		
	while ( 1 )
	{
		level waittill( "wave_ended" );

		rev_time = CONST_START_REV_TIMER;
		rev_time = rev_time - ( level.current_wave * CONST_REV_TIMER_DECREASE );
		rev_time = max( rev_time, CONST_MIN_REV_TIMER );
		
		self.laststand_info.bleedout_time_default = rev_time;
	}
}

// Modify weapon ammo on pick up to make sure the players
// don't pick up an empty weapon. This ammo adjustment
// is only allowed to happen so often to prevent people
// from picking up weapons and dropping them and never
// having to reload
#define CONST_WEAPON_CHANGE_AMMO_ADJUST_TIME  10	// 10 second minimum between ammo adjusts on each collected weapon 

weapon_collect_ammo_adjust()
{
	Assert( IsDefined( self ) && IsPlayer( self ), "Self not player." );
	
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	if ( !IsDefined( self.survival_weapons_swapped ) )
		self.survival_weapons_swapped = [];
	
	weap_list_old = self GetWeaponsListPrimaries();
	
	while ( true )
	{
		self waittill( "weapon_change", weapon );
		
		if ( !weapon_collect_ammo_adjust_valid( weapon ) )
			continue;
		
		// If the player just switched between held weapons continue
		is_new_weapon = !array_contains( weap_list_old, weapon );
		if ( !is_new_weapon )
			continue;
		
		// If the player didn't recently collect or drop this weapon
		// attempt to adjust the ammo and record if ammo was adjusted
		if ( !weapon_collect_ammo_adjust_was_recent( weapon ) )
		{
			if ( self weapon_collect_balance_ammo( weapon ) )
			{
				self weapon_collect_record_weapon_adjusted( weapon );
			}
		}
		
		// Figure out the weapons that are no longer in the list and flag
		// them as recently adjusted. This prevents players from
		// swapping a weapon on the ground and quickly picking
		// it back to get an instant reload. Ignore invalid weapons
		weap_list_curr = self GetWeaponsListPrimaries();
		foreach ( weap_old in weap_list_old )
		{
			if ( !array_contains( weap_list_curr, weap_old ) )
			{
				if ( !weapon_collect_ammo_adjust_valid( weap_old ) )
					continue;
				
				self weapon_collect_record_weapon_adjusted( weap_old );
			}
		}
		
		weap_list_old = weap_list_curr;
		
		// Remove weapons from the collected weapons array that
		// are old to prevent the array from just getting bigger
		// and bigger
		self weapon_collect_clean_recorded_weapons();
	}
}

weapon_collect_ammo_adjust_valid( weapon_name )
{
	// WeaponClass( "none" ) is returning primary which is incorrect!
	// so check that the WeaponClass( "none" ) is "none" which works.
	// Also Ignore RPGs and Riotshields as well
	if ( WeaponClass( weapon_name ) == "none" || WeaponClass( weapon_name ) == "rocketlauncher" || WeaponClass( weapon_name ) == "item" )
		return false;
	
	// Also make sure we're only changing primary weapons
	if ( WeaponInventoryType( weapon_name ) != "primary" )
		return false;
	
	return true;
}

weapon_collect_ammo_adjust_was_recent( weapon_name )
{
	Assert( IsDefined( self ) && IsPlayer( self ), "Self not player." );
	
	if ( !IsDefined( self.survival_weapons_swapped ) )
	{
		return false;
	}
	
	if ( !IsDefined( self.survival_weapons_swapped[ weapon_name ] ) )
	{
		return false;
	}
	
	if ( GetTime() - self.survival_weapons_swapped[ weapon_name ] <= CONST_WEAPON_CHANGE_AMMO_ADJUST_TIME * 1000 )
	{
		return true;
	}
	
	return false;
}

weapon_collect_balance_ammo( weapon_name )
{
	Assert( IsDefined( self ) && IsPlayer( self ), "Self not player." );
	
	ammo_clip	= self GetWeaponAmmoClip( weapon_name );
	ammo_stock	= self GetWeaponAmmoStock( weapon_name );
	
	ammo_clip_max	= WeaponClipSize( weapon_name );
	ammo_stock_max	= WeaponMaxAmmo( weapon_name );
	
	if ( ammo_clip == ammo_clip_max )
		return false;
	
	if ( ammo_stock <= 0 )
		return false;
	
	ammo_clip_free		= ammo_clip_max - ammo_clip;
	ammo_stock_shift	= 0;
	
	if ( ammo_clip_free > ammo_stock )
	{
		ammo_stock_shift = ammo_stock;	
	}
	else
	{
		ammo_stock_shift = ammo_clip_free;
	}
	
	self SetWeaponAmmoClip( weapon_name, ammo_clip + ammo_stock_shift );
	self SetWeaponAmmoStock( weapon_name, ammo_stock - ammo_stock_shift );
	
	return true;
}

weapon_collect_record_weapon_adjusted( weapon_name )
{
	Assert( IsDefined( self ) && IsPlayer( self ), "Self not player." );
	
	if ( !IsDefined( self.survival_weapons_swapped ) )
		self.survival_weapons_swapped = [];
	
	self.survival_weapons_swapped[ weapon_name ] = GetTime();
}

weapon_collect_clean_recorded_weapons()
{
	Assert( IsDefined( self ) && IsPlayer( self ), "Self not player." );
	
	if ( !IsDefined( self.survival_weapons_swapped ) || !self.survival_weapons_swapped.size )
		return;
	
	weapons_valid = [];
	
	foreach ( weapon, time in self.survival_weapons_swapped )
	{
		if ( self weapon_collect_ammo_adjust_was_recent( weapon ) )
			weapons_valid[ weapon ] = self.survival_weapons_swapped[ weapon ];
	}
	
	self.survival_weapons_swapped = weapons_valid;
}

// Slam Zoom Test
// ==========================================================================
do_slamzoom()
{
	// disable controls
	self DisableWeapons();
	self DisableOffhandWeapons();
	self FreezeControls( true );

	// we reset model and detached all from player for slamzoom but they will be restored by 
	// updatemodel() thread the moment player weapon has changed, 
	// which happens at the correct time when they are done with slamzoom and readys up
	if ( isdefined( self.last_modelfunc ) )
	{
		self detachall();
		self setmodel( "" );
	}
	
	// tweakables
	travel_time		= 1.75;
	zoomHeight 		= 16000;
	
	// setup player origin
	origin = self.origin;
	self PlayerSetStreamOrigin( origin );
	self.origin = origin + ( 0, 0, zoomHeight );
	
	// create rig to link player view to
	ent = Spawn( "script_model", ( 69, 69, 69 ) );
	ent SetModel( "tag_origin" );
	ent.origin = self.origin;
	ent.angles = self.angles;
	
	// link player
	self PlayerLinkTo( ent, undefined, 1, 0, 0, 0, 0 );
	ent.angles = ( ent.angles[ 0 ] + 89, ent.angles[ 1 ], 0 );
	
	// actual slamming 
	ent MoveTo( origin + ( 0, 0, 0 ), travel_time, 0, travel_time );
	
	// delay so sound would play
	wait 0.05;
	
	// SHUUUUUU
	self PlaySound( "survival_slamzoom_out" );
	
	wait( travel_time - 0.55 );
	
	// breif overbrightness
	VisionSetNaked( "end_game2", 0.25 );
	self VisionSetNakedForPlayer( "end_game2", 0.25 );
	
	// orient to player view
	ent RotateTo( ( ent.angles[ 0 ] - 89, ent.angles[ 1 ], 0 ), 0.5, 0.3, 0.2 );
	
	// restore vision file
	wait 0.2;
	if (isdefined(level.default_vision))
	{
		visionsetnaked(level.default_vision, 1.0);
	}
	else
	{
		visionsetnaked(level.script, 1.0);
	}
	
	// delay enough to make sure move was complete ( too early = player is out of place )
	wait 0.5;
	
	// restore player controls
	self Unlink();
	self EnableWeapons();
	self EnableOffhandWeapons();
	self FreezeControls( false );
	self PlayerClearStreamOrigin();
	
	// this is to make sure player model is setup correctly after slamzoom is done
	self notify( "player_update_model" );
	wait 0.5;
	flag_set( "slamzoom_finished" );

	ent Delete();
}

// ==========================================================================
// WAVE LOGIC
// ==========================================================================

survival_waves_setup()
{
	// wave setup
	level.pmc_alljuggernauts 			= false;
	level.skip_juggernaut_intro_sound	= true;// we have boss music
	level.survival_wave_intermission 	= false;
	level.uav_struct.view_cone			= 12;	// enlarged view cone for remote missile
	
	// reset enemy ping
	setsaveddvar( "bg_compassShowEnemies", "0" );
	
	// add all bad guys to remote_missile target
	array_thread( level.players, maps\_remotemissile_utility::setup_remote_missile_target );
	add_global_spawn_function( "axis", ::ai_remote_missile_fof_outline );

	// tracking
	if (getdvar("survival_start_wave") != "")
	{
		level.current_wave = int(getdvar("survival_start_wave"));
		if (level.current_wave < 1)
		{
			level waittill("eternity");
		}

		if (level.current_wave > 1)
		{
			level.cheat_used = true;
		}
	}
	else
	{
		level.current_wave = 1;
	}

	level thread update_wave();
}

update_wave()
{
	level endon( "special_op_terminated" );
	
	repeat_index 	= undefined;
	repeated_times 	= 0;
	
	starts_as_repeating = !wave_exist(level.current_wave);

	while ( 1 )
	{
		wave_num = undefined;

		if (starts_as_repeating)
		{
			wave_num = level.current_wave - 1;
		}
		else
		{
			level waittill( "wave_ended", wave_num_ );
			wave_num = wave_num_;
		}

		next_wave_num = wave_num + 1;

		starts_as_repeating = false;

		if ( !wave_exist( next_wave_num ) )
		{
			if ( !isdefined( repeat_index ) )
			{
				repeat_index = 0;
				repeated_times = 1;
			}
			
			if ( repeat_index == level.survival_repeat_wave.size )
			{
				repeat_index = 0;
				repeated_times++;				
			}

			// new wave struct with repeated wave properties
			new_wave 					= spawnstruct();
			new_wave.idx				= next_wave_num - 1;
			new_wave.num				= next_wave_num;
			new_wave.squadType			= level.survival_repeat_wave[ repeat_index ].squadType;
			new_wave.squadArray			= level.survival_repeat_wave[ repeat_index ].squadArray;
			new_wave.specialAI			= level.survival_repeat_wave[ repeat_index ].specialAI;
			new_wave.specialAIquantity	= level.survival_repeat_wave[ repeat_index ].specialAIquantity;
			new_wave.bossAI				= level.survival_repeat_wave[ repeat_index ].bossAI;
			new_wave.bossNonAI			= level.survival_repeat_wave[ repeat_index ].bossNonAI;
			new_wave.bossDelay			= level.survival_repeat_wave[ repeat_index ].bossDelay;
			new_wave.dogType			= level.survival_repeat_wave[ repeat_index ].dogType;
			new_wave.dogQuantity		= level.survival_repeat_wave[ repeat_index ].dogQuantity;
			new_wave.repeating			= level.survival_repeat_wave[ repeat_index ].repeating;
			
			// preserve previous wave then reset old wave data
			previous_wave 						= level.survival_wave[ wave_num ];
			level.survival_wave 				= [];
			level.survival_wave[ wave_num ] 	= previous_wave;
			level.survival_wave[ new_wave.num ]	= new_wave;
			
			repeat_index++;
			
			// Keep track of how many waves have been repeated. This is
			// used in setting up AI attributes to scale difficulty.
			level.survival_waves_repeated++;
		}
	}
}

//main wave logic, spawn location logic
survival_wave()
{
	level endon( "special_op_terminated" );
	
	//setup waves
	survival_waves_setup();
	
	// temp stinger music
	thread intro_music();
	
	waittill_survival_start();
	
	// in case timed out, IMPORTANT, DO NOT REMOVE!
	if ( !flag( "start_survival" ) )
		flag_set( "start_survival" );
	
	level notify( "wave_started", level.current_wave );
	luinotify("set_wave_num", level.current_wave);

	// Set view kick scale to match MP
	SetSavedDvar( "bg_viewKickScale", "0.2" );
	
	// squad AI waves logics
	while( 1 )
	{		
		// ============= Spawn Squad AIs ==============
		if ( isdefined( level.leaders.size ) && level.leaders.size >= 3 )
		{
			// careful, left over enemies need not be too many
			assertex( false, "Too many squads left alive before new wave, AI maxed out!" );
		}
		
		// spawn squads
		squad_array			= get_squad_array( level.current_wave );	// array of squad sizes
		squads_spawned		= 0;
		
		assert( isdefined( squad_array ) && squad_array.size );

		foreach ( squad_size in squad_array )
		{
			if ( squad_size > 0 )
				squads_spawned += spawn_wave( 1, squad_size );	//spawn_wave(num of squads,squad size)
		}
		
		// ============= Spawn Special AIs ==============	
		
		level.special_ai 	= [];
		special_ai_types	= get_special_ai( level.current_wave );
		
		if ( isdefined( special_ai_types ) )
		{
			foreach( special_type in special_ai_types )
			{
				// ============= Spawn Dogs ==============	
				if ( issubstr( special_type, "dog" ) )
				{
					thread spawn_dogs( special_type, get_dog_quantity( level.current_wave ) );
					continue;
				}
				
				special_ai_num = get_special_ai_type_quantity( level.current_wave, special_type );
				assertex( isdefined( special_ai_num ) && special_ai_num > 0, "Special ai of type: " + special_type + " requeste with an undefined or zero count." );
				
				if ( isdefined( special_ai_num ) && special_ai_num > 0 )
				{
					special_ai_spawned	= spawn_special_ai( special_type, special_ai_num );
					// This is commented out to prevent telefragging that could occur
					// between special ai reenforcement and squad reenforcements using
					// the same location on the same frame
					//thread reenforcement_special_ai_spawn( special_type, CONST_WAVE_REENFORCEMENT_SPECIAL_AI );
				}
			}
		}
		// reenforce squad(s) of size of the first squad spawned
		if ( squad_array[ 0 ] > 0 )
			thread reenforcement_squad_spawn( CONST_WAVE_REENFORCEMENT_SQUAD, squad_array[ 0 ] );

		// spawn boss if is defined by string table
		if ( wave_has_boss( level.current_wave ) )
			thread spawn_boss();
		
		// ping enemy location with a delay so we dont show their spanw locations
		level thread delayed_enemy_ping();
		
		// ============= Logic for AI aggression ==============
		
		// wait till a few AIs left, we then have the remaining aggress
		total_enemies = getaiarray( "axis" ).size + dog_get_count();
		while ( total_enemies > CONST_WAVE_AI_LEFT_TILL_AGGRO )
		{
			// Delay, but early out if an enemy died
			level waittill_any_timeout( 1.0, "axis_died" );
			
			total_enemies = getaiarray( "axis" ).size + dog_get_count();
		}
		
		flag_set( "aggressive_mode" );	
		maps\_squad_enemies::squad_disband( 0, ::aggressive_squad_leader );		
		// aggressing remaining Squad AIs
		level.squad_leader_behavior_func = maps\_so_survival_AI::aggressive_ai; // for new leaders to carry

		// aggressing remaining Special AIs
		level.special_ai_behavior_func = maps\_so_survival_AI::aggressive_ai; // for new special ais to carry
		if ( isdefined( level.special_ai ) && level.special_ai.size > 0 )
			foreach ( guy in level.special_ai )
				guy thread maps\_so_survival_AI::aggressive_ai(); // for existing special AIs
		
		// wait till certain number of AIs left, we can start the next wave or boss battle
		total_enemies = getaiarray( "axis" ).size + dog_get_count();
		while ( total_enemies > CONST_WAVE_AI_LEFT_TILL_NEXT_WAVE )
		{
			// Delay, but early out if an enemy died
			level waittill_any_timeout( 1.0, "axis_died" );
			
			total_enemies = getaiarray( "axis" ).size + dog_get_count();
		}
		
		// reset aggressing behavior for next wave/spawn
		level.squad_leader_behavior_func 	= maps\_so_survival_AI::default_ai;
		level.special_ai_behavior_func 		= maps\_so_survival_AI::default_ai;
		
		// ============= Wave Completion ==============
		
		// if boss spawned and not defeated, wait
		if ( wave_has_boss( level.current_wave ) )
		{
			flag_wait( "bosses_spawned" );
			
			while ( isdefined( level.bosses ) && level.bosses.size )
				wait 0.1;
		}
		
		flag_clear( "aggressive_mode" );
		
		level notify( "wave_ended", level.current_wave );
		
		// reset enemy pinging
		setsaveddvar( "bg_compassShowEnemies", "0" );
		
		if ( flag( "boss_music" ) )
		{
			level notify( "end_boss_music" );
			flag_clear( "boss_music" );
			music_stop( 3 );
		}
		
		survival_wave_pickup_downed_players();

		survival_wave_intermission();

		// Update Wave after the intermission
		level.current_wave++;
		luinotify("set_wave_num", level.current_wave);
		level notify( "wave_started", level.current_wave );
	}
}

delayed_enemy_ping()
{
	level endon( "wave_ended" );
	
	wait CONST_DELAYED_ENEMY_PING;
	setsaveddvar( "bg_compassShowEnemies", "1" );
}

survival_wave_intermission()
{			
	level endon( "special_op_terminated" );
	
	level.survival_wave_intermission = true;
	
	assertex( CONST_WAVE_DELAY_TOTAL >= CONST_WAVE_DELAY_COUNTDOWN + CONST_WAVE_DELAY_BEFORE_READY_UP, "The total wave delay must be bigger than the big countdown delay." );
	
	duration_before_count	= CONST_WAVE_DELAY_TOTAL - CONST_WAVE_DELAY_COUNTDOWN;
	duration_count			= CONST_WAVE_DELAY_COUNTDOWN;
	
	// Skip ready up and wave delay if timescale on
	if ( duration_before_count > 0 )
	{
		// Delay player ready up prompt and input handling
		wait CONST_WAVE_DELAY_BEFORE_READY_UP;
		
		duration_before_count -= CONST_WAVE_DELAY_BEFORE_READY_UP;
		
		assertex( duration_before_count >= 1, "Delay before ready up too long relative to wave delay and countdown delay." );
		
		// Give the players time to setup and provide a 
		// prompt for them to hit when ready
		array_thread( level.players, ::survival_wave_catch_player_ready, "survival_all_ready", duration_before_count + duration_count );
		
		// Wait till all players ready or until the
		// duration_before_count time has finished
		level waittill_any_timeout( duration_before_count, "survival_all_ready" );
		
		// make sure ready up threads clean up in case the wait timed out
		level notify( "survival_all_ready" );
	}
	
	// display MP sytle countdown
	foreach ( player in level.players )
	{
		player thread matchStartTimer( duration_count );
	}
	
	wait duration_count;
	level.survival_wave_intermission = false;
}

survival_wave_catch_player_ready( all_ready_msg, time )
{
	self endon( "death" );
	level endon( "special_op_terminated" );
	level endon( all_ready_msg );
	
	// Everyone passes this ypos as the xoffset... sad
	x_offset = maps\_specialops::so_hud_ypos() - 130;
	
	// Add press button to ready up prompt
	self.elem_ready_up = maps\_specialops::so_create_hud_item( -2, x_offset, &"SO_SURVIVAL_READY_UP", self, true );
	self.elem_ready_up elem_ready_up_setup();
	
	// Adjust time display of ready up hud elem
	self thread survival_wave_catch_player_ready_update( "survival_player_ready", all_ready_msg, self.elem_ready_up, time );
	
	// Remove ready up hud elem once all players are ready
	self thread survival_wave_catch_player_ready_clean( all_ready_msg );
	
	self NotifyOnPlayerCommand( "survival_player_ready", "skip" );
	self waittill( "survival_player_ready" );
	
	// Increment players ready count
	if ( !isdefined( level.survival_players_ready ) )
		level.survival_players_ready = 1;
	else
		level.survival_players_ready++;
	
	// Remove press button to ready up prompt
	self.elem_ready_up maps\_specialops::so_remove_hud_item( true );
	
	// Check to see if all players are ready
	if ( level.survival_players_ready == level.players.size )
	{
		level notify( all_ready_msg );
	}
	else
	{
		
		// add prompt of waiting on other player
		otherplayer = get_other_player( self );
		if ( isdefined( otherplayer ) && isdefined( otherplayer.elem_ready_up ) )
			otherplayer.elem_ready_up.label = &"SO_SURVIVAL_PARTNER_READY";
		
		self.elem_ready_up = maps\_specialops::so_create_hud_item( -2, x_offset, &"SO_SURVIVAL_READY_UP_WAIT", self, true );
		self.elem_ready_up elem_ready_up_setup();
	}
}

issplitscreen()
{
	return false;
}

elem_ready_up_setup()
{
	self.alignX = "left";
	self.alpha = 0.0;
	
	if ( issplitscreen() )
	{
		self.horzAlign = "center";
		self.x = 36;
		self.y = -22;
	}
	
	self thread maps\_hud_util::fade_over_time( 1.0, 0.5 );
}

survival_wave_catch_player_ready_update( player_endon, level_endon, hud_elem, time )
{
	level endon( level_endon );
	self endon( player_endon );
	
	time = int( time );
	
	while( isdefined( hud_elem ) && time > 0 )
	{
		hud_elem SetValue( time );
		wait 1.0;
		
		time--;
	}
}

survival_wave_catch_player_ready_clean( msg )
{
	level waittill( msg );
	
	level.survival_players_ready = undefined;
	
	if ( isdefined( self.elem_ready_up ) )
	{
		self.elem_ready_up maps\_specialops::so_remove_hud_item( true );
	}
}

survival_wave_pickup_downed_players()
{
	foreach( player in level.players )
	{
		if ( is_player_down( player ) )
			player.laststand_getup_fast = true;
	}
}

// spawn a wave with a specific number of squads
spawn_wave( spawn_squad_num, squad_size )
{
	level endon( "special_op_terminated" );

	spawn_squad_num = int( spawn_squad_num ); //insurance
	while( spawn_squad_num )
	{
		squad = maps\_squad_enemies::spawn_far_squad( level.wave_spawn_locs, get_class( "leader" ), get_class( "follower" ), squad_size - 1 );
		
		foreach( guy in squad )
		{
			guy	setthreatbiasgroup( "axis" );
			guy thread setup_AI_weapon();
		}
		spawn_squad_num--;
	}
	return level.leaders.size;
}

// returns AI type appropriate for current difficulty, class is either leader or follower
get_class( class )
{
	squad_type 	= get_squad_type( level.current_wave );
	classname 	= get_ai_classname( squad_type );
	
	if ( isdefined( class ) )
	{
		// this is if "leader" / "follower" uses different AI Types
		// right now we dont need this
	}
	
	return classname;
}

spawn_special_ai( ai_type, quantity )
{
	// pick a spawn thats far from all players
	avoid_locs = [];
	avoid_locs[ avoid_locs.size ] = level.player;
	if( is_coop() )
		avoid_locs[ avoid_locs.size ] = level.players[ 1 ];
		
	classname 	= get_ai_classname( ai_type );
	spawner 	= get_spawners_by_classname( classname )[ 0 ];
	
	for( i = 0; i < quantity; i++ )
	{	
		wait 0.05; // spawn one per frame per spawner
		
		spawn_loc 		= get_furthest_from_these( level.wave_spawn_locs, avoid_locs, 4 );
		spawner.count 	= 1;
		spawner.origin 	= spawn_loc.origin;
		spawner.angles 	= spawn_loc.angles;
		guy 			= spawner spawn_ai( true );
		guy				setthreatbiasgroup( "axis" );
		assertex( isdefined( guy ), "Special AI failed to spawn even though it was forced spawned." );
		
		guy.ai_type = get_ai_struct( ai_type );
		level.special_ai[ level.special_ai.size ] = guy;
		guy thread clear_from_special_ai_array_when_dead();
		guy thread setup_AI_weapon();
		
		assertex( isdefined( level.special_ai_behavior_func ), "No special AI behavior func defined!" );
		guy thread [[ level.special_ai_behavior_func ]]();
	}
	
	return level.special_ai;
}

reenforcement_squad_spawn( quantity, squad_size )
{
	level endon( "special_op_terminated" );
	level endon( "wave_ended" );
	
	initial_leaders = level.leaders.size;
	squad_spawned = 0;
	while ( squad_spawned < quantity )
	{
		if ( level.leaders.size >= initial_leaders )
		{
			wait 0.05;
			continue;
		}
	
		total_AI = getaiarray();
		if ( total_AI.size >= ( 32 - squad_size ) )
		{
			wait 0.05;
			continue;
		}
		
		// squad one squad reenforcement
		squad = maps\_squad_enemies::spawn_far_squad( level.wave_spawn_locs, get_class( "leader" ), get_class( "follower" ), squad_size - 1 );
		
		foreach( guy in squad )
		{
			guy	setthreatbiasgroup( "axis" );
			guy thread setup_AI_weapon();
		}
			
		squad_spawned++;
	}
}

reenforcement_special_ai_spawn( special_ai_type, quantity )
{
	level endon( "special_op_terminated" );
	level endon( "wave_ended" );
	
	initial_special_ais = level.special_ai.size;
	ai_spawned = 0;
	while ( ai_spawned < quantity )
	{
		if ( level.special_ai.size >= initial_special_ais )
		{
			wait 0.05;
			continue;
		}
		
		total_AI = getaiarray();
		if ( total_AI.size > 31 )
		{
			wait 0.05;
			continue;
		}
		
		// squad one squad reenforcement
		spawn_special_ai( special_ai_type, 1 );
		ai_spawned++;
		
		//iprintln( "Special AI Re-enforced" );
		wait 0.05;
	}	
}

// ==========================================================================
// BOSS LOGIC
// ==========================================================================

wave_has_boss( wave_num )
{
	// does current wave have boss?
	AI_bosses 		= get_bosses_ai( wave_num );
	nonAI_bosses 	= get_bosses_nonai( wave_num );
	
	if ( isdefined( AI_bosses ) || isdefined( nonAI_bosses ) )
		return true;
	
	return false;
}

spawn_boss()
{
	// This flag is dependenent on the spawning below happening
	// before this function gets to the end so no thread spawning!
	flag_clear( "bosses_spawned" );
	
	// Delay boss spawn if specified in wave table
	if ( level.survival_wave[ level.current_wave ].bossDelay 
		&& flag_exist( "aggressive_mode" ) 
		&& !flag( "aggressive_mode" )
	)
		flag_wait( "aggressive_mode" );
		
	level notify( "boss_spawning", level.current_wave );
	
	level.bosses 	= [];
	AI_bosses 		= get_bosses_ai( level.current_wave );
	nonAI_bosses 	= get_bosses_nonai( level.current_wave );
	
	if ( isdefined( AI_bosses ) )
	{
		spawn_boss_AI( AI_bosses, true );

		// introducing delay since nonAI needs to wait for this to avoid air space collision of choppers
		if ( level.bosses.size && isdefined( nonAI_bosses ) )
		{
			level waittill_any_timeout( 30, "juggernaut_jumpedout" );
			wait 6; // roughly 6 secs till drop chopper leaves
		}
	}
	
	if ( isdefined( nonAI_bosses ) )
		thread spawn_boss_nonAI( nonAI_bosses, !isdefined( AI_bosses ) );
	
	flag_set( "bosses_spawned" );
}

spawn_boss_AI( bosses, music_enable )
{
	foreach( boss_ref in bosses )
	{
		// minigun juggernaut is not yet in, temp!
		if ( boss_ref == "jug_minigun" )
			continue;
			
		if ( !issubstr( boss_ref, "jug_" ) )
			continue;
		
		path_start = chopper_wait_for_cloest_open_path_start( random_player_origin(), "drop_path_start", "script_unload" );
		thread spawn_juggernaut( boss_ref, path_start );
		wait 0.5;
	}
	
	if ( music_enable )
		thread music_boss( "juggernaut" );
}

spawn_boss_nonAI( bosses, music_enable )
{
	foreach( boss_ref in bosses )
	{
		if ( issubstr( boss_ref, "chopper" ) )
		{
			path_start = chopper_wait_for_cloest_open_path_start( random_player_origin(), "chopper_boss_path_start", "script_stopnode" );
			chopper = spawn_chopper_boss( boss_ref, path_start );
		}
		else
		{
			// some other non AI boss	
		}
	}
	
	if ( music_enable )
		thread music_boss( "chopper" );
}

// ==========================================================================
// ALLY LOGIC
// ==========================================================================

spawn_allies( target_origin, ally_type, owner )
{
	assert( isdefined( owner ), 		"allies' owner parameter is missing" );
	assert( isdefined( target_origin ), "Invalid target origin" );
	assert( isdefined( ally_type ), 	"Invalid ally_type" );
	
	path_start = chopper_wait_for_cloest_open_path_start( target_origin, "drop_path_start", "script_unload" );
	
	level notify( "so_airsupport_incoming", ally_type );
	
	spawn_ally_team( ally_type, 3, path_start, owner );
}

// ==========================================================================
// PLAYER PERFORMANCE TRACKING
// ==========================================================================

// performance standards
player_performance_init()
{
	// because inits below will use setplayerdata(), wait a frame
	wait 0.05;
	
	// setup player's performance standards
	level.performance_bonus[ "accuracy" ] 			= 3; 	// points per 1%
	level.performance_bonus[ "damagetaken" ] 		= 2;	// point per damage 
	level.performance_bonus[ "time" ] 				= 2; 	// points per second under 90
	
	if ( is_coop() )
	{
		level.performance_bonus[ "wavebonus" ] 		= 50; 	// points per wave
		level.performance_bonus[ "headshot" ] 		= 50; 	// points per headshot
		level.performance_bonus[ "kill" ] 			= 50;	// point per kill
	}
	else
	{
		level.performance_bonus[ "wavebonus" ] 		= 25; 	// points per wave
		level.performance_bonus[ "headshot" ] 		= 20; 	// points per headshot
		level.performance_bonus[ "kill" ] 			= 10;	// point per kill
	}
	
	foreach( player in level.players )
	{
		// init - tracks the entire game
		player.game_performance 					= [];
		player.game_performance[ "headshot" ] 		= 0;
		player.game_performance[ "accuracy" ] 		= 0;
		player.game_performance[ "damagetaken" ]	= 0;
		player.game_performance[ "kill" ]			= 0;
		player.game_performance[ "credits" ]		= 0;
		player.game_performance[ "downed" ]			= 0;
		player.game_performance[ "revives" ]		= 0;
		
		// init - tracks per wave
		player.performance 							= [];
		player.performance[ "headshot" ] 			= 0;
		player.performance[ "accuracy" ] 			= 0;
		player.performance[ "time" ] 				= 0;
		player.performance[ "damagetaken" ]			= 0;	
		player.performance[ "kill" ]				= 0;
		player.performance[ "wavebonus" ]			= 0;
		
		player player_performance_UI_init();
		player thread player_performance_think();
	}
	
	// track headshots
	add_global_spawn_function( "axis", ::performance_track_headshot );
}

// resets all performance values to 0
player_performance_reset()
{
	self _setplayerdata_single( "surHUD_performance_reward", 0 );

	// resets between waves
	foreach ( index_string, performance_item in self.performance )
	{
		self.performance[ index_string ] = 0;
		self _setplayerdata_array( "surHUD_performance", 		index_string, 0 );
		self _setplayerdata_array( "surHUD_performance_p2", 	index_string, 0 );
		self _setplayerdata_array( "surHUD_performance_credit", index_string, 0 );
	}
}

// tracks overall performance, self is player
player_performance_think()
{
	self endon( "death" );
	
	self thread performance_wave_reset();
	
	// track times downed
	self thread performance_track_downed();

	// track times downed
	self thread performance_track_revives();
		
	// track total credits earned
	self thread performance_track_credits();
	
	// track time
	self thread performance_track_time();
	
	// track damage taken
	self thread performance_track_damage();
	
	// track accuracy
	self thread performance_track_accuracy();

	// track kills
	self thread performance_track_kills();
	
	// track waves
	self thread performance_track_waves();
	
	while ( 1 )
	{
		// calculate at intermission
		level waittill( "wave_ended" );
		
		// register to player career data about total waves survived
		self maps\_player_stats::career_stat_increment( "waves_survived", 1 );
		
		// wait for updated performance data
		waittillframeend; 
		
		// give reward XP - reward is an array with key "total" = total points rewarded
		reward_array = self reward_calculation();
		
		// if no reward don't give 0xp
		if ( reward_array[ "total" ] )
			self thread giveXP( "personal_wave_reward", reward_array[ "total" ] );

		// sends information to display summary
		self thread performance_summary( reward_array );

		// reset player data for next intermission
		level waittill( "wave_started" ); // so that we dont reset during display of stats
		
		self.camping_time = 0;
	}
}

performance_wave_reset()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	while ( 1 )
	{
		level waittill( "wave_started" );
		
		self player_performance_reset();
		
		self.stats[ "kills" ] = 0;
		self.stats[ "shots_fired" ] = 0;
		self.stats[ "shots_hit" ] = 0;
	}
}

// track number of times player revived their teammate
performance_track_revives()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	while ( 1 )
	{
		self waittill( "so_revive_success" );
		self.game_performance[ "revives" ]++;
	}
}

// track number of times player downed, including last stand
performance_track_downed()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	while ( 1 )
	{
		self waittill( "player_downed" );
		self.game_performance[ "downed" ]++;
	}
}

// keep record of how much player earned
performance_track_credits()
{
	level endon( "special_op_terminated" );
	self endon( "death" );	
	
	while ( 1 )
	{
		self waittill( "deposit_credits", delta, donation );
		
		// once per session
		if ( self.survival_credit >= 50000 && !isdefined( self.survival_credit_balance_of_50000 ) )
		{
			self.survival_credit_balance_of_50000 = true;
			self thread so_achievement_update( "GET_RICH_OR_DIE_TRYING" );
		}
		
		if ( isdefined( donation ) && donation )
			continue;
		
		if ( delta > 0 )
			self.game_performance[ "credits" ] += delta;
	}
}

// tracks completion time for last set of waves
performance_track_time()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	waittill_survival_start();
	
	while ( 1 )
	{
		last_intermission_start_time = gettime();
		level waittill( "wave_ended" );
		self.performance[ "time" ] = gettime() - last_intermission_start_time;
		level waittill( "wave_started" );
	}
}

// track headshots, self is AI
performance_track_headshot()
{
	level endon( "special_op_terminated" );

	if ( !IsAI( self ) )
		return;

	head_shot = false;
	self waittill( "death", attacker, cause, weaponName, d, e, f, g );

	if(	self was_headshot() && isplayer( attacker ) )
	{
		msg = "player.performance array is missing headshot setting";
		assertex( isdefined( attacker.performance ) && isdefined( attacker.performance[ "headshot" ] ), msg );
		attacker.performance[ "headshot" ]++;
		attacker.game_performance[ "headshot" ]++;
		attacker notify( "sur_ch_headshot" );
	}
}

// track damage take, self is player
performance_track_damage()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	assertex( isdefined( self.team ), "Player isn't setup with a .team! for team based damage tracking" );
	
	if ( isdefined( self.armor ) )
		self.previous_armor = self.armor[ "points" ];
	else
		self.previous_armor = 0;
	
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );
		
		if ( isdefined( attacker ) && ( attacker != self ) && isdefined( attacker.team ) && attacker.team == self.team )
			continue;

		self thread performance_damagetaken_update( amount );
	}
}

performance_damagetaken_update( amount )
{
	max_hp = 100 + self.previous_armor;
	damage = int( min( max_hp, amount ) );
	
	self.performance[ "damagetaken" ] += damage;
	self.game_performance[ "damagetaken" ] += damage;
	
	// wait for armor & health are updated after damage notify so we get correct values for next damage catch
	waittillframeend;
	
	if ( isdefined( self.armor ) )
		self.previous_armor = self.armor[ "points" ];
	else
		self.previous_armor = 0;
}

// track accuracy, self is player
performance_track_accuracy()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	total_shots_fired = 0;
	total_shots_hit = 0;
	
	while ( 1 )
	{
		self waittill( "weapon_fired" );
			
		shots_fired = max( 1, float( self.stats[ "shots_fired" ] ) );
		shots_hit = float( self.stats[ "shots_hit" ] );
		
		total_shots_fired 	+= shots_fired;
		total_shots_hit 	+= shots_hit;
		
		self.performance[ "accuracy" ] 		= int_capped(  100 * (shots_hit / shots_fired ), 0, 100 );
		self.game_performance[ "accuracy" ] = int_capped(  100 * (total_shots_hit / total_shots_fired ), 0, 100 );
	}
}

performance_track_kills()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	while ( 1 )
	{
		level waittill( "specops_player_kill", attacker );
		
		if( isdefined( attacker ) && isplayer( attacker ) && attacker == self )
		{
			self.performance[ "kill" ]++;
			self.game_performance[ "kill" ]++;
		}
	}
}

performance_track_waves()
{
	level endon( "special_op_terminated" );
	self endon( "death" );

	while ( 1 )
	{
		level waittill( "wave_ended", current_wave );
		self.performance[ "wavebonus" ] = current_wave;
		
		// once
		if ( !isdefined( self.survived_a_wave ) )
		{
			self.survived_a_wave = true;
			self thread so_achievement_update( "I_LIVE" );
		}
		
		// update count
		if ( current_wave == 9 )
			self thread so_achievement_update( "SURVIVOR" );
		
		// update count
		if ( current_wave == 14 )
			self thread so_achievement_update( "UNSTOPPABLE" );
	}
}

reward_calculation()
{
	// calculate performance by formula - individual vars for debug
	points_headshot = self.performance[ "headshot" ] * level.performance_bonus[ "headshot" ];
	
	// only accuracy above 25% counts
	points_accuracy = int( max( self.performance[ "accuracy" ] - 25, 0 ) ) * level.performance_bonus[ "accuracy" ];
	
	// minus points from max reward points due to damage taken
	points_damage 	= 400;
	points_damage 	-= self.performance[ "damagetaken" ] * level.performance_bonus[ "damagetaken" ];
	points_damage 	= int( max( points_damage, 0 ) );
	
	// points multiplied by kills
	points_kills	= self.performance[ "kill" ] * level.performance_bonus[ "kill" ];
	
	// minus points from max reward time with time spent
	points_time 	= 0;
	bonus_time 		= 90; // seconds
	reward_time 	= max( bonus_time - int(self.performance[ "time" ]/1000), 0 );
	points_time 	= int( level.performance_bonus[ "time" ] * reward_time );
	
	// points awarded by waves survived
	points_wave		= self.performance[ "wavebonus" ] * level.performance_bonus[ "wavebonus" ];
	
	// total points accumulated
	reward_array = [];
	reward_array[ "time" ] 			= points_time;
	reward_array[ "headshot" ] 		= points_headshot;
	reward_array[ "accuracy" ] 		= points_accuracy;
	reward_array[ "damagetaken" ] 	= points_damage;
	reward_array[ "kill" ] 			= points_kills;
	reward_array[ "wavebonus" ]		= points_wave;
	
	assertex( self.performance.size == reward_array.size, "Reward calculation is missing something!" );
	
	total_points = 0;
	foreach ( bonus in reward_array )
		total_points += bonus;
	
	reward_array[ "total" ] = get_reward( total_points );

	// print debug
	//self thread performance_summary_debug( reward_array );

	return reward_array;
}

get_reward( points )
{
	// [2.0]
	return int( max( 0, int( points ) ) );
}

// ==========================================================================
// PLAYER CAMPING LOGIC
// ==========================================================================

camping_think()
{
	self endon( "death" );

	if ( !isdefined( self.camper_detection ) )
		self.camper_detection = false;
	
	// keep track of all camped locations
	self.camping_locs = [];
	self.camping_time	= 0;
	
	// enemy response to player camping
	self thread camp_response();
	
	old_origin 	= self.origin;
	camp_points = 0;
	kills 		= 0;
	
	while ( 1 )
	{
		self.camping 		= 0;
		self.camping_loc 	= self.origin;
		camp_points			= 0;
		old_origin 			= self.origin;
		
		// counting seconds toward camping status
		while ( camp_points <= 20 )
		{
			if ( distance( old_origin, self.origin ) < 220 )
				camp_points++;
			else
				camp_points-=2;
			
			// having low health is excused
			if ( self.health < 40 )
				camp_points--;
			
			// kills will make player 
			if ( self.stats[ "kills" ] - kills > 0 )
				camp_points += ( self.stats[ "kills" ] - kills );
			
			if ( 
				camp_points <= 0 
				|| level.survival_wave_intermission
				|| ( self ent_flag_exist( "laststand_downed" ) && self ent_flag( "laststand_downed" ) )
				)
			{
				camp_points = 0;
				old_origin = self.origin;
			}
			kills = self.stats[ "kills" ];
			wait 1;
		}
	
		self.camping 		= 1;
		self.camping_loc 	= self.origin;
		
		// keep track of all camped locations
		self.camping_locs[ self.camping_locs.size ] = self.camping_loc;
	
		self notify( "camping" );

		// wait till out of camping area
		while ( distance( old_origin, self.origin ) < 260 )
		{
			self.camping_time++;
			wait 1;
		}
		
		self notify( "stopped camping" );
	}
}

// enemy response to player camping
camp_response()
{
	self endon( "death" );
	
	level.camp_response_interval = CONST_CAMP_RESPONSE_INTERVAL;
	
	while ( 1 )
	{
		wait 0.05;
		
		// wait till camping
		if ( !isdefined( self.camping ) 	|| 
			 !isdefined( self.camping_loc ) || 
			 !isdefined( self.camping_time ) 
		)
			continue;

		if ( self.camping )
		{
			//iprintln( "R::grenade" );
			self thread level_AI_respond( self.camping_loc, self.camping_time );
			self thread level_AI_boss_respond( self.camping_loc, self.camping_time );
			wait level.camp_response_interval;
		}
	}
}

level_AI_respond( last_camp_loc, camp_time )
{
	all_ai = getaiarray( "axis" );
	foreach ( ai in all_ai )
		ai thread throw_grenade_at_player( self );
}

// if bosses exist in level, respond
level_AI_boss_respond( last_camp_loc, camp_time )
{
	if ( isdefined( level.bosses ) && level.bosses.size )
	{
		// just one respond for now
		responder = level.bosses[ randomint( level.bosses.size ) ];
	}	
}


// ==========================================================================
// XP LOGIC
// ==========================================================================

survival_credits()
{
	level endon( "special_op_terminated" );
	
	foreach ( player in level.players )
		player credits_UI_init();

	// waves spawn after this wait
	waittill_survival_start();

	// init player's credits
	foreach ( player in level.players )
	{
		player.survival_credit = 0;
		if (level.current_wave < 1)
		{
			player.survival_credit = 1000000;
		}
		else
		{
			player.survival_credit = (level.current_wave - 1) * 1000;
		}

		setdvar("ui_current_score", player.survival_credit);
        luinotify("add_score", 0);

		player thread update_from_xp();
		player thread update_from_credits();
	}
}

update_from_xp()
{

}

update_from_credits()
{

}

// ==========================================================================
// MUSIC
// ==========================================================================

survival_music_end()
{
	level waittill("special_op_terminated");
	level.current_music_type = "";
	music_stop(3);
}

survival_music()
{
	level.current_music_type = "";
	level thread survival_music_end();

	while (true)
	{
		level waittill("wave_started");

		if (level.current_music_type == "intro")
		{
			level waittill("stopped_intro_music");
		}

		custom_soundtrack = maps\_playerdata::get("custom_soundtrack");
		if (custom_soundtrack != "")
		{
			level.current_music_type = "custom";

			if (custom_soundtrack == "random")
			{
				csv = "sp/soundtracks.csv";
				rows = tablegetrowcount(csv);
				soundtrack_index = randomintrange(2, rows - 1);
				soundtrack = tablelookupbyrow(csv, soundtrack_index, 0);
				musicplaywrapper(soundtrack);
			}
			else if (assetexists("sound", custom_soundtrack))
			{
				musicplaywrapper(custom_soundtrack);
			}
		}

		level waittill("wave_ended");

		if (level.current_music_type == "custom")
		{
			music_stop(3);
		}
	}
}

intro_music( type )
{
	if (level.current_wave != 1)
	{
		return;
	}

	level endon( "special_op_terminated" );
	
	music_alias = "mus_so_survival_regular_music";
	level.current_music_type = "intro";

	wait 1.5;
	
	musicplaywrapper(music_alias);
	
	wait 5;
	
	music_stop( 20 );

	wait 20;
	level.current_music_type = "";
	level.playing_intro_music = false;
	level notify("stopped_intro_music");
}

music_boss( type )
{
	level endon( "special_op_terminated" );
	level endon( "end_boss_music" );

	wait 0.05;
	
	if (level.current_music_type == "custom")
	{
		return;
	}

	flag_set( "boss_music" );
	
	level.current_music_type = "boss";

	music_stop( 3 );
	
	// TO DO: music differ by difficulty of AI
	if ( type == "chopper" )
	{
		music_alias = "mus_so_survival_boss_music_01";
	}
	else if ( type == "juggernaut" )
	{
		music_alias = "mus_so_survival_boss_music_02";
	}
	else
	{
		music_alias = "mus_so_survival_boss_music_01";
	}
		
	music_time = musicLength( music_alias ) + 2;
	while ( flag( "boss_music" ) )
	{
		MusicPlayWrapper( music_alias );
		wait( music_time );
	}
}

// ==========================================================================
// ==========================================================================
// HUD LOGIC
// ==========================================================================
// ==========================================================================

hud_init()
{
	level endon( "special_op_terminated" );
}

survival_hud()
{
	thread hud_init();
	thread wave_splash();
	
	foreach ( player in level.players )
	{
		player player_reward_splash_init();
		player thread wave_HUD();
		player thread armor_HUD();
		player thread laststand_HUD();
		player thread perk_HUD();
		player thread enemy_remaining_HUD();
		//player thread wave_timer_player_setup();
	}
}

// ==========================================================================
// CREDITS UI

credits_UI_init()
{
	self _setplayerdata_single( "surHUD_credits", 		0 );	// credits counter that rolls
	self _setplayerdata_single( "surHUD_credits_delta", 0 );	// credits change amount
	self surHUD_enable( "credits" );
}

UI_rolling_credits( old_credits, delta )
{
	self notify( "stop_animate_credits" );
	self endon( "stop_animate_credits" );
	
	self _setplayerdata_single( "surHUD_credits_delta", 0 );	// reset so menu doesn't get a frame of old value
	self surHUD_animate( "credits" ); 							// credit delta animation
	self _setplayerdata_single( "surHUD_credits", self.survival_credit );
	self _setplayerdata_single( "surHUD_credits_delta", delta );// credits change amount
}

// ==========================================================================
// TIMERS
// displays wave set timer whenever player checks main timer

wave_timer_player_setup()
{
	level endon( "special_op_terminated" );
	
	// player is dead before "special_op_terminated" is notified = BAD!!!
	msg = "Player is either dead or removed while trying to setup its hud.";
	assertex( isdefined( self ) && isplayer( self ) && isalive( self ), msg );
	
	clock_icon_size = 28;
	xpos = maps\_specialops::so_hud_ypos();			// This actually returns x pos offset
	xpos_enemy_left = xpos + 12 + clock_icon_size; 	// Offset for print of "enemies left"
	
	//self.hud_so_wave_enemy 		 = maps\_specialops::so_create_hud_item( 2, xpos_enemy_left, &"SO_SURVIVAL_ENEMIES_LEFT", self, true );
	//self.hud_so_wave_num 	 	 = maps\_specialops::so_create_hud_item( 1, xpos-clock_icon_size, &"SO_SURVIVAL_WAVE_TIME", self, true );
	self.hud_so_wave_timer_time  = maps\_specialops::so_create_hud_item( -1, xpos, &"SO_SURVIVAL_SURVIVE_TIME", self, true );
	self.hud_so_wave_timer_clock = maps\_specialops::so_create_hud_item( -1, xpos-clock_icon_size, undefined, self, true );
	
	self.hud_so_wave_timer_time.alignX 	= "left";
	self.hud_so_wave_timer_clock.alignX = "left";
	self.hud_so_wave_timer_clock 		setShader( "hud_show_timer", clock_icon_size, clock_icon_size );
	
	self.hud_so_wave_timer_clock.alpha 	= 0;
	//self.hud_so_wave_enemy.alpha 		= 0;
	//self.hud_so_wave_num.alpha 			= 0;
	self.hud_so_wave_timer_time.alpha 	= 0;
	
	self thread wave_timer_wait_start( self.hud_so_wave_timer_time, self.hud_so_wave_timer_clock );	
}

// loop for wave set
wave_timer_wait_start( hud_time, hud_clock_icon )
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	// wait till mission starts
	waittill_survival_start();
	
	while ( 1 )
	{
		hud_time.label = "";
		hud_time settenthstimerup( 0.00 );
		start_time = gettime();
		
		// fade timer in
		//hud_wave thread maps\_hud_util::fade_over_time( 1.0, 0.5 );
		hud_time thread maps\_hud_util::fade_over_time( 1.0, 0.5 );
		hud_clock_icon thread maps\_hud_util::fade_over_time( 1.0, 0.5 );
		//hud_wave setvalue( level.current_wave );
		
		level waittill( "wave_ended" );
		
		hud_time.label = "";
		pause_time = max( 1, ( gettime() - start_time )/1000 );
		hud_time SetTenthsTimerStatic( pause_time );
		
		msg = "";
		if ( CONST_WAVE_ENDED_TIMER_FADE_DELAY > 0 )
		{
			msg = waittill_any_timeout( CONST_WAVE_ENDED_TIMER_FADE_DELAY, "wave_started" );
		}
		
		// If the wave_started msg already happend, hide the timer
		// instantly and continue, else start the fade out over time 
		// and wait for the wave to start
		if ( isdefined( msg ) && msg == "wave_started" )
		{
			// hide timer, wave number, and clock icon now
			hud_time thread maps\_hud_util::fade_over_time( 0.0, 0.0 );
			hud_clock_icon thread maps\_hud_util::fade_over_time( 0.0, 0.0 );
		}
		else
		{
			// fade timer, wave number and clock icon out
			hud_time thread maps\_hud_util::fade_over_time( 0.0, 0.5 );
			hud_clock_icon thread maps\_hud_util::fade_over_time( 0.0, 0.5 );
						
			level waittill( "wave_started" );
		}
	}
}

// ==========================================================================
// ARMOR UI

armor_HUD()
{
	self endon( "death" );
	
	self.armor_x 			= 0;
	
	if ( issplitscreen() )
		self.armor_y 		= 112 + ( self == level.player )*27;
	else
		self.armor_y 		= 196; //182;
		
	self.armor_shield_size 	= 35; //22;

	// shield
	self.shield_elem 		= self special_item_hudelem( self.armor_x, self.armor_y );
	self.shield_elem 		setShader( "specialty_armorvest", self.armor_shield_size, self.armor_shield_size );
	self.shield_elem.alpha 	= 0.85;
	
	// shield fade
	self.shield_elem_fade	= self special_item_hudelem( self.armor_x, self.armor_y );
	self.shield_elem_fade.alpha = 0;
		
	self thread print_armor_hint();
	
	waittillframeend;
	while ( 1 )
	{
		if ( isdefined( self.armor ) && isdefined( self.armor[ "points" ] ) && self.armor[ "points" ] )
		{
			// armor is green until under 100
			weaked_armor = 100;

			green 	= float_capped( self.armor["points"] / (weaked_armor/2), 0, 1 );
			red		= 1 - float_capped( ( self.armor[ "points" ] - weaked_armor/2 ) / (weaked_armor/2), 0, 1 );

			self.shield_elem.alpha 	= 0.85;
			self.shield_elem.color 	= ( 1, float_capped( green, 0, 0.95 ), float_capped( green, 0, 0.7 ) );
			
			self thread armor_jitter();
		}
		else
		{
			self.shield_elem.alpha = 0;
		}
		
		self waittill_any( "damage", "health_update" );
	}
}

armor_jitter()
{
	self endon( "death" );
	
	self.shield_elem_fade.alpha = 0.85;
	
	samples = 20;
	for( i=0; i<=samples; i++ )
	{
		// jittering
		jitter_amount = randomint(int(max(1, 5 - i / (samples / 5)))) - int(2 - i / (samples / 2));
		self.shield_elem.x = self.armor_x + jitter_amount;
		self.shield_elem.y = self.armor_y + jitter_amount;
		
		// this is the fading enlarging shield
		enlarge_amount = int(i * (40 / samples));
		self.shield_elem_fade setShader("specialty_armorvest", self.armor_shield_size + enlarge_amount, self.armor_shield_size + enlarge_amount);
		self.shield_elem_fade.alpha = max((samples * 0.85 - i ) / samples, 0);
		
		wait 0.05;
	}
	
	self.shield_elem_fade.alpha = 0;
	
	self.shield_elem.x = self.armor_x;
	self.shield_elem.y = self.armor_y;
}

print_armor_hint( points )
{
	self endon( "death" );

	self.armor_label 			= self special_item_hudelem( self.armor_x, self.armor_y );
	self.armor_label.alpha 		= 0.85;
	self.armor_label.elemType 	= "font";
	self.armor_label.label		= &"SO_SURVIVAL_ARMOR_POINTS";
	self.armor_label.y 			-= 2;
	self.armor_label.x 			-= 59;
	self.armor_label.font 		= "bankshadow";
	self.armor_label.fontscale 	= 1;
	self.armor_label.width 		= 0;
	self.armor_label.color		= ( 1, 0.95, 0.7 );
	self.armor_label.alignx 	= "left";
	if ( isdefined( self.armor ) )
		self.armor_label 		setvalue( self.armor[ "points" ] );
	else
		self.armor_label		setvalue( 0 );
	
	initial_display_time		= CONST_ARMOR_INITIAL_DISPLAY_TIME;
	
	while ( 1 )
	{
		if ( !isdefined( self.armor ) || !isdefined( self.armor[ "points" ] ) || !self.armor[ "points" ] )
		{	
			self.armor_label.alpha = 0;
			wait 0.05;
			continue;
		}
		
		self.armor_label.alpha 		= 0.85;
		// this ends early if new damage or update is notified to get fresh armor HP numbers or is ZERO

		msg 		= "";
		fade_time 	= 2;
		timer 		= CONST_ARMOR_DISPLAY_TIME;
		
		while ( timer > 0 || initial_display_time > 0 )
		{
			msg = self waittill_any_timeout( 0.5, "damage", "health_update" );
			self.armor_label setvalue( self.armor[ "points" ] );
			timer -= 0.5;
			
			if ( initial_display_time > 0 )
				initial_display_time -= 0.5;
			
			if ( self.armor[ "points" ] <= 0 )
			{
				fade_time = 0.5;
				break;
			}
		}
		
		// fade out
		self.armor_label FadeOverTime( fade_time );
		self.armor_label.alpha = 0;
		
		// if waittill messages hit, we dont wait again
		if ( msg != "damage" && msg != "health_update" )
			self waittill_any( "damage", "health_update" );
	}
}

// ==========================================================================
// ENEMIES REMAINING
/*
enemy_remaining_HUD()
{
	self endon( "death" );

	while ( 1 )
	{
		level waittill_either( "axis_spawned", "axis_died" );
		
		// update wave # on player HUD
		if ( !flag( "aggressive_mode" ) )
		{
			self.hud_so_wave_enemy.alpha = 0;
		}
		else
		{
			self.hud_so_wave_enemy thread maps\_hud_util::fade_over_time( 1.0, 0.5 );
			self.hud_so_wave_enemy setvalue( level.enemy_remaining );
			
			if ( level.enemy_remaining == 1 )
				self.hud_so_wave_enemy.label = &"SO_SURVIVAL_ENEMY_LEFT";
			else
				self.hud_so_wave_enemy.label = &"SO_SURVIVAL_ENEMIES_LEFT";
		}
	}
}*/

enemy_remaining_HUD()
{
	self endon( "death" );
	
	self surHUD_disable( "enemy" );
	self _setplayerdata_single( "surHUD_enemy", 0 );
	
	while ( 1 )
	{
		level waittill_either( "axis_spawned", "axis_died" );
		// update wave # on player HUD
		if ( !flag( "aggressive_mode" ) )
		{
			self surHUD_disable( "enemy" );
		}
		else
		{
			self surHUD_enable( "enemy" );
			self _setplayerdata_single( "surHUD_enemy", level.enemy_remaining );
		}
	}
}

perk_HUD()
{
	self endon( "death" );
	
	self.perk_icon_HUD 				= spawnstruct();
	self.perk_icon_HUD.pos_x		= -145;
	
	if ( issplitscreen() )
		self.perk_icon_HUD.pos_y	= 112 + ( self == level.player )*27;
	else
		self.perk_icon_HUD.pos_y	= 196;
		
	self.perk_icon_HUD.icon_size	= 35;			// Width & height
	
	self.perk_icon_HUD.icon 		= self special_item_hudelem( self.perk_icon_HUD.pos_x, self.perk_icon_HUD.pos_y );
	self.perk_icon_HUD.icon.color	= ( 1, 1, 1 ); //( 1, 0.9, 0.65 );
	self.perk_icon_HUD.icon.alpha	= 0.0;
	
	while ( 1 )
	{
		self waittill( "give_perk", ref );
		assert( isdefined( level.armory[ "airsupport" ][ ref ] ) );
		assert( self hasperk( ref, true ) );
		
		icon = level.armory[ "airsupport" ][ ref ].icon;
		self.perk_icon_HUD.icon setShader( icon, self.perk_icon_HUD.icon_size, self.perk_icon_HUD.icon_size );
		self.perk_icon_HUD.icon.alpha	= 0.85;
	}
}

laststand_HUD()
{
	self endon( "death" );
	
	self.laststand_HUD_lives 				= spawnstruct();
	self.laststand_HUD_lives.pos_x			= -104;
	
	if ( issplitscreen() )
		self.laststand_HUD_lives.pos_y		= 112 + ( self == level.player )*27;
	else
		self.laststand_HUD_lives.pos_y		= 196;

	self.laststand_HUD_lives.icon_size		= 35;			// Width & height

	// Laststand Icon
	self.laststand_HUD_lives.icon 		= self special_item_hudelem( self.laststand_HUD_lives.pos_x, self.laststand_HUD_lives.pos_y );
	self.laststand_HUD_lives.icon 		setShader( "specialty_pistoldeath", self.laststand_HUD_lives.icon_size, self.laststand_HUD_lives.icon_size );
	self.laststand_HUD_lives.icon.color	= ( 1, 1, 1 ); //( 1, 0.9, 0.65 );
	self.laststand_HUD_lives.icon.alpha	= 0.0;
	
	while ( 1 )
	{
		msg = self waittill_any_return( "laststand_lives_updated", "player_downed" );
		
		if ( msg == "player_downed" )
		{
			self.laststand_HUD_lives.icon.alpha	= 0.0;		
		}
		else if ( self maps\_laststand::get_lives_remaining() > 0 )
		{
			self.laststand_HUD_lives.icon.alpha	= 1;
		}
		else
		{
			self.laststand_HUD_lives.icon.alpha	= 0.0;		
		}
	}
}

special_item_hudelem( pos_x, pos_y )
{
	elem 				= NewClientHudElem( self );
	elem.hidden 		= false;
	elem.elemType 		= "icon";
	elem.hideWhenInMenu = true;
	elem.archived 		= false;
	elem.x 				= pos_x;
	elem.y 				= pos_y;
	elem.alignx 		= "center";
	elem.aligny 		= "middle";
	elem.horzAlign 		= "center";
	elem.vertAlign 		= "middle";
	
	return elem;
}

wave_HUD()
{
	self endon( "death" );
	
	self surHUD_disable( "wave" );
	self _setplayerdata_single( "surHUD_wave", 0 );
	
	while ( 1 )
	{
		level waittill( "wave_started" );
		self surHUD_enable( "wave" );
		
		// update wave # on player HUD
		self _setplayerdata_single( "surHUD_wave", level.current_wave );
	}
}

// ==========================================================================
// Intermission countdown timer using MP Style
// DIRECT COPY/PASE with minor removal of MP only stuff - 5/3/2011

matchStartTimer( duration )
{
	matchStartTimer = self creatCountDownHudElem( "bankshadow", 2 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer.sort = 1001;
	//matchStartTimer.color = (1,1,0);
	
	matchStartTimer.glowColor = ( 0.15, 0.35, 0.85 );
	matchStartTimer.color	= ( 0.95, 0.95, 0.95 );
	
	matchStartTimer.foreground = false;
	matchStartTimer.hidewheninmenu = true;
	matchStartTimer fontPulseInit(3);
	
	matchStartTimer_Internal( int( duration ), matchStartTimer );
	
	matchStartTimer destroy();
}

fontPulseInit( maxFontScale )
{
	self.baseFontScale = self.fontScale;
	if ( isDefined( maxFontScale ) )
		self.maxFontScale = min( maxFontScale, 6.3 );
	else
		self.maxFontScale = min( self.fontScale * 2, 6.3 );
	self.inFrames = 2;
	self.outFrames = 4;
}

creatCountDownHudElem( font, fontScale )
{
	fontElem = NewClientHudElem( self );
	
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.baseFontScale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int(level.fontHeight * fontScale);
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level.uiParent );
	fontElem.hidden = false;
	
	return fontElem;
}

matchStartTimer_Internal( countTime, matchStartTimer )
{
	while ( countTime > 0 )
	{
		if ( countTime > 99 )
			matchStartTimer.alpha = 0;
		else
			matchStartTimer.alpha = 1;
		
		foreach( player in level.players )
			player PlaySound( "countdown_beep" );
		
		matchStartTimer thread fontPulse();
		wait ( matchStartTimer.inFrames * 0.05 );
		matchStartTimer setValue( countTime );
		countTime--;
		wait ( 1 - (matchStartTimer.inFrames * 0.05) );
	}
}

fontPulse()
{
	self notify ( "fontPulse" );
	self endon ( "fontPulse" );
	self endon( "death" );
	
	self ChangeFontScaleOverTime( self.inFrames * 0.05 );
	self.fontScale = self.maxFontScale;	
	wait self.inFrames * 0.05;
	
	self ChangeFontScaleOverTime( self.outFrames * 0.05 );
	self.fontScale = self.baseFontScale;
}

// ==========================================================================
// COMBAT PERFORMANCE

player_performance_UI_init()
{
	/*	"time",
		"headshot",
		"kill",
		"accuracy",
		"damage",
		"damagedone",
		"knifekill",
		"killstreak",
		"revive",
		"downed",
		"assist",
		"moneydonated",
		"moneyearned",
	*/

	// reset wave performance stats
	self player_performance_reset();
	self surHUD_disable( "performance" );
}

performance_summary( reward_array )
{
	level notify("show_wave_summary", reward_array);

	/*self endon( "death" );
	
	assertex( isdefined( self.performance ), "Player performance data is not initialized." );
	
	// wait for reward calculation of the other player
	if ( is_coop() )
		waittillframeend;
	
	foreach ( index_string, performance in self.performance )
	{
		self _setplayerdata_array( "surHUD_performance", index_string, self.performance[ index_string ] );
		self _setplayerdata_array( "surHUD_performance_credit", index_string, reward_array[ index_string ] );
		
		// get other player's data
		if ( is_coop() )
		{
			// this is forced to player 2 will need to change for more than 2 players in future games
			player_2 = get_other_player( self );
			assertex( isdefined( player_2.performance ), "Other player's performance stats are not setup." );
			assertex( isdefined( player_2.performance[ index_string ] ), "Other player's performance["+index_string+"] is not setup." );

			self _setplayerdata_array( "surHUD_performance_p2", index_string, player_2.performance[ index_string ] );
		}
	}
	
	self _setplayerdata_single( "surHUD_performance_reward", reward_array[ "total" ] );
	
	wait 1;	// just a small delay so not too much stuff at once on screen at end of a wave
	self surHUD_animate( "performance" );*/
}

// debug console prints
performance_summary_debug( reward_array )
{	
	bar = "---------------------------------------------";
	title = "COOP";
	if ( !is_coop() )
		title = "SOLO";
	
	println( "====================" + title + "=====================" );
	println( "WAVE: " + level.current_wave );
	println( bar );
	foreach ( index_string, reward in reward_array )
	{
		if( index_string == "total" )
			continue;
		println( index_string + ": " + self.performance[ index_string ]	+ " = $" + reward );
	}
	println( bar );
	println( "TOTAL CREDITS REWARDED: $" + reward_array[ "total" ] );
}

// ==========================================================================
// SPLASH MESSAGES

wave_splash()
{
	level endon( "special_op_terminated" );
	
	waittill_survival_start();
	while ( 1 )
	{
		level waittill( "wave_started" );
		
		thread wave_start_splash( "" );
		level waittill( "wave_ended", wave_num );
		
		waittill_players_ready_for_splash( 10 );
		//wait( 2 );
		thread wave_clear_splash( wave_num );
	}
}

wave_start_splash( waveDesc )
{
	splashData 			= SpawnStruct();
	splashData.title 	= &"SO_SURVIVAL_WAVE_TITLE";
	splashData.duration = 1.5;
	splashData.sound 	= "survival_wave_start_splash";	
	
	array_thread( level.players, ::player_wave_splash, splashData );
}

wave_clear_splash( wave_num )
{
	splashData 					= SpawnStruct();
	splashData.title 			= &"SO_SURVIVAL_WAVE_SUCCESS_TITLE";
	splashData.title_set_value 	= wave_num;
	splashData.duration 		= 2.5;
	splashData.sound 			= "survival_wave_end_splash";

	array_thread( level.players, ::player_wave_splash, splashData );
}

player_wave_splash( splashData )
{
	if( IsDefined( self.doingNotify ) && self.doingNotify )
	{
		while( self.doingNotify )
			wait( 0.05 );
	}
	
	if ( !isdefined( splashData.duration ) )
		splashData.duration 	= 1.5;

	splashData.title_glowColor 	= ( 0.15, 0.35, 0.85 );
	splashData.title_color		= ( 0.95, 0.95, 0.95 );
	splashData.type 			= "wave";
	splashData.title_font 		= "bank";
	splashData.playSoundLocally = true;
	splashData.zoomIn 			= true;
	splashData.zoomOut 			= true;
	splashData.fadeIn 			= true;
	splashData.fadeOut 			= true;
	
	if( IsSplitscreen() )
	{
		splashData.title_baseFontScale = 1;
		splashData.desc_baseFontScale = 1.2;
	}
	else
	{
		splashData.title_baseFontScale = 2;
		splashData.desc_baseFontScale = 2;
	}
	
	self splash_notify_message( splashData );
}

// ==========================================================================
// ARMORY AVAILABLE HINT

survival_armory_hint()
{
	level endon( "special_op_terminated" );
	
	foreach( player in level.players )
	{
		player surHUD_disable( "armory" );
		
		player _setplayerdata_array( "surHUD_unlock_hint_armory", "name", "" );
		player _setplayerdata_array( "surHUD_unlock_hint_armory", "icon", "" );
		player _setplayerdata_array( "surHUD_unlock_hint_armory", "desc", "" );
	}
	
	while( 1 )
	{
		level waittill( "armory_open", armory_ent );
		
		armory_name = "";
		armory_desc = "";
		armory_icon = armory_ent.icon;
		
		if ( armory_ent.armory_type == "weapon" )
		{
			armory_name = "@SO_SURVIVAL_ARMORY_WEAPON_AV";
			armory_desc = "@SO_SURVIVAL_ARMORY_WEAPON_DESC";
		}
		else if ( armory_ent.armory_type == "airsupport" )
		{
			armory_name = "@SO_SURVIVAL_ARMORY_AIRSUPPORT_AV";
			armory_desc = "@SO_SURVIVAL_ARMORY_AIRSUPPORT_DESC";
		}
		else if ( armory_ent.armory_type == "equipment" )
		{
			armory_name = "@SO_SURVIVAL_ARMORY_EQUIPMENT_AV";
			armory_desc = "@SO_SURVIVAL_ARMORY_EQUIPMENT_DESC";
		}

		foreach( player in level.players )
		{
			player _setplayerdata_array( "surHUD_unlock_hint_armory", "name", armory_name );
			player _setplayerdata_array( "surHUD_unlock_hint_armory", "icon", armory_icon );
			player _setplayerdata_array( "surHUD_unlock_hint_armory", "desc", armory_desc );
			
			player surHUD_animate( "armory" );
		}
	}
}






