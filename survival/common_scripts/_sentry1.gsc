#include common_scripts\utility;
//#include maps\_hud_util;
#using_animtree( "sentry_gun" );

/*QUAKED script_model_pickup_sentry_gun (1 0 0) (-32 -16 0) (32 16 24) ORIENT_LOD NO_SHADOW  NO_STATIC_SHADOWS
defaultmdl="sentry_gun_folded"
default:"model" "sentry_gun_folded"
*/

/*QUAKED script_model_pickup_sentry_minigun (1 0 0) (-32 -16 0) (32 16 24) ORIENT_LOD NO_SHADOW  NO_STATIC_SHADOWS
defaultmdl="sentry_minigun_folded"
default:"model" "sentry_minigun_folded"
*/

/*
code support:
-physics on turrets

todo:
-make hint print while in placement mode
-hit max number of turrets at 32, but I could limit the number allowed
-get behind turret and change team
*/

/*
	Constants
*/

// default
SO_SUR_HEALTH_OVERRIDE				= 800;	// used by survival mode
SO_SUR_GL_HEALTH_OVERRIDE			= 1200;	// used by survival mode

underattack_dps						= 100;	// dps sampled that activates "sentry under fire!" notify
dps_sample_time						= 3;	// number of seconds to sample for dps

sentry_updateTime 				 	= 0.05;
shielded_sentry_health 			 	= 350;	// direct hit from an RPG
shielded_sentry_bullet_armor 	 	= 2000;
minigun_sentry_health 			 	= 190;	// frag grenade does 200 inner damage
minigun_sentry_bullet_armor 	 	= 1200;
minigun_sentry_bullet_armor_enemy 	= 0;

// mp
shielded_sentry_bullet_armor_mp	 	= 300;
minigun_sentry_bullet_armor_mp	 	= 300;

sentry_mode_name_on				 	= "sentry";
sentry_mode_name_off			 	= "sentry_offline";

main()
{
	setup_sentry_globals();
	setup_sentry_minigun();
	setup_sentry_grenade_launcher();
	if ( isSP_TowerDefense() )
	{
		setup_sentry_minigun_weak();
		setup_sentry_grenade_launcher_weak();
	}
}

setup_sentry_globals()
{
	// LANG_ENGLISH		Press and hold ^3&&1^7 to move the turret."
	precacheString( &"SENTRY_MOVE" );
	// Press and hold ^3&&1^7 to pick up the turret.
	precacheString( &"SENTRY_PICKUP" );
	precacheString( &"SENTRY_PLACE" );
	precacheString( &"SENTRY_CANNOT_PLACE" );

	precacheModel( "tag_laser" );

	level.placed_sentry = [];

	level.sentry_settings = [];

	level.sentryTurretSettings = [];
	level.sentryTurretSettings[ "easy" ] = [];
	level.sentryTurretSettings[ "easy" ][ "convergencePitchTime" ] 	= 2.5;
	level.sentryTurretSettings[ "easy" ][ "convergenceYawTime" ] 	= 2.5;
	level.sentryTurretSettings[ "easy" ][ "suppressionTime" ] 		= 3.0;
	level.sentryTurretSettings[ "easy" ][ "aiSpread" ] 				= 2.0;
	level.sentryTurretSettings[ "easy" ][ "playerSpread" ] 			= 0.5;

	level._effect[ "sentry_turret_overheat_smoke_sp" ]		= loadfx( "smoke/sentry_turret_overheat_smoke_sp" );
	level._effect[ "sentry_turret_explode" ]				= loadfx( "explosions/sentry_gun_explosion" );
	level._effect[ "sentry_turret_explode_smoke" ]			= loadfx( "smoke/car_damage_blacksmoke" );
}

setup_sentry_minigun()
{
	precacheModel( "sentry_minigun" );
	precacheModel( "sentry_minigun_obj" );
	precacheModel( "sentry_minigun_obj_red" );
	precacheModel( "sentry_minigun_folded_obj" );
	precacheModel( "sentry_minigun_destroyed" );

	if ( isSP() && !is_specialop() )
	{
		precacheTurret( "sentry_minigun" );
		precacheTurret( "sentry_minigun_enemy" );
	}
	else if ( is_specialop() )
	{
		precacheTurret( "sentry_minigun_so" );
	}
	else
	{
		precacheTurret( "sentry_minigun_mp" );
	}

	level.sentry_settings[ "sentry_minigun" ] = spawnStruct();
	sentry_minigun_default_settings( "sentry_minigun" );
	init_placed_sentries( "sentry_minigun" );
	array_thread( getentarray( "script_model_pickup_sentry_minigun", "classname" ), ::sentry_pickup_init, "sentry_minigun" );
}

setup_sentry_minigun_weak()
{
	precacheModel( "sentry_minigun_weak" );
	precacheModel( "sentry_minigun_weak_destroyed" );
	precacheModel( "sentry_minigun_weak_obj" );
	precacheModel( "sentry_minigun_weak_obj_red" );
	precacheModel( "sentry_minigun_weak_folded_obj" );

	precacheTurret( "sentry_minigun_weak" );

	level.sentry_settings[ "sentry_minigun_weak" ] = spawnStruct();
	sentry_minigun_weak_settings( "sentry_minigun_weak" );
	init_placed_sentries( "sentry_minigun_weak" );
	array_thread( getentarray( "script_model_pickup_sentry_minigun_weak", "classname" ), ::sentry_pickup_init, "sentry_minigun_weak" );
}

setup_sentry_grenade_launcher()
{
	precacheModel( "sentry_grenade_launcher_upgrade" );
	precacheModel( "sentry_grenade_launcher_upgrade_destroyed" );
	precacheModel( "sentry_grenade_launcher_upgrade_obj" );
	precacheModel( "sentry_grenade_launcher_upgrade_obj_red" );
	precacheModel( "sentry_grenade_launcher_upgrade_folded_obj" );

	if ( isSP() && !is_specialop() )
		precacheTurret( "sentry_gun" );
	else if ( is_specialop() )
		precacheTurret( "sentry_gun_so" );
	else
		precacheTurret( "sentry_gun_mp" );

	level.sentry_settings[ "sentry_gun" ] = spawnStruct();
	sentry_gun_default_settings( "sentry_gun" );
	init_placed_sentries( "sentry_gun" );
	array_thread( getentarray( "script_model_pickup_sentry_gun", "classname" ), ::sentry_pickup_init, "sentry_gun" );
}

setup_sentry_grenade_launcher_weak()
{
	precacheModel( "sentry_grenade_launcher" );
	precacheModel( "sentry_grenade_launcher_destroyed" );
	precacheModel( "sentry_grenade_launcher_obj" );
	precacheModel( "sentry_grenade_launcher_obj_red" );
	precacheModel( "sentry_grenade_launcher_folded_obj" );

	precacheTurret( "sentry_gun_weak" );

	level.sentry_settings[ "sentry_gun_weak" ] = spawnStruct();
	sentry_gun_weak_settings( "sentry_gun_weak" );
	init_placed_sentries( "sentry_gun_weak" );
	array_thread( getentarray( "script_model_pickup_sentry_gun_weak", "classname" ), ::sentry_pickup_init, "sentry_gun_weak" );
}

init_placed_sentries( sentry_type )
{
	sentries = getentarray( sentry_type, "targetname" );
	foreach( sentry in sentries )
		sentry sentry_init( undefined, sentry_type );
}

