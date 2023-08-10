#include common_scripts\utility;
#include maps\_utility;
#include maps\_so_survival_code;

perks_preload()
{

}

perks_init()
{
	
}

// gives perk to player, replace perk is optional
give_perk( give_ref )
{
	if ( self hasPerk( give_ref, true ) )
		return true;
	
	// one at a time
	self ClearPerks();

	switch ( give_ref )
	{
		case "specialty_stalker":
			self thread give_perk_stalker();
			break;
		case "specialty_longersprint":
			self thread give_perk_longersprint();
			break;
		case "specialty_fastreload":
			self thread give_perk_fastreload();
			break;
		case "specialty_quickdraw":
			self thread give_perk_quickdraw();
			break;
		case "specialty_detectexplosive":
			self thread give_perk_detectexplosive();
			break;
		case "specialty_bulletaccuracy":
			self thread give_perk_bulletaccuracy();
			break;
		default:
			self thread give_perk_dummy();
			break;
	}
	
	self notify( "give_perk", give_ref );
	
	return true;
}

// if replacing perk, use give_perk( give, replace ) instead, dont call take_perk() then give_perk() immediately
take_perk( take_ref )
{
	if ( !self hasperk( take_ref, true ) )
		return;
	
	switch ( take_ref )
	{
		case "specialty_stalker":
			self thread take_perk_stalker();
			break;
		case "specialty_longersprint":
			self thread take_perk_longersprint();
			break;
		case "specialty_fastreload":
			self thread take_perk_fastreload();
			break;
		case "specialty_quickdraw":
			self thread take_perk_quickdraw();
			break;
		case "specialty_detectexplosive":
			self thread take_perk_detectexplosive();
			break;
		case "specialty_bulletaccuracy":
			self thread take_perk_bulletaccuracy();
			break;
		default:
			self thread take_perk_dummy();
			break;
	}
	self notify( "take_perk", take_ref );
}


// ======================================================================
// PERK FUNCTIONS
// ======================================================================

give_perk_dummy()
{
}

take_perk_dummy()
{
}

// ======================================================================
// Extreme Conditioning [code] - Longer sprint duration

give_perk_longersprint()
{
	self SetPerk( "specialty_longersprint", true, true );
}

take_perk_longersprint()
{
	self UnSetPerk( "specialty_longersprint", true );
}

// ======================================================================
// Sleight of Hand [code] - Faster reload

give_perk_fastreload()
{
	self SetPerk( "specialty_fastreload", 1, 1 );
}

take_perk_fastreload()
{
	self UnSetPerk( "specialty_fastreload", true, true);
}

// ======================================================================
// Quickdraw [code] - Faster aiming/ADS

give_perk_quickdraw()
{
	self SetPerk( "specialty_quickdraw", true, true );
}

take_perk_quickdraw()
{
	self UnSetPerk( "specialty_quickdraw", true );
}

// ======================================================================
// Sitrep [code] - Detect enemy equipments

give_perk_detectexplosive()
{
	self SetPerk( "specialty_detectexplosive", true, true );
}

take_perk_detectexplosive()
{
	self UnSetPerk( "specialty_detectexplosive", true );
}

// ======================================================================
// Steady Aim [code] - Increased hipfire accurracy

give_perk_bulletaccuracy()
{
	self SetPerk( "specialty_bulletaccuracy", true, true );
}

take_perk_bulletaccuracy()
{
	self UnSetPerk( "specialty_bulletaccuracy", true );
}

// ======================================================================
// Stalker [code] - Move faster while aiming
give_perk_stalker()
{
	self SetPerk( "specialty_stalker", true, true );
}

take_perk_stalker()
{
	self UnSetPerk( "specialty_stalker", true );
}

// ======================================================================
// HUD
// ======================================================================

// refreshes perk display on HUD
perk_HUD()
{
	// self is player
	self flag_init( "HUD_giving_perk" );
	self flag_init( "HUD_taking_perk" );
	
	self thread update_on_give_perk();
	self thread update_on_take_perk();
	
	// HUD for perks and stuff
	
}

update_on_give_perk()
{
	self endon( "death" );
	
	while ( 1 )
	{
		self waittill( "give_perk", ref );
		
		self flag_set( "HUD_giving_perk" );
		while ( self flag( "HUD_taking_perk" ) )
			wait 0.05;
		
		// play give perk animation on HUD
		
		
		wait 1;
		self flag_clear( "HUD_giving_perk" );
	}
}

update_on_take_perk()
{
	self endon( "death" );
	
	while ( 1 )
	{
		self waittill( "take_perk", ref );

		self flag_set( "HUD_taking_perk" );
		while ( self flag( "HUD_giving_perk" ) )
			wait 0.05;
					
		// remove perk animation on HUD
		
		
		wait 1;
		self flag_clear( "HUD_taking_perk" );
	}
}
