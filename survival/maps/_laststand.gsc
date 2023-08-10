#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;

#define CONST_LASTSTAND_TYPE_OFF						 0		// When you gone, you stay gone
#define CONST_LASTSTAND_TYPE_HELPLESS					 1		// MW2 laststand where you get to use your gun briefly and then are helpless. In sp you die.
#define CONST_LASTSTAND_TYPE_GETUP						 2		// Players can pick themselves back up

#define CONST_LASTSTAND_DOWN_DELAY_AFTER_REVIVE			 1.75		// Time after getting up where the player is not allowed to be downed

#define CONST_LASTSTAND_GETUP_COUNT						 9999		// Max getups allowed
#define CONST_LASTSTAND_GETUP_INVULN_TIME				 2.0		// Time from the start of laststand to when the ai can actually hurt the player
#define CONST_LASTSTAND_GETUP_IGNORE_TIME				 0.25		// Time from the start of last stand that AI ignores the player
#define CONST_LASTSTAND_GETUP_BAD_PLACE_TIME			 90.0		// Time the bad place lives for before it is recreated if the player is still alive
#define CONST_LASTSTAND_GETUP_BAD_PLACE_RANGE			 120		// Range of the badplace created in laststand getup
#define CONST_LASTSTAND_GETUP_BAR_WIDTH					 130		// Width of the revive getup bar
#define CONST_LASTSTAND_GETUP_BAR_HEIGHT				 12		// Height of the revive getup bar
#define CONST_LASTSTAND_GETUP_ICON_SIZE					 28		// Width and height of the getup icon

#define CONST_LASTSTAND_GETUP_BAR_START					 0.5		// Fill amount of the getup bar the first time it is used
#define CONST_LASTSTAND_GETUP_BAR_START_PENALTY			 0.0		// Each time laststand is entered, the getup bar starting fill goes down by this amount
#define CONST_LASTSTAND_GETUP_BAR_START_MIN				 0.2		// Min starting fill amount of the getup bar 
#define CONST_LASTSTAND_GETUP_BAR_REGEN					 0.0025	// Percent of the bar filled for auto fill logic
#define CONST_LASTSTAND_GETUP_BAR_REGEN_FAST			 0.01		// Percent of the bar filled if the player is flagged for fast fill
#define CONST_LASTSTAND_GETUP_BAR_REGEN_TIME			 0.05		// Time between auto bar fills
#define CONST_LASTSTAND_GETUP_BAR_REGEN_NO_DMG_DELAY	 3.0		// If no damage has occured in this amount of time speed the bar regen up
#define CONST_LASTSTAND_GETUP_BAR_AI_KILL				 1.0		// Percent of the bar filled by an AI kill
#define CONST_LASTSTAND_GETUP_BAR_DAMAGE				 0.1		// Percent of the bar removed by AI damage
#define CONST_LASTSTAND_GETUP_BAR_DAMAGE_TIME			 0.2		// Min time in seconds between bar adjustments from AI damage
#define CONST_LASTSTAND_GETUP_BAR_CLEAN_DELAY			 0.5		// Time before the bar is removed, to allow the player to see the bar fill

#define CONST_LASTSTAND_GETUP_COUNT_START				 0		// The number of laststands in type getup that the player starts with

main()
{
	assertex( laststand_enabled(), "_laststand::main() called when laststand was not enabled." );
	
	assertex( !isdefined( level.laststand_initialized ), "_laststand::main() called more than once." );
	if ( isdefined( level.laststand_initialized ) )
		return;
	level.laststand_initialized = true;
	
	// Flag to enable disable laststand
	flag_init( "laststand_on" );
	
	foreach ( player in level.players )
	{
		player ent_flag_init( "laststand_downed" );
		player ent_flag_init( "laststand_pause_bleedout_timer" );
		player ent_flag_init( "laststand_proc_running" );
		player.laststand_info = SpawnStruct();
		player.laststand_info.type_getup_lives = CONST_LASTSTAND_GETUP_COUNT_START;
	}
	
	// "Partner down"
	precacheString( &"SCRIPT_COOP_BLEEDING_OUT_PARTNER" );
	// "Bleeding out"
	precacheString( &"SCRIPT_COOP_BLEEDING_OUT" );
	// "Reviving partner..."
	precacheString( &"SCRIPT_COOP_REVIVING_PARTNER" );
	// "Being revived..."
	precacheString( &"SCRIPT_COOP_REVIVING" );
	// "Hold ^3[{+usereload}]^7 to revive"
	precacheString( &"SCRIPT_COOP_REVIVE" );
	
	// Currently precached in the common_specialops.csv
	PreCacheShellShock( "laststand_getup" );
	
	// The default pistol to use if the player doesn't have
	// a pistol and level.coop_incap_weapon is not defined
	PreCacheItem( "fnfiveseven" );
	
	// Enable laststand by default. Level logic can clear this flag to disable the laststand functionality.
	flag_set( "laststand_on" );
	
	// Revive Hud Offsets
	level.revive_hud_base_offset = 75;
 	level.revive_bar_offset = 15;
 	level.revive_bar_getup_offset = 30;
		
	// Container for hud elements created once and then
	// left on until the end. This is used for clean up
	level.laststand_hud_elements = [];

	thread laststand_on_load_finished();
}

laststand_on_load_finished()
{
	// Wait till
		// - Player has model
		// - global spawn system initialized
	
	level waittill( "load_finished" );
	
	// Once the laststand type is decided see if the
	// material needs to be precached. This material
	// is in the common_survival csv
	if ( laststand_get_type() == CONST_LASTSTAND_TYPE_GETUP )
		PrecacheShader( "specialty_pistoldeath" );
	
	// Make sure the global spawn functions are added before 
	// any ai spawn
	thread laststand_global_spawn_funcs();
	
	// during slamzoom player has no model to have laststand setup on player, so we wait
	if ( flag_exist( "slamzoom_finished" ) && !flag( "slamzoom_finished" ) )
		flag_wait( "slamzoom_finished" );

	thread laststand_notify_on_player_state_changes( "laststand_player_state_changed" );
	thread laststand_downed_player_manager();
	thread laststand_coop_hud_manager();
	thread laststand_getup_hud_init();
	
	thread laststand_on_mission_end();
}

laststand_global_spawn_funcs()
{
	if ( laststand_get_type() == CONST_LASTSTAND_TYPE_GETUP )
		add_global_spawn_function( "axis", ::ai_laststand_on_death );
}

//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
//  Laststand Process
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//