sentry_gun_default_settings( type )
{
	level.sentry_settings[ type ].ammo 		 		 = 100;
	level.sentry_settings[ type ].use_laser 		 = true;
	level.sentry_settings[ type ].burst_shots_min 	 = 1;
	level.sentry_settings[ type ].burst_shots_max 	 = 2;
	level.sentry_settings[ type ].burst_pause_min 	 = 1;
	level.sentry_settings[ type ].burst_pause_max 	 = 1.5;
	level.sentry_settings[ type ].fire_only_on_target= true;
	level.sentry_settings[ type ].model 			 = "sentry_grenade_launcher_upgrade";
	level.sentry_settings[ type ].destroyedModel 	 = "sentry_grenade_launcher_upgrade_destroyed";
	level.sentry_settings[ type ].pickupModel 		 = "sentry_grenade_launcher_upgrade_folded";
	level.sentry_settings[ type ].pickupModelObj 	 = "sentry_grenade_launcher_upgrade_folded_obj";
	level.sentry_settings[ type ].placementmodel 	 = "sentry_grenade_launcher_upgrade_obj";
	level.sentry_settings[ type ].placementmodelfail = "sentry_grenade_launcher_upgrade_obj_red";
	level.sentry_settings[ type ].health 			 = shielded_sentry_health;
	
	// turrent weapon override
	if ( isSP() && !is_specialop() )
	{
		level.sentry_settings[ type ].damage_smoke_time = 15;
		level.sentry_settings[ type ].weaponInfo 	= "sentry_gun";
		level.sentry_settings[ type ].targetname 	= "sentry_gun";
	}
	else if ( is_specialop() )
	{
		level.sentry_settings[ type ].ammo 		 	= 50;
		level.sentry_settings[ type ].damage_smoke_time = 8;
		level.sentry_settings[ type ].weaponInfo 	= "sentry_gun_so";
		level.sentry_settings[ type ].targetname 	= "sentry_gun_so";
		level.sentry_settings[ type ].health		= SO_SUR_GL_HEALTH_OVERRIDE;
	}
	else
	{
		level.sentry_settings[ type ].damage_smoke_time = 5;
		level.sentry_settings[ type ].weaponInfo 	= "sentry_gun_mp";
		level.sentry_settings[ type ].targetname 	= "sentry_gun_mp";		
	}
}

sentry_gun_weak_settings( type )
{
	level.sentry_settings[ type ].use_laser 		 = false;
	level.sentry_settings[ type ].burst_shots_min 	 = 1;
	level.sentry_settings[ type ].burst_shots_max 	 = 2;
	level.sentry_settings[ type ].burst_pause_min 	 = 1;
	level.sentry_settings[ type ].burst_pause_max 	 = 1.5;
	level.sentry_settings[ type ].fire_only_on_target= true;
	level.sentry_settings[ type ].model 			 = "sentry_grenade_launcher";
	level.sentry_settings[ type ].destroyedModel 	 = "sentry_grenade_launcher_destroyed";
	level.sentry_settings[ type ].pickupModel 		 = "sentry_grenade_launcher_folded";
	level.sentry_settings[ type ].pickupModelObj 	 = "sentry_grenade_launcher_folded_obj";
	level.sentry_settings[ type ].placementmodel 	 = "sentry_grenade_launcher_obj";
	level.sentry_settings[ type ].placementmodelfail = "sentry_grenade_launcher_obj_red";
	level.sentry_settings[ type ].health 			 = int( shielded_sentry_health * 0.5 );
	
	// turrent weapon override
	if ( isSP() )
	{
		level.sentry_settings[ type ].damage_smoke_time = 15;
		level.sentry_settings[ type ].weaponInfo 		 = "sentry_gun_weak";
		level.sentry_settings[ type ].targetname 		 = "sentry_gun_weak";
	}
	else
	{
		level.sentry_settings[ type ].damage_smoke_time = 5;
		level.sentry_settings[ type ].weaponInfo 		 = "sentry_gun_mp";
		level.sentry_settings[ type ].targetname 		 = "sentry_gun_mp";
	}
}

sentry_minigun_default_settings( type )
{
	level.sentry_settings[ type ].ammo 		 		 = 1000;
	level.sentry_settings[ type ].use_laser 		 = true;
	level.sentry_settings[ type ].burst_shots_min 	 = 20;
	level.sentry_settings[ type ].burst_shots_max 	 = 60;
	level.sentry_settings[ type ].burst_pause_min 	 = 0.5;
	level.sentry_settings[ type ].burst_pause_max 	 = 1.3;
	level.sentry_settings[ type ].fire_only_on_target= false;
	level.sentry_settings[ type ].model 			 = "sentry_minigun";
	level.sentry_settings[ type ].destroyedModel 	 = "sentry_minigun_destroyed";
	level.sentry_settings[ type ].pickupModel 		 = "sentry_minigun_folded";
	level.sentry_settings[ type ].pickupModelObj 	 = "sentry_minigun_folded_obj";
	level.sentry_settings[ type ].placementmodel 	 = "sentry_minigun_obj";
	level.sentry_settings[ type ].placementmodelfail = "sentry_minigun_obj_red";
	level.sentry_settings[ type ].health 			 = minigun_sentry_health;

	// turrent weapon override
	if ( isSP() && !is_specialop() )
	{
		level.sentry_settings[ type ].damage_smoke_time = 15;
		level.sentry_settings[ type ].anim_loop 	= %minigun_spin_loop;
		level.sentry_settings[ type ].weaponInfo 	= "sentry_minigun";
		level.sentry_settings[ type ].targetname 	= "sentry_minigun";
	}
	else if ( is_specialop() )
	{
		level.sentry_settings[ type ].ammo 		 	= 800;
		level.sentry_settings[ type ].damage_smoke_time = 8;
		level.sentry_settings[ type ].anim_loop 	= %minigun_spin_loop;
		level.sentry_settings[ type ].weaponInfo 	= "sentry_minigun_so";
		level.sentry_settings[ type ].targetname 	= "sentry_minigun_so";
		level.sentry_settings[ type ].health		= SO_SUR_HEALTH_OVERRIDE;
	}
	else
	{
		level.sentry_settings[ type ].damage_smoke_time = 5;
		level.sentry_settings[ type ].weaponInfo 	= "sentry_minigun_mp";
		level.sentry_settings[ type ].targetname 	= "sentry_minigun_mp";
	}
}

sentry_minigun_weak_settings( type )
{
	level.sentry_settings[ type ].ammo 		 		 = 800;
	level.sentry_settings[ type ].use_laser 		 = false;
	level.sentry_settings[ type ].burst_shots_min 	 = 10;
	level.sentry_settings[ type ].burst_shots_max 	 = 30;
	level.sentry_settings[ type ].burst_pause_min 	 = 1.0;
	level.sentry_settings[ type ].burst_pause_max 	 = 2.6;
	level.sentry_settings[ type ].fire_only_on_target= false;
	level.sentry_settings[ type ].model 			 = "sentry_minigun_weak";
	level.sentry_settings[ type ].destroyedModel 	 = "sentry_minigun_weak_destroyed";
	level.sentry_settings[ type ].pickupModel 		 = "sentry_minigun_weak_folded";
	level.sentry_settings[ type ].pickupModelObj 	 = "sentry_minigun_weak_folded_obj";
	level.sentry_settings[ type ].placementmodel 	 = "sentry_minigun_weak_obj";
	level.sentry_settings[ type ].placementmodelfail = "sentry_minigun_weak_obj_red";
	level.sentry_settings[ type ].health 			 = int( minigun_sentry_health * 0.5 );

	// turrent weapon override
	if ( isSP() )
	{
		level.sentry_settings[ type ].damage_smoke_time = 15;
		level.sentry_settings[ type ].anim_loop 		 = %minigun_spin_loop;
		level.sentry_settings[ type ].weaponInfo 		 = "sentry_minigun_weak";
		level.sentry_settings[ type ].targetname 		 = "sentry_minigun_weak";
	}
	else
	{
		level.sentry_settings[ type ].damage_smoke_time = 5;
		level.sentry_settings[ type ].weaponInfo 		 = "sentry_minigun_mp";
		level.sentry_settings[ type ].targetname 		 = "sentry_minigun_mp";
	}
}

