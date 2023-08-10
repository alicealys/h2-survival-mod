#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_sp_killstreaks;
#include maps\_sp_airdrop;

// ======================================================================
// AIRDROP FUNCTIONS
// ======================================================================

// REMOTE MISSILE AND UAV LOGIC
// ==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
remotemissile_infantry_kills_dialogue_setup()
{
	//That looks to be at least five no, ten kills, hunter two one. Keep it up.
	level.scr_radio[ "inv_hqr_fivenotenkills" ] = "inv_hqr_fivenotenkills";
	//Oh man. Thats at least ten more confirms hunter two one. Good shooting.
	level.scr_radio[ "inv_hqr_tenmoreconfirms" ] = "inv_hqr_tenmoreconfirms";
	//Ten plus KIAs. Good hit. Good hit.
	level.scr_radio[ "inv_hqr_tenpluskia" ] = "inv_hqr_tenpluskia";
	//Five plus confirmed kills. Nice work. Hunter two one.
	level.scr_radio[ "inv_hqr_fiveplus" ] = "inv_hqr_fiveplus";
	//Hunter two one, thats another five plus confirmed.
	level.scr_radio[ "inv_hqr_another5plus" ] = "inv_hqr_another5plus";
	//Good hit. More than five KIAs.
	level.scr_radio[ "inv_hqr_morethanfive" ] = "inv_hqr_morethanfive";
	//You got 'em. Good kill.
	level.scr_radio[ "inv_hqr_yougotem" ] = "inv_hqr_yougotem";
	//Good kills hunter two one. Good kills.
	level.scr_radio[ "inv_hqr_goodkills" ] = "inv_hqr_goodkills";
	//Thats a direct hit hunter two one, keep up the fire.
	level.scr_radio[ "inv_hqr_directhit" ] = "inv_hqr_directhit";
	//He's down.
	level.scr_radio[ "inv_hqr_hesdown" ] = "inv_hqr_hesdown";
}

remotemissile_infantry_kills_dialogue()
{
	dialog10 = [];
	//Ten plus KIAs. Good hit. Good hit.	
	dialog10[dialog10.size] = "inv_hqr_tenpluskia";
	//Oh man. Thats at least ten more confirms hunter two one. Good shooting.	
	dialog10[dialog10.size] = "inv_hqr_tenmoreconfirms";	
	//That looks to be at least five no, ten kills, hunter two one. Keep it up.	
	dialog10[dialog10.size] = "inv_hqr_fivenotenkills";	
	current_dialog10 = 0;
	
	dialog5 = [];
	//Five plus confirmed kills. Nice work. Hunter two one.	
	dialog5[dialog5.size] = "inv_hqr_fiveplus";	
	//Hunter two one, thats another five plus confirmed. 	
	dialog5[dialog5.size] = "inv_hqr_another5plus";	
	//Good hit. More than five KIAs.	
	dialog5[dialog5.size] = "inv_hqr_morethanfive";	
	current_dialog5 = 0;
	
	said_hes_down = false;
	said_direct_hit = false;
	level.enemies_killed = 0;
	kills = 0;
	
	while( 1 )
	{
		level waittill( "remote_missile_exploded" );
		old_num = level.enemies_killed;
		
		wait .1;
		
		if( isdefined( level.uav_killstats[ "ai" ] ) )
			kills = level.uav_killstats[ "ai" ];
		
		if( kills == 0 )
		{
			continue;
		}
		wait .5;
		
		if( isdefined( level.uav_is_destroyed ) )
			return;
		
		if( kills == 1 )
		{
			if( said_hes_down )
			{
				//You got 'em. Good kill.	
				radio_dialogue( "inv_hqr_yougotem" );
				said_hes_down = false;
			}
			else
			{
				//He's down.
				radio_dialogue( "inv_hqr_hesdown" );
				said_hes_down = true;
			}
			continue;	
		}
		if( kills >= 10 )
		{
			radio_dialogue( dialog10[current_dialog10] );
			current_dialog10++;
			if( current_dialog10 >= dialog10.size )
				current_dialog10 = 0;
			continue;
		}
		if( kills >= 5 )
		{
			radio_dialogue( dialog5[current_dialog5] );
			current_dialog5++;
			if( current_dialog5 >= dialog5.size )
				current_dialog5 = 0;
			continue;
		}
		else
		{
			if( said_direct_hit )
			{
				//Good kills hunter two one. Good kills.	
				radio_dialogue( "inv_hqr_goodkills" );
				said_direct_hit = false;
			}
			else
			{
				//Thats a direct hit hunter two one, keep up the fire.	
				radio_dialogue( "inv_hqr_directhit" );
				said_direct_hit = true;
			}
			continue;
		}
	}
}

remotemissile_uav()
{
	level.uav = spawn_vehicle_from_targetname( "remotemissile_uav" );
	pathStart = GetVehicleNode( "vnode_remotemissile_uav_start", "targetname" );
	level.uav AttachPath( pathStart );
	gopath( level.uav );
	level.uav PlayLoopSound( "uav_engine_loop" );
	
	level.uavRig = Spawn( "script_model", level.uav.origin );
	level.uavRig SetModel( "tag_origin" );
	level thread uav_rig_aiming();
}