player_laststand_proc()
{		
	assertex( laststand_enabled(), "_laststand::player_laststand_proc() called when laststand was not enabled." );

	if ( !laststand_enabled() )
		return;
		
	if ( self ent_flag( "laststand_proc_running" ) )
		return;
	
	if ( !isdefined( self.original_maxhealth ) )
		self.original_maxhealth = self.maxhealth;
	
	// Catch if a script requeste bleed out not happen
	if ( !flag( "laststand_on" ) )
		return;

	level endon( "laststand_on" );
	
	self thread player_laststand_proc_ended();
	
	switch( level.gameskill )
	{
		case 0:
		case 1:
			self.laststand_info.bleedout_time_default = 120;
			level.laststand_stage2_multiplier = 0.5;
			level.laststand_stage3_multiplier = 0.25;
			break;
		case 2:
			self.laststand_info.bleedout_time_default = 90;	
			level.laststand_stage2_multiplier = 0.66;
			level.laststand_stage3_multiplier = 0.33;
			break;
		case 3:
			self.laststand_info.bleedout_time_default = 60;	
			level.laststand_stage2_multiplier = 0.5;
			level.laststand_stage3_multiplier = 0.25;
			break;
	}
	
	self ent_flag_set( "laststand_proc_running" );
	self EnableDeathShield( true );
	
	assertex( self ent_flag_exist( "laststand_downed" ), "laststand_downed not initialized." );
	self ent_flag_clear( "laststand_downed" );
	self ent_flag_clear( "laststand_pause_bleedout_timer" );
	
	self endon( "death" );
	
	my_id = self.unique_id;
	
	while ( 1 )
	{
		self waittill( "deathshield", damage, attacker, direction, point, type, modelName, tagName, partName, dflags, weaponName );
		
		// if armor saved player when damage exceeded 100 that caused deathshield notify
		if ( isdefined( self.saved_by_armor ) && self.saved_by_armor )
			continue;
		
		// we're already downed
		if ( self ent_flag( "laststand_downed" ) )
			continue;
		

		assertex( CONST_LASTSTAND_DOWN_DELAY_AFTER_REVIVE > 0.05, "The player must stay up for at least a frame after being revived." );
		// we were downed too recently
		if ( isdefined( self.laststand_revive_time ) && gettime() - self.laststand_revive_time <= CONST_LASTSTAND_DOWN_DELAY_AFTER_REVIVE * 1000 )
			continue;

		death_array = [];
		death_array[ "damage" ] = damage;
		death_array[ "player" ] = self;

		// If in coop and players can't get themselves up then both players down
		// is a gameover case. If players can get themselves up then the fail case
		// becomes one player actually dying.
		if ( is_coop() && laststand_downing_will_fail() )
		{
			// Only want to set this on the *second* player to go down.
			// We want to know the most recent reason for a player to be killed, rather than something that
			// happened to the first player potentially almost 2 minutes ago (or whatever the revive time is).
			buddy = get_other_player( self );
			if ( buddy ent_flag( "laststand_downed" ) )
			{
				self.coop_death_reason = [];
				self.coop_death_reason[ "attacker" ] 	= attacker;
				self.coop_death_reason[ "cause" ] 		= type;
				self.coop_death_reason[ "weapon_name" ] = weaponName;
			}
		}
		
		if ( !is_coop() )
		{
			self.coop_death_reason = [];
			self.coop_death_reason[ "attacker" ] 	= attacker;
			self.coop_death_reason[ "cause" ] 		= type;
			self.coop_death_reason[ "weapon_name" ] = weaponName;
		}
		
		level.down_player_requests[ self.unique_id ] = death_array;

		self try_crush_player( attacker, type );

		// the laststand_downed_player_manager will decide whether or not to down the player
		level notify( "request_player_downed" );
	}
}

player_laststand_proc_ended()
{
	self endon( "death" );

	flag_waitopen( "laststand_on" );
	self ent_flag_clear( "laststand_proc_running" );
	self EnableDeathShield( false );
}

//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
//  Laststand Managers
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//

laststand_downed_player_manager()
{
	// Initialize revive_ents and their manager if in coop
	if ( is_coop() )
		thread laststand_revive_ents_manager();
	
	// Used to keep one player alive for a few seconds when the other player goes down
	level.laststand_recent_player_downed_time = 0;
	
	while ( 1 )
	{
		// the array will be refilled when a player is downed
		level.down_player_requests = [];
		
		level waittill( "request_player_downed" );
		
		assertex( isdefined( level.player_downed_death_buffer_time ), "level.player_downed_death_buffer_time didn't get defined!" );
		
		// wait until the end of the frame so the array will have all players that were downed in it
		waittillframeend;

		current_time = gettime();
		
		// can't go down if a player has gone down recently
		if ( current_time < level.laststand_recent_player_downed_time + level.player_downed_death_buffer_time * 1000 )
			continue;
		level.laststand_recent_player_downed_time = current_time;

		// figure out which player to down, randomize if they tie on damage
		highest_damage = 0;
		downed_player = undefined;
		level.down_player_requests = array_randomize( level.down_player_requests );
		foreach ( unique_id, array in level.down_player_requests )
		{
			if ( array[ "damage" ] >= highest_damage )
			{
				downed_player = array[ "player" ];
			}
		}
		assertex( isdefined( downed_player ), "Downed_player was not defined!" );
		
		downed_player thread player_laststand_force_down();
		
		// the remaining player gets slightly buffed
		thread maps\_gameskill::resetSkill();
	}
}

laststand_revive_ents_manager()
{
	if ( !is_coop() )
		return;
	
	// Use radius increased when someone is down... more like MP distance
	level.default_use_radius = getdvarint( "player_useradius" );
	
	level endon ( "special_op_terminated" );
	
	// Setup revive ents
	level.revive_ents = [];
	
	foreach( player in level.players )
	{	
		revive_ent = spawn( "script_model", player.origin + (0, 0, 28) ); 
		revive_ent setModel( "tag_origin" );
		revive_ent linkTo( player, "tag_origin", (0, 0, 28), (0, 0, 0) ); // offset can't be higher than prone height of 30
		revive_ent setHintString( &"SCRIPT_COOP_REVIVE" );	// LANG_ENGLISH		Hold ^3[{+usereload}]^7 to revive"
		
		level.revive_ents[ player.unique_id ] = revive_ent;
		
		player thread player_laststand_on_revive();
	}
	
	// Update revive ents on player state change
	while ( 1 )
	{
		level waittill( "laststand_player_state_changed" );
		
		foreach ( player in level.players )
			player revive_set_use_target_state( is_player_down( player ) );
			
		// Use radius decreased to default when no one is down.
		if ( get_players_healthy().size == level.players.size )
			setsaveddvar( "player_useradius", level.default_use_radius );
		else
			setsaveddvar( "player_useradius", 128 );
	}
}

laststand_notify_on_player_state_changes( msg )
{
	level endon( "special_op_terminated" );
	
	foreach( player in level.players )
		player endon( "death" );
	
	while ( 1 )
	{
		foreach ( player in level.players )
		{
			player thread notify_on_ent_flag_change( "laststand_downed", msg );
		}
		
		level waittill( msg );
	}
}

notify_on_ent_flag_change( entity_flag, level_notify )
{
	assertex( isdefined( self ), "entity not defined." );
	assertex( isdefined( entity_flag ) && self ent_flag_exist( entity_flag ), "entity flag doesn't exist: " + entity_flag );
	assertex( isdefined( level_notify ), "level notify not defined" );
	
	level endon( "special_op_terminated" );
	level endon( level_notify );
	self endon( "death" );
		
	if ( self ent_flag( entity_flag ) )
		self ent_flag_waitopen( entity_flag );
	else
		self ent_flag_wait( entity_flag );
		
	level notify( level_notify );
}

//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
//  Laststand Player Down Logic
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//

player_laststand_force_down()
{
	// isdefined of self is already caught by an assert in laststand_downed_player_manager()
	// kill_wrapper is already called by kill triggers at this point which
	// kills player before we get to this point so we wont check for isalive of self.
	if ( !isalive( self ) )
		return;
	
	assertex( isplayer( self ), "Attempted to force non-player to laststand." );
	
	level endon( "special_op_terminated" );
	self endon( "death" );

	// Put player down and kill if fail case
	self player_laststand_set_down_attributes();
	
	// Only setup the friend dialogue and hud when in coop
	if ( is_coop() )
	{
		self thread player_laststand_downed_dialogue();
		self thread player_laststand_on_downed_hud_update();
		self thread player_laststand_downed_icon();
	}

	// Wait till the player is revived or bleeds out
	self add_wait( ::ent_flag_waitopen, "laststand_downed" );
	self add_wait( ::waittill_msg, "coop_bled_out" );
	do_wait_any();

	self notify( "end_func_player_laststand_downed_icon" );

	// If bled out (still down) then fail
	if ( self ent_flag( "laststand_downed" ) )
		self player_laststand_kill();
	else
		self player_laststand_set_original_attributes();
}

