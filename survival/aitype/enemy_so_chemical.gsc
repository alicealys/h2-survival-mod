// IW5 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self._id_3AA1 = "";
    self._id_3AA2 = "";
    self.team = "axis";
    self.type = "human";
    self._id_218D = "regular";
    self.accuracy = 0.2;
    self.health = 150;
    self.secondaryweapon = "";
    self._id_20A3 = "";
    self.grenadeweapon = "fraggrenade";
    self.grenadeammo = 0;

    if ( isai( self ) )
    {
        self setengagementmindist( 256.0, 0.0 );
        self setengagementmaxdist( 768.0, 1024.0 );
    }

    self.weapon = "none";

    switch ( codescripts\character::get_random_character( 4 ) )
    {
        case 0:
            _id_05CC::main();
            break;
        case 1:
            _id_05D1::main();
            break;
        case 2:
            _id_05DA::main();
            break;
        case 3:
            _id_05DB::main();
            break;
    }
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache()
{
    _id_05CC::precache();
    _id_05D1::precache();
    _id_05DA::precache();
    _id_05DB::precache();
    precacheitem( "fraggrenade" );
}
