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
}

spawner()
{
    self setspawnerteam("axis");
}

precache()
{
    _id_D2AD::precache();
    _id_CA11::precache();
    precacheitem(tablelookup(scripts\survival::get_csv_name(), 1, "easy", 5));
    precacheitem("fraggrenade" );
    precachemodel("body_op_airborne_sniper");
    precachemodel("body_op_airborne_sniper");
}
