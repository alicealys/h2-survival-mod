#include common_scripts\utility;
#include maps\_so_survival_code;

// Tweakables: Loot
#define LOOT_TABLE "sp/survival_loot.csv" // loot data tablelookup

#define TABLE_INDEX 0 // indexing
#define TABLE_REF 1 // reference loot asset name
#define TABLE_TYPE 2 // loot type
#define TABLE_NAME 3 // name
#define TABLE_DESC 4 // description
#define TABLE_CHANCE 5 // drop probability
#define TABLE_WAVE_UNLOCK 6 // earliest wave this loot can drop at
#define TABLE_WAVE_LOCK 7 // wave at which this loot stops dropping
#define TABLE_RANK 8 // player rank required for this loot to drop
#define TABLE_VAR1 9 // misc var for special needs

#define LOOT_INDEX_START 0 // starting index of weapon loot items in string table
#define LOOT_INDEX_END 20 // ending index of weapon loot items in string table

#define LOOT_VERSION_INDEX_START 100 // starting index of weapon type permutations
#define LOOT_VERSION_INDEX_END 199 // starting index of weapon type permutations

#define CONST_WEAPON_DROP_AMMO_CLIP				 0.4	// 0-1.0 rate of max ammo in clip on loot drops
#define CONST_WEAPON_DROP_AMMO_STOCK			 0.5	// 0-1.0 rate of max ammo in stock on loot drops
#define CONST_WEAPON_DROP_ALT_AMMO_CLIP			 0.5	// 0-1.0 rate of max ammo in clip of attachment
#define CONST_WEAPON_DROP_ALT_AMMO_STOCK		 0.5	// 0-1.0 rate of max ammo in stock of attachment


#define CONST_LOOT_DROP_MIN_WAVES_LAST_DROP		 2	// Waves since a loot type has dropped before it can be dropped again (type not version)
#define CONST_LOOT_LAST_WAVE_DROP_DEFAULT		 -999	// When a loot is being dropped for the first time, this is the last wave it was dropped.
loot_preload()
{
	// precaches all possible loots
	for ( i = LOOT_INDEX_START; i <= LOOT_INDEX_END; i++ )
	{
		loot_ref = get_loot_ref_by_index( i );
		
		if( isdefined( loot_ref ) && get_loot_type( loot_ref ) == "weapon" )
			precache_loadout_item( loot_ref );
	}
	
	// precaches all possible loot versions
	for ( i = LOOT_VERSION_INDEX_START; i <= LOOT_VERSION_INDEX_END; i++ )
	{
		loot_version = get_loot_version_by_index( i );
		
		if( isdefined( loot_version ) )
			precache_loadout_item( loot_version );
	}
}

loot_postload()
{
	
}

loot_init()
{
	loot_populate( LOOT_INDEX_START, LOOT_INDEX_END, LOOT_VERSION_INDEX_START, LOOT_VERSION_INDEX_END );
}

loot_populate( loot_start_idx, loot_end_idx, version_start_idx, version_end_idx )
{
	// Fill the loot version array
	level.loot_version_array = [];
	for ( i = version_start_idx; i <= version_end_idx; i++ )
	{
		version = get_loot_version_by_index( i );
		
		if ( isdefined( version ) && version != "" )
		{
			level.loot_version_array[ level.loot_version_array.size ] = version;
		}
	}
	
	// Next fill the loot info array
	level.loot_info_array = [];
	for ( i = loot_start_idx; i <= loot_end_idx; i++ )
	{
		loot_ref = get_loot_ref_by_index( i );
		
		if( !isdefined( loot_ref ) || loot_ref == "" )
			continue;
		
		loot_type = get_loot_type( loot_ref );
		
		if ( !isdefined( level.loot_info_array[ loot_type ] ) )
			level.loot_info_array[ loot_type ] = [];
			
		item 				= spawnstruct();
		item.index 			= i;
		item.ref			= loot_ref;
		item.type			= loot_type;
		item.name			= get_loot_name( loot_ref );
		item.desc			= get_loot_desc( loot_ref );
		item.chance			= get_loot_chance( loot_ref );
		item.wave_unlock	= get_loot_wave_unlock( loot_ref );
		item.wave_lock		= get_loot_wave_lock( loot_ref );
		item.wave_dropped	= CONST_LOOT_LAST_WAVE_DROP_DEFAULT;
		item.rank			= get_loot_rank( loot_ref );
		item.versions		= get_loot_versions( loot_ref );
		
		level.loot_info_array[ loot_type ][ loot_ref ] = item;
	}
}

