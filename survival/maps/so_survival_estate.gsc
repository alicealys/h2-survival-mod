main()
{
    precachemodel("vehicle_uaz_hardtop_dsr");
    precachemodel("vehicle_mig29_v2_dest");

    level._id_A9C5 = "estate"; // default lightset
    level.lvl_visionset = "estate"; // default vision
    level.default_vision = level.lvl_visionset; // default vision
	level.wave_table = "sp/so_survival/tier_1.csv"; // enables wave definition override
	level.loadout_table = "sp/so_survival/tier_1.csv"; // enables player load out override

    level.ac130_orbit_radius = 10000;
    level.ac130_orbit_height = 6000;

    level.min_spawn_dist = 4000;

    _id_B22E::main();
    _id_C989::main();
    _id_C908::main();
    maps\estate_anim::main();
    _id_BA9C::main();

	maps\_so_survival::survival_preload();

    maps\_load::main();
    maps\_compass::setupminimap("compass_map_estate");
    maps\estate_aud::main();
    maps\estate_lighting::main();
    maps\estate_beautiful_corner::_id_C85F();

	maps\_so_survival::survival_postload();
	maps\_so_survival::survival_init();

    level._id_B981._id_B23A = 30; // remotemissile view ang

    enable_portals();
    fix_map();
}

fix_map()
{
    ents = getentarray();
    foreach (ent in ents)
    {
        if (issubstr(ent.classname, "weapon_"))
        {
            ent delete();
        }
    }

    getent("dsm_obj", "targetname") delete();
    getent("dsm", "targetname") delete();
    common_scripts\utility::array_call(getentarray("broken_fence", "targetname"), ::delete);
    common_scripts\utility::array_call(getentarray("window_clip", "targetname"), ::delete);
    delete_spawners();
    thread add_clips();
}

add_clips()
{
    car = spawn("script_model", (1208.31, 3025.59, 31.8864));
    car.angles = (356.102, 30.3119, -9.46256);
    car setmodel("vehicle_uaz_hardtop_dsr");

    final_fence_clip = getent("final_area_fence", "targetname");

    car_clip = spawn("script_model", (1172.620117, 3067.385254, 22.684971));
    car_clip.angles = (0, 60, 0);
    car_clip clonebrushmodeltoscriptmodel(final_fence_clip);
    car_clip hide();

    fence_clip = spawn("script_model", (-2133.539795, 5104.060547, -87.472382));
    fence_clip.angles = (0, 60, 0);
    fence_clip clonebrushmodeltoscriptmodel(final_fence_clip);
    fence_clip hide();

    wait 0.05;

    final_fence = spawn("script_model", final_fence_clip.origin);
    final_fence.angles = final_fence_clip.angles;
    final_fence clonebrushmodeltoscriptmodel(final_fence_clip);

    final_fence_clip delete();
}

delete_spawners()
{
    maps\_specialops::so_delete_all_by_type(maps\_specialops::type_spawners, maps\_specialops::type_spawn_trigger);
}

enable_portals()
{
    portals = getentarray("portal_group", "classname");
    foreach (portal in portals)
    {
        enablepg(portal.targetname, true);
        portal delete();
    }

    portal_triggers = getentarray("trigger_multiple_flag_set", "classname");
    foreach (trigger in portal_triggers)
    {
        if (isdefined(trigger.targetname) && issubstr(trigger.targetname, "portal"))
        {
            trigger delete();
        }
    }
}
