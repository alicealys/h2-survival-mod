// H2 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

#using_animtree("generic_human");

init_riotshield_ai_anims()
{
    anim.notetracks["detach shield"] = ::notetrackdetachshield;
    animscripts\init_move_transitions::init_move_transition_arrays();
    var_0 = [];
    var_0["cover_trans"]["riotshield"][1] = %h2_riot_shield_movement_run2crouch_01;
    var_0["cover_trans"]["riotshield"][2] = %h2_riot_shield_movement_run2crouch_02;
    var_0["cover_trans"]["riotshield"][3] = %h2_riot_shield_movement_run2crouch_03;
    var_0["cover_trans"]["riotshield"][4] = %h2_riot_shield_movement_run2crouch_04;
    var_0["cover_trans"]["riotshield"][6] = %h2_riot_shield_movement_run2crouch_06;
    var_0["cover_trans"]["riotshield"][7] = %h2_riot_shield_movement_run2crouch_07;
    var_0["cover_trans"]["riotshield"][8] = %h2_riot_shield_movement_run2crouch_08;
    var_0["cover_trans"]["riotshield"][9] = %h2_riot_shield_movement_run2crouch_09;
    var_0["cover_trans"]["riotshield_crouch"][1] = %riotshield_walk_approach_1;
    var_0["cover_trans"]["riotshield_crouch"][2] = %riotshield_walk_approach_2;
    var_0["cover_trans"]["riotshield_crouch"][3] = %riotshield_walk_approach_3;
    var_0["cover_trans"]["riotshield_crouch"][4] = %riotshield_walk_approach_4;
    var_0["cover_trans"]["riotshield_crouch"][6] = %riotshield_walk_approach_6;
    var_0["cover_trans"]["riotshield_crouch"][7] = undefined;
    var_0["cover_trans"]["riotshield_crouch"][8] = %riotshield_walk2crouch_8;
    var_0["cover_trans"]["riotshield_crouch"][9] = undefined;
    var_0["cover_trans_angles"]["riotshield_crouch"][1] = 45;
    var_0["cover_trans_angles"]["riotshield_crouch"][2] = 0;
    var_0["cover_trans_angles"]["riotshield_crouch"][3] = -45;
    var_0["start_run"]["riotshield_crouch"][1] = %h2_riot_shield_movement_crouch2run_01;
    var_0["start_run"]["riotshield_crouch"][2] = %h2_riot_shield_movement_crouch2run_02;
    var_0["start_run"]["riotshield_crouch"][3] = %h2_riot_shield_movement_crouch2run_03;
    var_0["start_run"]["riotshield_crouch"][4] = %h2_riot_shield_movement_crouch2run_04;
    var_0["start_run"]["riotshield_crouch"][6] = %h2_riot_shield_movement_crouch2run_06;
    var_0["start_run"]["riotshield_crouch"][7] = %h2_riot_shield_movement_crouch2run_07;
    var_0["start_run"]["riotshield_crouch"][8] = %h2_riot_shield_movement_crouch2run_08;
    var_0["start_run"]["riotshield_crouch"][9] = %h2_riot_shield_movement_crouch2run_09;
    var_0["walk_turn"][0] = %h2_riot_shield_movement_crouch_08_l;
    var_0["walk_turn"][1] = %cqb_walk_tight_turn_l135;
    var_0["walk_turn"][2] = %cqb_walk_tight_turn_l90;
    var_0["walk_turn"][3] = %cqb_walk_tight_turn_l45;
    var_0["walk_turn"][5] = %cqb_walk_tight_turn_r45;
    var_0["walk_turn"][6] = %h2_riot_shield_movement_crouch_06;
    var_0["walk_turn"][7] = %cqb_walk_tight_turn_r135;
    var_0["walk_turn"][8] = %h2_riot_shield_movement_crouch_08_r;
    var_0["run_turn"][0] = %h2_riot_shield_movement_run_turn_08_l;
    var_0["run_turn"][1] = %h2_riot_shield_movement_run_turn_07;
    var_0["run_turn"][2] = %h2_riot_shield_movement_run_04;
    var_0["run_turn"][3] = %run_tight_turn_l45;
    var_0["run_turn"][5] = %run_tight_turn_r45;
    var_0["run_turn"][6] = %h2_riot_shield_movement_run_06;
    var_0["run_turn"][7] = %h2_riot_shield_movement_run_turn_09;
    var_0["run_turn"][8] = %h2_riot_shield_movement_run_turn_08_r;
    var_0["pain"]["riotshield"] = animscripts\utility::array( %riotshield_crouch_pain, %h2_riotshield_crouch_pain_01, %h2_riotshield_crouch_pain_02, %h2_riotshield_crouch_pain_03, %h2_riotshield_crouch_pain_05, %h2_riotshield_crouch_pain_01_b, %h2_riotshield_crouch_pain_05_b );
    var_0["walkBack2Run"][8] = %h2_riot_shield_movement_crouchshield_walk_b2run_02;
    var_1 = [];
    var_1[0] = "riotshield";
    var_1[1] = "riotshield_crouch";

    foreach ( var_5, var_3 in var_0["start_run"]["riotshield_crouch"] )
    {
        var_4 = length( getangledelta( var_3, 0, 1 ) );
        var_0["start_run_dist"]["riotshield_crouch"][var_5] = var_4;
    }

    var_0["CoverTransLongestDist"] = [];

    for ( var_6 = 0; var_6 < var_1.size; var_6++ )
    {
        var_7 = var_1[var_6];
        var_0["CoverTransLongestDist"][var_7] = 0;
        var_0["CoverTransLongestDistSq"][var_7] = 0;

        for ( var_8 = 1; var_8 <= 9; var_8++ )
        {
            if ( var_8 == 5 )
                continue;

            if ( isdefined( var_0["cover_trans"][var_7][var_8] ) )
            {
                var_0["cover_trans_dist"][var_7][var_8] = getangledelta( var_0["cover_trans"][var_7][var_8], 0, 1 );
                var_0["cover_trans_move_end"][var_7][var_8] = animscripts\init_move_transitions::_id_C132( var_0["cover_trans"][var_7][var_8] );
                var_9 = lengthsquared( var_0["cover_trans_dist"][var_7][var_8] );

                if ( var_0["CoverTransLongestDistSq"][var_7] < var_9 )
                    var_0["CoverTransLongestDistSq"][var_7] = var_9;
            }
        }

        var_0["CoverTransLongestDist"][var_7] = sqrt( var_0["CoverTransLongestDistSq"][var_7] );
    }

    foreach ( var_5, var_3 in var_0["cover_trans"]["riotshield"] )
    {
        var_11 = getmovedelta( var_3, 0, 1 );
        var_0["cover_trans_angles"]["riotshield"][var_5] = var_11;
    }

    foreach ( var_5, var_3 in var_0["start_run"]["riotshield_crouch"] )
    {
        var_11 = getmovedelta( var_3, 0, 1 );
        var_0["start_run_angles"]["riotshield_crouch"][var_5] = var_11;
    }

    animscripts\animset::registerarchetype( "riotshield", var_0, 0 );
    anim.arrivalendstance["riotshield"] = "crouch";
    anim.arrivalendstance["riotshield_crouch"] = "crouch";
    animscripts\combat_utility::addgrenadethrowanimoffset( %h2_riotshield_grenadetoss_forward, ( -5.53443, 17.8644, -4.63202 ) );
    animscripts\combat_utility::addgrenadethrowanimoffset( %h2_riotshield_grenadetoss_right, ( -5.15326, 17.5312, -5.11841 ) );
    animscripts\combat_utility::addgrenadethrowanimoffset( %h2_riotshield_grenadetoss_left, ( -7.4863, 21.6584, -3.18823 ) );
}

