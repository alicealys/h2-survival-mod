main()
{
    replacefunc(maps\_load::init_level_players, ::init_level_players_stub);
    replacefunc(maps\_load::weapon_ammo, ::weapon_ammo);
    replacefunc(maps\_spawner::spawn_team_axis, ::spawn_team_axis);
    replacefunc(maps\_player_stats::register_kill, ::register_kill);
    replacefunc(_id_C630::init, ::remotemissile_init);
    replacefunc(maps\_spawner::deathfunctions, ::deathfunctions);
    replacefunc(soundscripts\_snd_common::player_death, ::player_death);
}

player_death()
{
    level notify("kill_deaths_door_audio");
    soundscripts\_audio_mix_manager::mm_clear_submix("deaths_door");
    soundscripts\_snd_playsound::snd_play_2d("bullet_large_fatal");
}

weapon_ammo()
{
    maps\_specialops::specialops_init();

    var_0 = getentarray();

    for ( var_1 = 0; var_1 < var_0.size; var_1++ )
    {
        if ( isdefined( var_0[var_1].classname ) && getsubstr( var_0[var_1].classname, 0, 7 ) == "weapon_" )
        {
            var_2 = var_0[var_1];
            var_3 = getsubstr( var_2.classname, 7 );

            if ( ( issubstr( var_3, "_akimbo" ) || var_2 _meth_85C4() ) && ( !isdefined( var_2.script_noteworthy ) || var_2.script_noteworthy != "no_akimbo_model" ) )
            {
                var_4 = common_scripts\utility::ter_op( maps\_utility::hastag( var_2.model, "TAG_AKIMBO" ), "TAG_AKIMBO", "TAG_FLASH" );
                var_2 attach( var_2.model, var_4 );
            }

            if ( isdefined( var_2.script_ammo_max ) )
            {
                var_5 = weaponclipsize( var_3 );
                var_6 = weaponmaxammo( var_3 );
                var_2 itemweaponsetammo( var_5, var_6, var_5, 0 );
                var_7 = weaponaltweaponname( var_3 );

                if ( var_7 != "none" )
                {
                    var_8 = weaponclipsize( var_7 );
                    var_9 = weaponmaxammo( var_7 );
                    var_2 itemweaponsetammo( var_8, var_9, var_8, 1 );
                }

                continue;
            }

            var_10 = 0;
            var_5 = undefined;
            var_11 = undefined;
            var_12 = 0;
            var_13 = undefined;
            var_14 = undefined;

            if ( isdefined( var_2.script_ammo_clip ) )
            {
                var_5 = var_2.script_ammo_clip;
                var_10 = 1;
            }

            if ( isdefined( var_2.script_ammo_extra ) )
            {
                var_11 = var_2.script_ammo_extra;
                var_10 = 1;
            }

            if ( isdefined( var_2.script_ammo_alt_clip ) )
            {
                var_13 = var_2.script_ammo_alt_clip;
                var_12 = 1;
            }

            if ( isdefined( var_2.script_ammo_alt_extra ) )
            {
                var_14 = var_2.script_ammo_alt_extra;
                var_12 = 1;
            }

            if ( var_10 )
            {
                if ( !isdefined( var_5 ) )
                {

                }

                if ( !isdefined( var_11 ) )
                {

                }

                var_2 itemweaponsetammo( var_5, var_11 );
            }

            if ( var_12 )
            {
                if ( !isdefined( var_13 ) )
                {

                }

                if ( !isdefined( var_14 ) )
                {

                }

                var_2 itemweaponsetammo( var_13, var_14, 0, 1 );
            }
        }
    }
}

