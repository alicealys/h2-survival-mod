#include maps\_utility;
#include common_scripts\utility;

// ------------------
// --- AIRSTRIKES ---
// ------------------
airstrike_preload()
{
	precacheLocationSelector( "map_artillery_selector" );
	//precacheString( &"MP_AIR_SPACE_TOO_CROWDED" );
	PrecacheItem( "killstreak_precision_airstrike_sp" );
	PrecacheItem( "killstreak_stealth_airstrike_sp" );
	precacheItem( "stealth_bomb_mp" );
	precacheItem( "artillery_mp" );
	precacheItem( "harrier_missile_mp" );
	precacheModel( "vehicle_mig29_desert" );
	precacheModel( "vehicle_av8b_harrier_jet_mp" );
	precacheModel( "vehicle_av8b_harrier_jet_opfor_mp" );
	precacheModel( "weapon_minigun" );
	precacheModel( "vehicle_b2_bomber" );
	PrecacheModel( "projectile_cbu97_clusterbomb" );
	//PrecacheVehicle( "harrier_mp" );
	//precacheTurret( "harrier_FFAR_mp" );
	/* TODO figure out minimap icons for airstrike planes
	PrecacheMiniMapIcon( "compass_objpoint_airstrike_friendly" );
	PrecacheMiniMapIcon( "compass_objpoint_airstrike_busy" );
	PrecacheMiniMapIcon( "compass_objpoint_b2_airstrike_friendly" );
	PrecacheMiniMapIcon( "compass_objpoint_b2_airstrike_enemy" );
	PrecacheMiniMapIcon( "hud_minimap_harrier_green" );
	PrecacheMiniMapIcon( "hud_minimap_harrier_red" );
	*/
	
	PrecacheShader( "specialty_precision_airstrike" );
	PrecacheShader( "dpad_killstreak_precision_airstrike" );
	PrecacheString( &"SP_KILLSTREAKS_REWARDNAME_PRECISION_AIRSTRIKE" );
	PrecacheString( &"SP_KILLSTREAKS_EARNED_PRECISION_AIRSTRIKE" );
	PrecacheString( &"SP_KILLSTREAKS_PRECISION_AIRSTRIKE_PICKUP" );
	
	PrecacheShader( "specialty_stealth_bomber" );
	PrecacheShader( "dpad_killstreak_stealth_bomber" );
	PrecacheString( &"SP_KILLSTREAKS_REWARDNAME_STEALTH_AIRSTRIKE" );
	PrecacheString( &"SP_KILLSTREAKS_EARNED_STEALTH_AIRSTRIKE" );
	PrecacheString( &"SP_KILLSTREAKS_STEALTH_AIRSTRIKE_PICKUP" );
	
	level.onfirefx = loadfx ("fire/fire_smoke_trail_L");
	level.airstrikefx = loadfx ("explosions/clusterbomb");
	level.mortareffect = loadfx ("explosions/artilleryExp_dirt_brown");
	level.bombstrike = loadfx ("explosions/wall_explosion_pm_a");
	level.stealthbombfx = loadfx ("explosions/stealth_bomb_mp");

	level.planes = 0;
	
	level.harrier_smoke = loadfx("fire/jet_afterburner_harrier_damaged");
	level.harrier_deathfx = loadfx ("explosions/aerial_explosion_harrier");
	level.harrier_afterburnerfx = loadfx ("fire/jet_afterburner_harrier");
	level.fx_airstrike_afterburner = loadfx ("fire/jet_afterburner");
	level.fx_airstrike_contrail = loadfx ("smoke/jet_contrail");

	// airstrike danger area is the circle of radius artilleryDangerMaxRadius 
	// stretched by a factor of artilleryDangerOvalScale in the direction of the incoming airstrike,
	// moved by artilleryDangerForwardPush * artilleryDangerMaxRadius in the same direction.
	// use scr_Airstrikedebug to visualize.
	
	level.dangerMaxRadius["stealth"] = 900;
	level.dangerMinRadius["stealth"] = 750;
	level.dangerForwardPush["stealth"] = 1;
	level.dangerOvalScale["stealth"] = 6.0;

	level.dangerMaxRadius["default"] = 550;
	level.dangerMinRadius["default"] = 300;
	level.dangerForwardPush["default"] = 1.5;
	level.dangerOvalScale["default"] = 6.0;

	level.dangerMaxRadius["precision"] = 550;
	level.dangerMinRadius["precision"] = 300;
	level.dangerForwardPush["precision"] = 2.0;
	level.dangerOvalScale["precision"] = 6.0;

	level.dangerMaxRadius["harrier"] = 550;
	level.dangerMinRadius["harrier"] = 300;
	level.dangerForwardPush["harrier"] = 1.5;
	level.dangerOvalScale["harrier"] = 6.0;
	
	level.artilleryDangerCenters = [];
}

