// H2 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

_id_D1AA()
{
    soundscripts\_snd::snd_message( "snd_register_vehicle", "blackhawk", ::_id_CB5E );
}

_id_B2BA()
{
    if ( isdefined( self.snd_instance ) )
    {
        wait 1.0;
        _id_B652( 1.0 );
    }

    var_0 = spawnstruct();
    var_0.preset_name = "blackhawk";
    soundscripts\_snd::snd_message( "snd_start_vehicle", var_0 );
}

_id_B652( var_0 )
{
    if ( isdefined( self.snd_instance ) )
    {
        soundscripts\_snd::snd_message( "snd_stop_vehicle", var_0 );
        self notify( "snd_stop_vehicle" );
    }
}

_id_CB5E()
{
    soundscripts\_audio_vehicle_manager::avm_begin_preset_def( "blackhawk" );
    soundscripts\_audio_vehicle_manager::avm_begin_loop_data();
    soundscripts\_audio_vehicle_manager::avm_begin_loop_def( "h1r_blackhawk_engine_far_lp" );
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "speed" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "volume", "blackhawk_engine_far_vel2vol" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "pitch", "blackhawk_engine_far_vel2pch" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "doppler", 0.65, 0.3 );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "pitch", "blackhawk_doppler2pch" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_end_loop_def();
    soundscripts\_audio_vehicle_manager::avm_begin_loop_def( "h1r_blackhawk_engine_close_lp" );
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "speed" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "volume", "blackhawk_engine_close_vel2vol" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "doppler", 0.65, 0.3 );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "pitch", "blackhawk_doppler2pch" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_end_loop_def();
    soundscripts\_audio_vehicle_manager::avm_end_loop_data();
    soundscripts\_audio_vehicle_manager::avm_begin_oneshot_data( 0.5 );
    soundscripts\_audio_vehicle_manager::avm_begin_oneshot_def( "h1r_blackhawk_start_rev", "blackhawk_start_rev_duck" );
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "speed" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "volume", "blackhawk_start_rev_vel2vol" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_end_oneshot_def();
    soundscripts\_audio_vehicle_manager::avm_begin_oneshot_def( "h1r_blackhawk_pass_by", "blackhawk_pass_by_duck_envelope" );
    soundscripts\_audio_vehicle_manager::avm_begin_param_map( "speed" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "pitch", "blackhawk_pass_by_vel2pch" );
    soundscripts\_audio_vehicle_manager::avm_add_param_map_env( "volume", "blackhawk_pass_by_vel2vol" );
    soundscripts\_audio_vehicle_manager::avm_end_param_map();
    soundscripts\_audio_vehicle_manager::avm_end_oneshot_def();
    soundscripts\_audio_vehicle_manager::avm_end_oneshot_data();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_data();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_hover", ::_id_D044, [ "speed", "distance2d" ] );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "ALL" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_fly", ::_id_BEEA, [ "speed", "distance2d" ] );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "ALL" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_fly_from_hover", ::_id_BEEA, [ "speed", "distance2d" ] );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "ALL" );
    soundscripts\_audio_vehicle_manager::avm_add_oneshots( "h1r_blackhawk_start_rev" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_distant", ::_id_CACE, [ "distance2d" ] );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "h1r_blackhawk_engine_far_lp" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_begin_behavior_def( "to_state_flyby", ::_id_AE11, [ "speed", "distance2d", "relative_speed" ] );
    soundscripts\_audio_vehicle_manager::avm_add_loops( "ALL" );
    soundscripts\_audio_vehicle_manager::avm_add_oneshots( "h1r_blackhawk_pass_by" );
    soundscripts\_audio_vehicle_manager::avm_end_behavior_def();
    soundscripts\_audio_vehicle_manager::avm_end_behavior_data();
    soundscripts\_audio_vehicle_manager::avm_begin_state_data( 0.25, 0.5 );
    soundscripts\_audio_vehicle_manager::avm_begin_state_group( "engine_oneshots", "state_fly", "to_state_fly", 50, 1.0 );
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_hover" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_fly", "to_state_fly_from_hover" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_distant", "to_state_distant" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_distant" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_hover", "to_state_hover" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_fly", "to_state_fly" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_fly", 0.05 );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_hover", "to_state_hover" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_flyby", "to_state_flyby" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_distant", "to_state_distant" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_begin_state_def( "state_flyby", 7.0 );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_hover", "to_state_hover" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_fly", "to_state_fly" );
    soundscripts\_audio_vehicle_manager::avm_add_state_transition( "state_distant", "to_state_distant" );
    soundscripts\_audio_vehicle_manager::avm_end_state_def();
    soundscripts\_audio_vehicle_manager::avm_end_state_group();
    soundscripts\_audio_vehicle_manager::avm_end_state_data();
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "blackhawk_engine_far_vel2vol", [ [ 0, 1.0 ], [ 10, 1.0 ], [ 150.0, 1.0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "blackhawk_engine_close_vel2vol", [ [ 0, 1.0 ], [ 20, 1.0 ], [ 150.0, 1.0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "blackhawk_engine_far_vel2pch", [ [ 0, 0.9 ], [ 10, 1.0 ], [ 20, 1.1 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "blackhawk_start_rev_duck", [ [ 0.0, 1.0 ], [ 0.25, 1.0 ], [ 0.3, 0.7 ], [ 0.7, 1.0 ], [ 1.0, 1.0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "blackhawk_start_rev_vel2vol", [ [ 0.0, 0.0 ], [ 3.0, 0.3 ], [ 5.0, 0.7 ], [ 8.0, 0.8 ], [ 150.0, 1.0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "blackhawk_pass_by_duck_envelope", [ [ 0.0, 1.0 ], [ 0.15, 1.0 ], [ 0.3, 0.5 ], [ 0.5, 0.55 ], [ 0.6, 1.0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "blackhawk_pass_by_vel2vol", [ [ 0.0, 0.0 ], [ 9.06, 0.0 ], [ 15.1, 0.7 ], [ 150.0, 1.0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "blackhawk_pass_by_vel2pch", [ [ 0.0, 0.9 ], [ 15.1, 1.0 ], [ 150.0, 1.1 ] ] );
    soundscripts\_audio_vehicle_manager::avm_add_envelope( "blackhawk_doppler2pch", [ [ 0.0, 0.0 ], [ 2.0, 2.0 ] ] );
    soundscripts\_audio_vehicle_manager::avm_end_preset_def();
}

_id_D044( var_0, var_1 )
{
    var_2 = var_0["speed"];
    var_3 = var_0["distance2d"];
    var_4 = soundscripts\_audio_vehicle_manager::dist2yards( var_3 );

    if ( var_2 < 1.1 && var_4 < 3000 )
        return 1;

    return 0;
}

_id_BEEA( var_0, var_1 )
{
    var_2 = var_0["speed"];
    var_3 = var_0["distance2d"];
    var_4 = soundscripts\_audio_vehicle_manager::dist2yards( var_3 );

    if ( var_2 >= 1.1 && var_4 < 3000 )
        return 1;

    return 0;
}

_id_AE11( var_0, var_1 )
{
    var_2 = 0;
    var_3 = var_0["distance2d"];
    var_4 = var_0["relative_speed"];
    var_5 = var_0["speed"];

    if ( !isdefined( var_1.flyby ) )
    {
        var_1.flyby = spawnstruct();
        var_1.flyby.prev_dist = var_3;
        var_1.flyby.prev_dx = 0;
    }
    else
    {
        var_6 = var_3 - var_1.flyby.prev_dist;
        var_7 = var_4 * 63360 / 3600;

        if ( var_6 < 0 && var_5 >= 15.1 && var_3 <= var_7 * 2.1 )
            var_2 = 1;

        var_1.flyby.prev_dist = var_3;
        var_1.flyby.prev_dx = var_6;
    }

    return var_2;
}

_id_CACE( var_0, var_1 )
{
    var_2 = var_0["distance2d"];
    var_3 = soundscripts\_audio_vehicle_manager::dist2yards( var_2 );

    if ( var_3 >= 3000 )
        return 1;

    return 0;
}