uav_rig_aiming()
{
	level.uav endon( "death" );
	
	focusPoints = GetStructArray( "uav_focus_point", "targetname" );
	ASSERT( focusPoints.size );
	
	while( 1 )
	{
		focus_origin = level.player.origin;
		if ( isdefined( level.uav_user ) )
			focus_origin = level.uav_user.origin;
		
		closestPoint = getclosest( focus_origin, focusPoints );
		targetPos = closestPoint.origin;
		
		angles = VectorToAngles( targetPos - level.uav.origin );
		level.uavRig MoveTo( level.uav.origin, 0.10, 0, 0 );
		level.uavRig RotateTo( angles, 0.10, 0, 0 );
		
		wait( 0.05 );
	}
}

ai_remote_missile_fof_outline()
{
	if( !isAI( self ) )
		return;
		
	if( IsDefined( self.ridingvehicle ) )
	{
		self endon( "death" );
		self waittill( "jumpedout" );	
	}
	
	self maps\_remotemissile_utility::setup_remote_missile_target();
}

// ======================================================================
// HUD FUNCTIONS
// ======================================================================

splash_notify_message( splashData )
{
	self endon( "death" );

	assert( isDefined( splashData.title ) );

	// TODO - maybe reconstitute? With this, the message won't appear until after flashbangs wear off, etc.
	//waitRequireVisibility( 0 );
	
	if( !IsDefined( splashData.type ) )
		splashData.type = "";
	
	duration = splashData.duration;
	transTime = 0.15;
	
	self.doingNotify = true;
	self.splashTitle transitionReset();
	self.splashDesc transitionReset();
	self.splashDesc1 transitionReset();
	self.splashDesc2 transitionReset();
	self.splashDesc3 transitionReset();
	self.splashDesc4 transitionReset();
	self.splashHint transitionReset();
	self.splashIcon transitionReset();
	wait ( 0.05 );
	
	// don't draw the sniper breath hint while doing our splash
	SetSavedDvar( "cg_drawBreathHint", "0" );
	
	elements = [];
	elements[elements.size] = self.splashTitle;
	self.splashTitle.label = splashData.title;
	
	if( IsDefined( splashData.title_set_value ) )
		self.splashTitle SetValue( splashData.title_set_value );
	

	if (isdefined(splashData.rank_pulse_fx) && splashData.rank_pulse_fx)
	{
		self.splashTitle SetPulseFX( 100, int( duration * 1000 ), 1000 );
		self.splashDesc SetPulseFX( 100, int( duration * 1000 ), 1000 );
	}
	else
	{
		self.splashTitle SetPulseFX( int( 5 * duration ), int( duration * 1000 ), 1000 );
	}
	
	og_title_font = self.splashTitle.font;
	if( IsDefined( splashData.title_font ) )
		self.splashTitle.font = splashData.title_font;
	
	og_title_label = splashData.title;
	if ( isDefined( splashData.title_label ) )
		self.splashTitle.label = splashData.title_label;
	
	og_title_baseFontScale = self.splashTitle.baseFontScale;
	if( IsDefined( splashData.title_baseFontScale ) )
		self.splashTitle.baseFontScale = splashData.title_baseFontScale;

	og_title_glowColor = self.splashTitle.glowColor;
	og_title_glowAlpha = self.splashTitle.glowAlpha;
	if ( IsDefined( splashData.title_glowColor ) )
	{
		self.splashTitle.glowColor = splashData.title_glowColor;
		self.splashTitle.glowalpha = 0.3;
	}
	
	og_title_color = self.splashTitle.color;
	if ( isDefined( splashData.title_color ) )
	{
		og_title_color = splashData.title_color;
		self.splashTitle.color = splashData.title_color;
	}
	
	og_icon_shader = self.splashIcon.shader;
	if ( isDefined( splashData.icon ) && splashData.icon != "" )
	{
		elements[elements.size] = self.splashIcon;
		self.splashIcon.shader = splashData.icon;
	}

	og_desc_glowcolor = self.splashDesc.glowcolor;
	if (isdefined(splashData.desc_glowcolor))
	{
		self.splashDesc.glowcolor = splashData.desc_glowcolor;
	}

	og_desc_glowalpha = self.splashDesc.glowalpha;
	if (isdefined(splashData.desc_glowalpha))
	{
		self.splashDesc.glowalpha = splashData.desc_glowalpha;
	}
	
	// desc section =======================================================
	og_desc_font			= undefined;
	og_desc_baseFontScale	= undefined;

	if ( isDefined( splashData.desc ) && (!isString( splashData.desc ) || splashData.desc != "") )
	{
		elements[elements.size] = self.splashDesc;
		self.splashDesc.label = splashData.desc;

		if ( isdefined( splashData.desc_set_value ) )
			self.splashDesc SetValue( splashData.desc_set_value );

		og_desc_font = self.splashDesc.font;
		if( IsDefined( splashData.desc_font ) )
			self.splashDesc.font = splashData.Desc_Font;



		og_desc_baseFontScale = self.splashDesc.baseFontScale;
		if( IsDefined( splashData.desc_baseFontScale ) )
			self.splashDesc.baseFontScale = splashData.desc_baseFontScale;
		
		// extra desc
		if ( isDefined( splashData.desc1 ) && (!isString( splashData.desc1 ) || splashData.desc1 != "") )
		{
			elements[elements.size] = self.splashDesc1;
			self.splashDesc1.label = splashData.desc1;
			self.splashDesc1.font = self.splashDesc.font;
			
			if ( isdefined( splashData.desc1_set_value ) )
				self.splashDesc1 SetValue( splashData.desc1_set_value );
		}
		if ( isDefined( splashData.desc2 ) && (!isString( splashData.desc2 ) || splashData.desc2 != "") )
		{
			elements[elements.size] = self.splashDesc2;
			self.splashDesc2.label = splashData.desc2;
			self.splashDesc2.font = self.splashDesc.font;
			
			if ( isdefined( splashData.desc2_set_value ) )
				self.splashDesc2 SetValue( splashData.desc2_set_value );
		}
		if ( isDefined( splashData.desc3 ) && (!isString( splashData.desc3 ) || splashData.desc3 != "") )
		{
			elements[elements.size] = self.splashDesc3;
			self.splashDesc3.label = splashData.desc3;
			self.splashDesc3.font = self.splashDesc.font;
			
			if ( isdefined( splashData.desc3_set_value ) )
				self.splashDesc3 SetValue( splashData.desc3_set_value );
		}
		if ( isDefined( splashData.desc4 ) && (!isString( splashData.desc4 ) || splashData.desc4 != "") )
		{
			elements[elements.size] = self.splashDesc4;
			self.splashDesc4.label = splashData.desc4;
			self.splashDesc4.font = self.splashDesc.font;
			
			if ( isdefined( splashData.desc4_set_value ) )
				self.splashDesc4 SetValue( splashData.desc4_set_value );
		}
	}

	// END desc section =======================================================
	
	if ( isDefined( splashData.hint ) && ( !isString( splashData.hint ) || splashData.hint != "") )
	{
		elements[elements.size] = self.splashHint;
		self.splashHint.label = splashData.hint;

		if ( isDefined( splashData.hintLabel ) )
			self.splashHint.label = splashData.hintLabel;
	}
		
	if ( isDefined( splashData.fadeIn ) )
	{
		foreach ( element in elements )
			element transitionFadeIn( transTime );
	}
		
	if ( isDefined( splashData.zoomIn ) )
	{
		foreach ( element in elements )
			element transitionZoomIn( transTime );
	}

	if ( isDefined( splashData.slideIn ) )
	{
		foreach ( element in elements )
			element transitionSlideIn( transTime, splashData.slideIn );
	}

	if ( isDefined( splashData.pulseFXIn ) )
	{
		foreach ( element in elements )
			element transitionPulseFXIn( transTime, duration );
	}

	if ( isDefined( splashData.sound ) )
	{
		if( IsDefined( splashData.playSoundLocally ) )
		{
			self PlayLocalSound( splashData.sound );
		}
		else
		{
			foreach( player in level.players )
				player playLocalSound( splashData.sound );
		}
	}

	// wait for splash duration then reset
	if( IsDefined( splashData.abortFlag ) )
		ent_flag_wait_or_timeout( splashData.abortFlag, duration );
	else
		wait ( duration );

	if ( isDefined( splashData.fadeOut ) )
	{
		foreach ( element in elements )
			element transitionFadeOut( transTime );
	}
		
	if ( isDefined( splashData.zoomOut ) )
	{
		foreach ( element in elements )
			element transitionZoomOut( transTime );
	}

	if ( isDefined( splashData.slideOut ) )
	{
		foreach ( element in elements )
			element transitionSlideOut( transTime, splashData.slideOut );
	}
	
	wait( transTime );
	SetSavedDvar( "cg_drawBreathHint", "1" );
	
	// reset params that we may have changed from the default
	self.splashTitle.font			= og_title_font;
	self.splashTitle.label			= og_title_label;
	self.splashTitle.baseFontScale	= og_title_baseFontScale;
	self.splashTitle.glowColor		= og_title_glowColor;
	self.splashTitle.glowAlpha		= og_title_glowAlpha;
	self.splashTitle.color			= og_title_color;
	self.splashIcon.shader			= og_icon_shader;
	self.splashDesc.glowcolor 		= og_desc_glowcolor;

	if( IsDefined( og_desc_font ) )
		self.splashDesc.font = og_desc_font;
		
	if( IsDefined( og_desc_baseFontScale ) )
		self.splashDesc.baseFontScale = og_desc_baseFontScale;
		
	self.doingNotify = false;
}