sentry_pickup_init( sentryType )
{
	assert( isdefined( sentryType ) );
	assert( isdefined( level.sentry_settings[ sentryType ] ) );
	self setModel( self.model );
	self.sentryType = sentryType;

	self setCursorHint( "HINT_NOICON" );
	// Press and hold ^3&&1^7 to pick up the turret.
	self setHintString( &"SENTRY_PICKUP" );
	self makeUsable();

	self thread folded_sentry_use_wait( sentryType );
}

giveSentry( sentryType )
{
	assert( isdefined( level.sentry_settings ) );
	assert( isdefined( level.sentry_settings[ sentryType ] ) );

	self.last_sentry = sentryType;
	self thread spawn_and_place_sentry( sentryType );
}

sentry_init( team, sentryType, owner )
{
	/*if ( is_survival() )
	{
		level.sentry_ammo_enabled = true;
	}*/
	
	if ( isSP() )
	{
		// sentry overheat override settings
		level.sentry_overheating_speed 	= 1;	// 1 heat points per second
		level.sentry_cooling_speed 		= 1;	// 1 heat points cooling per second
		
		if ( !isdefined( level.sentry_fire_time ) )
			level.sentry_fire_time = 5;			// seconds of continous fire ( aka heat points )
		if ( !isdefined( level.sentry_cooldown_time ) )
			level.sentry_cooldown_time = 2;		// seconds of cool down ( aka heat points )
	}
	
	if ( !isdefined( team ) )
	{
		assert( isdefined( self.script_team ) );
		if ( !isdefined( self.script_team ) )
			self.script_team = "axis";
		team = self.script_team;
	}
	
	assert( isDefined( team ) );
	assert( isDefined( sentryType ) );
	
	self setTurretModeChangeWait( true );
	self makeSentrySolid();
	self makeTurretInoperable();
	self SentryPowerOn();
	self setCanDamage( true );
	self setDefaultDropPitch( -89.0 );	// setting this mainly prevents Turret_RestoreDefaultDropPitch() from running
	
	if ( isSP() || level.teambased || is_survival() )
		self setTurretTeam( team );
	
	self.sentryType = sentryType;
	self.isSentryGun = true;
	self.kill_reward_money = 350;
	self.kill_melee_reward_money = 400;
	self.sentry_battery_timer = 60;	// sec
	self.sentry_ammo = level.sentry_settings[ self.sentryType ].ammo; // rounds
	
	//bullet armor acts as an extra pool of health for bullet damage. 
	//once its removed bullet damage affects the sentry like other kinds of damage.
	if ( isSP() )
	{
		if ( self.weaponinfo == "sentry_gun" )// sentry_minigun and sentry_minigun_enemy get the same settings
			self.bullet_armor = shielded_sentry_bullet_armor;
		else
		{
			self.bullet_armor = minigun_sentry_bullet_armor;
		}
	}
	else
	{
		if ( self.weaponinfo == "sentry_gun" )
			self.bullet_armor = shielded_sentry_bullet_armor_mp;
		else
			self.bullet_armor = minigun_sentry_bullet_armor_mp;
	}

	if ( isSP() )
	{
		self call [[ level.makeEntitySentient_func ]]( team );
		self self_func( "useanimtree", #animtree );
		if ( isdefined( self.script_team ) && self.script_team == "axis" )
			self thread enemy_sentry_difficulty_settings();
	}

	self.health = level.sentry_settings[ sentryType ].health;

	self sentry_badplace_create();
	self thread sentry_beep_sounds();
	self thread sentry_enemy_wait();
	self thread sentry_death_wait();
	if ( !isSP() )
	{
		self thread sentry_emp_wait();
		self thread sentry_emp_damage_wait();
	}
	self thread sentry_health_monitor();
	self thread sentry_player_use_wait();
	
	if ( !isdefined( owner ) )
	{
		if( isSP() )
			owner = level.player;
	}
	assert( isdefined( owner ) );
	self sentry_set_owner( owner );
	self thread sentry_destroy_on_owner_leave( owner );
	
	if ( !isdefined( self.damage_functions ) )
		self.damage_functions = [];
}

sentry_death_wait()
{
	self endon( "deleted" );
	
	//self waittill_player_or_sentry_death();
	self waittill( "death", attacker, cause, weapon );
	level notify( "a_sentry_died" );	// for survival dialog notify
	
	if ( isdefined( attacker ) 
		&& isdefined( attacker.team ) 
		&& ( self.team != attacker.team ) 
		&& isdefined( level.stat_track_kill_func ) 
	)
	{
		attacker [[ level.stat_track_kill_func ]]( self, cause, weapon );
	}
	
	if ( !isSP() )
	{
		self removeFromTurretList();
		self thread sentry_place_mode_reset();
	}

	self thread sentry_burst_fire_stop();
	self thread sentry_turn_laser_off();

	assert( isdefined( level.sentry_settings[ self.sentryType ] ) );
	assert( isdefined( level.sentry_settings[ self.sentryType ].destroyedModel ) );
	self setmodel( level.sentry_settings[ self.sentryType ].destroyedModel );
	self SentryPowerOff();
	
	if ( isSP() )
		self call [[ level.freeEntitySentient_func ]]();

	if ( !isSP() &&  isDefined( attacker ) && isPlayer( attacker ) )
	{
		if ( isDefined( self.owner ) )
			self.owner thread [[level.leaderDialogOnPlayer_func]]( "destroy_sentry", "sentry_status" );
		attacker thread [[ level.onXPEvent ]]( "kill" );
	}

	self setSentryCarrier( undefined );
	self.carrier = undefined;
	self SetCanDamage( true );
	self.ignoreMe = true;
	self makeUnusable();
	self SetSentryOwner( undefined );
	self SetTurretMinimapVisible( false );
	self playsound( "sentry_explode" );
	playfxOnTag( getfx( "sentry_turret_explode" ), self, "tag_aim" );
	
	if ( isSP() && ( !isdefined( self.stay_solid_on_death ) || !self.stay_solid_on_death ) )
		self setContents( 0 );
	
	wait 1.5;
	self playsound( "sentry_explode_smoke" );
	timeToSteam = level.sentry_settings[ self.sentryType ].damage_smoke_time * 1000;
	startTime = getTime();
	for ( ;; )
	{
		playfxOnTag( getfx( "sentry_turret_explode_smoke" ), self, "tag_aim" );
		wait .4;
		if ( getTime() - startTime > timeToSteam )
			break;
	}

	level.placed_sentry = array_remove( level.placed_sentry, self );

	if ( !isSP() || GetDvar( "specialops" ) == "1" )
		self thread removeDeadSentry();
}

handle_sentry_on_carrier_death( sentry )
{
	level endon( "game_ended" );
	self endon( "sentry_placement_finished" );
	self waittill( "death" );

	if ( isSp() )
	{
		sentry notify( "death" );
		return;
	}

	if ( !self.canPlaceEntity )
	{	
		sentry sentry_place_mode_reset();
		sentry notify( "deleted" );
		
		waittillframeend;
		sentry delete();
		
		return;
	}
	
	if ( !isSp() )
	{	
		self thread place_sentry( sentry );
	}
	
}

kill_sentry_on_carrier_disconnect( sentry )
{
	level endon( "game_ended" );
	self endon( "sentry_placement_finished" );
	self waittill( "disconnect" );

	sentry notify( "death" );
}

handle_sentry_placement_failed( sentry )
{
	level endon( "game_ended" );
	self endon( "sentry_placement_finished" );
	
	self waittill( "sentry_placement_canceled" );
	
	sentry sentry_place_mode_reset();
	self sentry_placement_hint_hide();
	sentry notify( "death" );
}

// player carry sentry
sentry_player_use_wait()
{
	level endon( "game_ended" );
	self endon( "death" );
	
	assert( isDefined( self.sentryType ) );

	if ( self.health <= 0 )
		return;
	
	// Let the player pick up the sentry again
	self makeUsable();

	for ( ;; )
	{
		self waittill( "trigger", player );

		if ( isDefined( player.placingSentry ) )
			continue;

		// only owner of sentry can move sentry in MP
		if ( !isSP() )
		{
			// Checked through code now; Assert left for reference.
			assert( isDefined( self.owner ) );
			assert( player == self.owner );
		}

		break;
	}

	player thread handle_sentry_placement_failed( self );
	player thread handle_sentry_on_carrier_death( self );
	player thread kill_sentry_on_carrier_disconnect( self );
	player thread sentry_placement_endOfLevel_cancel_monitor( self );

	if ( !isSP() && !isAlive( player ) )
		return;
		
	if ( !isSP() )
		self sentry_team_hide_icon();

	self SentryPowerOff();// makes the turret non - operational while being moved
	player.placingSentry = self;
	self setSentryCarrier( player );
	self.carrier = player;
	self.ignoreMe = true;
	self SetCanDamage( false );
	
	self MakeUnusable();
	
	player _disableWeapon();
	//player _disableUsability();
	self makeSentryNotSolid();
	self sentry_badplace_delete();
	player thread move_sentry_wait( self );
	player thread updateSentryPositionThread( self );
}

sentry_badplace_create()
{
	if ( !isSP() )
		return;
	self.badplace_name = "" + getTime();
	call [[ level.badplace_cylinder_func ]]( self.badplace_name, 0, self.origin, 32, 128, self.team, "neutral" );
}

sentry_badplace_delete()
{
	if ( !isSP() )
		return;
	assert( isdefined( self.badplace_name ) );
	call [[ level.badplace_delete_func ]]( self.badplace_name );
	self.badplace_name = undefined;
}

move_sentry_wait( sentry )
{
	level endon( "game_ended" );
	sentry endon( "death" );
	sentry endon( "deleted" );

	self endon( "death" );
	self endon( "disconnect" );
	assert( isdefined( sentry ) );

	sentry notify( "sentry_move_started", self );
	self.carrying_pickedup_sentry = true;

	for ( ;; )
	{
		//debounce
		self waitActivateButton( false );

		// wait for button press
		self waitActivateButton( true );

		updateSentryPosition( sentry );
		if ( self.canPlaceEntity )
			break;
	}
	
	sentry notify( "sentry_move_finished", self );
	self.carrying_pickedup_sentry = false;
	
	place_sentry( sentry );
}

place_sentry( sentry )
{
	if ( !isSP() )
	{
		self endon( "death" );
		level endon( "end_game" );
	}
	
	self.placingSentry = undefined;
	sentry setSentryCarrier( undefined );
	sentry.carrier = undefined;
	sentry SetCanDamage( true );
	sentry.ignoreMe = false;
	
	self _enableWeapon();
	
	sentry makeSentrySolid();
	sentry setmodel( level.sentry_settings[ sentry.sentryType ].model );
	sentry sentry_badplace_create();
	assert( isdefined( sentry.contents ) );
	sentry setContents( sentry.contents );
	sentry sentry_set_owner( self );
	self notify( "sentry_placement_finished", sentry );
	
	sentry notify( "sentry_carried" );
	sentry.overheated = false;
	self sentry_placement_hint_hide();
	
	if ( !isSP() )
		sentry sentry_team_show_icon();
		
	sentry SentryPowerOn();
	thread play_sound_in_space( "sentry_gun_plant", sentry.origin );
	
	//debounce	
	self waitActivateButton( false );
	sentry thread sentry_player_use_wait();	
}

sentry_enemy_wait()
{
	level endon( "game_ended" );
	self endon( "death" );
	self thread sentry_overheat_monitor();
	
	for ( ;; )
	{
		self waittill_either( "turretstatechange", "cooled" );
		
		if ( self isFiringTurret() )
		{
			self thread sentry_burst_fire_start();
			self thread sentry_turn_laser_on();
		}
		else
		{
			self thread sentry_burst_fire_stop();
			self thread sentry_turn_laser_off();
		}
	}
}

// Sentry overheat behavoir for SP ====================================================

sentry_overheat_monitor()
{
	self endon( "death" );
	
	assert( isDefined( self ) );
	assert( isDefined( self.sentryType ) );
	if ( self.sentryType != "sentry_minigun" )
		return;
	
	if ( !isdefined( level.sentry_overheating_speed ) )
		return;
	
	self.overheat = 0;
	self.overheated = false;
	
	if ( getdvarint( "sentry_overheat_debug" ) == 1 )
		self thread sentry_overheat_debug();

	while ( true )
	{
		if ( self.overheat >= ( level.sentry_fire_time * 10 ) )
		{
			self thread sentry_overheat_deactivate();
			self waittill_either( "cooled", "sentry_carried" );
		}

		if ( self IsFiringTurret() )
		{
			self.overheat += 1;
		}
		else
		{
			if ( self.overheat > 0 )
				self.overheat -= 1;
		}
		
		wait 0.1/level.sentry_overheating_speed;
	}
}

sentry_cooling()
{
	self endon( "death" );

	while ( self.overheated )
	{
		if ( self.overheat > 0 )
			self.overheat -= 1;
		
		wait 0.1/level.sentry_overheating_speed;
	}
}

sentry_overheat_debug()
{
	self endon( "death" );
	while( true )
	{
		overheat_value = self.overheat / (level.sentry_fire_time*10);
		overheat_print_l = "[ ";
		overheat_print_r = " ]";
		if( self.overheated ) 
		{
			overheat_print_l = "{{{ ";
			overheat_print_r = " }}}";
		}
		
		print3d( self.origin + ( 0,0,45 ), overheat_print_l + self.overheat + " / " + level.sentry_fire_time*10 + overheat_print_r, ( 0+overheat_value, 1-overheat_value, 1-overheat_value ), 1, 0.35, 4 );
		wait 0.2;
	}
}

sentry_overheat_deactivate()
{
	self endon( "death" );
	
	self notify( "overheated" );
	self.overheated = true;
	self sentry_burst_fire_stop();
	
	self thread sentry_overheat_reactivate();
}

sentry_overheat_reactivate()
{
	self endon( "death" );
	self endon( "sentry_carried" );
	
	self thread sentry_cooling();
	
	wait level.sentry_cooldown_time;
	self notify( "cooled" );
	self.overheat = 0;
	self.overheated = false;
}

// END of sentry overheat behavoir for SP =================================================

sentry_burst_fire_start()
{
	self endon( "death" );
	level endon( "game_ended" );

	if ( level.sentry_settings[ self.sentryType ].fire_only_on_target )
		self waittill( "turret_on_target" );

	if ( isdefined( self.overheated ) && self.overheated )
		return;
	
	self thread fire_anim_start();

	self endon( "stop_shooting" );
	self notify( "shooting" );

	assert( isdefined( self.weaponinfo ) );
	fireTime = weaponFireTime( self.weaponinfo );
	assert( isdefined( fireTime ) && fireTime > 0 );

	for ( ;; )
	{		
		self turret_start_anim_wait();
		numShots = randomintrange( level.sentry_settings[ self.sentryType ].burst_shots_min, level.sentry_settings[ self.sentryType ].burst_shots_max );
		for ( i = 0 ; i < numShots ; i++ )
		{
			if ( self canFire() )
				self shootTurret();
				
			self notify( "bullet_fired" );
			wait fireTime;
		}
		wait randomfloatrange( level.sentry_settings[ self.sentryType ].burst_pause_min, level.sentry_settings[ self.sentryType ].burst_pause_max );
	}
}

sentry_allowFire( bAllow, timeOut )
{
	self notify( "allowFireThread" );
	self endon( "allowFireThread" );
	self endon( "death" );

	self.taking_damage = bAllow;

	if ( isdefined( timeOut ) && !bAllow )
	{
		wait timeOut;
		if ( isdefined( self ) )
			self thread sentry_allowFire( true );
	}
}

canFire()
{
	if ( !isdefined( self.taking_damage ) )
		return true;

	return self.taking_damage;
}

sentry_burst_fire_stop()
{
	self thread fire_anim_stop();
	self notify( "stop_shooting" );
	self thread sentry_steam();
}

sentry_steam()
{
	self endon( "shooting" );
	self endon( "deleted" );

	wait randomfloatrange( 0.0, 1.0 );

	timeToSteam = 6 * 1000;
	startTime = getTime();
	
	// temp sound fx
	if ( isdefined( self ) )
		self playsound( "sentry_steam" );
		
	while ( isdefined( self ) )
	{
		playfxOnTag( getfx( "sentry_turret_overheat_smoke_sp" ), self, "tag_flash" );
		wait .3;
		if ( getTime() - startTime > timeToSteam )
			break;
	}
}

turret_start_anim_wait()
{
	if ( isdefined( self.allow_fire ) && self.allow_fire == false )
		self waittill( "allow_fire" );
}

fire_anim_start()
{
	self notify( "anim_state_change" );
	self endon( "anim_state_change" );
	self endon( "stop_shooting" );
	self endon( "deleted" );
	level endon( "game_ended" );
	self endon( "death" );

	if ( !isdefined( level.sentry_settings[ self.sentryType ].anim_loop ) )
		return;

	self.allow_fire = false;

	//ramp up the animation from 0.1 speed to 1.0 speed over time
	if ( !isdefined( self.momentum ) )
		self.momentum = 0;

	self thread fire_sound_spinup();
	for ( ;; )
	{
		if ( self.momentum >= 1.0 )
			break;
		self.momentum += 0.1;
		self.momentum = clamp( self.momentum, 0.0, 1.0 );
		if ( isSP() )
			self self_func( "setanim", level.sentry_settings[ self.sentryType ].anim_loop, 1.0, 0.2, self.momentum );
		wait 0.2;
	}
	self.allow_fire = true;
	self notify( "allow_fire" );
}

delete_sentry_turret()
{
	self notify( "deleted" );
	wait .05;
	self notify( "death" );

	if ( isDefined( self.obj_overlay ) )
		self.obj_overlay delete();

	if ( isDefined( self.cam ) )
		self.cam delete();
		
	self delete();
}

fire_anim_stop()
{
	self notify( "anim_state_change" );
	self endon( "anim_state_change" );

	if ( !isdefined( level.sentry_settings[ self.sentryType ].anim_loop ) )
		return;

	self thread fire_sound_spindown();

	self.allow_fire = false;

	for ( ;; )
	{
		if ( !isdefined( self.momentum ) )
			break;
		if ( self.momentum <= 0.0 )
			break;
		self.momentum -= 0.1;
		self.momentum = clamp( self.momentum, 0.0, 1.0 );
		if ( isSP() )
			self self_func( "setanim", level.sentry_settings[ self.sentryType ].anim_loop, 1.0, 0.2, self.momentum );
		wait 0.2;
	}
}

fire_sound_spinup()
{
	self notify( "sound_state_change" );
	self endon( "sound_state_change" );
	self endon( "deleted" );

	if ( self.momentum < 0.25 )
	{
		self playsound( "sentry_minigun_spinup1" );
		wait 0.6;
		self playsound( "sentry_minigun_spinup2" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup3" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup4" );
		wait 0.5;
	}
	else
	if ( self.momentum < 0.5 )
	{
		self playsound( "sentry_minigun_spinup2" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup3" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup4" );
		wait 0.5;
	}
	else
	if ( self.momentum < 0.75 )
	{
		self playsound( "sentry_minigun_spinup3" );
		wait 0.5;
		self playsound( "sentry_minigun_spinup4" );
		wait 0.5;
	}
	else
	if ( self.momentum < 1 )
	{
		self playsound( "sentry_minigun_spinup4" );
		wait 0.5;
	}

	thread fire_sound_spinloop();
}

fire_sound_spinloop()
{
	self endon( "death" );
	self notify( "sound_state_change" );
	self endon( "sound_state_change" );

	while ( 1 )
	{
		self playsound( "sentry_minigun_spin" );
		wait 2.5;
	}
}

fire_sound_spindown()
{
	self notify( "sound_state_change" );
	self endon( "sound_state_change" );
	self endon( "deleted" );

	if ( !isdefined( self.momentum ) )
		return;

	if ( self.momentum > 0.75 )
	{
		self stopsounds();
		self playsound( "sentry_minigun_spindown4" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown3" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown2" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown1" );
		wait 0.65;
	}
	else
	if ( self.momentum > 0.5 )
	{
		self playsound( "sentry_minigun_spindown3" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown2" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown1" );
		wait 0.65;
	}
	else
	if ( self.momentum > 0.25 )
	{
		self playsound( "sentry_minigun_spindown2" );
		wait 0.5;
		self playsound( "sentry_minigun_spindown1" );
		wait 0.65;
	}
	else
	{
		self playsound( "sentry_minigun_spindown1" );
		wait 0.65;
	}
}

sentry_beep_sounds()
{
	self endon( "death" );
	for ( ;; )
	{
		wait randomfloatrange( 3.5, 4.5 );
		self thread play_sound_in_space( "sentry_gun_beep", self.origin + ( 0, 0, 40 ) );
	}
}

spawn_and_place_sentry( sentryType, spawn_origin, spawn_angles, spawn_immediately )
{
	level endon( "game_ended" );

	assert( self.classname == "player" );
	assert( isdefined( sentryType ) );
	assert( isdefined( level.sentry_settings[ sentryType ] ) );
	assert( isdefined( level.sentry_settings[ sentryType ].placementmodel ) );
	assert( isdefined( level.sentry_settings[ sentryType ].placementmodelfail ) );	

	if ( isdefined( self.placingSentry ) )
		return undefined;

	self _disableWeapon();
	//self _disableUsability();
	self notify( "placingSentry" );
	self.sentry_placement_failed = undefined;
	
	assert( isdefined( level.sentry_settings[ sentryType ] ) );
	assert( isdefined( level.sentry_settings[ sentryType ].weaponInfo ) );
	assert( isdefined( level.sentry_settings[ sentryType ].model ) );
	assert( isdefined( level.sentry_settings[ sentryType ].targetname ) );
	
	if ( !isdefined( spawn_origin ) )
		spawn_origin = self.origin;
	if ( !isdefined( spawn_angles ) )
		spawn_angles = self.angles;
	if ( !isdefined( spawn_immediately ) )
		spawn_immediately = false;
	
	sentry_gun = spawnTurret( "misc_turret", spawn_origin, level.sentry_settings[ sentryType ].weaponInfo );
	sentry_gun setmodel( level.sentry_settings[ sentryType ].placementModel );
	sentry_gun.weaponinfo = level.sentry_settings[ sentryType ].weaponInfo;    
    sentry_gun.targetname = level.sentry_settings[ sentryType ].targetname;
    sentry_gun.weaponName = level.sentry_settings[ sentryType ].weaponInfo;
    sentry_gun.angles = spawn_angles;
	sentry_gun.team = self.team;
	sentry_gun.attacker = self;
	sentry_gun.sentryType = sentryType;

	sentry_gun makeTurretInoperable();
	sentry_gun sentryPowerOff();
	sentry_gun setCanDamage( false );
	sentry_gun sentry_set_owner( self );
	sentry_gun setDefaultDropPitch( -89.0 );	// setting this mainly prevents Turret_RestoreDefaultDropPitch() from running

	self.placingSentry = sentry_gun;
	sentry_gun setSentryCarrier( self );
	sentry_gun.carrier = self;
	sentry_gun SetCanDamage( false );
	sentry_gun.ignoreMe = true;

	if ( !isSP() )
		sentry_gun addToTurretList();

	if ( !spawn_immediately )
	{
		// wait to delete the sentry when cancelled
		self thread sentry_placement_cancel_monitor( sentry_gun );
		
		// wait to delete the sentry on end of level
		self thread sentry_placement_endOfLevel_cancel_monitor( sentry_gun );
	}
	
	// wait until the player plants the sentry
	self thread sentry_placement_initial_wait( sentry_gun, spawn_immediately );

	if ( !spawn_immediately )
	{
		// keep the indicator model positioned with traces forever until the thread is ended
		self thread updateSentryPositionThread( sentry_gun );
		
		// wait until the turret placement has been finished or canceled
		if ( !isSP() )
			self waittill_any( "sentry_placement_finished", "sentry_placement_canceled", "death" );
		else
			self waittill_any( "sentry_placement_finished", "sentry_placement_canceled" );
	}
	
	self sentry_placement_hint_hide();

	self _enableWeapon();
		
	self.placingSentry = undefined;
	self SetCanDamage( true );
	
	sentry_gun setSentryCarrier( undefined );
	sentry_gun.carrier = undefined;
	sentry_gun.ignoreMe = false;
	
	if ( is_survival() )
	{
		// if sentry_placement_canceled
		waittillframeend;
		if ( isdefined( self.sentry_placement_failed ) && self.sentry_placement_failed )
			return undefined;
	}
			
	level.placed_sentry[ level.placed_sentry.size ] = sentry_gun;

	// notify any external function needing to update sentry attributes
	self notify( "new_sentry", sentry_gun );
	
	return sentry_gun;
}

sentry_placement_cancel_monitor( sentry_gun )
{
	self endon ( "sentry_placement_finished" );
	
	if ( !isSP() )
		self waittill_any( "sentry_placement_canceled", "death", "disconnect");
	else
		self waittill_any( "sentry_placement_canceled" );
	
	// need to send message to placement to cancel
	if ( is_survival() )
		self.sentry_placement_failed = true;
	
	waittillframeend;
	sentry_gun delete();
}

sentry_placement_endOfLevel_cancel_monitor( sentry_gun )
{
	self endon ( "sentry_placement_finished" );
	
	if ( isSP() )
		return;
			
	level waittill( "game_ended" );
	
	if ( !isDefined( sentry_gun ) )
		return;
	
	//sentry_gun notify( "deleted" );
	if ( !self.canPlaceEntity )
	{	
		sentry_gun notify( "deleted" );
		
		waittillframeend;
		sentry_gun delete();
		return;
	}

	self thread place_sentry( sentry_gun );
}


sentry_restock_wait()
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "restock_reset" );

	// Cancel/restock on death or when toggling the killstreak
	self notifyOnPlayerCommand( "cancel sentry", "+actionslot 4" );
	self waittill_any( "death", "cancel sentry" );
	assert( isdefined( self.last_sentry ) );
	
	self notify( "sentry_placement_canceled" );
}


