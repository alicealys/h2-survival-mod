
#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;

#define CH_REF_COL 0
#define CH_NAME_COL 1
#define CH_DESC_COL 2
#define CH_LABEL_COL 3
#define CH_RES1_COL 4
#define CH_RES2_COL 5
#define CH_TARGET_COL 6
#define CH_REWARD_COL 7


init()
{
	//precacheMenu( "coop_challenge" );

	foreach ( player in level.players )
	{
		player initNotifyMessage();
	}

}


monitor_challenges()
{
	//self thread monitorAIKills();
}


challenge_targetVal( tableName, refString, tierId )
{
	value = tableLookup( tableName, CH_REF_COL, refString, CH_TARGET_COL + ((tierId-1)*2) );
	return int( value );
}


challenge_rewardVal( tableName, refString, tierId )
{
	value = tableLookup( tableName, CH_REF_COL, refString, CH_REWARD_COL + ((tierId-1)*2) );
	return int( value );
}


getChallengeStatus( name )
{
	if ( isDefined( self.challengeData[name] ) )
		return self.challengeData[name];
	else
		return 0;
}


ch_getProgress( refString )
{
	return self maps\_playerdata::get_struct( "challengeProgress", refString );
}


ch_getState( refString )
{
	return self maps\_playerdata::get_struct( "challengeState", refString );
}


ch_setProgress( refString, value )
{
	return self maps\_playerdata::set_struct( "challengeProgress", refString, value );
}


ch_setState( refString, value )
{
	return self maps\_playerdata::set_struct( "challengeState", refString, value );
}


ch_getTarget( refString, state )
{
	return int( tableLookup( "sp/allChallengesTable.csv", 0, refString, 6 + ((state-1)*2) ) );
}

buildChallengeTableInfo( tableName, typeId )
{
	totalRewardXP = 0;

	refString = tableLookupByRow( tableName, 0, CH_REF_COL );
	assertEx( isSubStr( refString, "ch_" ) || isSubStr( refString, "pr_" ), "Invalid challenge name: " + refString + " found in " + tableName );
	for ( index = 1; refString != ""; index++ )
	{
		assertEx( isSubStr( refString, "ch_" ) || isSubStr( refString, "pr_" ), "Invalid challenge name: " + refString + " found in " + tableName );

		level.challengeInfo[refString] = [];
		level.challengeInfo[refString]["targetval"] = [];
		level.challengeInfo[refString]["reward"] = [];
		level.challengeInfo[refString]["type"] = typeId;

		for ( tierId = 1; tierId < 11; tierId++ )
		{
			targetVal = challenge_targetVal( tableName, refString, tierId );
			rewardVal = challenge_rewardVal( tableName, refString, tierId );

			if ( targetVal == 0 )
				break;

			level.challengeInfo[refString]["targetval"][tierId] = targetVal;
			level.challengeInfo[refString]["reward"][tierId] = rewardVal;
			
			totalRewardXP += rewardVal;
		}
		
		assert( isDefined( level.challengeInfo[refString]["targetval"][1] ) );

		refString = tableLookupByRow( tableName, index, CH_REF_COL );
	}
	
	return int( totalRewardXP );
}


buildChallengeInfo()
{
	level.challengeInfo = [];

	totalRewardXP = 0;
	
	totalRewardXP += buildChallengeTableInfo( "sp/allchallengesTable.csv", 0 );

	tierTable = tableLookupByRow( "sp/challengeTable.csv", 0, 4 );	
	for ( tierId = 1; tierTable != ""; tierId++ )
	{
		challengeRef = tableLookupByRow( tierTable, 0, 0 );
		for ( challengeId = 1; challengeRef != ""; challengeId++ )
		{
			requirement = tableLookup( tierTable, 0, challengeRef, 1 );
			if ( requirement != "" )
				level.challengeInfo[challengeRef]["requirement"] = requirement;
				
			challengeRef = tableLookupByRow( tierTable, challengeId, 0 );
		}
		
		tierTable = tableLookupByRow( "sp/challengeTable.csv", tierId, 4 );	
	}
}


challengeSplashNotify( challengeRef )
{
	self endon ( "disconnect" );
	waittillframeend;
	
	// this is used to ensure the client receives the new challenge state before the splash is shown.
	wait ( 0.05 );

	//subtracting one from state becase state was incremented after completing challenge
	challengeState = ( self ch_getState( challengeRef ) - 1 );
	challengeTarget = ch_getTarget( challengeRef, challengeState );
	
	if( challengeTarget == 0 )
		challengeTarget = 1;
	
	actionData = spawnStruct();
	actionData.type = "challenge";
	actionData.optionalNumber = challengeTarget;
	actionData.name = challengeRef;
	actionData.sound = tableLookup( "sp/splashTable.csv", 0, actionData.name, 9 );
	actionData.slot = 0;

	self thread maps\_rank::actionNotify( actionData );
}


updateChallenges()
{
	self.challengeData = [];

	// we need to hold off until the game actually starts before initializing the challenge data
	// this is because we may not have the other player's stats during loading.
	wait( 0.05 );
	
	foreach ( challengeRef, challengeData in level.challengeInfo )
	{
		self.challengeData[challengeRef] = 0;
		
		if ( !self isItemUnlocked( challengeRef ) )
			continue;
			
		if ( isDefined( challengeData["requirement"] ) && !self isItemUnlocked( challengeData["requirement"] ) )
			continue;
		
		status = 0;
		stateRef = challengeRef;
		
		status = ch_getState( challengeRef );
		if ( status == 0 )
		{
			ch_setState( challengeRef, 1 );
			status = 1;
		}
		
		self.challengeData[challengeRef] = status;
	}
}