notetrackdetachshield( var_0, var_1 )
{
    animscripts\shared::dropaiweapon( self.secondaryweapon );
    self.secondaryweapon = "none";

    if ( isalive( self ) )
        riotshield_turn_into_regular_ai();
}

riotshield_approach_type()
{
    if ( self.a.pose == "crouch" )
        return "riotshield_crouch";

    return "riotshield";
}

riotshield_approach_conditions( var_0 )
{
    return 1;
}

init_riotshield_ai()
{
    animscripts\shared::placeweaponon( self.secondaryweapon, "left", 0 );
    self.animarchetype = "riotshield";
    self initriotshieldhealth( self.secondaryweapon );
    self.shieldmodelvariant = 0;
    thread riotshield_damaged();
    self.subclass = "riotshield";
    self.approachtypefunc = ::riotshield_approach_type;
    self.approachconditioncheckfunc = ::riotshield_approach_conditions;
    self.faceenemyarrival = 1;
    self.disablecoverarrivalsonly = 1;
    self.pathrandompercent = 0;
    self.interval = 0;
    self.disabledoorbehavior = 1;
    self.no_pistol_switch = 1;
    self.dontshootwhilemoving = 1;
    self.disablebulletwhizbyreaction = 1;
    self.disablefriendlyfirereaction = 1;
    self.neversprintforvariation = 1;
    self.combatmode = "no_cover";
    self.fixednode = 0;
    self.maxfaceenemydist = 1500;
    self.nomeleechargedelay = 1;
    self.meleechargedistsq = squared( 256 );
    self.meleeplayerwhilemoving = 1;
    self.usemuzzlesideoffset = 1;

    if ( level.gameskill < 1 )
        self.shieldbulletblocklimit = randomintrange( 4, 8 );
    else
        self.shieldbulletblocklimit = randomintrange( 8, 12 );

    self.shieldbulletblockcount = 0;
    self.shieldbulletblocktime = 0;
    self.walkdist = 500;
    self.walkdistfacingmotion = 500;
    self.grenadeawareness = 1;
    self.frontshieldanglecos = 0.5;
    self.nogrenadereturnthrow = 1;
    self.a.grenadethrowpose = "crouch";
    self.minexposedgrenadedist = 400;
    self.ignoresuppression = 1;
    self.specialmelee_standard = ::riotshield_melee_standard;
    self.specialmeleechooseaction = ::riotshield_melee_aivsai;
    self.customarrivalfunc = ::_id_B4C0;
    maps\_utility::disable_turnanims();
    maps\_utility::disable_surprise();
    maps\_utility::disable_cqbwalk();
    init_riotshield_animsets();

    if ( level.gameskill < 1 )
        self.bullet_resistance = 30;
    else
        self.bullet_resistance = 40;

    maps\_utility::add_damage_function( maps\_spawner::bullet_resistance );
    maps\_utility::add_damage_function( animscripts\pain::additive_pain );
}