try_use_airstrike( airstrikeType )
{
	ASSERTEX( IsDefined( level.planes ), "Did you forget to call _sp_airstrike::airstrike_preload()?" );
	
	if( IsDefined( self.using_uav ) && self.using_uav )
	{
		return false;
	}
	
	if ( !isDefined( airstrikeType ) )
	{
		airstrikeType = "precision";
	}

	switch( airstrikeType )
	{
		case "precision":
			break;
		case "stealth":
			break;
		case "harrier":
			if ( level.planes > 1 )
			{
				//self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
				iprintlnbold( "Air space too crowded!" );
				return false;	
			}
			break;
		case "super":
			break;
	}
	
	result = self airstrike_location_select( airstrikeType );

	if ( !IsDefined( result ) )
	{
		return false;
	}
	
	self thread finish_using_airstrike( airstrikeType, result.location, result.directionYaw );
	return true;
}

airstrike_location_select( airstrikeType )
{
	chooseDirection = false;
	if ( airstrikeType == "precision" || airstrikeType == "stealth" )
	{
		chooseDirection = true;
	}
	
	targetSize = level.mapSize / 5.625; // 138 in 720

	self BeginLocationSelection( "map_artillery_selector", chooseDirection, targetSize );
	self.selectingLocation = true;

	self SetBlurForPlayer( 4.0, 0.3 );
	self thread waitForAirstrikeCancel();
	
	self thread endSelectionOn( "cancel_location" );
	self thread endSelectionOn( "death" );
	self thread endSelectionOn( "disconnect" );
	//self thread endSelectionOn( "used" ); // so that this thread doesn't kill itself when we use an airstrike

	self endon( "stop_location_selection" );

	// wait for the selection. randomize the yaw if we're not doing a precision airstrike.
	self waittill( "confirm_location", location, directionYaw );
	
	if ( !chooseDirection )
	{
		directionYaw = randomint(360);
	}

	self SetBlurForPlayer( 0, 0.3 );
	
	// maybe another one got called in while we were selecting
	if ( airstrikeType == "harrier" && level.planes > 1 )
	{
		self notify ( "cancel_location" );
		//self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
		iprintlnbold( "Air space too crowded!" );
		return false;	
	}
	
	struct = SpawnStruct();
	struct.location = location;
	struct.directionYaw = directionYaw;
	
	//self endLocationSelection();
	//self.selectingLocation = undefined;
	//self notify( "stop_location_selection" );
	self delaythread( 0.05, ::stopAirstrikeLocationSelection );
	//delaythread( 0.05, ::stopAirstrikeLocationSelection );
	
	return struct;
}

waitForAirstrikeCancel()
{
	self waittill( "cancel_location" );
	self SetBlurForPlayer( 0, 0.3 );
}

endSelectionOn( waitfor )
{
	self endon( "stop_location_selection" );
	self waittill( waitfor );
	self thread stopAirstrikeLocationSelection();
}

stopAirstrikeLocationSelection()
{
	self setblurforplayer( 0, 0.3 );
	self endLocationSelection();
	self.selectingLocation = undefined;
	
	self notify( "stop_location_selection" );
}

