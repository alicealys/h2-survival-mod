// H2 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

#using_animtree("vehicles");

main( var_0, var_1, var_2 )
{
    maps\_vehicle::build_template( "mi17_noai", var_0, var_1, var_2 );
    maps\_vehicle::build_localinit( ::init_local );
    maps\_vehicle::build_deathmodel( "vehicle_mi17_woodland" );
    maps\_vehicle::build_deathmodel( "vehicle_mi17_woodland_fly" );
    maps\_vehicle::build_deathmodel( "vehicle_mi17_woodland_fly_cheap" );
    var_3 = [];
    var_3["vehicle_mi17_woodland"] = "fx/explosions/helicopter_explosion_mi17_woodland";
    var_3["vehicle_mi17_woodland_fly"] = "fx/explosions/helicopter_explosion_mi17_woodland_low";
    var_3["vehicle_mi17_woodland_fly_cheap"] = "fx/explosions/helicopter_explosion_mi17_woodland_low";
    var_3["vehicle_mi-28_flying"] = "fx/explosions/helicopter_explosion_mi17_woodland_low";
    maps\_vehicle::build_deathfx( "vfx/fire/fire_helicopter_engine", "tag_engine_right", undefined, 1, undefined, undefined, 1.05, 1 );
    maps\_vehicle::build_deathfx( "vfx/fire/fire_helicopter_engine", "tag_engine_left", undefined, 1, 1.05, undefined, 1.05, 1 );
    maps\_vehicle::build_deathfx( "vfx/explosion/vehicle_mi17_flames_crashing_runner", "tag_deathfx", "mi17_helicopter_dying_loop", 1, 1.05, 1, 0.0, 1 );
    maps\_vehicle::build_deathfx( "vfx/explosion/vehicle_mi17_smoke_crashing_runner", "tag_deathfx", undefined, 1, 1.05, undefined, 3.5, 1 );
    maps\_vehicle::build_deathfx( "vfx/explosion/vehicle_mi17_aerial_explosion", "tag_deathfx", "mi17_helicopter_hit", undefined, undefined, undefined, 0.05, 1 );
    maps\_vehicle::build_deathfx( "vfx/explosion/vehicle_mi17_aerial_second_explosion", "tag_deathfx", "mi17_helicopter_secondary_exp", undefined, undefined, undefined, 3.5, 1 );
    maps\_vehicle::build_deathfx( var_3[var_0], undefined, "mi17_helicopter_crash", undefined, undefined, undefined, -1, undefined, "stop_crash_loop_sound" );
    maps\_vehicle::build_drive( %mi17_heli_rotors, undefined, 0 );
    maps\_vehicle::build_treadfx();
    maps\_vehicle::build_life( 999, 500, 1500 );
    maps\_vehicle::build_rumble( "tank_rumble", 0.15, 4.5, 600, 1, 1 );
    maps\_vehicle::build_team( "axis" );
    maps\_vehicle::build_light( var_2, "cockpit_blue_cargo01", "tag_light_cargo01", "fx/misc/aircraft_light_cockpit_red", "interior", 0.0 );
    maps\_vehicle::build_light( var_2, "cockpit_blue_cockpit01", "tag_light_cockpit01", "fx/misc/aircraft_light_cockpit_blue", "interior", 0.1 );
    maps\_vehicle::build_light( var_2, "white_blink", "tag_light_belly", "fx/misc/aircraft_light_white_blink", "running", 0.0 );
    maps\_vehicle::build_light( var_2, "white_blink_tail", "tag_light_tail", "fx/misc/aircraft_light_red_blink", "running", 0.3 );
    maps\_vehicle::build_light( var_2, "wingtip_green", "tag_light_L_wing", "fx/misc/aircraft_light_wingtip_green", "running", 0.0 );
    maps\_vehicle::build_light( var_2, "wingtip_red", "tag_light_R_wing", "fx/misc/aircraft_light_wingtip_red", "running", 0.0 );
    maps\_vehicle::build_is_helicopter();
    _id_B995();
}

init_local()
{
    self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );
    self.fastropeoffset = 710;
    self.script_badplace = 0;
    maps\_vehicle::vehicle_lights_on( "running" );
    maps\_vehicle::vehicle_lights_on( "interior" );
}

_id_B995()
{
    var_0 = spawnstruct();
    var_0.anims = [];
    var_0.anims = common_scripts\utility::array_add( var_0.anims, %mi17_heli_hitreact_flyin_01 );
    var_0.anims = common_scripts\utility::array_add( var_0.anims, %mi17_heli_hitreact_flyin_02 );
    var_0._id_D138 = 1;
    maps\_vehicle::build_deathanim( var_0 );
    var_1 = spawnstruct();
    var_1.anims = [];
    var_1.anims = common_scripts\utility::array_add( var_1.anims, %mi17_heli_hitreact_front );
    var_1.anims = common_scripts\utility::array_add( var_1.anims, %mi17_heli_hitreact_rear );
    var_1.anims = common_scripts\utility::array_add( var_1.anims, %mi17_heli_hitreact_left );
    var_1.anims = common_scripts\utility::array_add( var_1.anims, %mi17_heli_hitreact_right );
    var_1._id_B814 = 1;
    var_1._id_D138 = 1;
    maps\_vehicle::build_deathanim( var_1, "unloading" );
    var_2 = spawnstruct();
    var_2.anims = [];
    var_2.anims = common_scripts\utility::array_add( var_2.anims, %mi17_heli_hitreact_left );
    var_2.anims = common_scripts\utility::array_add( var_2.anims, %mi17_heli_hitreact_right );
    var_2._id_B814 = 1;
    var_2._id_D138 = 1;
    maps\_vehicle::build_deathanim( var_2, "unloaded" );
}
