send_data_thread()
{
    level._h2mod_challenge_send_data_thread = thisthread;
    level._h2mod_challenge_data = [];
    level._h2mod_challenge_data_prev = [];

    while (true)
    {
        foreach (k in getarraykeys(level._h2mod_challenge_data))
        {
            if (!isdefined(level._h2mod_challenge_data_prev[k]) || level._h2mod_challenge_data_prev[k] != level._h2mod_challenge_data[k])
            {
                luinotify(k, level._h2mod_challenge_data[k]);
            }

            level._h2mod_challenge_data_prev[k] = level._h2mod_challenge_data[k];
        }

        wait 0.05;
    }
}

initialize_challenge_data()
{
    level._h2mod_challenge_data = [];
    level._h2mod_challenge_data["challenge_1_highlight"] = 0;
    level._h2mod_challenge_data["challenge_2_highlight"] = 0;
    level._h2mod_challenge_data["challenge_1_set_percent"] = 0;
    level._h2mod_challenge_data["challenge_1_set_percent_animate"] = 0;
    level._h2mod_challenge_data["challenge_2_set_percent"] = 0;
    level._h2mod_challenge_data["challenge_2_set_percent_animate"] = 0;
    level._h2mod_challenge_data["challenge_1_set_score"] = 500;
    level._h2mod_challenge_data["challenge_2_set_score"] = 500;
}

send_notify_internal(name, value)
{
    if (!isdefined(level._h2mod_challenge_data))
    {
        initialize_challenge_data();
    }

    // prevent unnecessary notifies from being sent
    if (isdefined(level._h2mod_challenge_data[name]) && level._h2mod_challenge_data[name] == value)
    {
        return;
    }

    level._h2mod_challenge_data[name] = value;
    luinotify(name, value);
}

get_challenge_notify_name(index, notif)
{
    return "challenge_" + (index + 1) + "_" + notif;
}

sur_hud_reset()
{
    luinotify("challenge_reset");
}

send_notify(index, name, value)
{
    if (!isdefined(level._h2mod_challenge_send_data_thread))
    {
        level thread send_data_thread();
    }

    notif = get_challenge_notify_name(index, name);
    send_notify_internal(notif, value);
}

sur_hud_challenge_label(index, label)
{
    send_notify(index, "set_name", label);
}

sur_hud_challenge_progress(index, frac)
{
    frac = min(1.0, frac);
    if (frac == 1.0)
    {
        frac = 0.0;
    }

    send_notify(index, "set_percent", frac);
}

sur_hud_challenge_progress_animate(index, frac)
{
    frac = min(1.0, frac);
    if (frac == 1.0)
    {
        frac = 0.0;
    }

    send_notify(index, "set_percent_animate", frac);
}

sur_hud_challenge_reward(index, value, completed)
{
    if (completed > 1)
    {
        send_notify(index, "highlight", "1");
    }
    else
    {
        send_notify(index, "highlight", "0");
    }

    send_notify(index, "set_score", value);
}

sur_hud_animate(name)
{
    luinotify("challenge_fade_in", "");
}