player_laststand_on_revive()
{
	assertex( isdefined( self ) && isplayer( self ) && isalive( self ), "Invalid player listening to revive." );
	
	self endon( "death" );
	level endon( "special_op_terminated" );
	
	revive_ent = self player_get_revive_ent();
	
	assertex( isdefined( revive_ent ), "Undefined revive_ent for player with unique id: " + self.unique_id );
	
	buttonTime = 0;
	for ( ;; )
	{
		revive_ent waittill( "trigger", helper );
		
		if ( is_player_down( helper ) )
			continue;

		self.laststand_savior = helper;
		if ( is_player_down( self ) && helper player_laststand_is_reviving( self ) )
		{
			laststand_freeze_players( true, helper, self );
			
			// reset the other player's death protection if he initiates revive, so you can't infinitely revive each other
			level.laststand_recent_player_downed_time = 0;
			
			// Gives ability to reload by tapping support.
			wait 0.1;
			if ( !is_player_down( self ) || !helper player_laststand_is_reviving( self ) )
			{
				helper player_laststand_revive_buddy_cleanup( self );				
				continue;
			}

			level.bars = [];
			level.bars[ "p1" ] = createClientProgressBar( level.player, level.revive_hud_base_offset + level.revive_bar_offset );
			level.bars[ "p2" ] = createClientProgressBar( level.player2, level.revive_hud_base_offset + level.revive_bar_offset );

			speak_first = randomfloat( 1 ) > 0.33;
			if ( speak_first )
				helper notify( "so_reviving" );
			
			buttonTime = 0;
			totalTime = 1.5;
			while ( is_player_down( self ) && !is_player_down( helper ) && helper player_laststand_is_reviving( self ) )
			{
				self ent_flag_set( "laststand_pause_bleedout_timer" );
				foreach ( bar in level.bars )
					bar updateBar( buttonTime / totalTime );

				wait( 0.05 );
				buttonTime += 0.05;
				if ( is_player_down( self ) && buttonTime > totalTime )
				{
					//if we get to here - we double tapped	
					if ( !speak_first )
						helper notify( "so_revived" );
						
					//keep record of how many times a player has revived someone
					helper notify( "so_revive_success" );
					
					self player_laststand_revive_self();
					break;
				}
			}
			
			helper player_laststand_revive_buddy_cleanup( self );
		}
	}
}

player_laststand_is_reviving( downed_buddy )
{
	if ( !self UseButtonPressed() )
		return false;
	
	if ( isdefined( downed_buddy.laststand_savior ) && downed_buddy.laststand_savior == self )
		return true;
			
	return false;
}

player_laststand_revive_self()
{
	self.laststand_revive_time = gettime();
	
	self player_dying_effect_remove();
	
	self ent_flag_clear( "laststand_downed" );
	
	// clear death reason when done with last stand.
	self.coop_death_reason = undefined;
	
	// so other player loses health bonus from being only mobile guy
	thread maps\_gameskill::resetSkill();
	
	// Must happen last in case the function calling this function
	// ends on revive.
	self notify( "revived" );
}

player_laststand_revive_buddy_cleanup( downed_buddy )
{
	level notify( "revive_bars_killed" );

	revive_hud_cleanup_bars();
	
	if ( isdefined( downed_buddy ) && isalive( downed_buddy ) )
	{
		downed_buddy.laststand_savior = undefined;
		downed_buddy ent_flag_clear( "laststand_pause_bleedout_timer" );
	}
	
	if ( isdefined( self ) && isalive( self ) )
	{
		laststand_freeze_players( false, self, downed_buddy );
	}
}

laststand_freeze_players( frozen, helper, downed_buddy )
{
	assert( isdefined( self ) );
	assert( isdefined( frozen ) );
	
	downed_buddy = get_other_player( self );
	assert( isdefined( downed_buddy ) );
			
	if ( frozen )
	{
		helper freezecontrols( true );
		helper disableweapons();
		helper disableweaponswitch();

		downed_buddy freezecontrols( true );
		downed_buddy disableweapons();
	}
	else
	{
		helper freezecontrols( false );
		helper enableweapons();
		helper enableweaponswitch();

		downed_buddy freezecontrols( false );
		if ( !is_player_down_and_out( downed_buddy ) )
			downed_buddy enableweapons();
	}
}


//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
//  Laststand Manager
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//

player_laststand_downed_dialogue()
{
	self endon( "death" );
	self endon( "revived" );
	level endon( "special_op_terminated" );
	
	wait 1.0;
	self notify( "so_downed" );
	self thread player_laststand_downed_nag_button( 0.05 );
}

player_laststand_downed_nag_button( delay )
{
	self endon( "death" );
	self endon( "revived" );
	level endon( "special_op_terminated" );
	
	if ( isdefined( delay ) && delay > 0 )
		wait delay;
	
	self NotifyOnPlayerCommand( "nag", "weapnext" );
	
	while( 1 )
	{
		if( !self can_show_nag_prompt() )
		{
			wait 0.05;
			continue;
		}
		
		if( self nag_should_draw_hud() )
		{
			self thread nag_prompt_show();
			self thread nag_prompt_cancel();
		}
		
		msg = self waittill_any_timeout( level.coop_revive_nag_hud_refreshtime, "nag", "nag_cancel" );
		
		if( msg == "nag" )
		{
			self.lastReviveNagButtonPressTime = GetTime();
			self thread player_downed_hud_toggle_blinkstate();
			//self thread maps\_specialops_battlechatter::play_revive_nag();
		}
		
		wait 0.05;
	}
}

nag_should_draw_hud()
{
	waitTime = level.coop_revive_nag_hud_refreshtime * 1000;
	
	if ( isdefined( self ) && isdefined( self.nag_hud_on ) )
	{
		return false;	
	}
	else if( !IsDefined( self.lastReviveNagButtonPressTime ) )
	{
		return true;
	}
	else if( GetTime() - self.lastReviveNagButtonPressTime < waitTime )
	{
		return false;
	}
	
	return true;
}

nag_prompt_show()
{
	assertex( isdefined( self ), "Self not defined." );
	
	if ( !isdefined( self ) )
		return;
	
	self.nag_hud_on = true;
	fadeTime = 0.05;
	loc = &"SPECIAL_OPS_REVIVE_NAG_HINT";
	
	hud = self get_nag_hud();
	hud.alpha = 0;
	hud SetText( loc );
	hud FadeOverTime( fadeTime );
	hud.alpha = 1;
	
	self waittill_disable_nag();
	
	self.nag_hud_on = undefined;
	hud FadeOverTime( fadeTime );
	hud.alpha = 0;
	hud delaycall( ( fadeTime + 0.05 ), ::Destroy );
}

get_nag_hud()
{
	hudelem = NewClientHudElem( self );
	
	hudelem.x = 0;
	hudelem.y = 50;
	hudelem.alignX = "center";
	hudelem.alignY = "middle";
	hudelem.horzAlign = "center";
	hudelem.vertAlign = "middle";
	hudelem.fontScale = 1;
	hudelem.color = ( 1.0, 1.0, 1.0 );
	hudelem.font = "hudsmall";
	hudelem.glowColor = ( 0.3, 0.6, 0.3 );
	hudelem.glowAlpha = 0;
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = true;
	hudelem.hidewhendead = true;
	return hudelem;
}

nag_prompt_cancel()
{
	self endon( "nag" );
	
	while( is_player_down( self ) && self can_show_nag_prompt() )
	{
		wait( 0.05 );
	}
	
	self notify( "nag_cancel" );
}

can_show_nag_prompt()
{
	if ( isdefined( level.hide_nag_prompt ) && level.hide_nag_prompt )
	{
		return false;
	}
		
	otherplayer = get_other_player( self );
	if( otherplayer player_laststand_is_reviving( self ) )
	{
		return false;
	}
	
	//if( !self maps\_specialops_battlechatter::can_say_current_nag_event_type() )
	{
		return false;
	}
	
	//return true;
}

