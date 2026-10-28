// H2 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

armed( var_0, var_1 )
{
    return issubstr( var_0, "armed" ) || issubstr( var_1, "armed" );
}

#using_animtree("vehicles");

main( var_0, var_1, var_2 )
{
    if ( armed( var_0, var_2 ) )
        vehicle_scripts\_attack_heli::preload();

    if ( issubstr( var_2, "bench" ) )
    {
        precachemodel( "vehicle_sentinel_littlebird_benchleft" );
        precachemodel( "vehicle_sentinel_littlebird_benchright" );
    }

    maps\_vehicle::build_template( "littlebird", var_0, var_1, var_2 );
    maps\_vehicle::build_localinit( ::init_local );
    maps\_vehicle::build_deathmodel( "vehicle_little_bird_armed" );
    maps\_vehicle::build_deathmodel( "vehicle_little_bird_bench" );

    if ( issubstr( var_2, "kva" ) || issubstr( var_2, "atlas" ) || issubstr( var_2, "sentinel" ) )
        maps\_vehicle::build_drive( %mil_helicopter_littlebird_ai_rotors, undefined, 0, 3.0 );
    else
        maps\_vehicle::build_drive( %mi28_rotors, undefined, 0, 3.0 );

    maps\_vehicle::build_deathfx( "fx/explosions/helicopter_explosion_secondary_small", "tag_engine", "littlebird_helicopter_secondary_exp", undefined, undefined, undefined, 0.0, 1 );
    maps\_vehicle::build_deathfx( "vfx/trail/trail_fire_smoke_l", "tag_engine", "littlebird_helicopter_dying_loop", 1, 0.05, 1, 0.5, 1 );
    maps\_vehicle::build_deathfx( "fx/explosions/helicopter_explosion_secondary_small", "tag_engine", undefined, undefined, undefined, undefined, 2.5, 1 );
    maps\_vehicle::build_deathfx( "vfx/explosion/vehicle_littlebird_explosion_a", undefined, "littlebird_helicopter_crash", undefined, undefined, undefined, -1, undefined, "stop_crash_loop_sound" );
    maps\_vehicle::build_rocket_deathfx( "vfx/explosion/vehicle_littlebird_explosion_a", "tag_deathfx", "littlebird_helicopter_crash", undefined, undefined, undefined, undefined, 1, undefined, 0 );
    maps\_vehicle::build_deathquake( 0.8, 1.6, 2048 );
    maps\_vehicle::build_treadfx( var_2, "default", "vfx/treadfx/heli_dust_default", undefined, "h1r_default_helicopter_wind" );
    maps\_vehicle::build_life( 799 );
    maps\_vehicle::build_team( "axis" );
    maps\_vehicle::build_mainturret();
    maps\_vehicle::build_unload_groups( ::unload_groups );
    maps\_vehicle::build_aianims( ::setanims, ::set_vehicle_anims );
    var_3 = randomfloatrange( 0, 1 );
    maps\_vehicle::build_light( var_2, "white_blink", "TAG_LIGHT_BELLY", "vfx/lights/aircraft_light_white_blink", "running", var_3 );
    maps\_vehicle::build_light( var_2, "red_blink1", "TAG_LIGHT_TAIL1", "vfx/lights/aircraft_light_red_blink", "running", var_3 );
    maps\_vehicle::build_light( var_2, "red_blink2", "TAG_LIGHT_TAIL2", "vfx/lights/aircraft_light_red_blink", "running", var_3 );
    maps\_vehicle::build_light( var_2, "headlight_nose", "tag_light_nose", "vfx/lights/headlight_gaz", "headlights", 0.0 );

    if ( level.script == "af_chase" )
        maps\_vehicle::build_rumble( "chopper_ride_rumble", 3, 3, 1000, 1, 1 );

    var_4 = "littlebird_gunpod";

    if ( level.script == "gulag" )
        var_4 += "_gulag";

    maps\_vehicle::build_turret( var_4, "TAG_MINIGUN_ATTACH_LEFT", "vehicle_little_bird_minigun_left", undefined, undefined, undefined, -15 );
    maps\_vehicle::build_turret( var_4, "TAG_MINIGUN_ATTACH_RIGHT", "vehicle_little_bird_minigun_right", undefined, undefined, undefined, -15 );
    maps\_vehicle::build_is_helicopter();
    vehicle_scripts\_littlebird_landing::init_littlebird_landing();
}