remotemissile_init()
{
    level.no_friendly_fire_splash_damage = 1;

    if ( !isdefined( level._id_C60F ) )
        level._id_C60F = 12000;

    if ( !isdefined( level._id_BD18 ) )
        level._id_BD18 = [];

    level._id_C7B9 = 0 - level._id_C60F;
    level._id_B00B = 0;
    level._id_ABDD = 0;
    precacheitem( "remote_missile_detonator" );

    if ( isdefined( level._id_A96C ) )
        precacheitem( level._id_A96C );
    else
        precacheitem( "remote_missile" );

    precacheshader( "veh_hud_target" );
    precacheshader( "veh_hud_target_colorblind" );
    precacheshader( "veh_hud_target_offscreen" );
    precacheshader( "veh_hud_missile_flash" );
    precacheshader( "ac130_overlay_grain" );
    precacheshader( "remotemissile_infantry_target" );
    precacheshader( "remotemissile_infantry_target_2plr" );
    precacheshader( "remotemissile_infantry_target_colorblind" );
    precacheshader( "hud_fofbox_self_sp" );
    precacheshader( "hud_fofbox_self_sp_colorblind" );
    precacheshader( "dpad_killstreak_hellfire_missile_inactive" );
    precacheshader( "h2_overlays_predator_reticle" );
    precacheshellshock( "remoteMissile" );
    precachestring( &"HELLFIRE_DRONE_VIEW" );
    precachestring( &"HELLFIRE_MISSILE_VIEW" );
    precachestring( &"HELLFIRE_FIRE" );
    precachestring( &"HELLFIRE_BOOST_PROMPT" );
    precachestring( &"HELLFIRE_CANCEL_PROMPT" );
    precachestring( &"HELLFIRE_CANCEL_PROMPT_PC" );
    precachestring( &"CANCEL_PROMPT_WITH_CLAYMORE_PC" );
    _id_C630::_id_CBAA();
    level._id_B981 = spawnstruct();
    level._id_B981._id_B23A = 4;
    common_scripts\utility::flag_init( "predator_missile_launch_allowed" );
    common_scripts\utility::flag_set( "predator_missile_launch_allowed" );
    maps\_utility::add_hint_string( "hint_predator_drone_destroyed", &"HELLFIRE_DESTROYED", _id_C630::_id_A87C, undefined, "small_background" );
    maps\_utility::add_hint_string( "hint_predator_drone_4", &"HELLFIRE_USE_DRONE", _id_C630::_id_BEDE, undefined, "medium_background" );
    maps\_utility::add_hint_string( "hint_predator_drone_2", &"HELLFIRE_USE_DRONE_2", _id_C630::_id_BEDE, undefined, "medium_background" );
    maps\_utility::add_hint_string( "hint_predator_drone_not_available", &"HELLFIRE_DRONE_NOT_AVAILABLE", _id_C630::_id_BDEB, undefined, "small_background" );

    if ( isdefined( level._id_CAAA ) && level._id_CAAA )
        visionsetmissilecam( "missilecam" );
    else if ( !isdefined( level._id_A91C ) )
        visionsetmissilecam( "missilecam" );
    else
        visionsetmissilecam( level._id_A91C );

    setsaveddvar( "missileRemoteSpeedUp", "1000" );
    setsaveddvar( "missileRemoteSpeedTargetRange", "6000 12000" );
    maps\_utility::add_global_spawn_function( "axis", _id_C630::_id_AAF5 );
    common_scripts\utility::flag_init( "uav_reloading" );
    common_scripts\utility::flag_init( "uav_collecting_stats" );
    common_scripts\utility::flag_init( "uav_enabled" );
    common_scripts\utility::flag_set( "uav_enabled" );

    foreach ( var_1 in level.players )
        var_1 maps\_utility::ent_flag_init( "controlling_UAV" );

    level._id_C005 = 10;
}

deathfunctions()
{
    self waittill( "death", attacker, cause, weapon );
    level notify( "ai_killed", self );

    if ( !isdefined( self ) )
        return;

    if (isdefined(weapon) && weapon == "ac130_40mm_air_support_strobe")
    {
        attacker = level.player;
    }

    if ( isdefined( attacker ) )
    {

        if ( self.team == "axis" || self.team == "team3" )
        {
            var_3 = undefined;

            if ( isdefined( attacker.attacker ) )
            {
                if ( isdefined( attacker.issentrygun ) && attacker.issentrygun )
                    var_3 = "sentry";

                if ( isdefined( attacker.destructible_type ) )
                    var_3 = "destructible";

                attacker = attacker.attacker;
            }
            else if ( isdefined( attacker.owner ) )
            {
                if ( isai( attacker ) && isplayer( attacker.owner ) )
                    var_3 = "friendly";

                attacker = attacker.owner;
            }
            else if ( isdefined( attacker.damageowner ) )
            {
                if ( isdefined( attacker.destructible_type ) )
                    var_3 = "destructible";

                attacker = attacker.damageowner;
            }

            maps\_spawner::_id_D451( attacker, weapon, cause );
            validattacker = false;

            if ( isplayer( attacker ) )
            {
                validattacker = true;
            }

            if ( isdefined( level.pmc_match ) && level.pmc_match )
                validattacker = true;

            if ( validattacker )
                attacker maps\_player_stats::register_kill( self, cause, weapon, var_3 );
        }
    }

    for ( var_5 = 0; var_5 < self.deathfuncs.size; var_5++ )
    {
        var_6 = self.deathfuncs[var_5];

        switch ( var_6["params"] )
        {
            case 0:
                [[ var_6["func"] ]]( attacker );
                break;
            case 1:
                [[ var_6["func"] ]]( attacker, var_6["param1"] );
                break;
            case 2:
                [[ var_6["func"] ]]( attacker, var_6["param1"], var_6["param2"] );
                break;
            case 3:
                [[ var_6["func"] ]]( attacker, var_6["param1"], var_6["param2"], var_6["param3"] );
                break;
        }
    }
}

