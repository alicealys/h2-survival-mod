// H2 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

handle_littlebird_audio()
{
    self endon( "death" );
    soundscripts\_snd::snd_message( "rec_littlebird_formation_spawn", self );

    if ( issubstr( self.classname, "sentinel" ) || issubstr( self.classname, "armed" ) || issubstr( self.classname, "atlas_bench" ) )
    {
        var_0 = 0.25;

        if ( level.currentgen )
            var_0 = 1.0;

        var_1 = 0;
        var_2 = 0;
        var_3 = spawnstruct();
        var_3.preset_name = "littlebird_sentinel";
        var_3.fadein_time = 3;
        var_3.fadeout_time = 3;
        soundscripts\_snd::snd_message( "snd_register_vehicle", "littlebird_sentinel", ::littlebird_sentinel_constructor );

        for (;;)
        {
            if ( !isdefined( self.script_disablevehicleaudio ) || !self.script_disablevehicleaudio )
            {
                var_4 = distance( self.origin, level.player.origin );

                if ( !var_1 && var_4 < 5400 )
                {
                    soundscripts\_snd::snd_message( "snd_start_vehicle", var_3 );
                    var_1 = 1;
                }
                else if ( var_1 && var_4 > 5400 )
                {
                    soundscripts\_snd::snd_message( "snd_stop_vehicle" );
                    var_1 = 0;
                }
            }
            else if ( var_1 )
            {
                soundscripts\_snd::snd_message( "snd_stop_vehicle" );
                var_1 = 0;
            }

            wait( var_0 );
        }
    }
}

