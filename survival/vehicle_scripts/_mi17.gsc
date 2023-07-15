// H2 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

main( var_0, var_1, var_2 )
{
    vehicle_scripts\_mi17_noai::main( var_0, "mi17", var_2 );
    maps\_vehicle::build_localinit( ::init_local );
    maps\_vehicle::build_treadfx();
    maps\_vehicle::build_aianims( ::setanims, ::set_vehicle_anims );
    maps\_vehicle::build_attach_models( ::set_attached_models );
    maps\_vehicle::build_unload_groups( ::unload_groups );
    maps\_vehicle::build_is_helicopter();
}

init_local()
{
    self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );
    self.fastropeoffset = 710;
    self.script_badplace = 0;
    maps\_vehicle::vehicle_lights_on( "running" );
    thread handle_audio();
    thread _id_B970();
}

_id_B970()
{
    while ( isdefined( self ) )
    {
        ragdollwakeup( self.origin, 300 );
        wait 0.05;
    }
}

handle_audio()
{
    self endon( "death" );
    var_0 = 0;
    var_1 = 12000;
    vehicle_scripts\_mi17_aud::snd_init_mi17();
    thread monitor_death_stop_sounds();

    if ( isdefined( level._id_CD2B ) )
        var_1 = level._id_CD2B;

    for (;;)
    {
        if ( !isdefined( self.script_disablevehicleaudio ) || !self.script_disablevehicleaudio )
        {
            var_2 = distance( self.origin, level.player.origin );

            if ( var_0 && var_2 > var_1 )
            {
                vehicle_scripts\_mi17_aud::snd_stop_mi17( 1.0 );
                var_0 = 0;
                wait 0.1;
            }
            else if ( !var_0 && var_2 < var_1 )
            {
                vehicle_scripts\_mi17_aud::snd_start_mi17();
                var_0 = 1;
            }
        }
        else if ( var_0 )
        {
            vehicle_scripts\_mi17_aud::snd_stop_mi17( 1.0 );
            var_0 = 0;
        }

        wait 0.1;
    }
}

monitor_death_stop_sounds()
{
    self waittill( "death" );
    vehicle_scripts\_mi17_aud::snd_stop_mi17( 1.0 );
}

#using_animtree("vehicles");

set_vehicle_anims( var_0 )
{
    for ( var_1 = 0; var_1 < var_0.size; var_1++ )
        var_0[var_1].vehicle_getoutanim = %mi17_heli_idle;

    return var_0;
}

setplayer_anims( var_0 )
{
    return var_0;
}

#using_animtree("generic_human");