laststand_coop_hud_manager()
{
	if ( !is_coop() )
		return;
	level endon ( "special_op_terminated" );
	
	// Array to hold each player's previous down state
			// Was Down = true
			// Was Up = false
	player_previous_states = [];
	foreach( player in level.players )
		player_previous_states[ player.unique_id ] = is_player_down( player );
	
	// Create coop specific hud and store it for cleanup
	laststand_coop_hud_create();
	
	// When a player's state has changed manage appropriate hud pieces
	// and apply appropriate effect such as pulse.
	while ( 1 )
	{
		level waittill( "laststand_player_state_changed" );
		
		// In case both players go down in the same frame
		waittillframeend;
		
		foreach ( player in level.players )
		{
			other_player = get_other_player( player );
			
			player_changed_state		= player player_laststand_changed_state( player_previous_states );
			other_player_changed_state	= other_player player_laststand_changed_state( player_previous_states );
			
			if ( player_changed_state )
			{
				if ( is_player_down( player ) )
				{
					// Hide friend HUD
					player.revive_text_friend.alpha		= 0;
					player.revive_timer_friend.alpha	= 0;
					
					// Show local HUD
					//player.revive_text_local 			thread maps\_specialops::so_hud_pulse_stop();
					//player.revive_timer_local 			thread maps\_specialops::so_hud_pulse_stop();
					player.revive_text_local.alpha		= 1;
					player.revive_timer_local.alpha		= 1;
					//player.revive_text_local 			thread maps\_specialops::so_hud_pulse_create();
					//player.revive_timer_local 			thread maps\_specialops::so_hud_pulse_create();
				}
				else if ( is_player_down( other_player ) )
				{
					// Hide local HUD
					player.revive_text_local.alpha		= 0;
					player.revive_timer_local.alpha		= 0;
					
					// Show friend HUD
					//player.revive_text_friend 			thread maps\_specialops::so_hud_pulse_stop();
					//player.revive_timer_friend 			thread maps\_specialops::so_hud_pulse_stop();
					player.revive_text_friend.alpha		= 1;
					player.revive_timer_friend.alpha	= 1;
					//player.revive_text_friend 			thread maps\_specialops::so_hud_pulse_create();
					//player.revive_timer_friend 			thread maps\_specialops::so_hud_pulse_create();
				}
				else
				{
					player player_laststand_hud_hide();
				}
			}
			
			if ( other_player_changed_state )
			{
				if ( !is_player_down( player ) )
				{
					if ( is_player_down( other_player ) )
					{
						// Hide local HUD
						player.revive_text_local.alpha		= 0;
						player.revive_timer_local.alpha		= 0;
						
						// Show local HUD
						//player.revive_text_friend 			thread maps\_specialops::so_hud_pulse_stop();
						//player.revive_timer_friend 			thread maps\_specialops::so_hud_pulse_stop();
						player.revive_text_friend.alpha		= 1;
						player.revive_timer_friend.alpha	= 1;
						//player.revive_text_friend 			thread maps\_specialops::so_hud_pulse_create();
						//player.revive_timer_friend 			thread maps\_specialops::so_hud_pulse_create();
					}
					else
					{
						player player_laststand_hud_hide();
					}
				}
			}
		}
		
		// After the loop is done update the previous states to be the current
		foreach( player in level.players )
			player_previous_states[ player.unique_id ] = is_player_down( player );
	}
}

laststand_coop_hud_create()
{
	foreach ( player in level.players )
	{
		// Text
		player.revive_text_local			= player createClientFontString( "hudsmall", 1.0 );
		player.revive_text_local			setPoint( "CENTER", undefined, 0, level.revive_hud_base_offset );
		player.revive_text_local			settext( &"SCRIPT_COOP_BLEEDING_OUT" );
		
		player.revive_text_friend			= player createClientFontString( "hudsmall", 1.0 );
		player.revive_text_friend			setPoint( "CENTER", undefined, 0, level.revive_hud_base_offset );
		player.revive_text_friend			settext( &"SCRIPT_COOP_BLEEDING_OUT_PARTNER" );
		
		// Timers
		player.revive_timer_local			= player createClientTimer( "hudsmall", 1.2 );
		player.revive_timer_local			setPoint( "CENTER", undefined, 0, level.revive_hud_base_offset + level.revive_bar_offset );
		
		player.revive_timer_friend			= player createClientTimer( "hudsmall", 1.2 );
		player.revive_timer_friend			setPoint( "CENTER", undefined, 0, level.revive_hud_base_offset + level.revive_bar_offset );
		
		player player_laststand_hud_hide();
		
		// Grab all hud items for later cleanup
		level.laststand_hud_elements[ level.laststand_hud_elements.size ] = player.revive_text_local;
		level.laststand_hud_elements[ level.laststand_hud_elements.size ] = player.revive_text_friend;
		level.laststand_hud_elements[ level.laststand_hud_elements.size ] = player.revive_timer_local;
		level.laststand_hud_elements[ level.laststand_hud_elements.size ] = player.revive_timer_friend;
	}
}

player_laststand_hud_hide()
{
	assertex( IsDefined( self ) && IsAlive( self ) && IsPlayer( self ), "Player invalid." );
	
	self.revive_text_local.alpha		= 0;
	self.revive_text_friend.alpha		= 0;
	self.revive_timer_local.alpha		= 0;
	self.revive_timer_friend.alpha		= 0;
}

player_laststand_changed_state( array_previous_states )
{
	assertex( isdefined( array_previous_states ) && array_previous_states.size, "Array of previous states must be defined and filled." );
	
	current_state = is_player_down( self );
	previous_state = array_previous_states[ self.unique_id ];
	assertex( isdefined( previous_state ), "Could not get player previous down state using player unique_id." );
	
	return current_state != previous_state;
}

laststand_getup_hud_init()
{
	if ( laststand_get_type() != CONST_LASTSTAND_TYPE_GETUP )
		return;
	
	foreach( player in level.players )
		player.laststand_getup_fast = false;
	
	laststand_revive_bar_getup_create();
}

laststand_revive_bar_getup_create()
{	
	foreach( player in level.players )
	{
		y_offset = level.revive_hud_base_offset + level.revive_bar_getup_offset;
		
		// Getup Bar
		player.revive_bar_getup						= createClientProgressBar( player, y_offset, "white", "black", CONST_LASTSTAND_GETUP_BAR_WIDTH, CONST_LASTSTAND_GETUP_BAR_HEIGHT );	
		player player_laststand_getup_bar_set_fill( CONST_LASTSTAND_GETUP_BAR_START );
		level.laststand_hud_elements[ level.laststand_hud_elements.size ] = player.revive_bar_getup;
		
		// Getup Icon
		player.revive_bar_getup_icon				= NewClientHudElem( player );
		player.revive_bar_getup_icon.hidden 		= false;
		player.revive_bar_getup_icon.elemType 		= "icon";
		player.revive_bar_getup_icon.hideWhenInMenu = true;
		player.revive_bar_getup_icon.archived 		= false;
		player.revive_bar_getup_icon.x 				= ( ( CONST_LASTSTAND_GETUP_BAR_WIDTH / 2 ) + CONST_LASTSTAND_GETUP_ICON_SIZE ) * -1;
		player.revive_bar_getup_icon.y 				= y_offset;
		player.revive_bar_getup_icon.alignx 		= "center";
		player.revive_bar_getup_icon.aligny 		= "middle";
		player.revive_bar_getup_icon.horzAlign 		= "center";
		player.revive_bar_getup_icon.vertAlign 		= "middle";
		player.revive_bar_getup_icon.children 		= []; 		// Needed in destroyElem() call
		player.revive_bar_getup_icon.elemType 		= "icon";	// Needed in destroyElem() call
		player.revive_bar_getup_icon				setShader( "specialty_pistoldeath", CONST_LASTSTAND_GETUP_ICON_SIZE, CONST_LASTSTAND_GETUP_ICON_SIZE );
		level.laststand_hud_elements[ level.laststand_hud_elements.size ] = player.revive_bar_getup_icon;
		
		// Hide both
		player.revive_bar_getup hideBar( true );
		luinotify("toggle_laststand_bar", "0");
		player.revive_bar_getup_icon.alpha = 0.0;
	}
}