init_local()
{
    self endon( "death" );
    self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );
    self.script_badplace = 0;
    self.dontdisconnectpaths = 1;
    self.vehicle_loaded_notify_size = 6;
    thread vehicle_scripts\_littlebird_landing::littlebird_landing();
    thread attach_littlebird_parts();
    thread maps\_vehicle::vehicle_lights_on( "running" );

    if ( issubstr( self.classname, "sentinel" ) )
        self hidepart( "main_rotor_static_jnt" );

    waittillframeend;

    if ( !armed( self.model, self.classname ) )
    {
        maps\_vehicle::mgoff();

        foreach ( var_1 in self.mgturret )
            var_1 hide();
    }

    thread vehicle_scripts\_littlebird_aud::handle_littlebird_audio();
    self.emp_death_function = ::littlebird_emp_death;
    maps\_utility::add_damage_function( ::littlebird_emp_damage_function );
}

show_blurry_rotors()
{
    if ( issubstr( self.classname, "sentinel" ) )
    {
        self hidepart( "main_rotor_static_jnt" );
        self showpart( "main_rotor_jnt" );
    }
}

show_static_rotors()
{
    if ( issubstr( self.classname, "sentinel" ) )
    {
        self showpart( "main_rotor_static_jnt" );
        self hidepart( "main_rotor_jnt" );
    }
}

attach_littlebird_parts()
{
    switch ( self.classname )
    {
        case "script_vehicle_littlebird_atlas_bench":
        case "script_vehicle_littlebird_sentinel_bench":
            self attach( "vehicle_sentinel_littlebird_benchleft", "TAG_BENCH_ATTACH_LEFT" );
            self attach( "vehicle_sentinel_littlebird_benchright", "TAG_BENCH_ATTACH_RIGHT" );
            break;
        default:
            break;
    }
}

set_vehicle_anims( var_0 )
{
    return var_0;
}

#using_animtree("generic_human");