setanims()
{
    var_0 = [];

    for ( var_1 = 0; var_1 < 10; var_1++ )
        var_0[var_1] = spawnstruct();

    var_0[1].idle = %mi17_1_idle;
    var_0[2].idle = %mi17_2_idle;
    var_0[3].idle = %mi17_3_idle;
    var_0[4].idle = %mi17_4_idle;
    var_0[5].idle = %mi17_5_idle;
    var_0[6].idle = %mi17_6_idle;
    var_0[7].idle = %mi17_7_idle;
    var_0[8].idle = %mi17_8_idle;
    var_0[0].idle[0] = %helicopter_pilot1_idle;
    var_0[0].idle[1] = %helicopter_pilot1_twitch_clickpannel;
    var_0[0].idle[2] = %helicopter_pilot1_twitch_lookback;
    var_0[0].idle[3] = %helicopter_pilot1_twitch_lookoutside;
    var_0[0].idleoccurrence[0] = 500;
    var_0[0].idleoccurrence[1] = 100;
    var_0[0].idleoccurrence[2] = 100;
    var_0[0].idleoccurrence[3] = 100;
    var_0[0].bhasgunwhileriding = 0;
    var_0[9].bhasgunwhileriding = 0;
    var_0[9].idle[0] = %helicopter_pilot2_idle;
    var_0[9].idle[1] = %helicopter_pilot2_twitch_clickpannel;
    var_0[9].idle[2] = %helicopter_pilot2_twitch_lookoutside;
    var_0[9].idle[3] = %helicopter_pilot2_twitch_radio;
    var_0[9].idleoccurrence[0] = 450;
    var_0[9].idleoccurrence[1] = 100;
    var_0[9].idleoccurrence[2] = 100;
    var_0[9].idleoccurrence[3] = 100;
    var_0[0].sittag = "tag_driver";
    var_0[1].sittag = "tag_detach";
    var_0[2].sittag = "tag_detach";
    var_0[3].sittag = "tag_detach";
    var_0[4].sittag = "tag_detach";
    var_0[5].sittag = "tag_detach";
    var_0[6].sittag = "tag_detach";
    var_0[7].sittag = "tag_detach";
    var_0[8].sittag = "tag_detach";
    var_0[9].sittag = "tag_passenger";
    var_0[1].getout = %mi17_1_drop;
    var_0[2].getout = %mi17_2_drop;
    var_0[3].getout = %mi17_3_drop;
    var_0[4].getout = %mi17_4_drop;
    var_0[5].getout = %mi17_5_drop;
    var_0[6].getout = %mi17_6_drop;
    var_0[7].getout = %mi17_7_drop;
    var_0[8].getout = %mi17_8_drop;
    var_0[1].getoutstance = "crouch";
    var_0[2].getoutstance = "crouch";
    var_0[3].getoutstance = "crouch";
    var_0[4].getoutstance = "crouch";
    var_0[5].getoutstance = "crouch";
    var_0[6].getoutstance = "crouch";
    var_0[7].getoutstance = "crouch";
    var_0[8].getoutstance = "crouch";
    var_0[1].ragdoll_getout_death = 1;
    var_0[2].ragdoll_getout_death = 1;
    var_0[3].ragdoll_getout_death = 1;
    var_0[4].ragdoll_getout_death = 1;
    var_0[5].ragdoll_getout_death = 1;
    var_0[6].ragdoll_getout_death = 1;
    var_0[7].ragdoll_getout_death = 1;
    var_0[8].ragdoll_getout_death = 1;
    var_0[1].ragdoll_fall_anim = %fastrope_fall;
    var_0[2].ragdoll_fall_anim = %fastrope_fall;
    var_0[3].ragdoll_fall_anim = %fastrope_fall;
    var_0[4].ragdoll_fall_anim = %fastrope_fall;
    var_0[5].ragdoll_fall_anim = %fastrope_fall;
    var_0[6].ragdoll_fall_anim = %fastrope_fall;
    var_0[7].ragdoll_fall_anim = %fastrope_fall;
    var_0[8].ragdoll_fall_anim = %fastrope_fall;
    var_0[1].rappel_kill_achievement = 1;
    var_0[2].rappel_kill_achievement = 1;
    var_0[3].rappel_kill_achievement = 1;
    var_0[4].rappel_kill_achievement = 1;
    var_0[5].rappel_kill_achievement = 1;
    var_0[6].rappel_kill_achievement = 1;
    var_0[7].rappel_kill_achievement = 1;
    var_0[8].rappel_kill_achievement = 1;
    var_0[1].getoutsnd = "fastrope_getout_npc";
    var_0[2].getoutsnd = "fastrope_getout_npc";
    var_0[3].getoutsnd = "fastrope_getout_npc";
    var_0[4].getoutsnd = "fastrope_getout_npc";
    var_0[5].getoutsnd = "fastrope_getout_npc";
    var_0[6].getoutsnd = "fastrope_getout_npc";
    var_0[7].getoutsnd = "fastrope_getout_npc";
    var_0[8].getoutsnd = "fastrope_getout_npc";
    var_0[1].getoutloopsnd = "fastrope_loop_npc";
    var_0[2].getoutloopsnd = "fastrope_loop_npc";
    var_0[3].getoutloopsnd = "fastrope_loop_npc";
    var_0[4].getoutloopsnd = "fastrope_loop_npc";
    var_0[5].getoutloopsnd = "fastrope_loop_npc";
    var_0[6].getoutloopsnd = "fastrope_loop_npc";
    var_0[7].getoutloopsnd = "fastrope_loop_npc";
    var_0[8].getoutloopsnd = "fastrope_loop_npc";
    var_0[1].fastroperig = "TAG_FastRope_RI";
    var_0[2].fastroperig = "TAG_FastRope_RI";
    var_0[3].fastroperig = "TAG_FastRope_RI";
    var_0[4].fastroperig = "TAG_FastRope_RI";
    var_0[5].fastroperig = "TAG_FastRope_LE";
    var_0[6].fastroperig = "TAG_FastRope_LE";
    var_0[7].fastroperig = "TAG_FastRope_LE";
    var_0[8].fastroperig = "TAG_FastRope_LE";
    return setplayer_anims( var_0 );
}

unload_groups()
{
    var_0 = [];
    var_0["back"] = [];
    var_0["front"] = [];
    var_0["both"] = [];
    var_0["back"][var_0["back"].size] = 1;
    var_0["back"][var_0["back"].size] = 2;
    var_0["back"][var_0["back"].size] = 3;
    var_0["back"][var_0["back"].size] = 4;
    var_0["front"][var_0["front"].size] = 5;
    var_0["front"][var_0["front"].size] = 6;
    var_0["front"][var_0["front"].size] = 7;
    var_0["front"][var_0["front"].size] = 8;
    var_0["both"][var_0["both"].size] = 1;
    var_0["both"][var_0["both"].size] = 2;
    var_0["both"][var_0["both"].size] = 3;
    var_0["both"][var_0["both"].size] = 4;
    var_0["both"][var_0["both"].size] = 5;
    var_0["both"][var_0["both"].size] = 6;
    var_0["both"][var_0["both"].size] = 7;
    var_0["both"][var_0["both"].size] = 8;
    var_0["default"] = var_0["both"];
    return var_0;
}

set_attached_models()
{
    var_0 = [];
    var_0["TAG_FastRope_LE"] = spawnstruct();
    var_0["TAG_FastRope_LE"].model = "rope_test";
    var_0["TAG_FastRope_LE"].tag = "TAG_FastRope_LE";
    var_0["TAG_FastRope_LE"].idleanim = %mi17_rope_idle_le;
    var_0["TAG_FastRope_LE"].dropanim = %mi17_rope_drop_le;
    var_0["TAG_FastRope_RI"] = spawnstruct();
    var_0["TAG_FastRope_RI"].model = "rope_test_ri";
    var_0["TAG_FastRope_RI"].tag = "TAG_FastRope_RI";
    var_0["TAG_FastRope_RI"].idleanim = %mi17_rope_idle_ri;
    var_0["TAG_FastRope_RI"].dropanim = %mi17_rope_drop_ri;
    var_1 = getarraykeys( var_0 );

    for ( var_2 = 0; var_2 < var_1.size; var_2++ )
        precachemodel( var_0[var_1[var_2]].model );

    return var_0;
}