finish_using_airstrike( airstrikeType, location, directionYaw )
{
	// find underside of top of skybox
	trace = bullettrace( level.mapCenter + (0,0,1000000), level.mapCenter, false, undefined );
	location = ( location[ 0 ], location[ 1 ], trace[ "position" ][ 2 ] - 514 );
	
	ASSERT( IsDefined( self.team ) );
	thread do_airstrike( airstrikeType, location, directionYaw, self, self.team );
}

do_airstrike( airstrikeType, origin, yaw, owner, team )
{	
	assert( isDefined( origin ) );
	assert( isDefined( yaw ) );
	
	if ( !IsDefined( airstrikeType ) )
	{
		airstrikeType = "default";
	}

	if ( airStrikeType == "harrier" )
	{
		level.planes++;
	}
	
	if ( isDefined( level.airstrikeInProgress ) )
	{
		while ( isDefined( level.airstrikeInProgress ) )
		{
			level waittill( "begin_airstrike" );
		}

		level.airstrikeInProgress = true;
		wait ( 2.0 );
	}

	if ( !isDefined( owner ) )
	{
		if ( airStrikeType == "harrier" )
			level.planes--;
			
		return;
	}

	level.airstrikeInProgress = true;
	
	num = 17 + randomint(3);
	trace = bullettrace(origin, origin + (0,0,-1000000), false, undefined);
	targetpos = trace["position"];
	
	dangerCenter = spawnstruct();
	dangerCenter.origin = targetpos;
	dangerCenter.forward = anglesToForward( (0,yaw,0) );
	dangerCenter.airstrikeType = airstrikeType;

	level.artilleryDangerCenters[ level.artilleryDangerCenters.size ] = dangerCenter;

	harrierEnt = callStrike( owner, targetpos, yaw, airstrikeType );
	
	wait( 1.0 );
	level.airstrikeInProgress = undefined;
	owner notify ( "begin_airstrike" );
	level notify ( "begin_airstrike" );
	
	wait 7.5;

	found = false;
	newarray = [];
	for ( i = 0; i < level.artilleryDangerCenters.size; i++ )
	{
		if ( !found && level.artilleryDangerCenters[i].origin == targetpos )
		{
			found = true;
			continue;
		}
		
		newarray[ newarray.size ] = level.artilleryDangerCenters[i];
	}
	assert( found );
	assert( newarray.size == level.artilleryDangerCenters.size - 1 );
	level.artilleryDangerCenters = newarray;
	
	if ( airStrikeType != "harrier" )
		return;

	while ( isDefined( harrierEnt ) )
		wait ( 0.1 );
		
	level.planes--;
}