setanims()
{
    level.scr_anim["generic"]["stage_littlebird_right"] = %little_bird_premount_guy3;
    level.scr_anim["generic"]["stage_littlebird_left"] = %little_bird_premount_guy3;
    var_0 = [];

    for ( var_1 = 0; var_1 < 8; var_1++ )
        var_0[var_1] = spawnstruct();

    var_0[0].sittag = "tag_pilot1";
    var_0[1].sittag = "tag_pilot2";
    var_0[2].sittag = "tag_detach_right";
    var_0[3].sittag = "tag_detach_right";
    var_0[4].sittag = "tag_detach_right";
    var_0[5].sittag = "tag_detach_left";
    var_0[6].sittag = "tag_detach_left";
    var_0[7].sittag = "tag_detach_left";
    var_0[0].idle[0] = %h2_helicopter_pilot1_idle;
    var_0[0].idle[1] = %h2_helicopter_pilot1_twitch_clickpannel;
    var_0[0].idle[2] = %h2_helicopter_pilot1_twitch_lookoutside;
    var_0[0].idle[3] = %h2_helicopter_pilot1_twitch_lookback;
    var_0[0].idleoccurrence[0] = 500;
    var_0[0].idleoccurrence[1] = 100;
    var_0[0].idleoccurrence[2] = 100;
    var_0[0].idleoccurrence[3] = 100;
    var_0[1].idle[0] = %h2_helicopter_pilot2_idle;
    var_0[1].idle[1] = %h2_helicopter_pilot2_twitch_clickpannel;
    var_0[1].idle[2] = %h2_helicopter_pilot2_twitch_lookoutside;
    var_0[1].idle[3] = %h2_helicopter_pilot2_twitch_radio;
    var_0[1].idleoccurrence[0] = 450;
    var_0[1].idleoccurrence[1] = 100;
    var_0[1].idleoccurrence[2] = 100;
    var_0[1].idleoccurrence[3] = 100;
    var_0[2].idle[0] = %little_bird_casual_idle_guy1;
    var_0[3].idle[0] = %little_bird_casual_idle_guy3;
    var_0[4].idle[0] = %little_bird_casual_idle_guy2;
    var_0[5].idle[0] = %little_bird_casual_idle_guy1;
    var_0[6].idle[0] = %little_bird_casual_idle_guy3;
    var_0[7].idle[0] = %little_bird_casual_idle_guy2;
    var_0[2].idleoccurrence[0] = 100;
    var_0[3].idleoccurrence[0] = 166;
    var_0[4].idleoccurrence[0] = 122;
    var_0[5].idleoccurrence[0] = 177;
    var_0[6].idleoccurrence[0] = 136;
    var_0[7].idleoccurrence[0] = 188;
    var_0[2].idle[1] = %little_bird_aim_idle_guy1;
    var_0[3].idle[1] = %little_bird_aim_idle_guy3;
    var_0[4].idle[1] = %little_bird_aim_idle_guy2;
    var_0[5].idle[1] = %little_bird_aim_idle_guy1;
    var_0[7].idle[1] = %little_bird_aim_idle_guy2;
    var_0[2].idleoccurrence[1] = 200;
    var_0[3].idleoccurrence[1] = 266;
    var_0[4].idleoccurrence[1] = 156;
    var_0[5].idleoccurrence[1] = 277;
    var_0[7].idleoccurrence[1] = 288;
    var_0[2].idle_alert = %little_bird_alert_idle_guy1;
    var_0[3].idle_alert = %little_bird_alert_idle_guy3;
    var_0[4].idle_alert = %little_bird_alert_idle_guy2;
    var_0[5].idle_alert = %little_bird_alert_idle_guy1;
    var_0[6].idle_alert = %little_bird_alert_idle_guy3;
    var_0[7].idle_alert = %little_bird_alert_idle_guy2;
    var_0[2].idle_alert_to_casual = %little_bird_alert_2_aim_guy1;
    var_0[3].idle_alert_to_casual = %little_bird_alert_2_aim_guy3;
    var_0[4].idle_alert_to_casual = %little_bird_alert_2_aim_guy2;
    var_0[5].idle_alert_to_casual = %little_bird_alert_2_aim_guy1;
    var_0[6].idle_alert_to_casual = %little_bird_alert_2_aim_guy3;
    var_0[7].idle_alert_to_casual = %little_bird_alert_2_aim_guy2;
    var_0[2].getout = %little_bird_dismount_guy1;
    var_0[3].getout = %little_bird_dismount_guy3;
    var_0[4].getout = %little_bird_dismount_guy2;
    var_0[5].getout = %little_bird_dismount_guy1;
    var_0[6].getout = %little_bird_dismount_guy3;
    var_0[7].getout = %little_bird_dismount_guy2;
    var_0[2].littlebirde_getout_unlinks = 1;
    var_0[3].littlebirde_getout_unlinks = 1;
    var_0[4].littlebirde_getout_unlinks = 1;
    var_0[5].littlebirde_getout_unlinks = 1;
    var_0[6].littlebirde_getout_unlinks = 1;
    var_0[7].littlebirde_getout_unlinks = 1;
    var_0[2].getin = %little_bird_mount_guy1;
    var_0[2].getin_enteredvehicletrack = "mount_finish";
    var_0[3].getin = %little_bird_mount_guy3;
    var_0[3].getin_enteredvehicletrack = "mount_finish";
    var_0[4].getin = %little_bird_mount_guy2;
    var_0[4].getin_enteredvehicletrack = "mount_finish";
    var_0[5].getin = %little_bird_mount_guy1;
    var_0[5].getin_enteredvehicletrack = "mount_finish";
    var_0[6].getin = %little_bird_mount_guy3;
    var_0[6].getin_enteredvehicletrack = "mount_finish";
    var_0[7].getin = %little_bird_mount_guy2;
    var_0[7].getin_enteredvehicletrack = "mount_finish";
    var_0[2].getin_idle_func = maps\_vehicle_aianim::guy_idle_alert;
    var_0[3].getin_idle_func = maps\_vehicle_aianim::guy_idle_alert;
    var_0[4].getin_idle_func = maps\_vehicle_aianim::guy_idle_alert;
    var_0[5].getin_idle_func = maps\_vehicle_aianim::guy_idle_alert;
    var_0[6].getin_idle_func = maps\_vehicle_aianim::guy_idle_alert;
    var_0[7].getin_idle_func = maps\_vehicle_aianim::guy_idle_alert;
    var_0[2].pre_unload = %little_bird_aim_2_prelanding_guy1;
    var_0[3].pre_unload = %little_bird_aim_2_prelanding_guy3;
    var_0[4].pre_unload = %little_bird_aim_2_prelanding_guy2;
    var_0[5].pre_unload = %little_bird_aim_2_prelanding_guy1;
    var_0[6].pre_unload = %little_bird_aim_2_prelanding_guy3;
    var_0[7].pre_unload = %little_bird_aim_2_prelanding_guy2;
    var_0[2].pre_unload_idle = %little_bird_prelanding_idle_guy1;
    var_0[3].pre_unload_idle = %little_bird_prelanding_idle_guy3;
    var_0[4].pre_unload_idle = %little_bird_prelanding_idle_guy2;
    var_0[5].pre_unload_idle = %little_bird_prelanding_idle_guy1;
    var_0[6].pre_unload_idle = %little_bird_prelanding_idle_guy3;
    var_0[7].pre_unload_idle = %little_bird_prelanding_idle_guy2;
    var_0[0].bhasgunwhileriding = 0;
    var_0[1].bhasgunwhileriding = 0;
    return var_0;
}

