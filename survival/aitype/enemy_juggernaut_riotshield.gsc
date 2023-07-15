// H2 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self.animtree = "";
    self.additionalassets = "riotshield.csv";
    self.team = "axis";
    self.type = "human";
    self.subclass = "riotshield";
    self.accuracy = 0.2;
    self.health = 3600;
    self.grenadeweapon = "fraggrenade";
    self.grenadeammo = 0;
    self.secondaryweapon = "riotshield_so";
    self.sidearm = "h2_beretta_mp";

    if (isai(self))
    {
        self setengagementmindist(0.0, 0.0);
        self setengagementmaxdist(256.0, 1024.0);
    }

    self.weapon = "h1_feblmg_mp";
    character\character_sp_juggernaut_h2::main();
}

spawner()
{
    self setspawnerteam("axis");
}

precache()
{
    character\character_sp_juggernaut_h2::precache();
    maps\_riotshield::init_riotshield();
    maps\_juggernaut::main();
}
