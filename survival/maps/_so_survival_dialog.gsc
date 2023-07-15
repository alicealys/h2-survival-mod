#include common_scripts\utility;
#include maps\_utility;
#include maps\_so_survival_AI;

survival_dialog_init()
{
	survival_dialog_radio_setup();
	
	thread survival_dialog_wave_start();
	thread survival_dialog_boss();
	thread survival_dialog_wave_end();
	thread survival_dialog_airsupport();
	thread survival_dialog_claymore_plant();
	thread survival_dialog_sentry_updates();
}

survival_dialog_wave_start()
{
	level endon( "special_op_terminated" );
	
	ai_use_info = [];
	
	while ( 1 )
	{
		level waittill( "wave_started", wave_num );
		
		// Give the wave start message a 1 second delay. Catch if
		// a wave ended in this time.
		msg = level waittill_any_timeout( 1.5, "wave_ended" );
		if ( msg == "wave_ended" )
			continue;
		
		// On the first wave play mission intro dialog
		if ( wave_num == 1 )
		{
			if ( is_coop() )
				radio_dialogue( "so_hq_mission_intro" );
			else
				radio_dialogue( "so_hq_mission_intro_sp" );
			
			continue;	
		}
		
		// Get the least mentioned special AI type
		ai_type = dialog_get_special_ai_type( wave_num, ai_use_info );
		
		// If a special ai type was found to talk about update
		// the ai_use_info array otherwise grab the current squad
		// ai type
		if ( isdefined( ai_type ) && ai_type != "" )
		{
			// Update the ai_use_info array
			if ( !isdefined( ai_use_info[ ai_type ] ) )
				ai_use_info[ ai_type ] = 1;
			else
				ai_use_info[ ai_type ]++;
		}
		else
		{
			ai_type = get_squad_type( wave_num );	
		}
		
		// Play radio message
		if ( isdefined( ai_type ) && ai_type != "" )
		{
			assertex( isdefined( level.scr_radio[ "so_hq_enemy_intel_" + ai_type ] ), ai_type + " ai type does not have radio intel message." );
			
			if ( isdefined( level.scr_radio[ "so_hq_enemy_intel_" + ai_type ] ) )
			{
				radio_dialogue( "so_hq_enemy_intel_" + ai_type );
			}
		}
	}
}

dialog_get_special_ai_type( wave_num, ai_use_info )
{	
	special_types = get_special_ai( wave_num );
	
	if ( !isdefined( special_types ) || !special_types.size )
		return undefined;
	
	// Populate the use info array with special types
	// in the current wave that it doesn't already contain
	foreach ( s_type in special_types )
	{
		if ( !isdefined( ai_use_info[ s_type ] ) )
		{
			ai_use_info[ s_type ] = 0;
		}
	}
	
	chosen_ai_type = "";
	chosen_use_count = 0;
	
	// Find the least used special type in the current wave
	foreach ( ai_type, ai_count in ai_use_info )
	{
		if ( array_contains( special_types, ai_type ) && ( chosen_ai_type == "" || ai_count < chosen_use_count ) )
		{
			chosen_ai_type		= ai_type;
			chosen_use_count	= ai_count;
		}
	}
	
	return chosen_ai_type;
}

survival_dialog_boss()
{
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		boss_msg_played = false;
		
		level waittill( "boss_spawning", wave_num );
		
		AI_bosses 		= get_bosses_ai( wave_num );
		nonAI_bosses 	= get_bosses_nonai( wave_num );
		
		if ( isdefined( nonAI_bosses ) && nonAI_bosses.size )
		{
			if ( nonAI_bosses.size == 1 )
			{
				if ( isdefined( level.scr_radio[ "so_hq_boss_intel_" + nonAI_bosses[ 0 ] ] ) )
				{
					radio_dialogue( "so_hq_boss_intel_" + nonAI_bosses[ 0 ] );
					boss_msg_played = true;
				}
			}
			else
			{
				if ( isdefined( level.scr_radio[ "so_hq_boss_intel_" + nonAI_bosses[ 0 ] + "_many" ] ) )
				{
					radio_dialogue("so_hq_boss_intel_" + nonAI_bosses[ 0 ] + "_many" );
					boss_msg_played = true;
				}
			}
		}
		
		if ( isdefined( AI_bosses ) && AI_bosses.size )
		{
			// If the chopper boss HQ dialog played pause before
			// playing the jug dialog.
			if ( boss_msg_played )
			{
				msg = level waittill_any_timeout( 1.5, "wave_ended" );
				if ( msg == "wave_ended" )
					continue;
		
			}
			
			if ( AI_bosses.size == 1 )
			{
				if ( isdefined( level.scr_radio[ "so_hq_boss_intel_" + AI_bosses[ 0 ] ] ) )
				{
					radio_dialogue("so_hq_boss_intel_" + AI_bosses[ 0 ] );
				}
			}
			else
			{
				if ( isdefined( level.scr_radio[ "so_hq_enemy_intel_boss_transport_many" ] ) )
				{
					radio_dialogue( "so_hq_enemy_intel_boss_transport_many" );
				}
			}
		}
	}
}