riotshield_charge()
{
    if ( !animscripts\melee::melee_standard_updateandvalidatetarget() )
        return 0;

    if ( isai( self.melee.target ) && ( self.melee.target maps\_utility::doinglongdeath() || self.melee.target.delayeddeath ) )
    {
        var_0 = getangledelta( %riotshield_basha_attack, 0, 1 );
        var_1 = lengthsquared( var_0 );
        var_1 += 1600;
    }
    else
    {
        var_0 = getangledelta( %riotshield_basha_attack, 0, 1 );
        var_1 = lengthsquared( var_0 );
    }

    if ( distancesquared( self.origin, self.melee.target.origin ) < var_1 )
        return 1;

    animscripts\melee::melee_playchargesound();
    var_2 = 0.1;
    var_3 = 1;

    for (;;)
    {
        if ( !animscripts\melee::melee_standard_updateandvalidatetarget() )
            return 0;

        if ( var_3 )
        {
            self.a.pose = "stand";
            self setflaggedanimknoball( "chargeanim", %riotshield_sprint, %body, 1, 0.2, 1 );
            var_3 = 0;
        }

        self orientmode( "face point", self.melee.target.origin );
        animscripts\notetracks::donotetracksfortime( var_2, "chargeanim" );
        var_4 = distancesquared( self.origin, self.melee.target.origin );

        if ( var_4 < var_1 )
            break;

        if ( isai( self.melee.target ) && var_4 < var_1 * 1.5 )
            var_2 = 0.05;

        if ( gettime() >= self.melee.giveuptime )
            return 0;
    }

    return 1;
}

riotshield_melee_standard()
{
    self animmode( "zonly_physics" );
    animscripts\melee::melee_standard_resetgiveuptime();

    for (;;)
    {
        if ( !riotshield_charge() )
        {
            self.nextmeleechargetime = gettime() + 1500;
            self.nextmeleechargetarget = self.melee.target;
            break;
        }

        animscripts\battlechatter_ai::evaluatemeleeevent();
        self orientmode( "face point", self.melee.target.origin );

        if ( isai( self.melee.target ) && ( self.melee.target maps\_utility::doinglongdeath() || self.melee.target.delayeddeath ) )
            self setflaggedanimknoballrestart( "meleeanim", %h2_riotshield_close_melee, %body, 1, 0.2, 1 );
        else
            self setflaggedanimknoballrestart( "meleeanim", %riotshield_bash_vs_player, %body, 1, 0.2, 1 );

        self.melee.inprogress = 1;

        if ( !animscripts\melee::melee_standard_playattackloop() )
        {
            animscripts\melee::melee_standard_delaystandardcharge( self.melee.target );
            break;
        }

        self animmode( "none" );
    }

    self animmode( "none" );
}

riotshield_melee_aivsai()
{
    var_0 = self.melee.target;

    if ( self.subclass == "riotshield" && var_0.subclass == "riotshield" )
        return 0;

    animscripts\melee::melee_decide_winner();
    var_1 = vectortoangles( var_0.origin - self.origin );
    var_2 = angleclamp180( var_0.angles[1] - var_1[1] );

    if ( abs( var_2 ) > 100 )
    {
        if ( self.melee.winner )
        {
            if ( self.subclass == "riotshield" )
            {
                if ( var_0 maps\_utility::doinglongdeath() || var_0.delayeddeath )
                    return 0;
                else
                {
                    self.melee.animname = %riotshield_basha_attack;
                    var_0.melee.animname = %riotshield_basha_defend;
                    var_0.melee.surviveanimname = %riotshield_basha_defend_survive;
                }
            }
            else
            {
                self.melee.animname = %riotshield_bashb_defend;
                var_0.melee.animname = %riotshield_bashb_attack;
            }
        }
        else if ( self.subclass == "riotshield" )
        {
            self.melee.animname = %riotshield_bashb_attack;
            var_0.melee.animname = %riotshield_bashb_defend;
        }
        else
        {
            self.melee.animname = %riotshield_basha_defend;
            var_0.melee.animname = %riotshield_basha_attack;
        }
    }
    else
        return 0;

    self.melee.startpos = getstartorigin( var_0.origin, var_0.angles, self.melee.animname );
    self.melee.startangles = ( var_0.angles[0], angleclamp180( var_0.angles[1] + 180 ), var_0.angles[2] );
    self.lockorientation = 0;
    var_0.lockorientation = 0;
    return animscripts\melee::melee_updateandvalidatestartpos();
}

_id_D221( var_0 )
{
    for ( var_1 = 0; self.lockorientation; var_1 += 0.1 )
    {
        wait 0.1;
        var_2 = self aiphysicstrace( self.origin, self.goalpos, 0, 0, 1, 1 );

        if ( var_2["fraction"] >= 1 || var_1 > var_0 )
            self.lockorientation = 0;
    }
}

_id_CD58()
{
    var_0 = self.moveplaybackrate;
    var_1 = 0.75;
    var_2 = 0;

    while ( self.moveplaybackrate < var_0 )
    {
        self.moveplaybackrate = maps\_utility::linear_interpolate( var_2 / var_1, 0, var_0 );
        var_2 += 0.05;
        wait 0.05;
    }

    self.moveplaybackrate = var_0;
}

