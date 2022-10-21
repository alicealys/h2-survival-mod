main()
{
    maps\contingency::_id_C21D();
    var_0 = getentarray( "cargo1_group2", "targetname" );
    var_1 = getentarray( "cargo2_group2", "targetname" );
    var_2 = getentarray( "cargo3_group2", "targetname" );
    common_scripts\utility::array_call( var_0, ::delete );
    common_scripts\utility::array_call( var_1, ::delete );
    common_scripts\utility::array_call( var_2, ::delete );
    _id_C9A4::main();
    _id_AC17::main();
    _id_CD80::main();
    _id_C10B::main();
    maps\_load::main();
    maps\contingency_anim::_id_A902();
    maps\contingency_lighting::main();
    maps\contingency_aud::main();
}