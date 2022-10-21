main()
{
    _id_C7FC::main();
    _id_D55C::main();
    _id_D216::main();
    _id_CA3D::main();
    _id_CA8F::main();
    maps\favela_escape_anim::main();
    maps\_load::main();
    maps\favela_escape_lighting::main();

    var_4 = getent( "water_collector", "targetname" );
    var_4 delete();

    _id_D2A4::main(); // sentry
    _id_C630::init(); // predator
}