callStrike( owner, coord, yaw, airstrikeType )
{
	heightEnt = undefined;
	planeBombExplodeDistance = 0;
	
	// Get starting and ending point for the plane
	direction = ( 0, yaw, 0 );
	heightEnt = GetEnt( "airstrikeheight", "targetname" );

	if ( airStrikeType == "stealth" )
	{
		//thread teamPlayerCardSplash( "used_stealth_airstrike", owner, owner.team );
		
		planeHalfDistance = 12000;
		planeFlySpeed = 2000;
		
		if ( !isDefined( heightEnt ) )//old system 
		{
			println( "NO DEFINED AIRSTRIKE HEIGHT SCRIPT_ORIGIN IN LEVEL" );
			planeFlyHeight = 950;
			planeBombExplodeDistance = 1500;
			if ( isdefined( level.airstrikeHeightScale ) )
				planeFlyHeight *= level.airstrikeHeightScale;
		}
		else
		{
			planeFlyHeight = heightEnt.origin[2];
			planeBombExplodeDistance = getExplodeDistance( planeFlyHeight );
		}
		
	}
	else
	{
		planeHalfDistance = 24000;
		planeFlySpeed = 7000;
		
		if ( !isDefined( heightEnt ) )//old system 
		{
			println( "NO DEFINED AIRSTRIKE HEIGHT SCRIPT_ORIGIN IN LEVEL" );
			planeFlyHeight = 850;
			planeBombExplodeDistance = 1500;
			if ( isdefined( level.airstrikeHeightScale ) )
				planeFlyHeight *= level.airstrikeHeightScale;
		}
		else
		{
			planeFlyHeight = heightEnt.origin[2];
			planeBombExplodeDistance = getExplodeDistance( planeFlyHeight );
		}
	}
	
	startPoint = coord + ( anglestoforward( direction )*( -1 * planeHalfDistance ));
	
	if ( isDefined( heightEnt ) )// used in the new height system
	{
		startPoint *= (1,1,0);
	}
		
	startPoint += ( 0, 0, planeFlyHeight );

	if ( airStrikeType == "stealth" )
	{
		endPoint = coord + ( AnglesToForward( direction ) * ( planeHalfDistance * 4 ) );
	}
	else
	{
		endPoint = coord + ( AnglesToForward( direction ) * planeHalfDistance );
	}
	
	if ( isDefined( heightEnt ) )// used in the new height system
	{
		endPoint *= (1,1,0);
	}
		
	endPoint += ( 0, 0, planeFlyHeight );
	
	// Make the plane fly by
	d = length( startPoint - endPoint );
	flyTime = ( d / planeFlySpeed );
	
	// bomb explodes planeBombExplodeDistance after the plane passes the center
	d = abs( d/2 + planeBombExplodeDistance  );
	bombTime = ( d / planeFlySpeed );
	
	assert( flyTime > bombTime );
	
	owner endon( "disconnect" );
	
	level.airstrikeDamagedEnts = [];
	level.airStrikeDamagedEntsCount = 0;
	level.airStrikeDamagedEntsIndex = 0;
	
	// TODO maybe
	/*if ( airStrikeType == "harrier" )
	{
		level thread doPlaneStrike( lifeId, owner, requiredDeathCount, coord, startPoint+(0,0,randomInt(500)), endPoint+(0,0,randomInt(500)), bombTime, flyTime, direction, airStrikeType );
		
		wait randomfloatrange( 1.5, 2.5 );
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
		level thread doPlaneStrike( lifeId, owner, requiredDeathCount, coord, startPoint+(0,0,randomInt(200)), endPoint+(0,0,randomInt(200)), bombTime, flyTime, direction, airStrikeType );
		
		wait randomfloatrange( 1.5, 2.5 );
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
		harrier = beginHarrier( lifeId, startPoint, coord );
		owner thread defendLocation( harrier );

		return harrier;		
		//owner thread harrierMissileStrike( startPoint, coord );
	
	}*/
	if ( airStrikeType == "stealth" )
	{
		level thread doBomberStrike( owner, coord, startPoint+(0,0,randomInt(1000)), endPoint+(0,0,randomInt(1000)), bombTime, flyTime, direction );
	}
	else	//common airstrike
	{
		level thread doPlaneStrike( owner, coord, startPoint+(0,0,randomInt(500)), endPoint+(0,0,randomInt(500)), bombTime, flyTime, direction, airStrikeType );
		
		wait randomfloatrange( 1.5, 2.5 );
		level thread doPlaneStrike( owner, coord, startPoint+(0,0,randomInt(200)), endPoint+(0,0,randomInt(200)), bombTime, flyTime, direction, airStrikeType );
		
		wait randomfloatrange( 1.5, 2.5 );
		level thread doPlaneStrike( owner, coord, startPoint+(0,0,randomInt(200)), endPoint+(0,0,randomInt(200)), bombTime, flyTime, direction, airStrikeType );	

		if ( airStrikeType == "super" )
		{
			wait randomfloatrange( 2.5, 3.5 );
			level thread doPlaneStrike( owner, coord, startPoint+(0,0,randomInt(200)), endPoint+(0,0,randomInt(200)), bombTime, flyTime, direction, airStrikeType );	
		}
	}
}