player_laststand_on_downed_hud_update()
{
	self endon( "end_func_player_laststand_downed_icon" );
	self endon( "death" );
	self endon( "revived" );

	level endon( "special_op_terminated" );

	foreach ( player in level.players )
	{
		if ( player == self )
			player.revive_timer_local setTimer( self.laststand_info.bleedout_time_default - 1 );
		else
			player.revive_timer_friend setTimer( self.laststand_info.bleedout_time_default - 1 );
	}

	self thread player_laststand_countdown_timer( self.laststand_info.bleedout_time_default );

	time = self.laststand_info.bleedout_time_default;

	foreach ( player in level.players )
	{
		if ( player == self )
		{
			player.revive_text_local.color		= self.revive_text_local.color;
			player.revive_timer_local.color		= self.revive_text_local.color;
		}
		else
		{
			player.revive_text_friend.color		= player.revive_text_local.color;
			player.revive_timer_friend.color	= player.revive_text_local.color;
		}
	}
	
	// give player a chance to get his timer set
	waittillframeend;

	while ( time )
	{
		foreach ( player in level.players )
		{
			if ( player == self )
			{
				revive_text = player.revive_text_local;
				revive_timer = player.revive_timer_local;
			}
			else
			{
				revive_text = player.revive_text_friend;
				revive_timer = player.revive_timer_friend;
			}
			
			previous_color = revive_text.color;
			new_color = get_coop_downed_hud_color( self.laststand_info.bleedout_time, self.laststand_info.bleedout_time_default, false, player == self );
			revive_text.color = new_color;
			revive_timer.color = new_color;

			if ( distance( new_color, previous_color ) > 0.001 )
			{
				if ( distance( new_color, player.coop_icon_color_dying ) <= 0.001 )
				{
					revive_text.pulse_loop = true;
					revive_timer.pulse_loop = true;
				}
					
				//revive_text thread maps\_specialops::so_hud_pulse_create();
				//revive_timer thread maps\_specialops::so_hud_pulse_create();
			}
		}
		
		wait 1.0;
		time -= 1.0;
	}
}

player_laststand_downed_icon()
{
	self endon( "end_func_player_laststand_downed_icon" );
	self endon( "death" );
	self endon( "revived" );

	level endon( "special_op_terminated" );

	//give player a chance to get his timer set
	waittillframeend;
	
	while ( self.laststand_info.bleedout_time > 0 )
	{
		self ent_flag_waitopen( "laststand_pause_bleedout_timer" );
		
		wait 0.05;
	}
}

player_laststand_countdown_timer( time )
{
	self endon( "death" );
	self endon( "revived" );

	level endon( "special_op_terminated" );

	self.laststand_info.bleedout_time = time;

	while ( self.laststand_info.bleedout_time > 0 )
	{
		if ( self ent_flag( "laststand_pause_bleedout_timer" ) )
		{
			foreach ( player in level.players )
			{
				if ( player == self )
					player.revive_timer_local.alpha = 0;
				else
					player.revive_timer_friend.alpha = 0;
			}
			self ent_flag_waitopen( "laststand_pause_bleedout_timer" );

			//need this check because was setting a time that wasn't greater than 0 which would give an error
			if ( self.laststand_info.bleedout_time >= 1 )
			{
				foreach ( player in level.players )
				{
					if ( player == self )
						player.revive_timer_local settimer( self.laststand_info.bleedout_time - 1 );
					else
						player.revive_timer_friend settimer( self.laststand_info.bleedout_time - 1 );
				}
			}
		}
		else
		{
			foreach ( player in level.players )
				if ( player == self )
					player.revive_timer_local.alpha = 1;
				else if ( !is_player_down( player ) )
					player.revive_timer_friend.alpha = 1;
		}

		wait .05;
		self.laststand_info.bleedout_time -= .05;
	}

	self.laststand_info.bleedout_time = 0;
	//maps\_specialops::so_force_deadquote( "@DEADQUOTE_SO_BLED_OUT", "ui_bled_out" );
	//thread maps\_specialops::so_dialog_mission_failed_bleedout();
	self notify( "coop_bled_out" );
}

get_coop_downed_hud_color( current_time, total_time, doBlinks, for_self )
{
	if ( IsDefined( for_self ) && for_self )
	{
		player = self;
	}
	else
	{
		player = get_other_player( self );
	}
		
	// only one player should see the blinking
	if( !IsDefined( doBlinks ) )
	{
		doBlinks = true;
	}
	
	// maybe we have to deliver the blink state?
	if( doBlinks && self coop_downed_hud_should_blink() )
	{
		ASSERT( IsDefined( self.blinkState ) );
		
		if( self.blinkState == 1 )
		{
			return player.coop_icon_color_blink;
		}
	}
	
	// if we're not blinking, return the base color
	if ( current_time < ( total_time * level.laststand_stage3_multiplier ) )
	{
		return player.coop_icon_color_dying;
	}
	
	if ( current_time < ( total_time * level.laststand_stage2_multiplier ) )
	{
		return player.coop_icon_color_damage;
	}

	return player.coop_icon_color_downed;
}

coop_downed_hud_should_blink()
{
	otherplayer = get_other_player( self );
	
	if( otherplayer player_laststand_is_reviving( self ) )
	{
		return false;
	}
	
	// have we ever pressed the nag button?
	if( IsDefined( self.lastReviveNagButtonPressTime ) )
	{
		// did we press the button recently?
		if( ( GetTime() - self.lastReviveNagButtonPressTime ) < ( level.coop_icon_blinktime * 1000 ) )
		{
			return true;
		}
	}
	
	return false;
}

laststand_hud_destroy()
{
	if ( isdefined ( level.laststand_hud_elements ) )
	{
		foreach ( item in level.laststand_hud_elements )
		{
			if ( isdefined( item ) )
			{
				item notify( "destroying" );
				item destroyElem();
			}
		}
	}
	
	level.laststand_hud_elements = undefined;
}

player_laststand_set_down_attributes()
{
	self endon( "death" );
	
	self notify( "player_downed" );

	self.ignoreRandomBulletDamage = true;
	self EnableInvulnerability();
	
	self ent_flag_set( "laststand_downed" );
	self.laststand = true;
	
	self.health = 2;
	self.maxhealth = self.original_maxhealth;
	self.ignoreme = true;

	self DisableUsability();
	self DisableWeaponSwitch();
	self disableoffhandweapons();
	self DisableWeapons();

	if ( !isdefined( self.laststand_down_count ) )
		self.laststand_down_count = 1;
	else
		self.laststand_down_count++;
	
	// sentry placement cancelled - if fresh placement then sentry is stowed back, else sentry is destroyed
	if ( isdefined( self.placingSentry ) )
		self notify( "sentry_placement_canceled" );
		
	self thread player_laststand_kill_by_vehicle();
	
	if ( self laststand_downing_will_fail() )
	{
		self player_laststand_kill();
	}
	else
	{
		self thread player_laststand_set_down_part1();
	}
}

is_coop()
{
	return false;
}