unload_groups()
{
    var_0 = [];
    var_0["first_guy_left"] = [];
    var_0["first_guy_right"] = [];
    var_0["left"] = [];
    var_0["right"] = [];
    var_0["passengers"] = [];
    var_0["default"] = [];
    var_0["first_guy_left"][0] = 5;
    var_0["first_guy_right"][0] = 2;
    var_0["stage_guy_left"][0] = 7;
    var_0["stage_guy_right"][0] = 4;
    var_0["left"][var_0["left"].size] = 5;
    var_0["left"][var_0["left"].size] = 6;
    var_0["left"][var_0["left"].size] = 7;
    var_0["right"][var_0["right"].size] = 2;
    var_0["right"][var_0["right"].size] = 3;
    var_0["right"][var_0["right"].size] = 4;
    var_0["passengers"][var_0["passengers"].size] = 2;
    var_0["passengers"][var_0["passengers"].size] = 3;
    var_0["passengers"][var_0["passengers"].size] = 4;
    var_0["passengers"][var_0["passengers"].size] = 5;
    var_0["passengers"][var_0["passengers"].size] = 6;
    var_0["passengers"][var_0["passengers"].size] = 7;
    var_0["default"] = var_0["passengers"];
    return var_0;
}

littlebird_emp_damage_function( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    if ( var_4 == "MOD_ENERGY" && isdefined( self.emp_death_function ) )
        self thread [[ self.emp_death_function ]]( var_1, var_4 );
}

littlebird_emp_death( var_0, var_1 )
{
    self endon( "death" );
    self endon( "in_air_explosion" );
    self notify( "emp_death" );
    maps\_vehicle::vehicle_lights_off( "all" );
    self.vehicle_stays_alive = 1;
    var_2 = self vehicle_getvelocity();
    var_3 = 250;

    if ( isdefined( level.get_littlebird_crash_location_override ) )
        var_4 = [[ level.get_littlebird_crash_location_override ]]();
    else
    {
        var_5 = ( self.origin[0] + var_2[0] * 5, self.origin[1] + var_2[1] * 5, self.origin[2] - 2000 );
        var_4 = bullettrace( self.origin, var_5, 0, self )["position"];
    }

    self notify( "newpath" );
    self notify( "deathspin" );
    thread littlebird_deathspin();
    var_6 = 1000;
    self vehicle_setspeed( var_6, 40, 1000 );
    self neargoalnotifydist( var_3 );
    self setvehgoalpos( var_4, 0 );
    thread littlebird_emp_crash_movement( var_4, var_3, var_6 );
    common_scripts\utility::waittill_any( "goal", "near_goal" );
    self notify( "stop_crash_loop_sound" );
    self notify( "crash_done" );
    self.alwaysrocketdeath = 1;
    self.enablerocketdeath = 1;
    maps\_vehicle_code::vehicle_kill_common( var_0, var_1 );

    if ( getdvar( "mapname" ) == "lab" )
        check_lab_achievement();

    self kill( self.origin, var_0 );
}

check_lab_achievement()
{
    if ( !isdefined( level.restricted_airspace ) )
        level.restricted_airspace = 0;

    level.restricted_airspace++;

    if ( level.restricted_airspace >= 10 )
        maps\_utility::giveachievement_wrapper( "LEVEL_10A" );
}

littlebird_deathspin()
{
    self endon( "crash_done" );
    self clearlookatent();
    self setyawspeed( 400, 100, 100 );

    for (;;)
    {
        if ( !isdefined( self ) )
            return;

        var_0 = randomintrange( 90, 120 );
        self settargetyaw( self.angles[1] + var_0 );
        wait 0.5;
    }
}

littlebird_emp_crash_movement( var_0, var_1, var_2 )
{
    self endon( "crash_done" );
    self clearlookatent();
    self setyawspeed( 400, 100, 100 );
    var_3 = 400;
    var_4 = 100;
    var_5 = undefined;
    var_6 = 90 * randomintrange( -2, 3 );

    for (;;)
    {
        if ( self.origin[2] < var_0[2] + var_1 )
            self notify( "near_goal" );

        wait 0.05;
    }
}

helicopter_crash_rotate()
{
    self endon( "crash_done" );
    self clearlookatent();
    self setyawspeed( 400, 100, 100 );

    for (;;)
    {
        if ( !isdefined( self ) )
            return;

        var_0 = randomintrange( 90, 120 );
        self settargetyaw( self.angles[1] + var_0 );
        wait 0.5;
    }
}