player_reward_splash_init()
{
	line_yOffset = 15;
	
	titleFont = "bankshadow";
	titleSize = 1.5;
	title_yOffset = 70;
	title_xOffset = 0;
	
	textFont = "bankshadow";
	textSize = 1.5;
	text_yOffset = 100; //79;
	text_xOffset = 0;
	
	text2Font = "bankshadow";
	text2Size = 1.5;
	text2_yOffset = 300; //96;
	text2_xOffset = 0;
	
	iconSize = 42;
	icon_yOffset = 120; //8;
	icon_xOffset = 0;
	
	point = "TOP";
	relativePoint = "BOTTOM";
	
	elem = createFontString_mp( titleFont, titleSize );
	elem maps\_hud_util::setPoint( point, undefined, title_xOffset, title_yOffset );
	elem.glowColor = ( 0.3, 0.6, 0.3 );
	elem.glowalpha = 0.3;
	//elem.glowColor = (0.2, 0.3, 0.7);
	//elem.glowalpha = 0.3;
	elem.hideWhenInMenu = true;
	elem.archived = false;
	elem.alpha = 0;
	self.splashTitle = elem;
	
	elem = undefined;

	elem = createFontString_mp( textFont, textSize );
	elem maps\_hud_util::setParent( self.splashTitle );
	elem maps\_hud_util::setPoint( point, relativePoint, text_xOffset, text_yOffset );
	elem.glowColor = ( 0, 0, 0 );
	elem.glowAlpha = 0;
	elem.hideWhenInMenu = true;
	elem.archived = false;
	elem.alpha = 0;
	self.splashDesc = elem;
	
	elem = undefined;
	
	elem = createFontString_mp( textFont, textSize );
	elem maps\_hud_util::setParent( self.splashTitle );
	elem maps\_hud_util::setPoint( point, relativePoint, text_xOffset, text_yOffset+(1*(line_yOffset)) );
	elem.glowColor = ( 0, 0, 0 );
	elem.glowAlpha = 0;
	elem.hideWhenInMenu = true;
	elem.archived = false;
	elem.alpha = 0;
	self.splashDesc1 = elem;
	
	elem = undefined;

	elem = createFontString_mp( textFont, textSize );
	elem maps\_hud_util::setParent( self.splashTitle );
	elem maps\_hud_util::setPoint( point, relativePoint, text_xOffset, text_yOffset+(2*(line_yOffset)) );
	elem.glowColor = ( 0, 0, 0 );
	elem.glowAlpha = 0;
	elem.hideWhenInMenu = true;
	elem.archived = false;
	elem.alpha = 0;
	self.splashDesc2 = elem;
	
	elem = undefined;

	elem = createFontString_mp( textFont, textSize );
	elem maps\_hud_util::setParent( self.splashTitle );
	elem maps\_hud_util::setPoint( point, relativePoint, text_xOffset, text_yOffset+(3*(line_yOffset)) );
	elem.glowColor = ( 0, 0, 0 );
	elem.glowAlpha = 0;
	elem.hideWhenInMenu = true;
	elem.archived = false;
	elem.alpha = 0;
	self.splashDesc3 = elem;
	
	elem = undefined;

	elem = createFontString_mp( textFont, textSize );
	elem maps\_hud_util::setParent( self.splashTitle );
	elem maps\_hud_util::setPoint( point, relativePoint, text_xOffset, text_yOffset+(4*(line_yOffset)) );
	elem.glowColor = ( 0, 0, 0 );
	elem.glowAlpha = 0;
	elem.hideWhenInMenu = true;
	elem.archived = false;
	elem.alpha = 0;
	self.splashDesc4 = elem;
	
	elem = undefined;
	
	elem = createFontString_mp( "hudbig", 0.75 );
	elem maps\_hud_util::setParent( self.splashDesc );
	elem maps\_hud_util::setPoint( point, relativePoint, text2_xOffset, text2_yOffset );
	elem.glowColor = ( 0, 0, 0 );
	elem.glowAlpha = 0;
	elem.hideWhenInMenu = true;
	elem.archived = false;
	elem.alpha = 0;
	elem.color = ( 0.75, 1, 0.75 );
	self.splashHint = elem;
	
	elem = undefined;

	elem = createIcon_mp( "white", iconSize, iconSize );
	elem maps\_hud_util::setParent( self.splashTitle );
	elem setPoint( point, relativePoint, icon_xOffset, icon_yOffset );
	elem.hideWhenInMenu = true;
	elem.archived = false;
	elem.alpha = 0;
	self.splashIcon = elem;
}

