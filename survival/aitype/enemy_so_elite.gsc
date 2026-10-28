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

    self.weapon = tablelookup(scripts\survival::get_csv_name(), 1, "elite", 5);
    self.voice = "russian";
    self setmodel("body_opforce_fsb_assault_a");

    switch (codescripts\character::get_random_character(2))
    {
        case 0:
            self attach("head_opforce_fsb_a", "", true);
            self.headmodel = "head_opforce_fsb_a";
            break;
        case 1:
            self attach("head_opforce_fsb_b", "", true);
            self.headmodel = "head_opforce_fsb_b";
            break;
    }
}

spawner()
{
    self setspawnerteam("axis");
}

precache()
{
    precacheitem(tablelookup(scripts\survival::get_csv_name(), 1, "elite", 5));
    precacheitem("fraggrenade");
    precachemodel("body_opforce_fsb_assault_a");
    precachemodel("head_opforce_fsb_a");
    precachemodel("head_opforce_fsb_b");
}