_id_AC6E()
{
    if ( self.prevscript != "init" )
    {
        var_0 = vectortoyaw( self.lookaheaddir );
        var_1 = angleclamp180( var_0 - self.angles[1] );
        var_2 = undefined;
        var_3 = self aiphysicstrace( self.origin, self.goalpos, 10, 72, 1, 1 );

        if ( abs( var_1 ) > 90 && var_3["fraction"] < 1 )
            var_2 = common_scripts\utility::ter_op( var_1 > 0, %riotshield_crouch_lturn, %riotshield_crouch_rturn );

        if ( isdefined( var_2 ) )
        {
            self setflaggedanimknoballrestart( "exitnode", var_2, %body, 1, 0.1, 1.25 );
            animscripts\shared::donotetracks( "exitnode" );
        }
        else if ( 45 < abs( var_1 ) && abs( var_1 ) < 90 && var_3["fraction"] < 1 )
            return 1;
    }
    else
        return 1;

    return 0;
}

_id_CE11()
{
    var_0 = 0;
    var_1 = %riotshield_crouch2walk;

    if ( ( isdefined( self.sprint ) || isdefined( self.fastwalk ) ) && !_id_BB87() )
    {
        var_2 = self aiphysicstrace( self.origin, self.goalpos, 10, 72, 1, 1 );

        if ( var_2["fraction"] < 1 )
        {
            var_3 = vectortoyaw( self.lookaheaddir );
            var_4 = self.lookaheaddir;
        }
        else
        {
            var_3 = vectortoyaw( self.goalpos - self.origin );
            var_4 = vectornormalize( self.goalpos - self.origin );
        }

        var_5 = _id_C879( var_3, "start_run", "riotshield_crouch" );
        var_6 = var_5[0];
        var_1 = animscripts\utility::lookupanim( "start_run", "riotshield_crouch" )[var_6];
        var_7 = animscripts\utility::lookupanim( "start_run_dist", "riotshield_crouch" )[var_6];
        var_8 = common_scripts\utility::ter_op( isdefined( self.approachtype ), self.approachtype, "riotshield" );
        var_9 = getnotetracktimes( var_1, "code_move" );
        var_10 = var_4 * var_7 * var_9[0];
        var_11 = self.origin + var_10;
        var_2 = self aiphysicstrace( self.origin, var_11, 10, 72, 1, 1 );

        if ( var_2["fraction"] < 1 )
        {
            var_0 = 1;
            var_1 = %riotshield_crouch2stand;
            _id_AC6E();
        }

        if ( !isdefined( var_1 ) )
        {
            var_0 = 1;
            var_1 = %riotshield_crouch2stand;
            _id_AC6E();
        }
    }

    var_12 = randomfloatrange( 0.9, 1.1 );

    if ( isdefined( self.copgroup ) )
        var_12 = 2.5;

    self setflaggedanimknoballrestart( "startmove", var_1, %body, 1, 0.1, var_12 );

    if ( var_0 )
        thread _id_CD58();

    animscripts\shared::donotetracks( "startmove" );
    self clearanim( %riotshield_crouch2walk, 0.5 );
}

riotshield_startmovetransition()
{
    self notify( "start_move" );
    self endon( "start_move" );

    if ( isdefined( self.disableexits ) )
        return;

    self orientmode( "face current" );
    self animmode( "zonly_physics", 0 );

    if ( self.a.pose == "crouch" )
        _id_CE11();

    if ( isdefined( self.sprint ) || isdefined( self.fastwalk ) )
    {
        self allowedstances( "stand", "crouch" );
        self.a.pose = "stand";
    }

    if ( !self.lockorientation )
        thread _id_D221( 1 );

    self orientmode( "face default" );
    self animmode( "normal", 0 );
    thread riotshield_bullet_hit_shield();
}

_id_BB87()
{
    return isdefined( self._id_C8ED ) && self._id_C8ED;
}

_id_CE0F()
{
    if ( !_id_BB87() )
        self.lockorientation = 0;
}

riotshield_endmovetransition()
{
    _id_CE0F();

    if ( self.prevscript == "move" && self.a.pose == "crouch" )
    {
        self clearanim( %animscript_root, 0.2 );
        var_0 = randomfloatrange( 0.9, 1.1 );

        if ( isdefined( self.copgroup ) )
            var_0 = 2.5;

        self animmode( "zonly_physics" );
        self setflaggedanimknoballrestart( "endmove", %riotshield_walk2crouch_8, %body, 1, 0.2, var_0 );
        animscripts\shared::donotetracks( "endmove" );
        self animmode( "normal" );
    }

    self allowedstances( "crouch" );
}

_id_C879( var_0, var_1, var_2 )
{
    var_2 = common_scripts\utility::ter_op( isdefined( var_2 ), var_2, self.approachtype );
    var_3 = undefined;
    var_4 = undefined;
    var_5 = animscripts\utility::lookupanim( var_1 + "_angles", var_2 );

    foreach ( var_10, var_7 in var_5 )
    {
        var_8 = angleclamp( self.angles[1] + var_7 );
        var_9 = angleclamp180( var_0 - var_8 );

        if ( !isdefined( var_4 ) || !isdefined( var_3 ) )
        {
            var_3 = var_10;
            var_4 = var_9;
            continue;
        }

        if ( abs( var_9 ) < abs( var_4 ) )
        {
            var_3 = var_10;
            var_4 = var_9;
        }
    }

    return [ var_3, var_4 ];
}