getExplodeDistance( height )
{
	standardHeight = 850;
	standardDistance = 1500;
	distanceFrac = standardHeight/height;
	
	newDistance = distanceFrac * standardDistance;
	
	return newDistance;
}

// TODO add icons to minimap
airstrike_spawn_fake_plane( typeOfStrike, owner, pathStart )
{
	ASSERT( IsDefined( typeOfStrike ) );
	ASSERT( IsDefined( owner.team ) );
	
	model = "vehicle_mig29_desert";
	friendIcon = "compass_objpoint_airstrike_friendly";
	enemyIcon = "compass_objpoint_airstrike_busy";
	
	if( typeOfStrike == "harrier" )
	{
		model = "vehicle_av8b_harrier_jet_mp";
		if( owner.team != "allies" )
		{
			model = "vehicle_av8b_harrier_jet_opfor_mp";
		}
		friendIcon = "hud_minimap_harrier_green";
		enemyIcon = "hud_minimap_harrier_red";
	}
	else if( typeOfStrike == "stealth" )
	{
		model = "vehicle_b2_bomber";
		friendIcon = "compass_objpoint_b2_airstrike_friendly";
		enemyIcon = "compass_objpoint_b2_airstrike_enemy";
	}
	
	//spawner.script_team = owner.team;
	//spawner.origin = pathStart;
	//plane = maps\_vehicle::vehicle_spawn( spawner );
	
	plane = Spawn( "script_model", pathStart );
	plane.team = owner.team;
	plane SetModel( model );
	
	return plane;
}

doPlaneStrike( owner, bombsite, startPoint, endPoint, bombTime, flyTime, direction, typeOfStrike )
{
	// plane spawning randomness = up to 125 units, biased towards 0
	// radius of bomb damage is 512

	if ( !isDefined( owner ) ) 
		return;
	
	startPathRandomness = 100;
	endPathRandomness = 150;
	
	pathStart = startPoint + ( (randomfloat(2) - 1)*startPathRandomness, (randomfloat(2) - 1)*startPathRandomness, 0 );
	pathEnd   = endPoint   + ( (randomfloat(2) - 1)*endPathRandomness  , (randomfloat(2) - 1)*endPathRandomness  , 0 );
	
	plane = airstrike_spawn_fake_plane( typeOfStrike, owner, pathStart );

	plane PlayLoopSound( "veh_mig29_dist_loop" );
	//plane thread handleEMP( owner );

	plane.angles = direction;
	forward = anglesToForward( direction );
	plane thread playPlaneFx();
	plane MoveTo( pathEnd, flyTime, 0, 0 );
	
	thread callStrike_bombEffect( plane, pathEnd, flyTime, bombTime - 1.0, owner, typeOfStrike );

	// Delete the plane after its flyby
	wait flyTime;
	plane notify( "delete" );
	plane delete(); 
}

playPlaneFx()
{
	self endon ( "death" );

	wait( 0.5);
	playfxontag( level.fx_airstrike_afterburner, self, "tag_engine_right" );
	wait( 0.5);
	playfxontag( level.fx_airstrike_afterburner, self, "tag_engine_left" );
	wait( 0.5);
	playfxontag( level.fx_airstrike_contrail, self, "tag_right_wingtip" );
	wait( 0.5);
	playfxontag( level.fx_airstrike_contrail, self, "tag_left_wingtip" );
}

