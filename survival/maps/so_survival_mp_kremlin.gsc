main()
{
    level._id_A9C5 = "mp_kremlin"; // default lightset
    level.default_vision = "mp_kremlin"; // default vision
	level.wave_table = "sp/custom_waves.csv"; // enables wave definition override
	level.loadout_table = "sp/custom_waves.csv"; // enables player load out override
    level._id_B981._id_B23A = 20; // remotemissile view ang

    level.ac130_orbit_radius = 10000;
    level.ac130_orbit_height = 6000;

	maps\_so_survival::survival_preload();
    maps\mp_kremlin::main();
    maps\_load::main();
	maps\_so_survival::survival_postload();
	maps\_so_survival::survival_init();	
}