loot_roll( chance_override )
{
	if ( !isdefined( level.loot_info_array ) || !isdefined( level.loot_info_array[ "weapon" ] ) )
		return false;
	
	loot_item_array = [];
	
	// Collect loot type drop options according to required
	// rank and required wave number
	foreach( loot in level.loot_info_array[ "weapon" ] )
	{
		if	( 
			level.current_wave >= loot.wave_unlock
		&&	level.current_wave < loot.wave_lock
		&&	level.current_wave - loot.wave_dropped >= CONST_LOOT_DROP_MIN_WAVES_LAST_DROP
		&&	highest_player_rank() >= loot.rank
			)
		{
			loot_item_array[ loot_item_array.size ] = loot;
		}
	}
	
	if ( !loot_item_array.size )
		return false;
	
	// Sort loot according to last dropped
	loot_item_array = maps\_utility_joec::exchange_sort_by_handler( loot_item_array, ::loot_roll_compare_type_wave_dropped );
	
	loot_version = undefined;
	
	// Now roll on each possible loot and early out when one is found
	foreach( loot in loot_item_array )
	{
		chance = ter_op( isdefined( chance_override ), chance_override, loot.chance );
		if ( chance > randomfloatrange( 0.0, 1.0 ) )
		{
			loot_version = loot.versions[ randomint( loot.versions.size ) ];
			loot.wave_dropped = level.current_wave;
			break;
		}
	}
	
	// currently only weapons are dropped as loot
	if ( isdefined( loot_version ) )
	{
		weapon_name 	= loot_version;
		weapon_model 	= getweaponmodel( weapon_name );
		self.dropweapon	= false;
		
		self thread loot_drop_on_death( "weapon_" + weapon_name, weapon_name, "weapon", weapon_model, "tag_stowed_back" );

		return true;
	}
	
	return false;
}

loot_roll_compare_type_wave_dropped()
{
	assertex( isdefined( self ) && isdefined( self.wave_dropped ), "self.wave_dropped not defined." );
	
	last_drop_wave = ter_op( isdefined( self ) && isdefined( self.wave_dropped ), self.wave_dropped, CONST_LOOT_LAST_WAVE_DROP_DEFAULT );
	return last_drop_wave;
}

loot_drop_on_death( loot_class, loot_name, loot_type, model_name, tag )
{
	level endon( "special_op_terminated" );
	
	// Link the model instead of using Attach() because attach
	// actually messes with the AI weapon management logic
	loot_model = spawn( "script_model", self gettagorigin( tag ) );
	loot_model setmodel( model_name );
	loot_model linkto( self, tag, (0, 0, 0), (0, 0, 0) );
	
	self waittill_any( "death", "long_death" );
		
	//assertex( isdefined( self ), "Loot carrier self reference not valid after death." );
	if ( !isdefined( self ) )
		return;
	
	// Spawn the loot item
	loot_item = spawn( loot_class, self gettagorigin( tag ) );
	if ( isdefined( loot_type ) && loot_type == "weapon" )
	{
		ammo_in_clip 	= int( max( 1, CONST_WEAPON_DROP_AMMO_CLIP * weaponclipsize( loot_name ) ) );
		ammo_in_stock 	= int( max( 1, CONST_WEAPON_DROP_AMMO_STOCK * weaponmaxammo( loot_name ) ) );
		
		loot_item itemweaponsetammo( ammo_in_clip, ammo_in_stock );
		
		
		alt_weapon = weaponaltweaponname( loot_name );
		if ( alt_weapon != "none" )
		{
			ammo_alt_clip	= int( max( 1, CONST_WEAPON_DROP_ALT_AMMO_CLIP * weaponclipsize( alt_weapon ) ) );
			ammo_alt_stock	= int( max( 1, CONST_WEAPON_DROP_ALT_AMMO_STOCK * weaponmaxammo( alt_weapon ) ) );
			
			loot_item itemweaponsetammo( ammo_alt_clip, ammo_alt_stock, ammo_alt_clip, 1 );
		}
	}
		
	// debug
	print3d( loot_item.origin, "loot!", (1 ,1, 0), 0.5, 1, 200 );
	
	loot_model unlink();
	// Wait at least 0.05 to avoid error: cannot delete during think :-/
	wait 0.05;
	loot_model delete();
}