sentry_placement_initial_wait( sentry_gun, place_immediately )
{
	level endon( "game_ended" );

	self endon( "sentry_placement_canceled" );

	if ( !isdefined( place_immediately ) )
		place_immediately = false;
		
	if ( !isSP() )
	{
		self endon( "disconnect" );
		//self endon( "death" );
		sentry_gun thread sentry_reset_on_owner_death();
		self thread sentry_restock_wait();
	}

	if ( !place_immediately )
	{
		// player is carrying so make unusable
		sentry_gun MakeUnusable();
		
		//debounce from picking up the gun
		while ( self useButtonPressed() )
			wait 0.05;
	
		for ( ;; )
		{
			// couldn't place entity so wait until the buttons are unpressed before trying again
			self waitActivateButton( false );
	
			// wait until the button is pressed
			self waitActivateButton( true );
	
			updateSentryPosition( sentry_gun );
			if ( self.canPlaceEntity )
				break;
		}
	}
	
	if ( !isSP() ) //&& isAlive( self ) )
		self notify( "restock_reset" );

	if ( !isSP() )
	{
		sentry_gun.lifeId = self.lifeId;
		self sentry_team_setup( sentry_gun );
	}

	thread play_sound_in_space( "sentry_gun_plant", sentry_gun.origin );

	assert( isdefined( self.team ) );
	sentry_gun setmodel( level.sentry_settings[ sentry_gun.sentryType ].model );
	sentry_gun sentry_init( self.team, sentry_gun.sentryType, self );

	self notify( "sentry_placement_finished", sentry_gun );
	if ( !place_immediately )
		waittillframeend;	// wait so self.placingSentry can get cleared before notifying script that we can give the player another turret

	if ( isdefined( level.sentry_ammo_enabled ) && level.sentry_ammo_enabled )
		sentry_gun thread sentry_die_on_ammoout();

	if ( !isSP() )
		sentry_gun thread sentry_die_on_batteryout();
}

