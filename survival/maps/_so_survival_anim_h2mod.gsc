#using_animtree( "generic_human" );

main()
{
    if (!isdefined(level.scr_anim))
    {
        level.scr_anim = [];
    }

    level.scr_anim["crouch_2_stand"] = %exposed_crouch_2_stand;
}