loot_item_exist( ref )
{
	return isdefined( level.loot_info_array ) && isdefined( level.loot_info_array[ ref ] );
}

get_loot_ref_by_index( idx )
{
	assertex( idx >= LOOT_INDEX_START && idx <= LOOT_INDEX_END, "Tried to get loot outside of the bounds of the loot indexes." );
	return get_ref_by_index( idx );
}

get_ref_by_index( idx )
{
	return tablelookup( LOOT_TABLE, TABLE_INDEX, idx, TABLE_REF );
}

get_loot_type( ref )
{
	if ( loot_item_exist( ref ) )
		return level.loot_info_array[ ref ].type;
		
	return tablelookup( LOOT_TABLE, TABLE_REF, ref, TABLE_TYPE );
}

get_loot_name( ref )
{
	if ( loot_item_exist( ref ) )
		return level.loot_info_array[ ref ].name;
		
	return tablelookup( LOOT_TABLE, TABLE_REF, ref, TABLE_NAME );
}


get_loot_desc( ref )
{
	if ( loot_item_exist( ref ) )
		return level.loot_info_array[ ref ].desc;
		
	return tablelookup( LOOT_TABLE, TABLE_REF, ref, TABLE_DESC );
}

get_loot_chance( ref )
{
	if ( loot_item_exist( ref ) )
		return level.loot_info_array[ ref ].chance;
		
	return float( tablelookup( LOOT_TABLE, TABLE_REF, ref, TABLE_CHANCE ) );
}

get_loot_wave_unlock( ref )
{
	if ( loot_item_exist( ref ) )
		return level.loot_info_array[ ref ].wave_unlock;
		
	return int( tablelookup( LOOT_TABLE, TABLE_REF, ref, TABLE_WAVE_UNLOCK ) );
}

get_loot_wave_lock( ref )
{
	if ( loot_item_exist( ref ) )
		return level.loot_info_array[ ref ].wave_lock;
		
	return int( tablelookup( LOOT_TABLE, TABLE_REF, ref, TABLE_WAVE_LOCK ) );
}

get_loot_rank( ref )
{
	if ( loot_item_exist( ref ) )
		return level.loot_info_array[ ref ].rank;
		
	return int( tablelookup( LOOT_TABLE, TABLE_REF, ref, TABLE_RANK ) );
}

get_loot_version_by_index( idx )
{
	assertex( idx >= LOOT_VERSION_INDEX_START && idx <= LOOT_VERSION_INDEX_END, "Tried to get loot version outside of the bounds of the loot indexes." );
	return get_ref_by_index( idx );
}

get_loot_versions( ref )
{
	if ( loot_item_exist( ref ) )
		return level.loot_info_array[ ref ].versions;
	
	assertex( isdefined( level.loot_version_array ), "The loot version array has not been populated." );
	
	name = "joe";
	versions = [];
	
	base_ref = ref;
	
	// If weapon remove '_mp' to get the base name
	if ( get_loot_type( ref ) == "weapon" )
		base_ref = getsubstr( ref, 0, ref.size - 3 );
	
	foreach( v in level.loot_version_array )
	{
		if ( issubstr( v, base_ref ) )
		{
			versions[ versions.size ] = v;
		}
	}
	
	// If no versions were found use the original ref item
	if ( !versions.size )
		versions[ versions.size ] = ref;
	
	return versions;
}