updateSentryPositionThread( sentry_entity )
{
	level endon( "game_ended" );

	sentry_entity notify( "sentry_placement_started" );
	self endon( "sentry_placement_canceled" );
	self endon( "sentry_placement_finished" );
	
	sentry_entity endon( "death" );
	sentry_entity endon( "deleted" );

	if ( !isSP() )
	{
		self endon( "disconnect" );
		self endon( "death" );
	}

	for ( ;; )
	{
		updateSentryPosition( sentry_entity );		
		wait sentry_updateTime;
	}
}

updateSentryPosition( sentry_entity )
{
	placement = self canPlayerPlaceSentry();
	sentry_entity.origin = placement[ "origin" ];
	sentry_entity.angles = placement[ "angles" ];		
	self.canPlaceEntity = self isonground() && placement[ "result" ];
	self sentry_placement_hint_show( self.canPlaceEntity );

	if ( self.canPlaceEntity )
		sentry_entity setModel( level.sentry_settings[ sentry_entity.sentryType ].placementmodel );
	else
		sentry_entity setModel( level.sentry_settings[ sentry_entity.sentryType ].placementmodelfail );
}

sentry_placement_hint_show( hint_valid )
{
	assert( isDefined( self ) );
	assert( isDefined( hint_valid ) );
	
	// return if not changed
	if ( isdefined( self.forced_hint ) && (self.forced_hint == hint_valid) )
		return;

	self.forced_hint = hint_valid;

	if ( self.forced_hint )
		self ForceUseHintOn( &"SENTRY_PLACE" );
	else
		self ForceUseHintOn( &"SENTRY_CANNOT_PLACE" );
}

