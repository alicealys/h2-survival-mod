// H2 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

setup_remote_missile_target()
{
    if ( !isdefined( level._id_BD18 ) )
        level._id_BD18 = [];

    level._id_BD18[self.unique_id] = self;

    if ( isdefined( level._id_B981._id_B34B ) && !isdefined( level._id_B1DF ) )
    {
        level endon( "draw_target_end" );

        while ( isdefined( level._id_C0D8 ) && level._id_C0D8 == gettime() )
            wait 0.05;

        level._id_C0D8 = gettime();

        if ( isalive( self ) )
            _id_C630::_id_C1B7();
    }

    self waittill( "death" );
    level._id_BD18[self.unique_id] = undefined;

    if ( !isdefined( self ) )
        return;

    if ( isdefined( self._id_C192 ) )
    {
        self._id_C192 = undefined;
        target_remove( self );
    }
}

player_uav_rig()
{
    if ( isdefined( level.uavrig ) )
        return level.uavrig;

    var_0 = _id_C630::_id_CE9C();
    return var_0;
}

create_uav_rigs( var_0 )
{
    foreach ( var_2 in level.players )
    {
        var_3 = common_scripts\utility::spawn_tag_origin();
        var_3.origin = self.origin;
        var_3._id_C176 = self;
        var_3 thread _id_C630::_id_D0F3( var_0, var_2 );
        var_2 add_player_rig( var_3 );
        var_2 thread _id_C630::_id_B922();
    }
}

add_player_rig( var_0 )
{
    if ( !isdefined( self._id_D456 ) )
        self._id_D456 = [];

    self._id_D456[self._id_D456.size] = var_0;
}

give_player_remote_missiles()
{
    self giveweapon( "remote_missile_detonator" );
    self.remotemissile_actionslot = 4;
    thread remotemissile_with_autoreloading();
    common_scripts\utility::flag_clear( "predator_missile_launch_allowed" );
    self setactionslot( self.remotemissile_actionslot, "weapon", "remote_missile_detonator" );
}

remotemissile_reload()
{
    level endon( "stop_uav_reload" );
    level endon( "special_op_terminated" );

    if ( common_scripts\utility::flag( "uav_reloading" ) )
    {
        if ( isdefined( level._id_B1DF ) )
            return;

        _id_C630::_id_CB86();

        if ( common_scripts\utility::flag( "uav_collecting_stats" ) )
        {
            level waittill( "uav_collecting_stats" );
            _id_C630::_id_AA28();
        }

        if ( isdefined( level._id_B1DF ) )
            return;

        level._id_B27A = undefined;

        if ( common_scripts\utility::flag( "uav_reloading" ) )
            level waittill( "uav_reloading" );

        if ( isdefined( level._id_B1DF ) )
            return;

        if ( !common_scripts\utility::flag( "uav_enabled" ) )
            return;

        if ( self getweaponammoclip( self._id_C277 ) < 1 )
        {
            _id_C630::_id_C563();
            return;
        }

        _id_C630::_id_B802();
        thread _id_C630::_id_CBA7( "uav_online" );
        thread _id_C630::_id_AF62();
    }
}

remotemissile_with_autoreloading()
{
    _id_C630::_id_BA47( ::remotemissile_reload );
}

remotemissile_no_autoreload()
{
    _id_C630::_id_BA47();
}

remotemissile_move_player()
{
    return isdefined( level._id_D592 );
}
