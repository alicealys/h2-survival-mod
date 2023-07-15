// H2 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

main( var_0, var_1, var_2 )
{
    maps\_vehicle::build_template( "ucav", var_0, var_1, var_2 );
    maps\_vehicle::build_localinit( ::init_local );
    maps\_vehicle::build_deathmodel( "vehicle_ucav" );
    level._effect["jettrail"] = loadfx( "fx/smoke/jet_contrail" );
    maps\_vehicle::build_deathfx( "fx/explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );
    maps\_vehicle::build_life( 999, 500, 1500 );
    maps\_vehicle::build_team( "allies" );
    maps\_vehicle::build_mainturret();
}

init_local()
{
    thread _id_B1DA();
    self.missiletags[0] = "tag_missile_left";
    self.missiletags[1] = "tag_missile_right";
    self.nextmissiletag = 0;
}

set_vehicle_anims( var_0 )
{
    return var_0;
}

setanims()
{
    var_0 = [];

    for ( var_1 = 0; var_1 < 1; var_1++ )
        var_0[var_1] = spawnstruct();

    return var_0;
}

_id_B1DA()
{
    playfxontag( level._effect["jettrail"], self, "TAG_JET_TRAIL" );
}

plane_sound_node()
{
    self waittill( "trigger", var_0 );
    var_0 endon( "death" );
    thread plane_sound_node();
    var_0 thread _id_AFE8();
}

_id_AFE8()
{
    self endon( "death" );
    self endon( "reached_end_node" );

    while ( !playerisclose( self, 1 ) )
        wait 0.05;

    thread maps\_utility::play_sound_on_entity( "veh_uav_flyby" );
}

playerisclose( var_0, var_1 )
{
    var_2 = playerisinfront( var_0 );

    if ( var_2 )
        var_3 = 1;
    else
        var_3 = -1;

    var_4 = common_scripts\utility::flat_origin( var_0.origin );
    var_5 = var_4 + anglestoforward( common_scripts\utility::flat_angle( var_0.angles ) ) * ( var_3 * 100000 );
    var_6 = pointonsegmentnearesttopoint( var_4, var_5, level.player.origin );
    var_7 = distance( var_4, var_6 );
    var_8 = 3000;

    if ( isdefined( var_1 ) && var_1 )
    {
        var_9 = var_0 vehicle_getspeed();
        var_10 = var_9 * 63360 / 3600;
        var_8 = var_10 * 4.1;
    }

    return var_7 < var_8;
}

playerisinfront( var_0 )
{
    var_1 = anglestoforward( common_scripts\utility::flat_angle( var_0.angles ) );
    var_2 = vectornormalize( common_scripts\utility::flat_origin( level.player.origin ) - var_0.origin );
    var_3 = vectordot( var_1, var_2 );

    if ( var_3 > 0 )
        return 1;
    else
        return 0;
}

_id_ABF8()
{
    self waittill( "trigger", var_0 );
    var_0 endon( "death" );
    thread _id_ABF8();
    var_0 setvehweapon( "ucav_sidewinder" );
    var_1 = common_scripts\utility::get_linked_ent();
    var_0 fireweapon( var_0.missiletags[var_0.nextmissiletag], var_1, ( 0, 0, 0 ) );
    var_0.nextmissiletag++;

    if ( var_0.nextmissiletag >= var_0.missiletags.size )
        var_0.nextmissiletag = 0;
}