survival_dialog_wave_end()
{
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		level waittill( "wave_ended", wave_num );
		
		// Give the wave end message a 1 second delay. Catch if
		// a wave started in this time. Shouldn't happen.
		msg = level waittill_any_timeout( 1.5, "wave_started" );
		if ( msg == "wave_started" )
			continue;
		
		armory_type = "";
		if ( isdefined( level.armory_unlock ) )
		{
			if ( isdefined( level.armory_unlock[ "weapon" ] ) && level.armory_unlock[ "weapon" ] == wave_num )
				armory_type = "weapon";
			else if ( isdefined( level.armory_unlock[ "equipment" ] ) && level.armory_unlock[ "equipment" ] == wave_num )
				armory_type = "equipment";
			else if ( isdefined( level.armory_unlock[ "airsupport" ] ) && level.armory_unlock[ "airsupport" ] == wave_num )
				armory_type = "airsupport";
		}
		
		if ( armory_type != "" && isdefined( level.scr_radio[ "so_hq_armory_open_" + armory_type ] ) )
		{
			radio_dialogue( "so_hq_armory_open_" + armory_type );
		}
		else
		{
			radio_dialogue( "so_hq_wave_over_flavor" );
		}
	}
}

survival_dialog_airsupport()
{
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		level waittill( "so_airsupport_incoming", support_type );
		
		if ( isdefined( level.scr_radio[ "so_hq_as_" + support_type ] ) )
			radio_dialogue( "so_hq_as_" + support_type );
	}
}

survival_dialog_claymore_plant()
{
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		msg = level waittill_any_return( "ai_claymore_planted", "ai_chembomb_planted" );
		
		if ( msg == "ai_claymore_planted" )
		{
			if ( isdefined( level.scr_radio[ "so_hq_enemy_update_claymore" ] ) )
			{
				radio_dialogue( "so_hq_enemy_update_claymore" );
			}
		}
		else if ( msg == "ai_chembomb_planted" )
		{
			
		}
		
		level waittill( "wave_ended" );	
	}
}

// JC-ToDo: Armories currently don't get restocked so this isn't hooked up yet.
survival_dialog_armory_restocked( armory_type )
{
	assertex( isdefined( level.scr_radio[ "so_hq_armory_stocked_" + armory_type ] ), armory_type + " armory does not have restock chatter." );
	
	if ( armory_type != "" && isdefined( level.scr_radio[ "so_hq_armory_stocked_" + armory_type ] ) )
		radio_dialogue( "so_hq_armory_stocked_" + armory_type );
}

survival_dialog_sentry_updates()
{	
	level endon( "special_op_terminated" );

	// min time between per sentry dialog type	
	msg_last = "";
	
	while ( 1 )
	{
		msg = level waittill_any_return( "a_sentry_died", "a_sentry_is_underattack", "wave_ended" );
		
		if ( msg == "wave_ended" )
		{
			// Clear the last message to allow under attack message
			// again
			msg_last = "";
		}
		else if ( msg == "a_sentry_is_underattack" && msg_last != "a_sentry_is_underattack" )
		{
			thread survival_dialog_radio_sentry_underattack();
		}
		else if ( msg == "a_sentry_died" )
		{
			thread survival_dialog_radio_sentry_down();
		}
		
		msg_last = msg;
	}
}

survival_dialog_radio_sentry_down()
{
	if ( isdefined( level.scr_radio[ "so_hq_sentry_down" ] ) )
		radio_dialogue( "so_hq_sentry_down" );
}
survival_dialog_radio_sentry_underattack()
{
	if ( isdefined( level.scr_radio[ "so_hq_sentry_underattack" ] ) )
		radio_dialogue( "so_hq_sentry_underattack" );
}