_id_BA92( var_0, var_1 )
{
    self endon( "killanimscript" );
    self endon( "abort_approach" );
    var_2 = animscripts\utility::lookupanim( "cover_trans_dist", self.approachtype )[var_0];
    var_3 = 3 * length2dsquared( var_2 ) / 4;

    while ( !isdefined( self.goalpos ) )
        wait 0.05;

    while ( distance2dsquared( self.origin, self.goalpos ) > var_3 )
        wait 0.05;

    _id_A937( var_1 );
}

_id_A937( var_0 )
{
    var_1 = 5;
    var_2 = common_scripts\utility::ter_op( var_0 > 0, var_1, var_1 * -1 );

    while ( abs( var_0 ) > var_1 )
    {
        self orientmode( "face angle", self.angles[1] + var_2 );
        var_0 -= var_2;
        wait 0.05;
    }

    self orientmode( "face angle", self.angles[1] + var_0 );
}

_id_B4C0()
{
    self endon( "killanimscript" );
    self endon( "abort_approach" );
    _id_CE0F();

    while ( !isdefined( self.goalpos ) )
        wait 0.05;

    var_0 = %riotshield_walk2crouch_8;
    var_1 = self aiphysicstrace( self.origin, self.goalpos, 10, 72, 1, 1 );

    if ( !_id_BB87() )
    {
        if ( var_1["fraction"] < 1 )
            return;

        var_2 = vectortoyaw( self.goalpos - self.origin );

        if ( isdefined( self.color_node ) && self.goalpos == self.color_node.origin )
        {
            var_2 = self.color_node.angles[1];

            switch ( self.color_node.type )
            {
                case "Cover Left":
                    var_2 += 60;
                    break;
                case "Cover Right":
                    var_2 -= 60;
                    break;
            }

            var_2 = angleclamp( var_2 );
        }

        var_3 = _id_C879( var_2, "cover_trans" );
        var_4 = var_3[0];
        var_5 = var_3[1];
        var_0 = animscripts\utility::lookupanim( "cover_trans", self.approachtype )[var_4];
        thread _id_BA92( var_4, var_5 );
    }

    self clearanim( %body, 0.2 );
    self setflaggedanimrestart( "coverArrival", var_0, 1, 0.2, self.movetransitionrate );
    animscripts\face::playfacialanim( var_0, "run" );
    animscripts\shared::donotetracks( "coverArrival" );
    var_6 = anim.arrivalendstance[self.approachtype];

    if ( isdefined( var_6 ) )
        self.a.pose = var_6;

    self.a.movement = "stop";
    self.a.arrivaltype = self.approachtype;
    self clearanim( %animscript_root, 0.2 );

    if ( _id_BB87() )
        self setgoalpos( self.origin );

    self.lastapproachaborttime = undefined;
}

riotshield_startcombat()
{
    _id_CE0F();
    riotshield_endmovetransition();
    self.pushable = 0;
    thread riotshield_bullet_hit_shield();
}

riotshield_bullet_hit_shield()
{
    self endon( "killanimscript" );

    for (;;)
    {
        self waittill( "bullet_hitshield" );
        var_0 = gettime();

        if ( var_0 - self.shieldbulletblocktime > 500 )
            self.shieldbulletblockcount = 0;
        else
            self.shieldbulletblockcount++;

        self.shieldbulletblocktime = var_0;

        if ( self.shieldbulletblockcount > self.shieldbulletblocklimit )
            self dodamage( 1, ( 0, 0, 0 ) );

        if ( common_scripts\utility::cointoss() )
            var_1 = %riotshield_reacta;
        else
            var_1 = %riotshield_reactb;

        self notify( "new_hit_react" );
        self setflaggedanimrestart( "hitreact", var_1, 1, 0.1, 1 );
        thread riotshield_bullet_hit_shield_clear();
    }
}

riotshield_bullet_hit_shield_clear()
{
    self endon( "killanimscript" );
    self endon( "new_hit_react" );
    self waittillmatch( "hitreact", "end" );
    self clearanim( %riotshield_react, 0.1 );
}

riotshield_grenadecower()
{
    if ( self.a.pose == "stand" )
    {
        self clearanim( %animscript_root, 0.2 );
        self setflaggedanimknoballrestart( "trans", %riotshield_walk2crouch_8, %body, 1, 0.2, 1.2 );
        animscripts\shared::donotetracks( "trans" );
    }

    if ( isdefined( self.grenade ) )
    {
        var_0 = 1;
        var_1 = self.grenade.origin - self.origin;

        if ( isdefined( self.enemy ) )
        {
            var_2 = self.enemy.origin - self.origin;

            if ( vectordot( var_1, var_2 ) < 0 )
                var_0 = 0;
        }

        if ( var_0 )
        {
            var_3 = angleclamp180( self.angles[1] - vectortoyaw( var_1 ) );

            if ( !isdefined( self.turnthreshold ) )
                self.turnthreshold = 55;

            while ( abs( var_3 ) > self.turnthreshold )
            {
                if ( !isdefined( self.a.array ) )
                    animscripts\combat::setup_anim_array();

                if ( !animscripts\combat::turntofacerelativeyaw( var_3 ) )
                    break;

                var_3 = angleclamp180( self.angles[1] - vectortoyaw( var_1 ) );
            }
        }
    }

    self setanimknoball( %riotshield_crouch_aim_5, %body, 1, 0.2, 1 );
    self setflaggedanimknoballrestart( "grenadecower", %riotshield_crouch_idle_add, %add_idle, 1, 0.2, self.animplaybackrate );
    animscripts\shared::donotetracks( "grenadecower" );
}

