main()
{
    setdvar("ui_current_score", 0);
    setsaveddvar("compassHideVehicles", 0);

    maps\_loadout_code::loadout_complete();
    animscripts\dog\dog_init::initdoganimations();
    maps\_playerdata::init();

    level.laststand_type = 2;
	level.laststand_player_func = maps\_laststand::player_laststand_proc;

    level.xp_enable = true;
    level.xp_give_func = ::give_xp;

    level._so_survival_h2mod = spawnstruct();
    level._so_survival_h2mod.score_buffer = 0;
    level._so_survival_h2mod.player_score = 0;

    maps\_utility::set_mission_failed_override(::mission_fail_func);

    thread notify_score();
    thread survival_hud();
    thread survival_hud_uav();
    thread wave_tracking();
    init_stats();
}

mission_fail_func()
{
    level.challenge_end_time = gettime();
	thread maps\_specialops_code::failure_summary_display();
}

wave_tracking()
{
    while (true)
    {
        level waittill("wave_started");
        maps\_playerdata::set_best_wave(level.script, level.current_wave);
    }
}

init_stats()
{
    player = getentbynum(0);
    player maps\_player_stats::stat_notify_register_func(::career_stat_increment);
}

career_stat_increment(stat, delta)
{
    new_stat = int(maps\_playerdata::get_struct("career", stat)) + delta;
	maps\_playerdata::set_struct("career", stat, new_stat);
}

survival_hud_uav()
{
    while (true)
    {
        if (!isdefined(level.player))
        {
            wait 0.05;
        }

        level.player waittill("player_is_controlling_UAV");
        luinotify("show_survival_hud", "0");
        level.player waittill("exiting_uav_control");
        luinotify("show_survival_hud", "1");
    }
}

survival_hud()
{
    if (!isdefined(level.player))
    {
        wait 0.05;
    }

    level.player waittill("player_update_model");
    luinotify("show_survival_hud", "1");
}

notify_score()
{
    level endon("special_op_terminated");
    while (true)
    {
        if (level._so_survival_h2mod.score_buffer != 0)
        {
            luinotify("add_score", level._so_survival_h2mod.score_buffer);
            level._so_survival_h2mod.score_buffer = 0;
        }

        wait 0.05;
    }
}

add_score(increment)
{
    if (!isdefined(self.survival_credit))
    {
        self.survival_credit = 0;
    }

	self.survival_credit += increment;
    level._so_survival_h2mod.score_buffer += increment;
    setdvar("ui_current_score", self.survival_credit);
}

give_xp(type, value)
{
    self add_score(value);
    self maps\_rank::updateplayerscore(type, value);
}