callStrike_bomb( coord, owner, offset, showFx )
{
	if ( !isDefined( owner ) ) //|| owner isEMPed() )
	{
		self notify( "stop_bombing" );
		return;
	}
	
	accuracyRadius = 512;
	
	randVec = ( 0, randomint( 360 ), 0 );
	bombPoint = coord + ( anglestoforward( randVec )* randomFloat( accuracyRadius ) );
	trace = bulletTrace( bombPoint, bombPoint + (0,0,-10000), false, undefined );
	
	bombPoint = trace["position"];
	bombHeight = distance( coord, bombPoint );

	if ( bombHeight > 5000 )
		return;

	wait ( 0.85 * (bombHeight / 2000) );

	if ( !isDefined( owner ) ) //|| owner isEMPed() )
	{
		self notify( "stop_bombing" );
		return;
	}

	if ( showFx )
	{
		playFx( level.mortareffect, bombPoint );

		PlayRumbleOnPosition( "grenade_rumble", bombPoint );
		earthquake( 1.0, 0.6, bombPoint, 2000 );
	}

	thread play_sound_in_space( "exp_airstrike_bomb", bombPoint );
	radiusArtilleryShellshock( bombPoint, 512, 8, 4 );
	RadiusDamage( bombPoint + (0,0,16), 896, 300, 50, owner, "MOD_PROJECTILE_SPLASH", "stealth_bomb_mp" );
}

radiusArtilleryShellshock( pos, radius, maxduration, minduration )
{
	foreach ( player in level.players )
	{
		if ( !isAlive( player ) )
		{
			continue;
		}
			
		playerPos = player.origin + ( 0, 0, 32 );
		dist = Distance( pos, playerPos );

		if ( dist > radius )
		{
			continue;
		}
		
		//duration = int( maxduration + ( minduration - maxduration ) * dist / radius );
		distPercentage = dist / radius;
		duration = linear_interpolate( distPercentage, minduration, maxduration );
		
		player thread artilleryShellshock( "default", duration );
	}
}

artilleryShellshock( type, duration )
{
	if( IsDefined( self.beingArtilleryShellshocked ) && self.beingArtilleryShellshocked )
	{
		return;
	}
	self.beingArtilleryShellshocked = true;
	
	self Shellshock( type, duration );
	wait( duration + 1 );
	
	self.beingArtilleryShellshocked = false;
}

callStrike_bombEffect( plane, pathEnd, flyTime, launchTime, owner, typeOfStrike )
{
	wait ( launchTime );

	if ( !isDefined( owner ) ) //|| owner isEMPed() )
	{
		return;
	}
	
	plane PlaySound( "veh_mig29_sonic_boom" );
	planedir = AnglesToForward( plane.angles );
	
	bomb = spawnbomb( plane.origin, plane.angles );
	bomb.airstrikeType = typeOfStrike;
	bomb moveGravity( ( anglestoforward( plane.angles )*( 7000/1.5 )), 3.0 );
	
	// was a bunch of killcament waiting here
	wait( 1 );
	
	newBomb = spawn( "script_model", bomb.origin );
 	newBomb setModel( "tag_origin" );
  	newBomb.origin = bomb.origin;
  	newBomb.angles = bomb.angles;

	bomb setModel( "tag_origin" );
	wait( 0.1 );  // wait two server frames before playing fx
	
	bombOrigin = newBomb.origin;
	bombAngles = newBomb.angles;
	playfxontag( level.airstrikefx, newBomb, "tag_origin" );
	
	// was a bunch of killcament waiting here
	wait( 1 );
	
	repeat = 12;
	minAngles = 5;
	maxAngles = 55;
	angleDiff = ( maxAngles - minAngles ) / repeat;
	
	hitpos = ( 0, 0, 0 );
	
	for( i = 0; i < repeat; i++ )
	{
		traceDir = anglesToForward( bombAngles + (maxAngles-(angleDiff * i),randomInt( 10 )-5,0) );
		traceEnd = bombOrigin + ( traceDir* 10000 );
		trace = bulletTrace( bombOrigin, traceEnd, false, undefined );
		
		traceHit = trace["position"];
		hitpos += traceHit;
		
		RadiusDamage( traceHit + (0,0,16), 512, 200, 30, owner, "MOD_PROJECTILE_SPLASH", "artillery_mp" );
	
		if ( i%3 == 0 )
		{
			thread play_sound_in_space( "exp_airstrike_bomb", traceHit );
			playRumbleOnPosition( "artillery_rumble", traceHit );
			earthquake( 0.7, 0.75, traceHit, 1000 );
		}
		
		wait ( 0.05 );
	}
	
	hitpos = hitpos / repeat + (0,0,128);
	
	wait ( 5.0 );
	newBomb delete();
	bomb delete();
}