register_kill( var_0, var_1, var_2, var_3 )
{
    var_4 = self;
    var_5 = 0;

    if ( isdefined( self.owner ) )
        var_4 = self.owner;

    if ( !isplayer( var_4 ) )
    {
        if ( isdefined( level.pmc_match ) && level.pmc_match )
            var_4 = level.players[randomint( level.players.size )];
    }

    if ( !isplayer( var_4 ) )
        return;

    if ( isdefined( level.skip_pilot_kill_count ) && isdefined( var_0.drivingvehicle ) && var_0.drivingvehicle )
        return;

    var_4.stats["kills"]++;
    var_4 maps\_player_stats::career_stat_increment( "kills", 1 );

    var_7 = level.missionsettings maps\_endmission::getlevelindex( level.script );

    if ( isdefined( var_7 ) )
    {
        var_8 = level.player getplayerdata( common_scripts\utility::_id_AC0E(), "career", "campaign", level.gameskill, "levels", level.script, "current_playtrough_kills" );

        if ( isdefined( var_8 ) )
        {
            var_8++;
            level.player setplayerdata( common_scripts\utility::_id_AC0E(), "career", "campaign", level.gameskill, "levels", level.script, "current_playtrough_kills", var_8 );
        }
    }

    //if ( maps\_utility::is_specialop() )
    level notify( "specops_player_kill", var_4, var_0, var_2, var_3 );

    if ( isdefined( var_0 ) )
    {
        if ( var_0 maps\_player_stats::was_headshot() && var_1 != "MOD_MELEE" && var_1 != "MOD_MELEE_ALT" )
        {
            var_4.stats["headshots"]++;
            var_4 maps\_player_stats::career_stat_increment( "headshots", 1 );
            var_5 = 1;
        }

        if ( isdefined( var_0.juggernaut ) )
        {
            var_4.stats["kills_juggernaut"]++;
            var_4 maps\_player_stats::career_stat_increment( "kills_juggernaut", 1 );
        }

        if ( isdefined( var_0.issentrygun ) )
            var_4.stats["kills_sentry"]++;

        if ( var_0.code_classname == "script_vehicle" )
        {
            var_4.stats["kills_vehicle"]++;

            if ( var_4 maps\_player_stats::should_register_kills_for_vehicle_occupants() )
            {
                if ( isdefined( var_0.riders ) )
                {
                    foreach ( var_10 in var_0.riders )
                    {
                        if ( isdefined( var_10 ) )
                            var_4 register_kill( var_10, var_1, var_2, var_3 );
                    }
                }
            }
        }
    }

    var_12 = 0;

    if ( maps\_player_stats::cause_is_explosive( var_1 ) )
    {
        var_4.stats["kills_explosives"]++;
        var_12 = 1;
    }

    if ( maps\_player_stats::cause_is_grenade( var_1, var_2 ) && ( !isdefined( var_4.mechdata ) || !isdefined( var_4.mechdata.active ) || !var_4.mechdata.active ) )
    {
        var_4.stats["kills_grenades"]++;
        var_4 maps\_player_stats::stat_notify( "kills_grenades", 1 );
        var_12 = 1;
    }

    if ( !isdefined( var_2 ) )
        var_2 = var_4 getcurrentweapon();

    if ( issubstr( tolower( var_1 ), "melee" ) )
    {
        var_4.stats["kills_melee"]++;

        if ( weaponinventorytype( var_2 ) == "primary" )
            return;
    }

    if ( var_4 maps\_player_stats::is_new_weapon( var_2 ) )
        var_4 maps\_player_stats::register_new_weapon( var_2 );

    var_4.stats["weapon"][var_2].kills++;
    var_4.stats["career_kills_total"]++;

    if ( !var_12 )
        maps\_sp_matchdata::increment_kill( var_2, var_5 );
}

init_level_players_stub()
{
    init_level_players();
    maps\_laststand::main();
}

init_level_players()
{
    level.players = getentarray( "player", "classname" );

    for ( var_0 = 0; var_0 < level.players.size; var_0++ )
        level.players[var_0].unique_id = "player" + var_0;

    level.player = level.players[0];

    if ( level.players.size > 1 )
        level.player2 = level.players[1];

    foreach ( var_2 in level.players )
    {
        var_2.weapon_snd = spawn( "script_origin", ( 0, 0, 0 ) );
        var_2 _meth_85CD( var_2.weapon_snd );
    }

    level notify( "level.players initialized" );

    foreach ( var_2 in level.players )
    {
        var_2 thread maps\_load::recon_player();

        if ( maps\_utility::is_specialop() )
            var_2 thread maps\_load::recon_player_downed();
    }
}

spawn_team_axis()
{
	if ( isdefined( level.xp_enable ) && level.xp_enable )
    {
		self thread maps\_rank::ai_xp_init();
    }

    if ( self.type == "human" && !isdefined( level.disablegeardrop ) )
        thread maps\_spawner::drop_gear();

    maps\_utility::add_damage_function( maps\_gameskill::auto_adjust_enemy_death_detection );

    if ( isdefined( self.script_combatmode ) )
        self.combatmode = self.script_combatmode;
}