riotshield_flashbang()
{
    self notify( "flashed" );

    if ( !isdefined( self.a.onback ) )
    {
        var_0 = randomfloatrange( 0.9, 1.1 );
        self.frontshieldanglecos = 1;
        var_1 = [];
        var_1[0] = %riotshield_crouch_grenade_flash1;
        var_1[1] = %riotshield_crouch_grenade_flash2;
        var_1[2] = %riotshield_crouch_grenade_flash3;
        var_1[3] = %riotshield_crouch_grenade_flash4;
        var_2 = var_1[randomint( var_1.size )];
        self setflaggedanimknoballrestart( "flashanim", var_2, %body, 1, 0.1, var_0 );
        self.minpaindamage = 1000;
        animscripts\shared::donotetracks( "flashanim" );
    }
    else
        wait 0.1;

    self.minpaindamage = 0;

    if ( isdefined( self.subclass ) && self.subclass == "riotshield" )
        self.frontshieldanglecos = 0.5;
}

riotshield_pain()
{
    self.a.pose = "crouch";

    if ( animscripts\utility::usingsidearm() )
        maps\_utility::forceuseweapon( self.primaryweapon, "primary" );

    if ( !isdefined( self.a.onback ) )
    {
        var_0 = randomfloatrange( 0.8, 1.15 );
        self.frontshieldanglecos = 1;

        if ( isexplosivedamagemod( self.damagemod ) )
        {
            if ( self.damagetaken > 65 )
            {
                if ( abs( self.damageyaw ) > 135 )
                    var_1 = common_scripts\utility::random( [ %h2_riotshield_crouch_grenadeblowback_front, %h2_crouchshield_grenade_blowback_f ] );

                if ( self.damageyaw < 0 )
                    var_1 = common_scripts\utility::random( [ %h2_riotshield_crouch_grenadeblowback_right, %h2_crouchshield_grenade_blowback_r ] );
                else
                    var_1 = common_scripts\utility::random( [ %h2_riotshield_crouch_grenadeblowback_left, %h2_crouchshield_grenade_blowback_l ] );

                self setflaggedanimknoballrestart( "painanim", var_1, %body, 1, 0.2, var_0 );

                if ( self.damageyaw < -120 || self.damageyaw > 120 )
                    self.minpaindamage = 1000;
            }
            else
            {
                var_2 = animscripts\utility::lookupanim( "pain", self.animarchetype );

                if ( !isdefined( level.riotshieldpainexplosiongrenadeindex ) )
                    level.riotshieldpainexplosiongrenadeindex = randomint( var_2.size );

                var_3 = var_2[level.riotshieldpainexplosiongrenadeindex];
                level.riotshieldpainexplosiongrenadeindex = ( level.riotshieldpainexplosiongrenadeindex + 1 ) % var_2.size;
                self setflaggedanimknoballrestart( "painanim", var_3, %body, 1, 0.2, var_0 );
            }
        }
        else
        {
            var_2 = animscripts\utility::lookupanim( "pain", self.animarchetype );
            var_3 = var_2[randomint( var_2.size )];
            self setflaggedanimknoballrestart( "painanim", var_3, %body, 1, 0.2, var_0 );
        }

        animscripts\shared::donotetracks( "painanim" );
    }
    else
        wait 0.1;

    self.minpaindamage = 0;

    if ( isdefined( self.subclass ) && self.subclass == "riotshield" )
        self.frontshieldanglecos = 0.5;
}

riotshield_death()
{
    if ( isdefined( self.a.onback ) && self.a.pose == "crouch" )
    {
        var_0 = [];
        var_0[0] = %dying_back_death_v2;
        var_0[1] = %dying_back_death_v3;
        var_0[2] = %dying_back_death_v4;
        var_1 = var_0[randomint( var_0.size )];
        animscripts\death::playdeathanim( var_1 );
        return 1;
    }

    if ( self.prevscript == "pain" || self.prevscript == "flashed" )
        var_2 = randomint( 2 ) == 0;
    else
        var_2 = 1;

    if ( var_2 )
    {
        if ( isexplosivedamagemod( self.damagemod ) )
        {
            if ( abs( self.damageyaw ) > 135 )
                var_1 = %riotshield_crouch_death_fallback;
            else if ( abs( self.damageyaw ) < 45 )
                var_1 = common_scripts\utility::random( [ %h2_riotshield_crouch_grenade_death, %h2_riotshield_crouch_grenade_death_b_v1, %h2_riotshield_crouch_grenade_death_b_v2 ] );
            else if ( self.damageyaw > 0 )
                var_1 = %h2_riotshield_crouch_grenade_death_r;
            else
                var_1 = %h2_riotshield_crouch_grenade_death_l;
        }
        else if ( animscripts\utility::damagelocationisany( "right_arm_upper", "right_arm_lower", "right_hand", "right_leg_upper", "right_leg_lower", "rightt_foot" ) )
            var_1 = common_scripts\utility::ter_op( common_scripts\utility::cointoss(), %h2_riotshield_crouchdeath_left_01, %h2_riotshield_crouchdeath_left_02 );
        else if ( animscripts\utility::damagelocationisany( "left_arm_upper", "left_arm_lower", "left_hand", "left_leg_upper", "left_leg_lower", "left_foot" ) )
            var_1 = common_scripts\utility::ter_op( common_scripts\utility::cointoss(), %h2_riotshield_crouchdeath_right_01, %h2_riotshield_crouchdeath_right_02 );
        else
            var_1 = common_scripts\utility::ter_op( abs( self.damageyaw ) < 90, %riotshield_crouch_death, %riotshield_crouch_death_fallback );

        animscripts\death::playdeathanim( var_1 );
        return 1;
    }

    self.a.pose = "crouch";
    return 0;
}