spawnbomb( origin, angles )
{
	bomb = spawn( "script_model", origin );
	bomb.angles = angles;
	bomb setModel( "projectile_cbu97_clusterbomb" );

	return bomb;
}

doBomberStrike( owner, bombsite, startPoint, endPoint, bombTime, flyTime, direction )
{
	// plane spawning randomness = up to 125 units, biased towards 0
	// radius of bomb damage is 512

	if ( !isDefined( owner ) )
	{
		return;
	}
	
	startPathRandomness = 100;
	endPathRandomness = 150;
	
	pathStart = startPoint + ( (randomfloat(2) - 1)*startPathRandomness, (randomfloat(2) - 1)*startPathRandomness, 0 );
	pathEnd   = endPoint   + ( (randomfloat(2) - 1)*endPathRandomness  , (randomfloat(2) - 1)*endPathRandomness  , 0 );
	
	plane = airstrike_spawn_fake_plane( "stealth", owner, pathStart );
	plane playLoopSound( "veh_b2_dist_loop" );
	plane setModel( "vehicle_b2_bomber" );
	//plane thread handleEMP( owner );

	plane.angles = direction;
	forward = AnglesToForward( direction );
	plane MoveTo( pathEnd, flyTime, 0, 0 );
	
	thread bomberDropBombs( plane, bombsite, owner );

	// Delete the plane after its flyby
	wait ( flyTime );
	plane notify( "delete" );
	plane delete(); 
}


bomberDropBombs( plane, bombSite, owner )
{
	while ( !targetIsClose( plane, bombsite, 5000 ) )
	{
		wait ( 0.05 );
	}
	
	showFx = true;
	sonicBoom = false;

	plane notify ( "start_bombing" );
	plane thread playBombFx();
	
	for ( dist = targetGetDist( plane, bombsite ); dist < 5000; dist = targetGetDist( plane, bombsite ) )
	{
		if ( dist < 1500 && !sonicBoom )
		{
			plane playSound( "veh_b2_sonic_boom" );
			sonicBoom = true;
		}

		showFx = !showFx;  // TODO wtf?
		if ( dist < 4500 )
			plane thread callStrike_bomb( plane.origin, owner, (0,0,0), showFx );
		wait ( 0.1 );
	}

	plane notify ( "stop_bombing" );
}

targetisclose(other, target, closeDist)
{
	if ( !isDefined( closeDist ) )
		closeDist = 3000;
		
	infront = targetisinfront(other, target);
	if(infront)
		dir = 1;
	else
		dir = -1;
	a = flat_origin(other.origin);
	b = a +( AnglesToForward( flat_angle( other.angles ) ) * ( dir * 100000 ) );
	point = pointOnSegmentNearestToPoint(a,b, target);
	dist = distance(a,point);
	if (dist < closeDist)
		return true;
	else
		return false;
}

targetisinfront(other, target)
{
	forwardvec = anglestoforward(flat_angle(other.angles));
	normalvec = vectorNormalize(flat_origin(target)-other.origin);
	dot = vectordot(forwardvec,normalvec); 
	if(dot > 0)
		return true;
	else
		return false;
}

targetGetDist( other, target )
{
	infront = targetisinfront( other, target );
	if( infront )
		dir = 1;
	else
		dir = -1;
	a = flat_origin( other.origin );
	b = a +( AnglesToForward( flat_angle( other.angles ) ) * ( dir * 100000 ) );
	point = pointOnSegmentNearestToPoint(a,b, target);
	dist = distance(a,point);

	return dist;
}

playBombFx()
{
	self endon ( "stop_bombing" );

	for ( ;; )
	{
		playFxOnTag( level.stealthbombfx, self, "tag_left_alamo_missile" );
		playFxOnTag( level.stealthbombfx, self, "tag_right_alamo_missile" );
		
		wait ( 0.5 );
	}
}