/*
monitorAIKills()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		level waittill( "specops_player_kill", attacker );

		if ( isDefined( attacker ) && isPlayer( attacker ) )
			attacker processChallenge( "ch_killer" );
	}
}*/


giveRankXpAfterWait( baseName,missionStatus )
{
	self endon( "death" );
	self endon( "disconnect" );

	wait( 0.25 );
	self maps\_utility::giveXp( "challenge", level.challengeInfo[baseName]["reward"][missionStatus] );
}


processChallenge( baseName, progressInc, forceSetProgress )
{
	if ( !isDefined( progressInc ) )
		progressInc = 1;
	
	missionStatus = getChallengeStatus( baseName );
	
	if ( missionStatus == 0 )
		return;
	
	// challenge already completed
	if ( missionStatus > level.challengeInfo[baseName]["targetval"].size )
		return;

	// get the current progress from the player data
	currentProgress = ch_getProgress( baseName );

	if ( isDefined( forceSetProgress ) && forceSetProgress )
	{
		newProgress = progressInc;
		assertex( newProgress >= currentProgress, "Attempted progress regression (forceSet) for challenge '" + baseName + "' - from " + currentProgress + " to " + newProgress + " for player " + self.playername );
	}
	else
	{
		newProgress = currentProgress + progressInc;
		assertex( newProgress >= currentProgress, "Attempted progress regression (inc) for challenge '" + baseName + "' - from " + currentProgress + " to " + newProgress + " for player " + self.playername );
	}

	// check whether we've completed this tier
	targetProgress = level.challengeInfo[baseName]["targetval"][missionStatus];
	if ( newProgress >= targetProgress )
	{
		reachedNewTier = true;
		newProgress = targetProgress;
		assertex( newProgress >= currentProgress, "Attempted progress regression (tiered up) for challenge '" + baseName + "' - from " + currentProgress + " to " + newProgress + " for player " + self.playername );
	}
	else
	{
		reachedNewTier = false;
	}

	// defensive, don't set the progress if it would be a regression
	if ( currentProgress < newProgress )
		self ch_setProgress( baseName, newProgress );

	if ( reachedNewTier )
	{
		self thread giveRankXpAfterWait( baseName, missionStatus );
		
		missionStatus++;		
		self ch_setState( baseName, missionStatus );
		self.challengeData[baseName] = missionStatus;
		
		self thread challengeSplashNotify( baseName );
	}
}

initNotifyMessage()
{
	if ( is_coop() )
	{
		titleSize = 2.5;
		textSize = 1.75;
		iconSize = 24;
		font = "objective";
		point = "TOP";
		relativePoint = "BOTTOM";
		yOffset = 30;
		xOffset = 0;
	}
	else
	{
		titleSize = 2.5;
		textSize = 1.75;
		iconSize = 30;
		font = "objective";
		point = "TOP";
		relativePoint = "BOTTOM";
		yOffset = 30;
		xOffset = 0;
	}

	self.notifyTitle = createClientFontString( font, titleSize );
	self.notifyTitle setPoint( point, undefined, xOffset, yOffset );
	self.notifyTitle.glowColor = ( 0.2, 0.3, 0.7 );
	self.notifyTitle.glowAlpha = 1;
	self.notifyTitle.hideWhenInMenu = true;
	self.notifyTitle.archived = false;
	self.notifyTitle.alpha = 0;

	self.notifyText = createClientFontString( font, textSize );
	self.notifyText setParent( self.notifyTitle );
	self.notifyText setPoint( point, relativePoint, 0, 0 );
	self.notifyText.glowColor = ( 0.2, 0.3, 0.7 );
	self.notifyText.glowAlpha = 1;
	self.notifyText.hideWhenInMenu = true;
	self.notifyText.archived = false;
	self.notifyText.alpha = 0;

	self.notifyText2 = createClientFontString( font, textSize );
	self.notifyText2 setParent( self.notifyTitle );
	self.notifyText2 setPoint( point, relativePoint, 0, 0 );
	self.notifyText2.glowColor = ( 0.2, 0.3, 0.7 );
	self.notifyText2.glowAlpha = 1;
	self.notifyText2.hideWhenInMenu = true;
	self.notifyText2.archived = false;
	self.notifyText2.alpha = 0;

	self.notifyIcon = createClientIcon( "white", iconSize, iconSize );
	self.notifyIcon setParent( self.notifyText2 );
	self.notifyIcon setPoint( point, relativePoint, 0, 0 );
	self.notifyIcon.hideWhenInMenu = true;
	self.notifyIcon.archived = false;
	self.notifyIcon.alpha = 0;

	self.doingNotify = false;
	self.notifyQueue = [];

	self.doingSplash = [];
	self.doingSplash[0] = undefined;
	self.doingSplash[1] = undefined;
	self.doingSplash[2] = undefined;
	self.doingSplash[3] = undefined;

	self.splashQueue = [];
	self.splashQueue[0] = [];
	self.splashQueue[1] = [];
	self.splashQueue[2] = [];
	self.splashQueue[3] = [];
}
