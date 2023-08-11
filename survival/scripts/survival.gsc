main()
{
    replacefunc(maps\_utility::musiclength, ::music_length);
    replacefunc(maps\_load::ammo_cache_think_global, ::nullsub);
    replacefunc(_id_D2A4::h2_sentry_pickup, ::h2_sentry_pickup);

    common_scripts\utility::array_thread(getentarray("ammo_cache", "targetname"), ::delete);

    intel = getentarray("intelligence_item", "targetname");
    foreach (i in intel)
    {
        getent(i.target, "targetname") delete();
        i delete();
    }

    replacefunc(maps\_gameskill::should_show_cover_warning, ::ret_false);
    replacefunc(maps\_load::_id_B3AD, ::_id_B3AD);
    level.custom_gameskill_func = maps\_gameskill::solo_player_in_special_ops;

    replacefunc(maps\_utility::is_specialop, ::ret_true);
    replacefunc(_id_D2A4::is_specialop, ::ret_true);
    replacefunc(maps\_utility::is_survival, ::ret_true);
    replacefunc(_id_D2A4::is_survival, ::ret_true);
}

_id_B3AD()
{
    ents = getentarray();

    if (!isdefined(ents))
    {
        return;
    }

    foreach (ent in ents)
    {
        if (ent maps\_load::_id_B92E(true))
        {
            ent delete();
        }
    }

    maps\_load::_id_B29C();
}

ret_false()
{
    return false;
}

ret_true()
{
    return true;
}

nullsub()
{

}

music_length(name)
{
    value = tablelookup("mp/sound/soundlength.csv", 0, name, 1);

    if (!isdefined(value) || value == "")
    {
        value = getsoundlength(name);
    }

    if (value == -1)
    {
        return -1;
    }

    value = int(value);
    value *= 0.001;
    return value;
}

get_helicopters()
{
    vehicles = vehicle_getarray();
    helicopters = [];
    foreach (vehicle in vehicles)
    {
        if (self != vehicle && vehicle.vehicletype == "littlebird")
        {
            helicopters[helicopters.size] = vehicle;
        }
    }
    return helicopters;
}

get_closest(org, array, maxdist)
{
    if (!isdefined(maxdist))
    {
        maxdist = 500000;
    }

    helis = self get_helicopters();
    ent = undefined;

    foreach (item in array)
    {
        if (!isdefined(item))
        {
            continue;
        }

        valid = true;
        foreach (heli in helis)
        {
            if (isdefined(heli.goal_origin) && distance(heli.goal_origin, item.origin) < 1000)
            {
                valid = false;
                break;
            }
        }

        if (!valid)
        {
            continue;
        }

        newdist = distance(item.origin, org);

        if (newdist >= maxdist)
        {
            continue;
        }

        maxdist = newdist;
        ent = item;
    }

    return ent;
}

heli_circling_think(heli_points, base_speed)
{
    if (!isdefined(heli_points))
    {
        heli_points = "attack_heli_circle_node";
    }

    points = getentarray(heli_points, "targetname");

    if (!isdefined(points) || points.size < 1)
    {
        points = common_scripts\utility::getstructarray(heli_points, "targetname");
    }

    heli = self;
    heli endon("stop_circling");
    heli endon("death");
    heli endon("returning_home");
    heli endon("heli_players_dead");

    while (true)
    {
        heli vehicle_setspeed(base_speed, base_speed / 4, base_speed / 4);
        heli neargoalnotifydist(100);

        player = maps\_utility::get_closest_player_healthy(heli.origin);
        player_origin = player.origin;
        heli setlookatent(player);
        
        player_location = heli get_closest(player_origin, points);
        heli_locations = getentarray(player_location.target, "targetname");

        if (!isdefined(heli_locations) || heli_locations.size < 1)
        {
            heli_locations = common_scripts\utility::getstructarray(player_location.target, "targetname");
        }

        goal = heli_locations[randomint(heli_locations.size)];
        heli.goal_origin = goal.origin;
        heli setvehgoalpos(goal.origin, 1);
        heli waittill("near_goal");

        if (!isdefined(player.is_controlling_uav))
        {
            wait 1;
            wait (randomfloatrange(0.8, 1.3));
        }
    }
}

get_csv_name_internal()
{
    return "sp/survival_waves.csv";
}

get_csv_name()
{
    if (isdefined(level.survival_waves_csv))
    {
        return level.survival_waves_csv;
    }

    level.survival_waves_csv = get_csv_name_internal();
    return level.survival_waves_csv;
}

h2_sentry_pickup(sentry)
{
    sentry setsentrycarrier(level.player);
    level.player disableweapons();
}
