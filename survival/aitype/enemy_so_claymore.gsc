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

    self.weapon = tablelookup(scripts\survival::get_csv_name(), 1, "martyrdom", 5);

    self setmodel("body_work_civ_male_a_bomb");
    self attach("head_spetsnaz_assault_vlad_facemask", "", true);
    self.headmodel = "head_spetsnaz_assault_vlad_facemask";
    self.voice = "russian";
}

spawner()
{
    self setspawnerteam("axis");
}

precache()
{
    precachemodel("body_work_civ_male_a_bomb");
    precachemodel("h2_weapon_c4");
    precachemodel("mp_body_fso_vest_d_dirty");
    precachemodel("head_spetsnaz_assault_vlad_facemask");
    precacheitem("aa12");
    precacheitem("c4");
    precacheitem("fraggrenade");
}