init_riotshield_animsets()
{
    var_0 = [];
    var_0["sprint"] = %riotshield_sprint;
    var_0["prone"] = %prone_crawl;
    var_0["straight"] = %riotshield_run_f;
    var_0["smg_straight"] = %riotshield_run_f;
    var_0["move_f"] = %riotshield_run_f;
    var_0["move_l"] = %riotshield_run_l;
    var_0["move_r"] = %riotshield_run_r;
    var_0["move_b"] = %riotshield_run_b;
    var_0["crouch"] = %riotshield_crouchwalk_f;
    var_0["crouch_l"] = %riotshield_crouchwalk_l;
    var_0["crouch_r"] = %riotshield_crouchwalk_r;
    var_0["crouch_b"] = %riotshield_crouchwalk_b;
    var_0["stairs_up"] = %traverse_stair_run_01;
    var_0["stairs_down"] = %traverse_stair_run_down;
    self.custommoveanimset["run"] = var_0;
    self.custommoveanimset["walk"] = var_0;
    self.custommoveanimset["cqb"] = var_0;
    self.customidleanimset = [];
    self.customidleanimset["crouch"] = %riotshield_crouch_aim_5;
    self.customidleanimset["crouch_add"] = %riotshield_crouch_idle_add;
    self.customidleanimset["stand"] = %riotshield_crouch_aim_5;
    self.customidleanimset["stand_add"] = %riotshield_crouch_idle_add;
    self.a.pose = "crouch";
    self allowedstances( "crouch" );
    var_0 = anim.animsets.defaultstand;
    var_0["add_aim_up"] = %riotshield_crouch_aim_8;
    var_0["add_aim_down"] = %riotshield_crouch_aim_2;
    var_0["add_aim_left"] = %riotshield_crouch_aim_4;
    var_0["add_aim_right"] = %riotshield_crouch_aim_6;
    var_0["straight_level"] = %riotshield_crouch_aim_5;
    var_0["fire"] = %riotshield_crouch_fire_auto;
    var_0["single"] = animscripts\utility::array( %riotshield_crouch_fire_single );
    var_0["burst2"] = %riotshield_crouch_fire_burst;
    var_0["burst3"] = %riotshield_crouch_fire_burst;
    var_0["burst4"] = %riotshield_crouch_fire_burst;
    var_0["burst5"] = %riotshield_crouch_fire_burst;
    var_0["burst6"] = %riotshield_crouch_fire_burst;
    var_0["semi2"] = %riotshield_crouch_fire_burst;
    var_0["semi3"] = %riotshield_crouch_fire_burst;
    var_0["semi4"] = %riotshield_crouch_fire_burst;
    var_0["semi5"] = %riotshield_crouch_fire_burst;
    var_0["exposed_idle"] = animscripts\utility::array( %riotshield_crouch_idle_add, %riotshield_crouch_twitch );
    var_0["exposed_grenade"] = animscripts\utility::array( %h2_riotshield_grenadetoss_forward, %h2_riotshield_grenadetoss_right, %h2_riotshield_grenadetoss_left );
    var_0["reload"] = animscripts\utility::array( %h2_riotshield_reload_01 );
    var_0["reload_crouchhide"] = animscripts\utility::array( %h2_riotshield_reload_01 );
    var_0["turn_left_45"] = %riotshield_crouch_lturn;
    var_0["turn_left_90"] = %riotshield_crouch_lturn;
    var_0["turn_left_135"] = %riotshield_crouch_lturn;
    var_0["turn_left_180"] = %riotshield_crouch_lturn;
    var_0["turn_right_45"] = %riotshield_crouch_rturn;
    var_0["turn_right_90"] = %riotshield_crouch_rturn;
    var_0["turn_right_135"] = %riotshield_crouch_rturn;
    var_0["turn_right_180"] = %riotshield_crouch_rturn;
    var_0["stand_2_crouch"] = %riotshield_walk2crouch_8;
    animscripts\animset::init_animset_complete_custom_stand( var_0 );
    animscripts\animset::init_animset_complete_custom_crouch( var_0 );
    self.chooseposefunc = ::riotshield_choose_pose;
    self.painfunction = ::riotshield_pain;
    self.specialdeathfunc = ::riotshield_death;
    self.specialflashedfunc = ::riotshield_flashbang;
    self.grenadecowerfunction = ::riotshield_grenadecower;
    self.custommovetransition = ::riotshield_startmovetransition;
    self.permanentcustommovetransition = 1;
    common_scripts\utility::set_exception( "exposed", ::riotshield_startcombat );
}