sentry_placement_hint_hide()
{
	assert( isDefined( self ) );
	
	// return if hidden already
	if ( !isdefined( self.forced_hint ) )
		return;

	self ForceUseHintOff();
	self.forced_hint = undefined;	
}

folded_sentry_use_wait( sentryType )
{
	// spawn another copy of the model so that it's not translucent
	self.obj_overlay = spawn( "script_model", self.origin );
	self.obj_overlay.angles = self.angles;
	self.obj_overlay setModel( level.sentry_settings[ sentryType ].pickupModelObj );

	for ( ;; )
	{
		self waittill( "trigger", player );

		if ( !isdefined( player ) )
			continue;

		if ( isDefined( player.placingSentry ) )
			continue;

		if ( !isSP() )
		{
			assert( isdefined( self.owner ) );
			if ( player != self.owner )
				continue;
		}

		break;
	}

	self thread play_sound_in_space( "sentry_pickup" );
	self.obj_overlay delete();
	self delete();

	// put the player into placement mode
	player thread spawn_and_place_sentry( sentryType );
}

sentry_health_monitor()
{
	self.healthbuffer = 20000;
	self.health += self.healthbuffer;
	self.currenthealth = self.health;
	attacker = undefined;
	type = undefined;
	
	damage_buffer 		= 0;
	damage_timer 		= 0;
	last_damage_time 	= gettime();
	
	while ( self.health > 0 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName );
		
		// sentry under enemy attack notify, only if player is not close enough to notice
		if ( isdefined( attacker ) && !isplayer( attacker ) )
		{
			damage_buffer 		+= amount;
			damage_timer 		+= gettime() - last_damage_time;
			last_damage_time 	= gettime();
			
			if ( damage_timer < ( 1000 * dps_sample_time ) && damage_buffer > ( underattack_dps * dps_sample_time ) )
			{
				player_close = false;
				foreach ( player in level.players )
				{
					if ( distancesquared( player.origin, self.origin ) <= squared(500) )
						player_close = true;
				}
				
				if ( !player_close )
					level notify( "a_sentry_is_underattack" );
				
				// reset
				damage_buffer = 0;
				damage_timer = 0;
			}
			
			if ( damage_timer >= ( 1000 * dps_sample_time ) )
			{
				// reset
				damage_buffer = 0;
				damage_timer = 0;
			}
		}
		
		if ( !isSP() && isdefined( attacker ) && isplayer( attacker ) && attacker sentry_attacker_is_friendly( self ) )
		{
			self.health = self.currenthealth;
			return;
		}

		if ( isdefined( level.stat_track_damage_func ) && isdefined( attacker ) )
			attacker [[ level.stat_track_damage_func ]]();

		assertex( isdefined( level.func[ "damagefeedback" ] ), "damagefeedback display function is undefined" );
		if ( isdefined( attacker ) && isplayer( attacker ) )
		{
			if ( !isSP() )
				attacker [[ level.func[ "damagefeedback" ] ]]( "false" );
			/* no more hit indicator in SP, commenting this out and replacing with the line above for MP only
			if ( isSP() )
				attacker [[ level.func[ "damagefeedback" ] ]]( self );
			else
				attacker [[ level.func[ "damagefeedback" ] ]]( "false" );
			*/
			self thread sentry_allowFire( false, 2.0 );
		}

		if ( self sentry_hit_bullet_armor( type, attacker ) )
		{
			//damage was to bullet armor, restore health and decrement bullet armor.
			self.health = self.currenthealth;
			self.bullet_armor -= amount;
		}
		else
			self.currenthealth = self.health;

		if ( self.health < self.healthbuffer )
			break;
	}

	if ( !isSP() &&  attacker sentry_attacker_can_get_xp( self ) )
		attacker thread [[ level.onXPEvent ]]( "kill" );

	self notify( "death", attacker, type );
}

