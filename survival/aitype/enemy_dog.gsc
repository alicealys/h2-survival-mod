// H2 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self.animtree = "dog.atr";
    self.additionalassets = "";
    self.team = "axis";
    self.type = "dog";
    self.subclass = "regular";
    self.accuracy = 0.2;
    self.health = 200;
    self.grenadeweapon = "fraggrenade";
    self.grenadeammo = 0;
    self.secondaryweapon = "dog_bite";
    self.sidearm = "";

    if (isai(self))
    {
        self setengagementmindist(256.0, 0.0);
        self setengagementmaxdist(768.0, 1024.0);
    }

    self.weapon = "dog_bite";
    _id_B46B::main();
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache()
{
    _id_B46B::precache();
    precacheitem("dog_bite");
    precacheitem("fraggrenade");
}
