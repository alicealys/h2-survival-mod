// IW5 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self.animtree = "";
    self.additionalassets = "";
    self.team = "axis";
    self.type = "human";
    self.subclass = "regular";
    self.accuracy = 0.2;
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

    self.weapon = tablelookup(scripts\survival::get_csv_name(), 1, "hardened", 5);
    self.voice = "russian";

    switch (codescripts\character::get_random_character(3))
    {
        case 0:
            self setmodel("body_airborne_assault_a");
            break;
        case 1:
            self setmodel("body_airborne_assault_b");
            break;
        case 2:
            self setmodel("body_airborne_assault_c");
            break;
    }

    switch (codescripts\character::get_random_character(5))
    {
        case 0:
            self attach("head_airborne_a", "", true);
            self.headmodel = "head_airborne_a";
            break;
        case 1:
            self attach("head_airborne_b", "", true);
            self.headmodel = "head_airborne_b";
            break;
        case 2:
            self attach("head_airborne_c", "", true);
            self.headmodel = "head_airborne_c";
            break;
        case 3:
            self attach("head_airborne_d", "", true);
            self.headmodel = "head_airborne_d";
            break;
        case 4:
            self attach("head_airborne_e", "", true);
            self.headmodel = "head_airborne_e";
            break;
    }
}

spawner()
{
    self setspawnerteam("axis");
}

precache()
{
    precacheitem(tablelookup(scripts\survival::get_csv_name(), 1, "hardened", 5));
    precacheitem("fraggrenade");
    precachemodel("head_airborne_a");
    precachemodel("head_airborne_b");
    precachemodel("head_airborne_c");
    precachemodel("head_airborne_d");
    precachemodel("head_airborne_e");
    precachemodel("body_airborne_assault_a");
    precachemodel("body_airborne_assault_b");
    precachemodel("body_airborne_assault_c");
}
