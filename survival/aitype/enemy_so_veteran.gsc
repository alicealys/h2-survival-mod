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

    self.weapon = tablelookup(scripts\survival::get_csv_name(), 1, "veteran", 5);
    self.voice = "russian";

    switch (codescripts\character::get_random_character(4))
    {
        case 0:
            self setmodel("body_shadow_co_assault");
            break;
        case 1:
            self setmodel("body_shadow_co_lmg");
            break;
        case 2:
            self setmodel("body_shadow_co_shotgun");
            break;
        case 3:
            self setmodel("body_shadow_co_smg");
            break;
    }

    switch (codescripts\character::get_random_character(2))
    {
        case 0:
            self attach("head_shadow_co_b", "", true);
            self.headmodel = "head_shadow_co_b";
            break;
        case 1:
            self attach("head_shadow_co_c", "", true);
            self.headmodel = "head_shadow_co_c";
            break;
    }
}

spawner()
{
    self setspawnerteam("axis");
}

precache()
{
    precacheitem(tablelookup(scripts\survival::get_csv_name(), 1, "veteran", 5) );
    precacheitem("fraggrenade");
    precachemodel("body_shadow_co_assault");
    precachemodel("body_shadow_co_lmg");
    precachemodel("body_shadow_co_shotgun");
    precachemodel("body_shadow_co_smg");
    precachemodel("head_shadow_co_b");
    precachemodel("head_shadow_co_c");
}

