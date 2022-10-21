// IW5 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self.animtree = "";
    self.additionalassets = "";
    self.team = "axis";
    self.type = "human";
    self.subclass = "regular";
    self.accuracy = 100;
    self.health = 150;
    self.grenadeweapon = "fraggrenade";
    self.grenadeammo = 0;
    self.secondaryweapon = "";
    self.sidearm = "";

    if (isai(self))
    {
        self setengagementmindist(256.0, 0.0);
        self setengagementmaxdist(768.0, 1024.0);
    }

    self.weapon = tablelookup(scripts\survival::get_csv_name(), 1, "easy", 5);

    if (issubstr(level.script, "favela"))
    {
        switch (codescripts\character::get_random_character(11))
        {
            case 0:
                _id_C874::main();
                break;
            case 1:
                _id_B17F::main();
                break;
            case 2:
                _id_C242::main();
                break;
            case 3:
                _id_D2AA::main();
                break;
            case 4:
                _id_AEDD::main();
                break;
            case 5:
                _id_D303::main();
                break;
            case 6:
                _id_B90E::main();
                break;
            case 7:
                _id_B377::main();
                break;
            case 8:
                _id_BC62::main();
                break;
            case 9:
                _id_B9C3::main();
                break;
            case 10:
                _id_A935::main();
                break;
        }
    }
    else 
    {
        switch (codescripts\character::get_random_character(2))
        {
            case 0:
                _id_D2AD::main();
                break;
            case 1:
                _id_CA11::main();
                break;
        }
        
        self setmodel("body_op_airborne_sniper");

        if (isdefined(self.hatmodel))
        {
            self.hatmodel = undefined;
            self detach(self.hatmodel);
        }

        self.headmodel = undefined;
    }
}

spawner()
{
    self setspawnerteam("axis");
}

precache()
{
    if (issubstr(level.script, "favela"))
    {
        _id_C874::precache();
        _id_B17F::precache();
        _id_C242::precache();
        _id_D2AA::precache();
        _id_AEDD::precache();
        _id_D303::precache();
        _id_B90E::precache();
        _id_B377::precache();
        _id_BC62::precache();
        _id_B9C3::precache();
        _id_A935::precache();
    }

    _id_D2AD::precache();
    _id_CA11::precache();
    precacheitem(tablelookup(scripts\survival::get_csv_name(), 1, "easy", 5));
    precacheitem("fraggrenade" );
    precachemodel("body_op_airborne_sniper");
    precachemodel("body_op_airborne_sniper");
    precachemodel("hat_opforce_merc_b");
}