createFontString_mp( font, textSize )
{
	fontElem = NewClientHudElem( self );
	fontElem.hidden = false;
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = textSize;
	fontElem.baseFontScale = fontElem.fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int( level.fontHeight * fontElem.fontScale );
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem maps\_hud_util::setParent( level.uiParent );
	
	return fontElem;
}

createIcon_mp( shader, width, height )
{
	iconElem = NewClientHudElem( self );
	iconElem.elemType = "icon";
	iconElem.x = 0;
	iconElem.y = 0;
	iconElem.width = width;
	iconElem.height = height;
	iconElem.baseWidth = iconElem.width;
	iconElem.baseHeight = iconElem.height;
	iconElem.xOffset = 0;
	iconElem.yOffset = 0;
	iconElem.children = [];
	iconElem maps\_hud_util::setParent( level.uiParent );
	iconElem.hidden = false;
	
	if ( isDefined( shader ) )
	{
		iconElem setShader( shader, width, height );
		iconElem.shader = shader;
	}
	
	return iconElem;
}

// waits for splash notifies, uav usage, etc to finish
waittill_players_ready_for_splash( timeoutSecs )
{
	timeoutTime = GetTime() + milliseconds( timeoutSecs );
	
	while( 1 )
	{
		if( GetTime() >= timeoutTime )
		{
			break;
		}
		
		delay = false;
		foreach( player in level.players )
		{
			if( player.doingNotify || player.using_uav )
			{
				delay = true;
				break;
			}
		}
		
		if( delay )
		{
			wait( 0.1 );
		}
		else
		{
			break;
		}
	}
}