riotshield_choose_pose( var_0 )
{
    if ( isdefined( self.grenade ) )
        return "stand";

    return animscripts\utility::choosepose( var_0 );
}

riotshield_sprint_on()
{
    self.maxfaceenemydist = 128;
    self.sprint = 1;
    self orientmode( "face default" );
    self.lockorientation = 0;
    self.walkdist = 32;
    self.walkdistfacingmotion = 32;
}

riotshield_fastwalk_on()
{
    self.maxfaceenemydist = 128;
    self.fastwalk = 1;
    self.walkdist = 32;
    self.walkdistfacingmotion = 32;
}

riotshield_sprint_off()
{
    self.maxfaceenemydist = 1500;
    self.walkdist = 500;
    self.walkdistfacingmotion = 500;
    self.sprint = undefined;
    self allowedstances( "crouch" );
}

riotshield_fastwalk_off()
{
    self.maxfaceenemydist = 1500;
    self.walkdist = 500;
    self.walkdistfacingmotion = 500;
    self.fastwalk = undefined;
    self allowedstances( "crouch" );
}

null_func()
{

}

riotshield_init_flee()
{
    if ( self.script == "move" )
        self animcustom( ::null_func );

    self.custommovetransition = ::riotshield_flee_and_drop_shield;
}

riotshield_flee_and_drop_shield()
{
    iPrintLnbold("riotshield_flee_and_drop_shield");
    self.custommovetransition = ::riotshield_startmovetransition;
    self.custommovetransitionendscript = ::riotshield_force_drop_shield;
    self animmode( "zonly_physics", 0 );
    self orientmode( "face current" );

    if ( !isdefined( self.dropshieldinplace ) && isdefined( self.enemy ) && vectordot( self.lookaheaddir, anglestoforward( self.angles ) ) < 0 )
        var_0 = %riotshield_crouch2walk_2flee;
    else
        var_0 = %riotshield_crouch2stand_shield_drop;

    var_1 = randomfloatrange( 0.85, 1.1 );
    self setflaggedanimknoball( "fleeanim", var_0, %animscript_root, 1, 0.1, var_1 );
    animscripts\shared::donotetracks( "fleeanim" );
    self.custommovetransitionendscript = undefined;
    self.maxfaceenemydist = 32;
    self.lockorientation = 0;
    self orientmode( "face default" );
    self animmode( "normal", 0 );
    animscripts\shared::donotetracks( "fleeanim" );
    self clearanim( var_0, 0.2 );
    self.maxfaceenemydist = 128;
}

riotshield_force_drop_shield()
{
    notetrackdetachshield();
}

riotshield_turn_into_regular_ai()
{
    self.subclass = "regular";
    self.combatmode = "cover";
    self.animarchetype = undefined;
    self.approachtypefunc = undefined;
    self.approachconditioncheckfunc = undefined;
    self.faceenemyarrival = undefined;
    self.disablecoverarrivalsonly = undefined;
    self.pathrandompercent = 0;
    self.interval = 80;
    self.disabledoorbehavior = undefined;
    self.no_pistol_switch = undefined;
    self.dontshootwhilemoving = undefined;
    self.disablebulletwhizbyreaction = undefined;
    self.disablefriendlyfirereaction = undefined;
    self.neversprintforvariation = undefined;
    self.maxfaceenemydist = 128;
    self.nomeleechargedelay = undefined;
    self.meleechargedistsq = undefined;
    self.meleeplayerwhilemoving = undefined;
    self.usemuzzlesideoffset = undefined;
    self.pathenemyfightdist = 128;
    self.pathenemylookahead = 128;
    self.walkdist = 256;
    self.walkdistfacingmotion = 64;
    self.lockorientation = 0;
    self.frontshieldanglecos = 1;
    self.nogrenadereturnthrow = 0;
    self.ignoresuppression = 0;
    self.sprint = undefined;
    self allowedstances( "stand", "crouch", "prone" );
    self.specialmelee_standard = undefined;
    self.specialmeleechooseaction = undefined;
    self.customarrivalfunc = undefined;
    maps\_utility::enable_turnanims();
    self.bullet_resistance = undefined;
    maps\_utility::remove_damage_function( maps\_spawner::bullet_resistance );
    maps\_utility::remove_damage_function( animscripts\pain::additive_pain );
    animscripts\animset::clear_custom_animset();
    self.chooseposefunc = animscripts\utility::choosepose;
    self.painfunction = undefined;
    self.specialdeathfunc = undefined;
    self.specialflashedfunc = undefined;
    self.grenadecowerfunction = undefined;
    self.custommovetransition = undefined;
    self.permanentcustommovetransition = undefined;
    common_scripts\utility::clear_exception( "exposed" );
    common_scripts\utility::clear_exception( "stop_immediate" );
}

riotshield_damaged()
{
    self endon( "death" );
    self waittill( "riotshield_damaged" );
    self.shieldbroken = 1;
    animscripts\shared::detachallweaponmodels();
    self.shieldmodelvariant = 1;
    animscripts\shared::updateattachedweaponmodels();
}
