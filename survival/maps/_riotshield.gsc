// H2 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

init_riotshield()
{
    if ( isdefined( level.riotshield_initialized ) )
        return;

    level.riotshield_initialized = 1;
    level._effect["riot_shield_dmg"] = loadfx( "fx/misc/riot_shield_dmg" );

    if ( !isdefined( level.subclass_spawn_functions ) )
        level.subclass_spawn_functions = [];

    level.subclass_spawn_functions["riotshield"] = ::subclass_riotshield;
    animscripts\riotshield\riotshield::init_riotshield_ai_anims();
}

subclass_riotshield()
{
    animscripts\riotshield\riotshield::init_riotshield_ai();
}

riotshield_sprint_on()
{
    animscripts\riotshield\riotshield::riotshield_sprint_on();
}

riotshield_fastwalk_on()
{
    animscripts\riotshield\riotshield::riotshield_fastwalk_on();
}

riotshield_sprint_off()
{
    animscripts\riotshield\riotshield::riotshield_sprint_off();
}

riotshield_fastwalk_off()
{
    animscripts\riotshield\riotshield::riotshield_fastwalk_off();
}

riotshield_flee()
{
    if ( self.subclass != "riotshield" )
        return;

    self.combatmode = "cover";
    self.goalradius = 2048;
    self._id_C8ED = undefined;
    animscripts\riotshield\riotshield::riotshield_init_flee();
    var_0 = self findbestcovernode();

    if ( isdefined( var_0 ) )
        self usecovernode( var_0 );
}

group_create( var_0, var_1, var_2 )
{
    var_3 = [];

    foreach ( var_5 in var_0 )
    {
        if ( var_5.combatmode != "no_cover" )
            continue;

        var_3[var_3.size] = var_5;
    }

    var_7 = spawnstruct();

    foreach ( var_5 in var_3 )
    {
        if ( isdefined( var_5.group ) && isdefined( var_5.group.ai_array ) )
            var_5.group.ai_array = common_scripts\utility::array_remove( var_5.group.ai_array, var_5 );

        var_5.group = var_7;
    }

    var_7.ai_array = var_3;
    var_7.fleethreshold = 1;
    var_7.spacing = 50;
    var_7 thread group_check_deaths();
    return var_7;
}

group_initialize_formation( var_0, var_1 )
{
    self.ai_array = maps\_utility::array_removedead( self.ai_array );
    self.forward = var_0;

    if ( isdefined( var_1 ) )
        self.spacing = var_1;

    foreach ( var_3 in self.ai_array )
    {
        var_3.goalradius = 25;
        var_3.meleechargedistsq = squared( 160 );
        var_3._id_C8ED = 1;
        var_3.pathenemyfightdist = 128;
        var_3.pathenemylookahead = 128;
    }

    group_sort_by_closest_match();
    thread check_group_facing_forward();
}

group_resort_on_deaths()
{
    self endon( "break_group" );

    if ( self.ai_array.size == 0 )
        return;

    while ( self.ai_array.size )
    {
        maps\_utility::waittill_dead( self.ai_array, 1 );

        if ( self.group_move_mode != "stopped" )
            self waittill( "goal" );

        self.ai_array = maps\_utility::array_removedead( self.ai_array );
        group_sort_by_closest_match();
    }
}

group_sort_by_closest_match( var_0 )
{
    if ( self.ai_array.size == 0 )
        return;

    if ( isdefined( var_0 ) )
        self.forward = var_0;
    else
        var_0 = self.forward;

    var_1 = group_center();
    var_2 = ( self.forward[1], -1 * self.forward[0], 0 );
    var_3 = var_2 * self.spacing;
    var_4 = group_left_corner( var_1, var_3 );
    var_5 = [];

    for ( var_6 = 0; var_6 < self.ai_array.size; var_6++ )
    {
        if ( isdefined( self.ai_array[var_6] ) )
        {
            var_5[var_6] = vectordot( var_4 - self.ai_array[var_6].origin, var_2 );
            continue;
        }

        var_5[var_6] = 0;
    }

    for ( var_6 = 1; var_6 < var_5.size; var_6++ )
    {
        var_7 = var_5[var_6];
        var_8 = self.ai_array[var_6];

        for ( var_9 = var_6 - 1; var_9 >= 0; var_9-- )
        {
            if ( var_7 < var_5[var_9] )
                break;

            var_5[var_9 + 1] = var_5[var_9];
            self.ai_array[var_9 + 1] = self.ai_array[var_9];
        }

        var_5[var_9 + 1] = var_7;
        self.ai_array[var_9 + 1] = var_8;
    }
}