transitionReset()
{
	self SetText( "" );
	
	self.x = self.xOffset;
	self.y = self.yOffset;
	if ( self.elemType == "font" )
	{
		self.fontScale = self.baseFontScale;
		self.label = &"";
	}
	else if ( self.elemType == "icon" )
	{
		//self scaleOverTime( 0.001, self.width, self.height );
		self setShader( self.shader, self.width, self.height );
	}
	self.alpha = 0;
}

transitionZoomIn( duration )
{
	switch ( self.elemType )
	{
		case "font":
		case "timer":
			self.fontScale = 6.3;
			self changeFontScaleOverTime( duration );
			self.fontScale = self.baseFontScale;
			break;
		case "icon":
			self setShader( self.shader, self.width * 6, self.height * 6 );
			self scaleOverTime( duration, self.width, self.height );
			break;
	}
}

transitionPulseFXIn( inTime, duration )
{
	transTime = int(inTime)*1000;
	showTime = int(duration)*1000;
	
	switch ( self.elemType )
	{
		case "font":
		case "timer":
			self setPulseFX( transTime+250, showTime+transTime, transTime+250 );
			break;
		default:
			break;
	}
}

transitionSlideIn( duration, direction )
{
	if ( !isDefined( direction ) )
		direction = "left";

	switch ( direction )
	{
		case "left":
			self.x += 1000;
			break;
		case "right":
			self.x -= 1000;
			break;
		case "up":
			self.y -= 1000;
			break;
		case "down":
			self.y += 1000;
			break;		
	}
	self moveOverTime( duration );
	self.x = self.xOffset;
	self.y = self.yOffset;
}

transitionSlideOut( duration, direction )
{
	if ( !isDefined( direction ) )
		direction = "left";

	gotoX = self.xOffset;
	gotoY = self.yOffset;

	switch ( direction )
	{
		case "left":
			gotoX += 1000;
			break;
		case "right":
			gotoX -= 1000;
			break;
		case "up":
			gotoY -= 1000;
			break;
		case "down":
			gotoY += 1000;
			break;		
	}

	self.alpha = 1;
	
	self moveOverTime( duration );
	self.x = gotoX;
	self.y = gotoY;
}

transitionZoomOut( duration )
{
	switch ( self.elemType )
	{
		case "font":
		case "timer":
			self changeFontScaleOverTime( duration );
			self.fontScale = 6.3;
		case "icon":
			self scaleOverTime( duration, self.width * 6, self.height * 6 );
			break;
	}
}

transitionFadeIn( duration )
{
	self fadeOverTime( duration );
	if ( isDefined( self.maxAlpha ) )
		self.alpha = self.maxAlpha;
	else
		self.alpha = 1;
}

transitionFadeOut( duration )
{
	self fadeOverTime( 0.15 );
	self.alpha = 0;
}
// END HUD UTILITY -------------------------------------------------------

// ==========================================================================
// AI HELPER FUNCTIONS
// ==========================================================================

// get spawners array by classname
get_spawners_by_classname( classname )
{
	spawners = getentarray( classname, "classname" );
	real_spawners = [];
	foreach( spawner in spawners )
	{
		if ( isspawner( spawner ) )
			real_spawners[ real_spawners.size ] = spawner;
	}
	
	return real_spawners;
}

get_spawners_by_targetname( targetname )
{
	all_spawners 	= getspawnerarray();
	found_spawners 	= [];
	
	foreach( spawner in all_spawners )
		if ( isdefined( spawner.targetname ) && spawner.targetname == targetname )
			found_spawners[ found_spawners.size ] = spawner;
	
	return found_spawners;
}

// best spawn location helper function
get_furthest_from_these( array, avoid_locs, rand_locs_num )
{
	rand_locs_num = ter_op( isdefined( rand_locs_num ), rand_locs_num, 1 );
	rand_locs_num = max( 1, rand_locs_num );
	
	// keep removing closest spawns to leaders and players until 1 left, then randomly pick one to spawn
	while( array.size > rand_locs_num )
	{
		foreach ( avoid_loc in avoid_locs )
		{
			element = getclosest( avoid_loc.origin, array );
			if ( array.size > rand_locs_num )
			{
				//thread maps\_squad_enemies::draw_debug_marker( element.origin, ( 1, 0.5, 0.5 ) );
				array = array_remove( array, element );
			}
			else
			{
				element = array[ 0 ];
				thread maps\_squad_enemies::draw_debug_marker( element.origin, ( 1, 1, 1 ) );
				break;
			}
		}
	}
	
	return array[ randomint( array.size ) ];
}