player_laststand_set_original_attributes()
{
	self.ignoreRandomBulletDamage = false;
	self ent_flag_clear( "laststand_downed" );
	self.laststand = false;
	self.achieve_downed_kills = undefined;
	self.down_part2_proc_ran = undefined;

	if ( is_coop() )
	{
	}
	
	self disableweapons();
	self remove_pistol_if_extra();

	self.health = self.maxhealth;
	self.ignoreme = false;
	self setstance( "stand" );

	self EnableUsability();
	self enableoffhandweapons();
	self EnableWeaponSwitch();
	self EnableWeapons();
	self notify( "not_in_last_stand" );

	wait 1.0;
	self DisableInvulnerability();

	soundscripts\_audio_reverb::rvb_start_preset("none");
}

remove_pistol_if_extra()
{
	AssertEx( IsPlayer( self ), "remove_pistol_if_extra() was called on a non-player." );

	if ( isdefined( self.forced_pistol ) )
	{
		self takeweapon( self.forced_pistol );
		self.forced_pistol = undefined;
	}

	if ( isdefined( self.preincap_pistol ) )
	{
		self setweaponammoclip( self.preincap_pistol, self.preincap_pistol_clip );
		self setweaponammostock( self.preincap_pistol, self.preincap_pistol_stock );
	}
	
	if ( player_can_restore_weapon( self.preincap_weapon ) )
	{
		self SwitchToWeapon( self.preincap_weapon );
	}
	else
	{
		primary_weapons = self GetWeaponsListPrimaries();
		assert( primary_weapons.size > 0 );
		self SwitchToWeapon( primary_weapons[0] );
	}
	self.preincap_weapon = undefined;
}

player_laststand_kill_by_vehicle()
{
	self endon( "revived" );
	self endon( "death" );
	level endon( "special_op_terminated" );

	if ( flag( "special_op_terminated" ) )
	{
		return;
	}

	if ( !IsAlive( self ) )
	{
		return;
	}

	while ( 1 )
	{
		vehicles = Vehicle_GetArray();
		foreach ( vehicle in vehicles )
		{
			if ( isdefined( vehicle.dont_crush_player ) && vehicle.dont_crush_player )
				continue;

			speed = vehicle Vehicle_GetSpeed();
			if ( abs( speed ) == 0 )
				continue;

			if ( self IsTouching( vehicle ) )
			{
				//vehicle maps\_specialops::so_crush_player( self, "MOD_CRUSH" );
				self kill();
				return;
			}
		}

		wait 0.05;
	}
}

player_laststand_set_down_part1()
{
	self endon( "revived" );
	self endon( "death" );
	
	level endon( "special_op_terminated" );

	// Keeping the timing of the origianl laststand when
	// not using getup type or if getup type is out of uses
	if ( laststand_get_type() != CONST_LASTSTAND_TYPE_GETUP )
		wait 0.3;
	
	self thread player_laststand_force_switch_to_pistol();

	// Main Laststand GETUP logic loop
	if ( laststand_get_type() == CONST_LASTSTAND_TYPE_GETUP )
	{
		// If the player has at least one getup left, decrement
		// the count and run the getup sequence
		if ( self get_lives_remaining() > 0 )
		{
			// Update laststand used count
			if ( !isdefined( self.laststand_count ) )
				self.laststand_count = 1;
			else
				self.laststand_count++;
			
			// If the player has not used up all of their laststands
			// let them try and fight their way out. If they successfully
			// revive themself this function will end.
			if ( self.laststand_count <= CONST_LASTSTAND_GETUP_COUNT )
			{
				self thread player_laststand_getup_sequence();
				self waittill( "laststand_getup_failed" );
			}
			
			// If not coop or the other player is down and out then kill
			// this player because both players just became down and out
			if ( !is_coop() || is_player_down_and_out( get_other_player( self ) ) )
			{
				self player_laststand_kill();
				return;
			}
		}
		else
		{
			// Wait a frame here because the player is going from standing
			// right into down and out. This happens when the player
			// is in laststand type GetUp and he doesn't have any
			// lives. This allows things like the _remotemissile 
			// and the _sentry drop logic to give weapons back before
			// player_laststand_set_down_part2() takes them away again -JC
			waittillframeend;
		}
	}
	else
	{
		wait 0.25;
		self DisableInvulnerability();
	
		self thread player_laststand_down_draw_attention();
	
		self waittill( "damage" );
	}
	
	self thread player_laststand_set_down_part2();
}

player_laststand_getup_sequence()
{
	self endon( "revived" );
	self endon( "death" );
	self endon( "laststand_getup_failed" );	
	level endon( "special_op_terminated" );
	
	self thread player_laststand_getup_sequence_clean_up();
	self thread player_laststand_getup_sequence_catch_kills();
	self thread player_laststand_getup_sequence_catch_damage();
	self thread player_laststand_getup_sequence_bad_place();
	self thread player_laststand_effect();
	self thread player_laststand_getup_sequence_ignore();
	
	fill_penalty	= ( self.laststand_count - 1 ) * CONST_LASTSTAND_GETUP_BAR_START_PENALTY;
	fill_start		= max( CONST_LASTSTAND_GETUP_BAR_START - fill_penalty, CONST_LASTSTAND_GETUP_BAR_START_MIN );
	
	self player_laststand_getup_bar_set_fill( fill_start );
	//self.revive_bar_getup hideBar( false );
	luinotify("toggle_laststand_bar", "1");
	self.revive_bar_getup_icon.alpha = 1.0;
	
	wait CONST_LASTSTAND_GETUP_INVULN_TIME;
	
	// Let AI damage the player (his death shield protects him)
	self DisableInvulnerability();
	
	// As soon as the player can be damaged record that AI
	// damaged the player so that the below bar speed up 
	// gives the AI a chance to hurt the player.
	self.last_damage_time = gettime();
	
	// Bar Auto Fills
	while( 1 )
	{
		fast_fill = false;
	
		if ( isdefined( self.laststand_getup_fast ) && self.laststand_getup_fast )
			fast_fill = true;
		else if ( gettime() - self.last_damage_time > CONST_LASTSTAND_GETUP_BAR_REGEN_NO_DMG_DELAY * 1000 )
			fast_fill = true;
		
		fill_amount = ter_op( fast_fill, CONST_LASTSTAND_GETUP_BAR_REGEN_FAST, CONST_LASTSTAND_GETUP_BAR_REGEN );

		self player_laststand_getup_bar_adjust( fill_amount );
		wait CONST_LASTSTAND_GETUP_BAR_REGEN_TIME;
	}
}

player_laststand_getup_sequence_clean_up()
{
	level endon( "special_op_terminated" );
	self endon( "death" );
	
	msg = self waittill_any_return( "player_down_and_out", "revived" );
	
	if ( isdefined( msg ) && msg == "player_down_and_out" )
	{
		self.ignoreme = true;
	}
	
	// At this point the player has used up the current laststand
	self update_lives_remaining( false );
	
	self thread player_laststand_getup_sequence_clean_up_delayed( CONST_LASTSTAND_GETUP_BAR_CLEAN_DELAY );
	
	// This getup sequence is over so reset the fast fill field
	self.laststand_getup_fast = false;
	
	if ( isdefined( self.laststand_badplace ) )
	{
		BadPlace_Delete( self.laststand_badplace );
		self.laststand_badplace = undefined;
	}
}

player_laststand_getup_sequence_clean_up_delayed( delay )
{
	level endon( "special_op_terminated" );
	
	// If the player goes down again while this is waiting to 
	// clear the bar end
	self endon( "player_downed" );
	
	wait delay;
	
	self.revive_bar_getup hideBar( true );
	luinotify("toggle_laststand_bar", "0");
	self.revive_bar_getup_icon.alpha = 0.0;
}

player_laststand_getup_sequence_ignore()
{
	self endon( "revived" );
	self endon( "death" );
	self endon( "laststand_getup_failed" );
	level endon( "special_op_terminated" );
	
	self.ignoreme = true;	
	wait CONST_LASTSTAND_GETUP_IGNORE_TIME;
	self.ignoreme = false;
}