sentry_hit_bullet_armor( type, attacker )
{
	//juggernaut damages through armor - specops survival
	if ( isdefined( attacker ) && isAI( attacker ) && isdefined( attacker.juggernaut ) && attacker.juggernaut )
		return false;
	if ( self.bullet_armor <= 0 )
		return false;
	if ( !( isdefined( type ) ) )
		return false;
	if ( ! issubstr( type, "BULLET" ) )
		return false;
	else
		return true;
}

enemy_sentry_difficulty_settings()
{
	difficulty = "easy";
	
	self SetConvergenceTime( level.sentryTurretSettings[ difficulty ][ "convergencePitchTime" ], "pitch" );	
    self SetConvergenceTime( level.sentryTurretSettings[ difficulty ][ "convergenceYawTime" ], "yaw" );    
	self SetSuppressionTime( level.sentryTurretSettings[ difficulty ][ "suppressionTime" ] );
	self SetAiSpread( level.sentryTurretSettings[ difficulty ][ "aiSpread" ] );
	self SetPlayerSpread( level.sentryTurretSettings[ difficulty ][ "playerSpread" ] );

	self.maxrange = 1100;
	self.bullet_armor = minigun_sentry_bullet_armor_enemy;
}

waitActivateButton( bCheck )
{
	if ( !isSP() )
	{
		self endon( "death" );
		self endon( "disconnect" );
	}

	assert( isdefined( bCheck ) );

	if ( bCheck == true )
	{
		while ( !self attackButtonPressed() && !self useButtonPressed() )
			wait 0.05;
	}
	else if ( bCheck == false )
	{
		while ( self attackButtonPressed() || self useButtonPressed() )
			wait 0.05;
	}
}

makeSentrySolid()
{
	self makeTurretSolid();
}

makeSentryNotSolid()
{
	self.contents = self setContents( 0 );
}

SentryPowerOn()
{
	if ( !IsSentient( self ) && isdefined( self.owner ) && isdefined( self.owner.team ) )
		self call [[ level.makeEntitySentient_func ]]( self.owner.team );
	
	self setMode( sentry_mode_name_on );
	self.battery_usage = true;
}

SentryPowerOff()
{
	if ( IsSentient( self ) )
		self call [[ level.freeEntitySentient_func ]]();
		
	self setMode( sentry_mode_name_off );
	self.battery_usage = false;
}

// =============================================================================
// MP functions:
// =============================================================================


// MP sentry team and head icons
sentry_team_setup( sentry_gun )
{
	// self == player

	assert( isDefined( sentry_gun ) );
	assert( isDefined( sentry_gun.sentryType ) );
	
	if ( isdefined( self.pers[ "team" ] ) )
		sentry_gun.pers[ "team" ] = self.pers[ "team" ];

	sentry_gun sentry_team_show_icon();
}


sentry_team_show_icon()
{
	assert( isdefined( level.func[ "setTeamHeadIcon" ] ) );

	sentry_headicon_offset = ( 0, 0, 65 );
	if ( self.sentryType == "sentry_gun" )
		sentry_headicon_offset = ( 0, 0, 75 );

	self [[ level.func[ "setTeamHeadIcon" ] ]]( self.pers[ "team" ], sentry_headicon_offset );
}