// this only makes AI more inclined to throw grenade, not ASAP nor guaranteed
throw_grenade_at_player( player )
{
	self 	endon( "death" );
	player 	endon( "stopped camping" );
	
	// some stuns
	if ( cointoss() )
		self.grenadeweapon  = "flash_grenade";
	else
		self.grenadeweapon  = "fraggrenade";
	
	self.grenadeammo = 2;
	self.script_forceGrenade = 1;
	//self ThrowGrenadeAtPlayerASAP();
	wait 8;
	self.script_forceGrenade = 0;
	
	// reset
	self.grenadeweapon  = "fraggrenade";
}

// rid the dead or removed bosses from level.bosses array
clear_from_boss_array_when_dead()
{
	self waittill( "death" );
	bosses = [];
	
	foreach( boss in level.bosses )
		if ( isdefined( boss ) && ( !isdefined( self ) || self != boss ) )
			bosses[ bosses.size ] = boss;

	level.bosses = bosses;
}

// rid the dead or removed special AI from level.special_ai array
clear_from_special_ai_array_when_dead()
{
	self waittill( "death" );
	special_ais = [];
	foreach( ai in level.special_ai )
	{
		if ( isalive( ai ) )
			special_ais[ special_ais.size ] = ai;
	}
	level.special_ai = special_ais;	
}

was_headshot()
{
	// Special field set in Survival AI when damage was scaled
	// up enough on a headshot to force a kill
	if ( IsDefined( self.died_of_headshot ) && self.died_of_headshot )
		return true;
		
	if ( !IsDefined( self.damageLocation ) )
		return false;

	return( self.damageLocation == "helmet" || self.damageLocation == "head" || self.damageLocation == "neck" );
}

// ==========================================================================
// VEHICLE FUNCTIONS
// ==========================================================================

// This is all wrapped up in one function so that as soon as a chopper is
// needed the desired path is flagged as in use.
chopper_spawn_from_targetname_and_drive( name, spawn_origin, path_start )
{
	msg = "passed start struct without targetname: " + name;
	assertex( !isdefined( path_start.in_use ), "helicopter told to use path that is in use." );
	
	// Must happen first since chopper_spawn() functions could 
	// potentially wait for the spawner to be free
	path_start.in_use = true;
	
	chopper = chopper_spawn_from_targetname( name, spawn_origin );
	chopper.loc_current = path_start;
	
	chopper thread vehicle_paths( path_start );

	return chopper;
}

chopper_spawn_from_targetname( name, spawn_origin )
{
	chopper_spawner = getent( name, "targetname" );
	assertex( isdefined( chopper_spawner ), "Invalid chopper spawner targetname: " + name );
	
	// set health if defined in string table
	set_health = maps\_so_survival_ai::get_ai_health( name );
	if ( isdefined( set_health ) )
		chopper_spawner.script_startinghealth = set_health;
	
	while ( isdefined( chopper_spawner.vehicle_spawned_thisframe ) )
		wait 0.05;
		
	if ( isdefined( spawn_origin ) )
		chopper_spawner.origin = spawn_origin;

	chopper = spawn_vehicle_from_targetname( name );
	assertex( isdefined( chopper ), "chopper failed to spawn." );
		
	return chopper;
}

// pilot is a drone
chopper_spawn_pilot_from_targetname( name, position )
{
	all_spawners = getspawnerarray();
	spawner = undefined;
	foreach ( spawner in all_spawners )
		if ( isdefined( spawner.targetname ) && spawner.targetname == name )
			break;
			
	assertex( isdefined( spawner ), "no spawner with targetname of: " + name );
	
	pilot = self chopper_spawn_passenger( spawner, position, true );
	
	// Pilot should not die, magic_bullet_shield is not an option because
	// vehicle scripts assert when dying with a magically shielded passenger
	pilot.health = 9999;
	
	return pilot;
}

chopper_spawn_passenger( spawner, position, drone )
{
	passenger = undefined;
	while( 1 )
	{
		spawner.count = 1;
		if ( isdefined( drone ) && drone )
		{
			passenger = dronespawn( spawner );
			break;
		}
		else
		{
			passenger = spawner spawn_ai( true );
		
			if ( !spawn_failed( passenger ) )
				break;
		}
		
		wait 0.5;
	}
	
	if ( isdefined( position ) )
		passenger.forced_startingposition = position;
	
	self guy_enter_vehicle( passenger );
	
	return passenger;
}