player_laststand_getup_sequence_catch_kills()
{
	self endon( "revived" );
	self endon( "death" );
	self endon( "laststand_getup_failed" );
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		self waittill( "revive_kill" );
		
		self player_laststand_getup_bar_adjust( CONST_LASTSTAND_GETUP_BAR_AI_KILL );
	}
}

player_laststand_getup_sequence_catch_damage()
{
	self endon( "revived" );
	self endon( "death" );
	self endon( "laststand_getup_failed" );
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		self waittill_any( "damage", "deathshield" );
		
		self player_laststand_getup_bar_adjust( -1 * CONST_LASTSTAND_GETUP_BAR_DAMAGE );
		self.last_damage_time = gettime();
		
		wait CONST_LASTSTAND_GETUP_BAR_DAMAGE_TIME;
	}
}

player_laststand_getup_sequence_bad_place()
{
	self endon( "revived" );
	self endon( "death" );
	self endon( "laststand_getup_failed" );
	level endon( "special_op_terminated" );
	
	// Badplace is removed by player_laststand_getup_sequence_clean_up()
	self.laststand_badplace = self.unique_id + "_ls_badplace";
	
	while( 1 )
	{
		BadPlace_Cylinder( self.laststand_badplace, CONST_LASTSTAND_GETUP_BAD_PLACE_TIME, self.origin, CONST_LASTSTAND_GETUP_BAD_PLACE_RANGE, CONST_LASTSTAND_GETUP_BAD_PLACE_RANGE, "axis" );
		
		wait CONST_LASTSTAND_GETUP_BAD_PLACE_TIME;
		
		BadPlace_Delete( self.laststand_badplace );
	}
	
}

player_laststand_getup_bar_adjust( frac_adjust )
{
	frac_adjust = clamp( frac_adjust, -1.0, 1.0 );
	
	bar_frac = clamp( self.revive_bar_getup.bar.frac + frac_adjust, 0.0, 1.0 );
	
	self player_laststand_getup_bar_set_fill( bar_frac );
	
	if ( bar_frac == 1.0 )
		self player_laststand_revive_self();
	else if ( bar_frac == 0.0 )
		self notify( "laststand_getup_failed" );
}

player_laststand_getup_bar_set_fill( frac )
{
	luinotify("set_laststand_percent", frac);

	// Try super red to light red all red
	white		= ( 1, 1, 1 );
	red_light	= ( 1, 0.4, 0.4 );
	red			= ( 1, 0.0, 0.0 );

	self.revive_bar_getup.bar.color = VectorLerp( red, red_light, frac );
	self.revive_bar_getup updateBar( frac );
}

player_laststand_set_down_part2()
{
	self.down_part2_proc_ran = true;
	self notify( "player_down_and_out" );

	self disableweapons();
	self thread player_dying_effect();

	self.ignoreme = true;
	self.ignoreRandomBulletDamage = true;
	self EnableInvulnerability();
}

player_laststand_force_switch_to_pistol()
{
	self.preincap_weapon = self GetCurrentWeapon();
	
	current_pistol = self player_laststand_check_for_pistol();

	self.preincap_pistol = undefined;
	self.preincap_pistol_stock = 0;
	self.preincap_pistol_clip = 0;
	
	laststand_pistol = undefined;
	
	// If the player has a pistol use that otherwise use 
	// the incap weapon if it is defined, lastly use the fnfiveseven
	if ( isdefined( current_pistol ) )
	{
		self.preincap_pistol 		= current_pistol;
		self.preincap_pistol_stock 	= self getweaponammostock( current_pistol );
		self.preincap_pistol_clip 	= self getweaponammoclip( current_pistol );
		
		laststand_pistol = current_pistol;
	}
	else if ( isdefined( level.coop_incap_weapon ) )
	{
		has_incap_weapon = IsDefined( level.coop_incap_weapon ) && self HasWeapon( level.coop_incap_weapon );
		
		if ( !has_incap_weapon )
		{
			self.forced_pistol = level.coop_incap_weapon;
			self giveWeapon( level.coop_incap_weapon );
		}
		else
		{
			self.preincap_pistol 		= level.coop_incap_weapon;
			self.preincap_pistol_stock 	= self getweaponammostock( current_pistol );
			self.preincap_pistol_clip 	= self getweaponammoclip( current_pistol );
		}
		
		laststand_pistol = level.coop_incap_weapon;
	}
	else
	{
		laststand_pistol = "beretta";
		self.forced_pistol = laststand_pistol;
		self giveWeapon( laststand_pistol );
	}

	// Give the player max ammo
	self setweaponammoclip( laststand_pistol, WeaponClipSize( laststand_pistol ) );
	self setweaponammostock( laststand_pistol, WeaponMaxAmmo( laststand_pistol ) );
	
	// Make sure the player's stock never runs out
	self thread player_laststand_on_reload_fill_stock();
	
	self SwitchToWeapon( laststand_pistol );	
	self EnableWeapons();
}

player_laststand_on_reload_fill_stock()
{
	AssertEx( is_player_down(self) , "Laststand should not be filling the stock on reload if the player is not down." );
	
	level endon( "special_op_terminated" );
	self endon( "death" );
	self endon( "player_down_and_out" );
	self endon( "not_in_last_stand" );
	self endon( "revived" );
	self endon( "weapon_change" );
	
	while ( 1 )
	{
		self waittill( "reload" );
		
		weapon = self GetCurrentWeapon();
		self SetWeaponAmmoStock( weapon, WeaponMaxAmmo( weapon ) );
	}
}

player_laststand_down_draw_attention()
{
	self endon( "death" );
	self endon( "revived" );
	self endon( "damage" );

	notifyoncommand( "draw_attention", "+attack" );
	notifyoncommand( "draw_attention", "+attack_akimbo_accessible" );	// support accessibility control scheme
	
	self waittill_any_timeout( 4, "draw_attention", "player_down_and_out" );
	
	// If the player is completely downed don't mess 
	// with ignore me or random bullet damage. Those
	// attributes are set in the down and out func
	if ( is_player_down_and_out( self ) )
		return;

	self.ignoreme = false;
	self.ignoreRandomBulletDamage = false;
}

ai_laststand_on_death()
{
	level endon( "special_op_terminated" );
	
	self waittill( "death", attacker, type, weapon );
	
	revive_kill = false;
	
	// Weapon is checked to insure that kills resulting
	// from a longdeath ending are not counted for 
	// revives
	if	(
		isdefined( attacker )
	&&	isalive( attacker )
	&&	isplayer( attacker )
	&&	is_player_down( attacker )
		)
	{
		if ( IsDefined( weapon ) && WeaponClass( weapon ) == "pistol" )
		{
			revive_kill = true;	
		}
		else if ( IsDefined( type ) && type == "MOD_MELEE" )
		{
			revive_kill = true;
		}
	}
	
	if ( revive_kill )
		attacker notify( "revive_kill" );
}

//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
//  Fx Utils
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//

player_dying_effect()
{
	self endon( "death" );
	self endon( "revived" );

	//allow this thread to only be run once
	if ( !self ent_flag_exist( "laststand_dying_effect" ) )
		self ent_flag_init( "laststand_dying_effect" );
	else if ( self ent_flag( "laststand_dying_effect" ) )
		return;
	self ent_flag_set( "laststand_dying_effect" );
	
	// Not threaded so that this function inherits revive endon	
	player_shock_effect( "default", 60, true );
}

player_dying_effect_remove()
{
	if ( self ent_flag_exist( "laststand_dying_effect" ) )
		self ent_flag_clear( "laststand_dying_effect" );

	self stopShellShock();
}

