main()
{
    level._id_A9C5 = "mp_vacant"; // default lightset
    level.default_vision = "mp_vacant"; // default vision
    level.lvl_visionset = level.default_vision;
	level.wave_table = "sp/so_survival/tier_1.csv"; // enables wave definition override
	level.loadout_table = "sp/so_survival/tier_1.csv"; // enables player load out override

    level.so_compass_zoom = "close";

    level.ac130_orbit_radius = 10000;
    level.ac130_orbit_height = 6000;

    executecommand("r_tonemaphighlightrange 22");

    triggers = getentarray("trigger_multiple_dyn_copier_no_light", "classname");
    foreach (trigger in triggers)
    {
        trigger delete();
    }

	maps\_so_survival::survival_preload();
    maps\mp\mp_vacant::main();
    maps\_load::main();
	maps\_so_survival::survival_postload();
	maps\_so_survival::survival_init();

    level._id_B981._id_B23A = 30; // remotemissile view ang
}