chopper_drop_smoke_at_unloading()
{
	self endon( "death" );

	self waittill( "unloading" );
	
	// drop smoke at ground position traced from back of chopper, where AI will land essentially
	tail_pos = self.origin - ( vectornormalize( anglestoforward( self.angles ) ) * 145 );
	groundposition = groundpos( tail_pos );
	MagicGrenadeManual( "smoke_grenade_american", groundposition, ( 0, 0, -1 ), 0 );
}

chopper_wait_for_cloest_open_path_start( target_origin, start_name, struct_string_field )
{
	path_start = undefined;
	while ( 1 )
	{
		path_start = chopper_closest_open_path_start( target_origin, start_name, struct_string_field );
		if ( isdefined( path_start ) )
			break;
			
		wait 0.25;
	}
	
	return path_start;
}

// returns the start struct of the helicopter path containing the
// closest struct with the specified struct_string_field that is
// not currently in use
chopper_closest_open_path_start( target_origin, start_name, struct_string_field )
{
	path_starts = GetStructArray( start_name, "targetname" );
	assertex( path_starts.size, "No heli path structs with targetname: " + start_name );
	
	closest_path_start = undefined;
	closest_path_start_dist = undefined;
	closest_path_drop = undefined;
	
	foreach ( path_start in path_starts )
	{
		if ( isdefined( path_start.in_use ) )
			continue;
		
		path_drop = path_start;
		
		switch ( struct_string_field )
		{
			case "script_unload":
			{
				while ( !isdefined( path_drop.script_unload ) )
					path_drop = getstruct( path_drop.target, "targetname" );
					
				assertex( isdefined( path_drop.script_unload ), "Level has a helicopter path without a struct with script_unload defined." );
				if ( !isdefined( path_drop.script_unload ) )
					continue;
					
				break;
			}
			case "script_stopnode":
			{
				while ( !isdefined( path_drop.script_stopnode ) )
					path_drop = getstruct( path_drop.target, "targetname" );
					
				assertex( isdefined( path_drop.script_stopnode ), "Level has a helicopter path without a struct with script_stopnode defined." );
				if ( !isdefined( path_drop.script_stopnode ) )
					continue;
					
				break;
			}
			default:
				assertmsg( "Invalid struct_string_field: " + struct_string_field );
				break;
		}
		
		if ( !isdefined( closest_path_drop ) )
		{
			closest_path_drop = path_drop;
			closest_path_start_dist = distance2d( target_origin, path_drop.origin );
			closest_path_start = path_start;
		}
		else
		{
			path_drop_dist = distance2d( target_origin, path_drop.origin );
			if ( path_drop_dist < closest_path_start_dist )
			{
				closest_path_drop = path_drop;
				closest_path_start_dist = distance2d( target_origin, closest_path_drop.origin );
				closest_path_start = path_start;
			}
		}	
	}
	
	return closest_path_start;	
}

// ==========================================================================
// UTILITY FUNCTIONS
// ==========================================================================

// removing MP ents that show up in SO
MP_ents_cleanup()
{
	entitytypes = getentarray();
	for ( i = 0; i < entitytypes.size; i++ )
	{
		if ( isdefined( entitytypes[ i ].script_gameobjectname ) )
			entitytypes[ i ] delete();
	}
}

// Precache item helper
Precache_loadout_item( item_ref )
{
	if ( isdefined( item_ref ) && item_ref != "" )
		PrecacheItem( item_ref );	
}

int_capped( int_input, int_min, int_max )
{
	return int( max( int_min, min( int_max, int_input ) ) );
}

float_capped( float_input, float_min, float_max )
{
	return max( float_min, min( float_max, float_input ) );
}

delete_on_load()
{
	ents = GetEntArray( "delete", "targetname" );
	foreach( ent in ents )
		ent Delete();
}

milliseconds( seconds )
{
	return seconds * 1000;
}

seconds( milliseconds )
{
	return milliseconds / 1000;
}

random_player_origin()
{
	assertex( isdefined( level.players ) && level.players.size, "Level.players not defined yet." );
	
	return level.players[ randomint( level.players.size ) ].origin;
}

highest_player_rank()
{
	rank = -1;
	foreach( player in level.players )
	{
		player_rank = player maps\_rank::getRank();
		
		if ( player_rank > rank )
			rank = player_rank;	
	}
	
	return rank;
}

// Wait at least 0.05 to avoid error: - cannot delete during think -
// that happens when an entity was linked and then is deleted :-/
ent_linked_delete()
{
	assertex( isdefined( self ), "Entity must be defined." );
	
	self endon( "death" );
	
	self unlink();
	
	wait 0.05;
	
	if ( isdefined( self ) )
		self delete();
}