littlebird_sentinel_constructor()
{
    var_0 = undefined;
    var_1 = 1;
    var_2 = 1;
    soundscripts\_audio_vehicle_manager::avm_begin_preset_def( "littlebird_sentinel" );
    soundscripts\_audio_vehicle_manager::avm_begin_loop_data( var_0, var_1, var_2 );
    soundscripts\_audio_vehicle_manager::avm_begin_loop_def( "lbs_near" );
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "DISTANCE" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "volume", "lbs_near_dist2vol" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "pitch" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "volume", "lbs_near_pch2vol" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "DOPPLER" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "pitch", "lbs_dplr2pch" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_end_loop_def();
    soundscripts\_audio_vehicle_manager::avm_begin_loop_def( "lbs_far" );
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "DISTANCE" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "volume", "lbs_far_dist2vol" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "pitch" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "volume", "lbs_far_pch2vol" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "DOPPLER" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "pitch", "lbs_dplr2pch" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_end_loop_def();
    soundscripts\_audio_vehicle_manager::avm_begin_loop_def( "lbs_pitch" );
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "pitch" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "volume", "lbs_pitch_pch2vol" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "DOPPLER" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "pitch", "lbs_dplr2pch" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_end_loop_def();
    soundscripts\_audio_vehicle_manager::avm_end_loop_data();
    soundscripts\_audio_vehicle_manager::avm_begin_oneshot_data();
    soundscripts\_audio_vehicle_manager::avm_end_oneshot_data();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_data();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_hover", ::lbs_condition_callback_to_state_hover, [ "speed", "distance2d" ] );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "ALL" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_flying", ::lbs_condition_callback_to_state_flying, [ "speed", "distance2d" ] );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "ALL" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_distant", ::lbs_condition_callback_to_state_distant, [ "distance2d" ] );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "ALL" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_flyby", ::lbs_condition_callback_to_state_flyby, [ "distance2d" ] );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "ALL" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_deathspin", ::lbs_condition_callback_to_state_deathspin );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "NONE" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_destruct", ::lbs_condition_callback_to_state_destruct );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "NONE" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_off", ::lbs_condition_callback_to_state_off );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "NONE" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_end_behavior_data();
    soundscripts\_audio_vehicle_manager::avm_begin_state_data( 0.25, 50 );
    soundscripts\_audio_vehicle_manager::avm_begin_state_group( "main_oneshots", "state_hover", "to_state_hover", 50, 1.0 );
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_off" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_hover", "to_state_hover" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_distant", "to_state_distant" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_hover" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_flyby", "to_state_flyby" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_flying", "to_state_flying" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_distant", "to_state_distant" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_deathspin", "to_state_deathspin" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_destruct", "to_state_destruct" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_flying" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_flyby", "to_state_flyby" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_distant", "to_state_distant" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_deathspin", "to_state_deathspin" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_destruct", "to_state_destruct" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_distant" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_hover", "to_state_hover" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_flying", "to_state_flying" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_flyby", "to_state_flyby" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_deathspin", "to_state_deathspin" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_destruct", "to_state_destruct" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_flyby", 3.0 );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_hover", "to_state_hover" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_flying", "to_state_flying" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_flyby", "to_state_flyby" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_distant", "to_state_distant" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_deathspin", "to_state_deathspin" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_destruct", "to_state_destruct" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_deathspin" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_destruct", "to_state_destruct" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_destruct" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_off", "to_state_off" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_end_state_group();
    soundscripts\_audio_vehicle_manager::avm_end_state_data();
    var_3 = 0;
    var_4 = 10;
    var_5 = 30;
    var_6 = var_5 - var_3;
    var_7 = soundscripts\_audio_vehicle_manager::yards2units( 0 );
    var_8 = soundscripts\_audio_vehicle_manager::yards2units( 99.0 );
    var_9 = var_8 - var_7;
    var_10 = 0.0;
    var_11 = 1.0;
    var_12 = var_11 - var_10;
    var_13 = soundscripts\_audio_vehicle_manager::yards2units( 10 );
    var_14 = soundscripts\_audio_vehicle_manager::yards2units( 30 );
    var_15 = soundscripts\_audio_vehicle_manager::yards2units( 1000000 );
    var_16 = var_15 - var_13;
    var_17 = 0.0;
    var_18 = 1.0;
    var_19 = var_18 - var_17;
    var_20 = -25;
    var_21 = 0;
    var_22 = 25;
    var_23 = soundscripts\_audio_vehicle_manager::yards2units( 0 );
    var_24 = soundscripts\_audio_vehicle_manager::yards2units( 75.0 );
    var_25 = var_24 - var_23;
    var_26 = 0.0;
    var_27 = 1.0;
    var_28 = var_27 - var_26;
    var_29 = 0.6;
    var_30 = 1.0;
    var_31 = 1.6;
    var_32 = soundscripts\_audio_vehicle_manager::yards2units( 0 );
    var_33 = soundscripts\_audio_vehicle_manager::yards2units( 150.0 );
    var_34 = var_24 - var_23;
    var_35 = 0.0;
    var_36 = 0.4;
    var_37 = var_27 - var_26;
    var_38 = 0.0;
    var_39 = 0.5;
    var_40 = var_27 - var_26;
    var_41 = var_23;
    var_42 = var_24;
    var_43 = 0.0;
    var_44 = 1.0;
    var_45 = var_44 - var_43;
    var_46 = 1.0;
    var_47 = 2.0;
    var_48 = var_47 - var_46;
    var_49 = 30;
    var_50 = 0.0;
    var_51 = 1.0;
    var_52 = 0.5;
    var_53 = 1.5;
    var_54 = 100;
    var_55 = 200;
    var_56 = 500;
    var_57 = 6.0;
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_near_dist2vol", [ [ var_7, 1 ], [ var_8, 0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_far_dist2vol", [ [ var_13, 0 ], [ var_14, 1 ], [ var_15, 1 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_near_pch2vol", [ [ var_20, 0.2 ], [ var_21, 1.0 ], [ var_22, 0.2 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_far_pch2vol", [ [ var_20, 0.2 ], [ var_21, 1.0 ], [ var_22, 0.2 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_pitch_pch2vol", [ [ var_20, 1 ], [ var_21, 0 ], [ var_22, 1 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_live_dist2vol", [ [ var_23, 1 ], [ var_24, 0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_dist_far_dist2vol", [ [ var_32, 0.0 ], [ var_33 * 0.333, 0.333 ], [ var_33, 0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_live1_accel2pch", [ [ var_38, 0.9 ], [ var_39, 1.1 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_live1_accel2vol", [ [ var_38, 0 ], [ var_39, 1 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_live1_dst2vol", [ [ var_41, var_44 ], [ var_42, var_43 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_flyby_vel2vol", [ [ var_3, var_50 ], [ var_6 * 0.25, var_51 * 0.5 ], [ var_5, var_51 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_flyby_vel2pch", [ [ var_3, var_52 ], [ var_5, var_53 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_dplr2pch", [ [ 0.0, 0.0 ], [ 2.0, 2.0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_dplr2vol", [ [ var_29, var_27 ], [ var_30, var_26 ], [ var_31, var_27 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "lbs_flyby_duck_envelope", [ [ 0.0, 1.0 ], [ 0.4, 0.7 ], [ 0.6, 0.5 ], [ 0.8, 0.7 ], [ 1.0, 1.0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_end_preset_def();
}

lbs_condition_callback_to_state_off()
{
    return 0;
}

lbs_condition_callback_to_state_hover( var_0, var_1 )
{
    var_2 = 0;
    var_3 = var_0["speed"];
    var_4 = var_0["distance2d"];
    var_5 = soundscripts\_audio_vehicle_manager::units2yards( var_4 );

    if ( var_3 <= 5.1 && var_5 < 100.0 )
        var_2 = 1;

    return var_2;
}

lbs_condition_callback_to_state_flying( var_0, var_1 )
{
    var_2 = 0;
    var_3 = var_0["speed"];
    var_4 = var_0["distance2d"];
    var_5 = soundscripts\_audio_vehicle_manager::units2yards( var_4 );

    if ( var_3 > 5.1 && var_5 < 100.0 )
        var_2 = 1;

    return var_2;
}

lbs_condition_callback_to_state_distant( var_0, var_1 )
{
    var_2 = 0;
    var_3 = var_0["distance2d"];
    var_4 = soundscripts\_audio_vehicle_manager::units2yards( var_3 );

    if ( var_4 >= 100.0 )
        var_2 = 1;

    return var_2;
}

lbs_condition_callback_to_state_flyby( var_0, var_1 )
{
    var_2 = 0;
    var_3 = var_0["distance2d"];
    var_4 = soundscripts\_audio_vehicle_manager::units2yards( var_3 );

    if ( !isdefined( var_1.flyby ) )
    {
        var_1.flyby = spawnstruct();
        var_1.flyby.prev_yards = var_4;
        var_1.flyby.prev_dx = 0;
    }
    else
    {
        var_5 = var_4 - var_1.flyby.prev_yards;

        if ( var_5 < 0 && var_4 < 6.0 )
            var_2 = 1;

        var_1.flyby.prev_yards = var_4;
        var_1.flyby.prev_dx = var_5;
    }

    return var_2;
}

lbs_condition_callback_to_state_flyover( var_0, var_1 )
{
    var_2 = 0;
    var_3 = var_0["distance2d"];
    var_4 = var_0["relative_speed"];
    var_5 = soundscripts\_audio_vehicle_manager::units2yards( var_3 );

    if ( var_5 < 30 )
        var_2 = 1;

    return var_2;
}

lbs_condition_callback_to_state_deathspin( var_0, var_1 )
{
    return 0;
}

lbs_condition_callback_to_state_destruct( var_0, var_1 )
{
    return 0;
}
