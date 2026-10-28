// H2 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

init_littlebird_landing()
{
    if ( isdefined( level.little_bird_landing_init ) )
        return;

    level.little_bird_landing_init = 1;
    thread init_littlebird_landing_thread();
}

init_littlebird_landing_thread()
{
    waittillframeend;
    common_scripts\utility::array_thread( common_scripts\utility::getstructarray( "gag_stage_littlebird_unload", "script_noteworthy" ), ::setup_gag_stage_littlebird_unload );
    common_scripts\utility::array_thread( common_scripts\utility::getstructarray( "gag_stage_littlebird_load", "script_noteworthy" ), ::setup_gag_stage_littlebird_load );
}

littlebird_landing()
{
    self endon( "death" );
    maps\_utility::ent_flag_init( "prep_unload" );
    maps\_utility::ent_flag_wait( "prep_unload" );
    maps\_vehicle_code::turn_unloading_drones_to_ai();
    var_0 = get_landing_node();
    var_0 littlebird_lands_and_unloads( self );
    maps\_vehicle::vehicle_paths( var_0 );
}

setup_gag_stage_littlebird_unload()
{
    for (;;)
    {
        self waittill( "trigger", var_0 );
        littlebird_lands_and_unloads( var_0 );
    }
}

setup_gag_stage_littlebird_load()
{
    for (;;)
    {
        self waittill( "trigger", var_0 );
        var_0 setdeceleration( 6 );
        var_0 setacceleration( 4 );
        var_0 settargetyaw( self.angles[1] );
        var_0 vehicle_setspeed( 20, 7, 7 );

        while ( distance( common_scripts\utility::flat_origin( var_0.origin ), common_scripts\utility::flat_origin( self.origin ) ) > 256 )
            wait 0.05;

        var_0 endon( "death" );
        var_0 thread vehicle_land_beneath_node( 220, self );
        var_0 waittill( "near_goal" );
        var_0 vehicle_setspeed( 20, 22, 7 );
        var_0 thread vehicle_land_beneath_node( 16, self );
        var_0 waittill( "near_goal" );
        var_0 maps\_vehicle_code::waittill_stable();
        var_0 notify( "touch_down", self );
        var_0 vehicle_setspeed( 20, 8, 7 );
    }
}

littlebird_lands_and_unloads( var_0 )
{
    var_0 setdeceleration( 6 );
    var_0 setacceleration( 4 );
    var_0 settargetyaw( self.angles[1] );
    var_0 vehicle_setspeed( 20, 7, 7 );

    while ( distance( common_scripts\utility::flat_origin( var_0.origin ), common_scripts\utility::flat_origin( self.origin ) ) > 512 )
        wait 0.05;

    var_0 endon( "death" );
    var_1 = "landing" + randomint( 99999 );
    badplace_cylinder( var_1, 30, self.origin, 200, 300, "axis", "allies", "neutral", "team3" );
    var_0 thread vehicle_land_beneath_node( 424, self );
    var_0 waittill( "near_goal" );
    badplace_delete( var_1 );
    badplace_cylinder( var_1, 30, self.origin, 200, 300, "axis", "allies", "neutral", "team3" );
    var_0 notify( "groupedanimevent", "pre_unload" );
    var_0 thread maps\_vehicle_aianim::animate_guys( "pre_unload" );
    var_0 vehicle_setspeed( 20, 22, 7 );
    var_0 notify( "nearing_landing" );

    if ( isdefined( var_0.custom_landing ) )
    {
        switch ( var_0.custom_landing )
        {
            case "hover_then_land":
                var_0 vehicle_setspeed( 10, 22, 7 );
                var_0 thread vehicle_land_beneath_node( 32, self, 64 );
                var_0 waittill( "near_goal" );
                var_0 notify( "hovering" );
                wait 1;
                break;
            default:
                break;
        }
    }

    var_0 thread vehicle_land_beneath_node( 16, self );
    var_0 waittill( "near_goal" );
    badplace_delete( var_1 );
    maps\_utility::script_delay();
    var_0 maps\_vehicle::vehicle_unload();
    var_0 maps\_vehicle_code::waittill_stable();
    var_0 vehicle_setspeed( 20, 8, 7 );
    wait 0.2;
    var_0 notify( "stable_for_unlink" );
    wait 0.2;

    if ( isdefined( self.script_flag_set ) )
        common_scripts\utility::flag_set( self.script_flag_set );

    if ( isdefined( self.script_flag_wait ) )
        common_scripts\utility::flag_wait( self.script_flag_wait );

    var_0 notify( "littlebird_liftoff" );
}

get_landing_node()
{
    var_0 = self.currentnode;

    for (;;)
    {
        var_1 = maps\_utility::getent_or_struct( var_0.target, "targetname" );

        if ( isdefined( var_1.script_unload ) )
            return var_1;

        var_0 = var_1;
    }
}

vehicle_land_beneath_node( var_0, var_1, var_2 )
{
    if ( !isdefined( var_2 ) )
        var_2 = 0;

    self notify( "newpath" );

    if ( !isdefined( var_0 ) )
        var_0 = 2;

    self neargoalnotifydist( var_0 );
    self sethoverparams( 0, 0, 0 );
    self cleargoalyaw();
    self settargetyaw( common_scripts\utility::flat_angle( var_1.angles )[1] );
    maps\_vehicle_code::_setvehgoalpos_wrap( maps\_utility::groundpos( var_1.origin ) + ( 0, 0, var_2 ), 1 );
    self waittill( "goal" );
}