so_survival_kill_ai( attacker, dmg_type, weapon_type )
{
	AssertEx( IsDefined( self ), "Survival kill AI must have defined self." );
	AssertEx( IsAlive( self ), "Survival kill AI called on already dead actor." );
	AssertEx( IsAI( self ), "Survival kill AI called on non AI." );
	AssertEx( !IsDefined( self.magic_bullet_shield ), "Survival kill AI called on AI with magic_bullet_shield." );
	
	if ( IsDefined( attacker ) )
	{
		if ( IsDefined( dmg_type ) && IsDefined( weapon_type ) )
		{
			// Need to make sure script waiting for this AI to die get
			// the passed damage type and weapon type so notify death
			// with these parameters and then kill the AI.
			self notify( "death", attacker, dmg_type, weapon_type );
			
			// Notify death does not kill the AI so make sure he's
			// actually dead for any function waiting on death or
			// using getaiarray() to see who is alive
			self Kill();
		}
		else
		{
			self Kill( attacker.origin, attacker );	
		}
	}
	else
	{
		self Kill();
	}	
}

break_glass()
{
	glass_break_structs = getstructarray( "struct_break_glass", "targetname" );
	foreach ( struct in glass_break_structs )
	{
		GlassRadiusDamage( struct.origin, 64, 100, 99 );
	}
}

// ======================================================================
// DEBUG ENTITY PLACEMENTS
// ======================================================================

so_survival_validate_entities()
{
	// Make armories not solid while testing entities
	array_script_brushmodels = GetEntArray( "armory_script_brushmodel", "targetname" );
	foreach ( brush_model in array_script_brushmodels )
	{
		brush_model NotSolid();
	}
	
	
	origin_offset 		= (0,0,0);
	trace_length_up		= 60.0;
	trace_length_down	= 60.0;
	
	array_objects = [];
	
	// Armories
	array_objects[ array_objects.size ] = GetEnt( "armory_weapon", "targetname" );
	array_objects[ array_objects.size ] = GetEnt( "armory_equipment", "targetname" );
	array_objects[ array_objects.size ] = GetEnt( "armory_airsupport", "targetname" );
	
	// Claymores
	array_objects = array_combine( array_objects, getstructarray( "so_claymore_loc", "targetname" ) );
	
	// Spawn Locations
	array_objects = array_combine( array_objects, getstructarray( "leader", "script_noteworthy" ) );
	array_objects = array_combine( array_objects, getstructarray( "follower", "script_noteworthy" ) );
	
	foreach ( object in array_objects )
	{
		object so_survival_validate_entity( origin_offset, trace_length_up, trace_length_down );
	}
	
	// Make armories solid again
	foreach ( brush_model in array_script_brushmodels )
	{
		brush_model Solid();
	}
	
	wait 2.0;
	
	if ( IsDefined( level.debug_survival_error_msgs ) && level.debug_survival_error_msgs.size )
	{
		// Print each error to the console
		foreach ( error in level.debug_survival_error_msgs )
		{
			PrintLn( "^1" + error );
		}
		
//		// Comment this out for now so there are no prints in fast server
		
//		// Tell people to look at the console with bold print
//		IPrintLnBold( "^1Survival Errors->Console" );
//		
//		// Draw 3D text at the location of each bad ent / struct
//		thread so_survival_display_entity_error_3D();
	}
}

so_survival_validate_entity( origin_offset, trace_length_up, trace_length_down )
{
	Assert( IsDefined( self ), "Self not defined when validating entity." );
	
	if ( !IsDefined( level.debug_survival_error_msgs ) )
	{
		level.debug_survival_error_msgs = [];
	}
	
	if ( !IsDefined( level.debug_survival_error_locs ) )
	{
		level.debug_survival_error_locs = [];
	}
	
	
	// Check above the object
	origin_start 	= self.origin + origin_offset + ( 0, 0, trace_length_up );
	origin_end		= self.origin + origin_offset;
	
	trace_pos = PhysicsTrace( origin_start, origin_end );
	// Use distance because there is margin for error in trace return
	if ( Distance( trace_pos, origin_end ) > 0.1 )
	{
		level.debug_survival_error_msgs[ level.debug_survival_error_msgs.size ] = "Error: Survival Entity may be in solid at: " + self.origin;
		level.debug_survival_error_locs[ level.debug_survival_error_locs.size ] = self.origin;
		return;
	}
	
	// Check to make sure the ojbect isn't floating
	origin_start 	= self.origin + origin_offset;
	origin_end		= self.origin + origin_offset - ( 0, 0, trace_length_down );
	
	trace_pos = PhysicsTrace( origin_start, origin_end );
	// Use distance because there is margin for error in trace return
	if ( Distance( trace_pos, origin_end ) < 0.1 )
	{
		level.debug_survival_error_msgs[ level.debug_survival_error_msgs.size ] = "Error: Survival Entity floating or under floor: " + self.origin;
		level.debug_survival_error_locs[ level.debug_survival_error_locs.size ] = self.origin;
		return;
	}
}

so_survival_display_entity_error_3D()
{
	if ( !IsDefined( level.debug_survival_error_locs ) || !level.debug_survival_error_locs.size )
	{
		return;
	}
	
	level endon( "special_op_terminated" );
	
	while ( true )
	{
		foreach ( location in level.debug_survival_error_locs )
		{
			Print3d( location, "Ent Bad", (1,0,0), 1.0, 1.0, 200 );
		}
		wait 10.0;
	}
}

// END DEBUG ENTITY PLACEMENTS ----------------------------------------------------
