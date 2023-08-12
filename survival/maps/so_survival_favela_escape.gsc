main()
{
    level._id_A9C5 = "favela_escape"; // default lightset
    level.default_vision = "favela_escape"; // default vision
    level.lvl_visionset = level.default_vision;
	level.wave_table = "sp/so_survival/tier_1.csv"; // enables wave definition override
	level.loadout_table = "sp/so_survival/tier_1.csv"; // enables player load out override

    level.ac130_orbit_radius = 8000;
    level.ac130_orbit_height = 12000;

	maps\_so_survival::survival_preload();
    thread favela_escape();
    maps\_load::main();
	maps\_so_survival::survival_postload();
	maps\_so_survival::survival_init();

    level._id_B981._id_B23A = 30; // remotemissile view ang

    enable_portals();
}

favela_escape()
{
    _id_C7FC::main();
    _id_D55C::main();
    _id_D216::main();
    _id_CA3D::main();
    _id_CA8F::main();
    maps\favela_escape_anim::main();
    maps\favela_escape_lighting::main();

    maps\_compass::setupminimap("compass_map_favela_escape");

    var_4 = getent( "water_collector", "targetname" );
    var_4 delete();

    delete_spawners();
    fix_map();

    level.not_solid_armory = true;
}

fix_map()
{
    precachemodel("h1_me_door_wood_painted");

    ents = getentarray();
    foreach (ent in ents)
    {
        if (isdefined(ent.model) && ent.model == "h2_favela_escape_truck_fence_clean_a")
        {
            ent delete();
        }

        if (issubstr(ent.classname, "weapon_"))
        {
            ent delete();
        }
    }

    planes = getentarray("sbmodel_airliner_flyby", "targetname");
    foreach (plane in planes)
    {
        plane delete();
    }

    getent("sbmodel_market_door_1", "targetname") delete();
    getent("sbmodel_vista1_door1", "targetname") delete();
    getent("pf0_auto7013", "targetname") delete();

    brush = getent("pf0_auto7014", "targetname");
    brush.origin =(0, 0, -100000);

    door = spawn("script_model", (-2515.680420, -1538.391724, 1036.596436));
    door setmodel("h1_me_door_wood_painted");
    door.angles = (0, -270, 0);

    doorcol = spawn("script_model", (-2515.680420, -1539.391724, 1086.596436));
    doorcol clonebrushmodeltoscriptmodel(brush);

    col1 = spawn("script_model", (6368.233887, 51.760971, 1053.604370));
    col1.angles = (0.000000, 83.053589, 0.000000);
    col2 = spawn("script_model", (6349.233887, -8.239029, 1053.604370));
    col2.angles = (0.000000, 72.053589, 0.000000);
    col3 = spawn("script_model", (6356.696289, 11.948925, 1055.381226));
    col3.angles = (0.000000, 72.053589, 0.000000);

    col4 = spawn("script_model", col1.origin + (0, 0, 70));
    col4.angles = col1.angles;
    col5 = spawn("script_model", col2.origin + (0, 0, 70));
    col5.angles = col2.angles;
    col6 = spawn("script_model", col3.origin + (0, 0, 70));
    col6.angles = col3.angles;

    col1 clonebrushmodeltoscriptmodel(brush);
    col2 clonebrushmodeltoscriptmodel(brush);
    col3 clonebrushmodeltoscriptmodel(brush); 
    col4 clonebrushmodeltoscriptmodel(brush); 
    col5 clonebrushmodeltoscriptmodel(brush); 
    col6 clonebrushmodeltoscriptmodel(brush);

    add_doors();
}

add_doors()
{
    brush = getent("pf0_auto7014", "targetname");

    door1 = spawn("script_model", (3763.51, 446.056, 1043.13));
    door1 setmodel("h1_me_door_wood_painted");
    door1.angles = (0, 0, 0);

    doorcol1 = spawn("script_model", (3705, 446.056, 1043.13));
    doorcol1 clonebrushmodeltoscriptmodel(brush);
    
    door2 = spawn("script_model", (3508.37, 164.903, 1019.63));
    door2 setmodel("h1_me_door_wood_painted");
    door2.angles = (0, -90, 0);

    doorcol2 = spawn("script_model", (3508.37, 164.903, 1019.63));
    doorcol2 clonebrushmodeltoscriptmodel(brush);
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
