init()
{
    level._playerdata = spawnstruct();
    level._playerdata.default_values = [];
    level._playerdata.default_values["experience"] = 0;
    level._playerdata.default_values["viewhands"] = "viewmodel_base_viewhands";
    level._playerdata.default_values["viewhands_player"] = "viewhands_player_us_army";
    level._playerdata.default_values["starting_pistol"] = "h2_beretta_mp";
    level._playerdata.default_values["custom_soundtrack"] = "";

    level._playerdata.struct_default_values["career"] = [];
    level._playerdata.struct_default_values["career"]["__default"] = 0;

    level._playerdata.struct_default_values["best_wave"] = [];
    level._playerdata.struct_default_values["best_wave"]["__default"] = 0;
}

get_default(key)
{
    default_value = level._playerdata.default_values[key];
    if (!isdefined(default_value))
    {
        return;
    }

    return default_value;
}

get(key)
{
    default_value = level._playerdata.default_values[key];
    if (!isdefined(default_value))
    {
        return;
    }

    value = statsgetor(key, default_value);
    if (typeof(value) != typeof(default_value))
    {
        return default_value;
    }

    return value;
}

get_struct(struct, field)
{
    s = level._playerdata.struct_default_values[struct];
    if (!isdefined(s))
    {
        return;
    }

    default_value = s[field];
    if (!isdefined(default_value))
    {
        default_value = s["__default"];
    }

    if (isdefined(default_value))
    {
        value = statsgetstructor(struct, field);
        if (typeof(value) != typeof(default_value))
        {
            return default_value;
        }

        return value;
    }

    return statsgetstruct(struct, field);
}

set(key, value)
{
    default_value = level._playerdata.default_values[key];
    if (!isdefined(default_value))
    {
        return;
    }

    if (typeof(value) != typeof(default_value))
    {
        return;
    }

    statsset(key, value);
}

set_struct(struct, field, value)
{
    s = level._playerdata.struct_default_values[struct];
    if (!isdefined(s))
    {
        return;
    }

    default_value = s[field];
    if (!isdefined(default_value))
    {
        default_value = s["__default"];
    }

    if (isdefined(default_value) && typeof(value) != typeof(default_value))
    {
        return;
    }

    statssetstruct(struct, field, value);
}

set_best_wave(map, wave)
{
    current = get_struct("best_wave", map);
    if (current < wave)
    {
        set_struct("best_wave", map, wave);
    }
}
