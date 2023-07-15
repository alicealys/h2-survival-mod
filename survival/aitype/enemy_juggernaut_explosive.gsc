// H2 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self.animtree = "";
    self.additionalassets = "juggernaut.csv";
    self.team = "axis";
    self.type = "human";
    self.subclass = "juggernaut";
    self.accuracy = 0.2;
    self.health = 3600;
    self.grenadeweapon = "fraggrenade";
    self.grenadeammo = 0;
    self.secondaryweapon = "h2_berretta_mp";
    self.sidearm = "h2_berretta_mp";

    if (isai(self))
    {
        self setengagementmindist(0.0, 0.0);
        self setengagementmaxdist(256.0, 1024.0);
    }

    self.weapon = "h2_m240_mp";
    character\character_sp_juggernaut_h2::main();
}

spawner()
{
    self setspawnerteam("axis");
}

precache()
{
    character\character_sp_juggernaut_h2::precache();
    maps\_juggernaut::main();
}
