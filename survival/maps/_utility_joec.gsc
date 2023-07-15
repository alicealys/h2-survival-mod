#include maps\_utility;
#include common_scripts\utility;

// Exchange sort
exchange_sort_by_handler( array, compare_func )
{
	assertex( isdefined( array ), "Array not defined." );
	assertex( isdefined( compare_func ), "Compare function not defined." );
	
	for( i = 0; i < array.size - 1; i++ )
	{
		index_small = 0;
		for ( j = i + 1; j < array.size; j++ )
		{
			if ( array[ j ] [[ compare_func ]]() < array[ i ] [[ compare_func]]() )
			{
				ref = array[ j ];
				array[ j ] = array[ i ];
				array[ i ] = ref;	
			}
		}	
	}
	
	return array;
}

// Record Player Time and Notify
on_player_trig_record_and_notify( trig_noteworthy, flag_all_times_recorded )
{
	trigger = GetEnt( trig_noteworthy, "script_noteworthy" );
	
	Assert( IsDefined( trigger ), "Trigger could not be found with noteworthy: " + trig_noteworthy );
	
	while ( 1 )
	{
		trigger waittill( "trigger", activator );
		
		if ( IsDefined( activator ) && activator == self )
		{
			self.stat_finish_time = GetTime();
			
			if ( IsDefined( level.challenge_time_limit ) )
			{
				self.stat_finish_time_remaining = max( level.challenge_time_limit - ( self.stat_finish_time - level.challenge_start_time ), 0 );
			}
			
			if ( !is_coop() || IsDefined( get_other_player( self ).stat_finish_time ) )
			{
				flag_set( flag_all_times_recorded );
			}
			break;
		}
	}
}