// JC-ToDo: This may not be needed and currently isn't hooked up.
survival_dialog_player_down()
{
	level endon( "special_op_terminated" );
	
	while ( 1 )
	{
		level waittill( "so_player_down" );
		
		if ( isdefined( level.scr_radio[ "so_hq_player_down" ] ) )
			radio_dialogue( "so_hq_player_down" );
	}
}

survival_dialog_radio_setup()
{
	//-- Wave Start --//
	
	// Ground forces are stalled.  We'll support you as best we can - but you're on your own.  Good luck, gentlemen.
	// Be advised, all ground forces are pinned down.  You'll need to hold out as long as you can.  
	// Team,  enemy personnel are entering your area.  Use any resource you can to survive.  
	// Be advised, we cannot provide support at this time.  Recommend you conserve ammo and hold out as long as you can.
	// SIGINT shows large enemy forces en route to your location.  Dig in and do whatever you can to survive.
	// Team, we cannot get to you.  I repeat, you are on your own.  Survive by any means necessary.
	// Gentlemen, you're on your own on this one.  Good hunting.
	// Hostile forces are inbound.  Support is limited so you'll be up against everything they have.  Good luck, gentlemen.
	// Team, ground forces are stalled and cannot get to the LZ.  It's just the two of you from here on out.  
	// Enemy forces are advancing to your position.  Do whatever you can to survive.
	// Hostiles approaching your location.  Recommend you dig in and use all available resources at your disposal.
	// Gentlemen, you've got an entire army headed your way.  Limited support is available, but you're on your own. 
	level.scr_radio[ "so_hq_mission_intro" ]					= "so_hq_mission_intro";
	level.scr_radio[ "so_hq_mission_intro_sp" ]					= "so_hq_mission_intro_sp";
	
	//	Hostiles inbound.
	//	Enemy forces heading your way.
	//	Enemy contacts approaching your position.
	//	Enemy forces inbound.  Get ready.
	//	Hostiles approaching your position from multiple directions.
	//	Team, large enemy force moving towards your location.
	//	Hostiles approaching your AO.
	//	Enemy troops incoming.  
	//	Be advised, large enemy force inbound.  Recommend you get dug in, over.
	//	FLEER is picking up heat signatures headed your way, over.
	//	Multiple contacts inbound.  
	//	Team, be advised, intel shows enemy strongpoints near your position.
	level.scr_radio[ "so_hq_enemy_intel_easy" ]					= "so_hq_enemy_intel_generic";
	level.scr_radio[ "so_hq_enemy_intel_regular" ]				= "so_hq_enemy_intel_generic";
	level.scr_radio[ "so_hq_enemy_intel_hardened" ]				= "so_hq_enemy_intel_generic";
	level.scr_radio[ "so_hq_enemy_intel_veteran" ]				= "so_hq_enemy_intel_generic";
	level.scr_radio[ "so_hq_enemy_intel_elite" ]				= "so_hq_enemy_intel_generic";
	
	// Note: Clamymore AI just use regular intro lines. They have update lines for when they plant.
	level.scr_radio[ "so_hq_enemy_intel_claymore" ]				= "so_hq_enemy_intel_generic";
	
	//	Suicide bombers, keep your distance.
	//	Be aware, tangoes reported to have C4 strapped to their chests.
	level.scr_radio[ "so_hq_enemy_intel_martyrdom" ]			= "so_hq_enemy_intel_martyrdom";
	
	//	Team, chemical agents have been detected in your area.
	//	Be advised, enemy forces are moving chemical elements near your position.
	level.scr_radio[ "so_hq_enemy_intel_chemical" ]				= "so_hq_enemy_intel_chemical";
	
	//	Enemy attack dogs near your position.  Be advised, they are carrying explosives.
	//	Attack dogs outfitted with explosives are in your vicnity.  Recommend you keep your distance, over.
	level.scr_radio[ "so_hq_enemy_intel_dog_splode" ]			= "so_hq_enemy_intel_dog_splode";

	//	Thermal scans show attack dogs in your area.  
	//	Team, enemy attack dogs are approaching your location.
	level.scr_radio[ "so_hq_enemy_intel_dog_reg" ]				= "so_hq_enemy_intel_dog_reg";
	
	//-- Wave End --//
	
	//	Weapons armory is online.  Ammo and weapon upgrades are available.
	level.scr_radio[ "so_hq_armory_open_weapon" ]				= "so_hq_armory_open_weapon";
	
	//	Equipment armory online.  You now have access to explosives and armor upgrades.
	level.scr_radio[ "so_hq_armory_open_equipment" ]			= "so_hq_armory_open_equipment";
	
	//	Air support armory now online. Close Air Support is available for tasking.
	level.scr_radio[ "so_hq_armory_open_airsupport" ]			= "so_hq_armory_open_airstrike";
	
	//	Armories have been restocked.
	level.scr_radio[ "so_hq_armory_stocked_all" ]				= "so_hq_armory_stocked_all";
	
	//	Equipment armory has been restocked.
	level.scr_radio[ "so_hq_armory_stocked_equipment" ]			= "so_hq_armory_stocked_equipment";
	
	//-- Wave Over --//
	
	//	Enemy forces eliminated.  Good work, team.
	//	Hostiles neutralized.  Re-arm if you need to.
	//	They're falling back.  Check equipment and ammo.
	//	That's all of 'em.  Nice work, team.
	//	They're running scared.  Keep up the good work.
	//	All enemy contacts eliminated.  
	//	That's the last of 'em.  Good job.
	//	They're done.  Good work, gentlemen.
	//	All hostile forces in the area have been neutralized.
	level.scr_radio[ "so_hq_wave_over_flavor" ]					= "so_hq_wave_over_flavor";
	
	//-- Wave Intel --//
	
	//	Enemy forces are setting explosive traps in your vicinity.  Be on the look out.
	//	Be advised, enemy claymores near your position.
	level.scr_radio[ "so_hq_enemy_update_claymore" ]			= "so_hq_enemy_update_claymore";
	
	// Sentry gun offline.
	level.scr_radio[ "so_hq_sentry_down" ]						= "so_hq_sentry_down";

	//	Sentry is taking heavy fire.
	level.scr_radio[ "so_hq_sentry_underattack" ]				= "so_hq_sentry_underattack";
		
	// Man down, man down
	// Team member, pick him up now
	level.scr_radio[ "so_hq_player_down" ]						= "so_hq_player_down";
	
	//-- Wave Boss Incoming
	
	//	Enemy transports inbound.
	//	Enemy choppers are transporting armored divisions to the area.  Recommend you switch to heavy weapons.
	level.scr_radio[ "so_hq_boss_intel_jug_regular" ]			= "so_hq_enemy_intel_boss_transport";
	level.scr_radio[ "so_hq_boss_intel_jug_riotshield" ]		= "so_hq_enemy_intel_boss_transport";
	level.scr_radio[ "so_hq_boss_intel_jug_explosive" ]			= "so_hq_enemy_intel_boss_transport";
	level.scr_radio[ "so_hq_boss_intel_jug_headshot" ]			= "so_hq_enemy_intel_boss_transport";
	level.scr_radio[ "so_hq_boss_intel_jug_minigun" ]			= "so_hq_enemy_intel_boss_transport";
	
	//	Be advised, heavily armored ground forces are being deployed by the enemy.
	//	Team, use heavy weapons when engaging enemy forces at this time.
	level.scr_radio[ "so_hq_enemy_intel_boss_transport_many" ]	= "so_hq_enemy_intel_boss_transport_many";
	
	//	Enemy Littlebird incoming.
	//	Enemy attack chopper near your location.  Recommend you find some cover.
	level.scr_radio[ "so_hq_boss_intel_chopper" ]				= "so_hq_boss_intel_chopper";
	
	//	Intel shows multiple enemy rotor-wings in your airspace.
	//	Team, enemy air support is headed in from all directions.  Find cover.
	level.scr_radio[ "so_hq_boss_intel_chopper_many" ]			= "so_hq_boss_intel_chopper_many";
	
	//-- Air Support --//

	//	Task Force Delta is inbound.  ETA - twenty seconds.  Watch your fire.
	//	Chopping a Task Force to your location.  Standby.
	level.scr_radio[ "so_hq_as_friendly_support_delta" ]	= "so_hq_airsupport_ally_delta";
	
	//	GIGN Team outfitted with riot gear is inbound to your position.
	//	Riot Team will be on station in thirty seconds.
	level.scr_radio[ "so_hq_as_friendly_support_riotshield" ]	= "so_hq_airsupport_ally_riotshield";
	
	//	UAV controller is already active. Stand by.
	// 	UAV is already in your airspace.
	// 	Your team already has a UAV active.
	// 	Standby. UAV request is already being processed.
	// 	UAV is already being tasked.
	// 	Your team is already being assigned a UAV.
	level.scr_radio[ "so_hq_uav_busy" ] = "so_hq_uav_busy";
}






