// IW5 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self.animtree = "";
    self.additionalassets = "";
    self.team = "allies";
    self.type = "human";
    self.subclass = "regular";
    self.accuracy = 0.2;
    self.health = 100;
    self.secondaryweapon = "";
    self.sidearm = "";
    self.grenadeweapon = "";
    self.grenadeammo = 0;

    if ( isai( self ) )
    {
        self setengagementmindist( 256.0, 0.0 );
        self setengagementmaxdist( 768.0, 1024.0 );
    }

    self.weapon = "none";

    switch ( codescripts\character::get_random_character( 3 ) )
    {
        case 0:
            _id_AFEB::main();
            break;
        case 1:
            _id_B367::main();
            break;
        case 2:
            _id_A944::main();
            break;
    }
}

spawner()
{
    self setspawnerteam( "allies" );
}

precache()
{
    _id_AFEB::precache();
    _id_B367::precache();
    _id_A944::precache();
}
