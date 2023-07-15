// IW5 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self.animtree = "";
    self.additionalassets = "riotshield.csv";
    self.team = "allies";
    self.type = "human";
    self.subclass = "riotshield";
    self.accuracy = 0.2;
    self.health = 100;
    self.grenadeweapon = "";
    self.grenadeammo = 0;
    self.secondaryweapon = "riotshield_so";
    self.sidearm = "h2_usp_mp";

    if ( isai( self ) )
    {
        self setengagementmindist( 256.0, 0.0 );
        self setengagementmaxdist( 768.0, 1024.0 );
    }

    self.weapon = "h2_mp5k_mp";

    switch ( codescripts\character::get_random_character( 2 ) )
    {
        case 0:
            _id_B434::main();
            break;
        case 1:
            _id_BFDC::main();
            break;
    }
}

spawner()
{
    self setspawnerteam( "allies" );
}

precache()
{
    _id_B434::precache();
    _id_BFDC::precache();
    maps\_riotshield::init_riotshield();
}