group_check_deaths()
{
    for (;;)
    {
        if ( self.fleethreshold > 0 )
        {
            self.ai_array = maps\_utility::array_removedead( self.ai_array );

            if ( self.ai_array.size <= self.fleethreshold )
            {
                foreach ( var_1 in self.ai_array )
                    var_1 riotshield_flee();

                self notify( "break_group" );
                break;
            }
        }

        wait 1;
    }
}

group_left_corner( var_0, var_1 )
{
    return var_0 - ( self.ai_array.size - 1 ) / 2 * var_1;
}

group_move( var_0, var_1 )
{
    self notify( "new_goal_set" );
    self.group_move_mode = "moving";

    if ( isdefined( var_1 ) )
        self.forward = var_1;
    else
        var_1 = self.forward;

    var_2 = ( var_1[1], -1 * var_1[0], 0 );
    var_3 = var_2 * self.spacing;
    var_4 = group_left_corner( var_0, var_3 );

    for ( var_5 = 0; var_5 < self.ai_array.size; var_5++ )
    {
        var_6 = self.ai_array[var_5];

        if ( isdefined( var_6 ) )
            var_6 setgoalpos( var_4 );

        var_4 += var_3;
    }

    thread check_group_at_goal();
}

check_group_at_goal()
{
    self endon( "new_goal_set" );

    for (;;)
    {
        wait 0.5;
        var_0 = 0;

        foreach ( var_2 in self.ai_array )
        {
            if ( isdefined( var_2 ) && isalive( var_2 ) )
                var_0++;
        }

        var_4 = 0;

        for ( var_5 = 0; var_5 < self.ai_array.size; var_5++ )
        {
            var_2 = self.ai_array[var_5];

            if ( isdefined( var_2 ) )
            {
                var_6 = max( 45, var_2.goalradius );

                if ( distancesquared( var_2.origin, var_2.goalpos ) < squared( var_6 ) )
                    var_4++;
            }
        }

        if ( var_4 == var_0 )
        {
            self notify( "goal" );
            self.group_move_mode = "stopped";
        }
    }
}

check_group_facing_forward()
{
    self endon( "break_group" );

    for (;;)
    {
        wait 0.5;
        var_0 = 0;

        foreach ( var_2 in self.ai_array )
        {
            if ( isdefined( var_2 ) && isalive( var_2 ) )
                var_0++;
        }

        var_4 = 0;
        var_5 = vectortoyaw( self.forward );

        for ( var_6 = 0; var_6 < self.ai_array.size; var_6++ )
        {
            var_2 = self.ai_array[var_6];

            if ( isdefined( var_2 ) )
            {
                if ( abs( var_2.angles[1] - var_5 ) < 45 )
                    var_4++;
            }
        }

        if ( var_4 == var_0 )
            self notify( "goal_yaw" );
    }
}

group_sprint_on()
{
    foreach ( var_1 in self.ai_array )
    {
        if ( isalive( var_1 ) )
            var_1 riotshield_sprint_on();
    }
}

group_fastwalk_on()
{
    foreach ( var_1 in self.ai_array )
    {
        if ( isalive( var_1 ) )
            var_1 riotshield_fastwalk_on();
    }
}

group_sprint_off()
{
    foreach ( var_1 in self.ai_array )
    {
        if ( isalive( var_1 ) )
            var_1 riotshield_sprint_off();
    }
}

group_fastwalk_off()
{
    foreach ( var_1 in self.ai_array )
    {
        if ( isalive( var_1 ) )
            var_1 riotshield_fastwalk_off();
    }
}

group_lock_angles( var_0 )
{
    self.forward = var_0;
    var_1 = vectortoyaw( var_0 );

    foreach ( var_3 in self.ai_array )
    {
        if ( !isdefined( var_3 ) )
            continue;

        if ( isdefined( var_3.enemy ) && distancesquared( var_3.origin, var_3.enemy.origin ) < squared( var_3.pathenemyfightdist ) )
            continue;

        var_3 orientmode( "face angle", var_1 );
        var_3.lockorientation = 1;
    }

    wait 0.1;
}

group_unlock_angles()
{
    foreach ( var_1 in self.ai_array )
    {
        if ( !isdefined( var_1 ) )
            continue;

        var_1 orientmode( "face default" );
        var_1.lockorientation = 0;
    }
}

group_free_combat()
{
    group_unlock_angles();

    foreach ( var_1 in self.ai_array )
    {
        if ( !isdefined( var_1 ) )
            continue;

        var_1.goalradius = 2048;
        var_1.pathenemyfightdist = 400;
        var_1.pathenemylookahead = 400;
    }
}

group_center()
{
    var_0 = ( 0, 0, 0 );
    var_1 = 0;

    foreach ( var_3 in self.ai_array )
    {
        if ( isdefined( var_3 ) )
        {
            var_0 += var_3.origin;
            var_1++;
        }
    }

    if ( var_1 )
        var_0 = 1 / var_1 * var_0;

    return var_0;
}