player_laststand_effect()
{
	self endon( "death" );
	self endon( "revived" );
	self endon( "player_down_and_out" );
	
	self notify( "laststand_effect" );
	self endon( "laststand_effect" );
	
	// Not threaded so that this function inherits endons
	self player_shock_effect( "laststand_getup", 60, true );
}

player_shock_effect( shock_type, time, loop, self_endons )
{
	self endon( "death" );
	level endon( "special_op_terminated" );
	
	assertex( isdefined( shock_type ), "shock type undefined." );
	assertex( isdefined( time ), "shellshock requires time" );
	
	if ( !isdefined( shock_type ) || !isdefined( time ) )
		return;
	
	if ( isdefined( self_endons ) )
	{
		endon_list = StrTok( self_endons, " " );	
		foreach ( e in endon_list )
			self endon( e );
	}
	
	while ( 1 )
	{
		self shellshock( shock_type, time );
		
		wait ( time );
		
		if ( isdefined( loop ) && !loop )
			break;
	}
}

//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
//  Misc Utils
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//

laststand_get_type()
{
	assertex( isdefined( level.laststand_initialized ), "laststand type accessed before _laststand::main() call" );
	assertex( isdefined( level.laststand_type ), "laststand type not defined." );
	
	valid 	=	isdefined( level.laststand_type ) 
			&&	level.laststand_type == CONST_LASTSTAND_TYPE_OFF
			||	level.laststand_type == CONST_LASTSTAND_TYPE_HELPLESS
			||	level.laststand_type == CONST_LASTSTAND_TYPE_GETUP;
			
	assertex( valid, "Laststand type not valid" );
	
	if ( valid )
		return level.laststand_type;
	else
		return CONST_LASTSTAND_TYPE_OFF;
}

laststand_can_pick_self_up()
{
	return	laststand_get_type() == CONST_LASTSTAND_TYPE_GETUP && get_lives_remaining() > 0;
}

laststand_downing_will_fail()
{
	assert( isdefined( self ) && isPlayer( self ) );

	if ( is_coop() )
	{
		other_player = get_other_player( self );
		other_player_helpless = is_player_down( other_player ) && !other_player laststand_can_pick_self_up() ||	is_player_down_and_out( other_player );
		
		if ( other_player_helpless && !self laststand_can_pick_self_up() )
		{
			return true;
		}
		
		return false;
	}
	else
	{
		if ( !self laststand_can_pick_self_up() )
		{
			return true;
		}
		
		return false;
	}
}

get_lives_remaining()
{
	assertex( laststand_get_type() == CONST_LASTSTAND_TYPE_GETUP, "Lives only exist in the Laststand type GETUP." );
	
	if ( laststand_get_type() == CONST_LASTSTAND_TYPE_GETUP && isdefined( self.laststand_info.type_getup_lives ) )
	{
		return max( 0, self.laststand_info.type_getup_lives );
	}
	
	return 0;
}

update_lives_remaining( increment )
{
	assertex( laststand_get_type() == CONST_LASTSTAND_TYPE_GETUP, "Lives only exist in the Laststand type GETUP." );
	assertex( isdefined( increment ), "Must specify increment true or false" );

	// Increment / Decrement lives 
	increment = ter_op( isdefined( increment ), increment, false );
	self.laststand_info.type_getup_lives = max( 0, ter_op( increment, self.laststand_info.type_getup_lives + 1, self.laststand_info.type_getup_lives - 1 ) );

	// Notify HUD that laststand life amount has changed
	self notify( "laststand_lives_updated" );
}

player_laststand_kill()
{
	level endon( "special_op_terminated" );
	
	self thread player_dying_effect_remove();
	
	self EnableDeathShield( false );
	self DisableInvulnerability();
	self EnableHealthShield( false );
	
	// Leave the player in laststand so that
	// he doesn't stand up when the game ends
	//self.laststand = false;
	
	self.achieve_downed_kills = undefined;
	waittillframeend;
	self kill();
}

try_crush_player( attacker, type )
{
	if ( !Isdefined( attacker ) )
	{
		return;
	}

	if ( isdefined( attacker.dont_crush_player ) && attacker.dont_crush_player )
	{
		return;
	}
		
	if ( !Isdefined( type ) )
	{
		return;
	}

	if ( type != "MOD_CRUSH" )
	{
		return;
	}

	// If a vehicle crushed the player, make sure the vehicle is moving before we kill, if not, then the player should live
	if ( IsDefined( attacker.vehicletype ) )
	{
		speed = attacker Vehicle_GetSpeed();
		if ( abs( speed ) == 0 )
		{
			return;
		}
	}

	if ( flag( "special_op_terminated" ) )
	{
		return;
	}

	//attacker maps\_specialops::so_crush_player( self, type );
}

// Could possibly be a useful utility function, but only useful here right now.
player_laststand_check_for_pistol( preferred_pistol )
{
	AssertEx( IsPlayer( self ), "player_laststand_check_for_pistol() was called on a non-player." );

	weapon_list = self GetWeaponsListPrimaries();

	// check for the exact pistol first	
	if ( isdefined( preferred_pistol ) )
		foreach( weapon in weapon_list )
			if ( weapon == preferred_pistol )
				return weapon;
	
	// Return the current weapon if it's a pistol
	weapon_current = self GetCurrentWeapon();
	if ( WeaponClass( weapon_current ) == "pistol" )
	{
		return weapon_current;
	}
	
	// check for any pistol
	foreach ( weapon in weapon_list )
	{
		// Need to account for Akimbo weapons?
		if ( WeaponClass( weapon ) == "pistol" )
			return weapon;
	}
		
	return undefined;
}

laststand_on_mission_end()
{
	level waittill( "special_op_terminated" );
	
	revive_destroy_use_targets();
	revive_hud_cleanup_bars();
	laststand_hud_destroy();
}

revive_hud_cleanup_bars()
{
	if ( isdefined( level.bars ) )
	{
		foreach ( bar in level.bars )
		{
			if ( isdefined( bar ) )
			{
				bar notify( "destroying" );
				bar destroyElem();
			}
		}
		level.bars = undefined;
	}
}

waittill_disable_nag()
{
	level endon( "special_op_terminated" );
	self waittill_any( "nag", "nag_cancel", "death", "revived" );
}


player_can_restore_weapon( weapon )
{
	if ( !isdefined( weapon ) )
		return false;

	if ( weapon == "none" )
		return false;

	if ( !self HasWeapon( weapon ) )
		return false;

	return true;
}

revive_set_use_target_state( turn_on )
{
	assertex( isdefined( self ) && isplayer( self ), "player not passed as self to revive_set_use_target_state()" );
	assertex( isdefined( turn_on ), "revive_set_use_target_state() requires boolean for state setting." );
	
	revive_ent = self player_get_revive_ent();
	
	assertex( isdefined( revive_ent ), "revive ent could not be found for player with unique_id of " + self.unique_id );
	
	if ( turn_on )
		revive_ent makeusable();
	else
		revive_ent makeunusable();
		
	return revive_ent;
}

player_get_revive_ent()
{
	assertex( isdefined( level.revive_ents ) && level.revive_ents.size, "level.revive_ents not initialized." );
	
	return level.revive_ents[ self.unique_id ];
}

revive_destroy_use_targets()
{
	if ( isdefined( level.revive_ents ) )		
		foreach ( revive_ent in level.revive_ents )
			revive_ent delete();
}

player_downed_hud_toggle_blinkstate()
{
	self notify( "player_downed_hud_blinkstate" );
	self endon( "player_downed_hud_blinkstate" );
	self endon( "death" );
	self endon( "revived" );
	
	self.blinkState = 1;
	
	while( 1 )
	{
		wait( level.coop_icon_blinkcrement );
		
		if( self.blinkState == 1 )
		{
			self.blinkState = 0;
		}
		else
		{
			self.blinkState = 1;
		}
	}
}