// MP clear team and head icons
sentry_team_hide_icon()
{
	assert( isdefined( level.func[ "setTeamHeadIcon" ] ) );
	self [[ level.func[ "setTeamHeadIcon" ] ]]( "none", (0, 0, 0) );
}


// resets sentry placement mode when owner carrying sentry dies
sentry_place_mode_reset()
{
	if ( !isDefined( self.carrier ) )
		return;

	self.carrier notify( "sentry_placement_canceled" );
	self.carrier _enableWeapon();
	self.carrier.placingSentry = undefined;
	self setSentryCarrier( undefined );
	self.carrier = undefined;
	self SetCanDamage( true );
	self.ignoreMe = false;
}

sentry_set_owner( owner )
{
	assert( isdefined( owner ) );
	assert( isPlayer( owner ) );
	
	// don't need to set it twice. will happen for non-static sentries
	if ( isDefined ( self.owner ) && self.owner == owner )
		return;

	owner.debug_sentry			 = self;// for debug
	self.owner 					 = owner;
	self SetSentryOwner( owner );
	self SetTurretMinimapVisible( true );
}

sentry_destroy_on_owner_leave( owner )
{
	level endon( "game_ended" );
	self endon( "death" );

	owner waittill_any( "disconnect", "joined_team", "joined_spectators" );
	self notify( "death" );
}

// battery monitor, batter only used while sentry is on
sentry_die_on_batteryout()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "deleted" );

	// only one instance
	self notify( "battery_count_started" );
	self endon( "battery_count_started" );

	while ( self.sentry_battery_timer >= 0 )
	{
		if ( self.battery_usage )
			self.sentry_battery_timer -= 1;
		wait 1;
	}

	self notify( "death" );
}

// ammo monitor, ammo only used while sentry is firing
sentry_die_on_ammoout()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "deleted" );

	// only one instance
	self notify( "ammo_count_started" );
	self endon( "ammo_count_started" );
	
	//if ( getdvarint( "sentry_debug" ) == 1 )
		self thread sentry_ammo_debug();
	
	while ( self.sentry_ammo >= 0 )
	{
		self waittill( "bullet_fired" );
		self.sentry_ammo -= 1;
	}
	
	self thread sentry_burst_fire_stop();
	self thread sentry_turn_laser_off();
	wait 1;
	self SentryPowerOff();
	wait 5;
	self notify( "death" );
}

sentry_ammo_debug()
{
	self endon( "death" );
	while ( 1 )
	{
		total_ammo 	= level.sentry_settings[ self.sentryType ].ammo;
		ammo 		= self.sentry_ammo;
		ammo_ratio 	= ammo/total_ammo;
		ammo_msg 	= "Ammo: " + ammo + "/" + total_ammo;
		
		total_health= level.sentry_settings[ self.sentryType ].health;
		health		= self.health - self.healthbuffer;
		health_ratio= health / total_health;
		health_msg	= "Health: " + health + "/" + total_health;
		
		print3d( self.origin + ( 0,0,55 ), health_msg, ( 1-health_ratio, 0+health_ratio, 0+health_ratio ), 1, 0.3, 1 );		
		print3d( self.origin + ( 0,0,58 ), ammo_msg, ( 1-ammo_ratio, 0+ammo_ratio, 0+ammo_ratio ), 1, 0.3, 1 );
		wait 0.05;
	}
}

removeDeadSentry()
{
	// ahodge - 07/27/11 - option to keep a sentry gun in the level after it is killed
	if( isDefined( self.keep_after_death ) && self.keep_after_death )
	{
		return;
	}

	self delete_sentry_turret();
}


sentry_reset_on_owner_death()
{
	// self is sentry
	assert( isDefined( self ) );
	self endon( "death" );
	self endon( "deleted" );

	assert( isdefined( self.owner ) );
	self.owner waittill_any( "death", "disconnect" );

	if ( isDefined( self.owner.placingSentry ) && (self.owner.placingSentry == self) )
	{
		self.owner.placingSentry = undefined;
		self setSentryCarrier( undefined );
		self.carrier = undefined;
		self SetCanDamage( true );
		self.ignoreMe = false;
		self notify( "death" );
	}
}

sentry_attacker_can_get_xp( sentry )
{
	assert( isdefined( sentry.owner ) );

	// defensive much?
	if ( !isdefined( self ) )
		return false;

	if ( !isPlayer( self ) )
		return false;

	if ( !isdefined( level.onXPEvent ) )
		return false;

	if ( !isdefined( self.pers[ "team" ] ) )
		return false;

	if ( !isdefined( sentry.team ) )
		return false;

	if ( !level.teambased && self == sentry.owner )
		return false;

	if ( level.teambased && ( self.pers[ "team" ] == sentry.team ) )
		return false;

	return true;
}


sentry_attacker_is_friendly( sentry )
{
	assert( isdefined( sentry.owner ) );

	// defensive much?
	if ( !isdefined( self ) )
		return false;

	if ( !isPlayer( self ) )
		return false;

	if ( !level.teamBased )
		return false;
	
	if ( self == sentry.owner )
		return false;

	if ( self.team != sentry.team )
		return false;

	return true;	
}


sentry_emp_damage_wait()
{
	self endon( "deleted" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "emp_damage", attacker, duration );

		// TODO: friendly fire check here

		self thread sentry_burst_fire_stop();
		self thread sentry_turn_laser_off();

		self SentryPowerOff();
		playfxOnTag( getfx( "sentry_turret_explode" ), self, "tag_aim" );

		wait( duration );

		self SentryPowerOn();
	}
}


sentry_emp_wait()
{
	self endon( "deleted" );
	self endon( "death" );

	for ( ;; )
	{
		level waittill( "emp_update" );

		// TODO: make this work in FFA
		if ( level.teamEMPed[self.team] )
		{
			self thread sentry_burst_fire_stop();
			self thread sentry_turn_laser_off();
	
			self SentryPowerOff();
			playfxOnTag( getfx( "sentry_turret_explode" ), self, "tag_aim" );
		}
		else
		{
			self SentryPowerOn();
		}
	}
}

addToTurretList()
{
	level.turrets[self getEntityNumber()] = self;	
}

removeFromTurretList()
{
	level.turrets[self getEntityNumber()] = undefined;
}

dual_waittill( ent1, msg1, ent2, msg2 )
{
	ent1 endon ( msg1 );
	ent2 endon ( msg2 );
	
	level waittill ( "hell_freezes_over_AND_THEN_thaws_out" );
}

sentry_turn_laser_on()
{
	assert( isdefined( level.sentry_settings[ self.sentryType ].use_laser ) );
	
	if ( !level.sentry_settings[ self.sentryType ].use_laser )
		return;
		
	if ( !isdefined( level.laserOn_func ) )
		return;
		
	self call [[ level.laserOn_func ]]();
}

sentry_turn_laser_off()
{
	assert( isdefined( level.sentry_settings[ self.sentryType ].use_laser ) );
	
	if ( !level.sentry_settings[ self.sentryType ].use_laser )
		return;
		
	if ( !isdefined( level.laserOff_func ) )
		return;
		
	self call [[ level.laserOff_func ]]();
}

is_specialop()
{
	return GetDvarInt( "specialops" ) >= 1;
}

is_survival()
{
	return ( is_specialop() && ( GetDvarInt( "so_survival" ) > 0 ) );
}