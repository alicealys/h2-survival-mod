#include common_scripts\utility;
#include maps\_utility;
#include maps\_so_survival_code;
#include maps\_specialops;

// Global Constants:

#define CONST_CHALLENGE_SET_NUM 2	// number of challenges per set

// Tweakables: Tables
#define CH_TABLE "sp/survival_challenge.csv"	// challenge data tablelookup

#define CH_INDEX 0	// Indexing
#define CH_REF 1	// REference String        
#define CH_NAME 2	// Name Loc String         
#define CH_DESC 3	// Desc Loc String  
#define CH_SPLASH 4	// Splash message Loc String
#define CH_ICON 5	// Icon
#define CH_REQ 6	// Requirement Int/Str 
#define CH_XP 7	// XP reward per completion   
#define CH_REPEAT 8	// Repeatable within a wave    
#define CH_CARRY 9	// Does not reset between waves
#define CH_WAVE_ACTIVE 10	// Only available starting this wave
#define CH_WAVE_INACTIVE 11	// Only available upto this wave

// Kill staggering bonus XP
#define CONST_STAGGER_DECAY 1	//points per second
#define CONST_STAGGER_KILLPOINTS 6	//points per kill

// UI stuff
#define CONST_PROG_BAR_WIDTH 104
#define CONST_PROG_BAR_HEIGHT 10

// ======================================================================
// Survival Challenges
// ======================================================================

// precache all challenge strings
precache_challenge_strings()
{
	// mini challenge splash text
	precachestring(&"SO_SURVIVAL_SUR_CH_HEADSHOT");
	//precachestring(&"SO_SURVIVAL_SUR_CH_EXECUTION");
	precachestring(&"SO_SURVIVAL_SUR_CH_STREAK");
	precachestring(&"SO_SURVIVAL_SUR_CH_STAGGER");
	precachestring(&"SO_SURVIVAL_SUR_CH_QUADKILL");
	precachestring(&"SO_SURVIVAL_SUR_CH_FLASH");
	//precachestring(&"SO_SURVIVAL_SUR_CH_SIDEKICK");
	precachestring(&"SO_SURVIVAL_SUR_CH_KNIFE");
}

ch_populate()
{
	index_start = 0;
	index_end = 20;
	ch_array =[];

	for (i = index_start; i <= index_end; i++)
	{
		ref = ch_get_ref_by_index(i);
		if (!isdefined(ref) || ref == "")
			break;

		sur_ch = spawnstruct();
		sur_ch.idx = i;
		sur_ch.ref = ref;
		sur_ch.name = ch_get_name(ref);
		sur_ch.desc = ch_get_desc(ref);
		sur_ch.splash = ch_get_splash(ref);
		sur_ch.icon = ch_get_icon(ref);
		sur_ch.requirement = ch_get_requirement(ref);
		sur_ch.XP = ch_get_xp(ref);
		sur_ch.repeatable = ch_get_repeatable(ref);
		sur_ch.carry = ch_get_carry(ref);
		sur_ch.wave_active = ch_get_wave_active(ref);
		sur_ch.wave_inactive = ch_get_wave_inactive(ref);
		sur_ch.func = challenge_func_director(ref);

		ch_array[ref] = sur_ch;
	}

	return ch_array;	// this array has string index
}

challenge_init()
{
	// init stuff
	level.sur_ch = ch_populate();
	flag_init("challenge_monitor_busy");

	// required by melee kills in roll tracking
	add_global_spawn_function("axis", ::track_melee_streak);
	// required by flashed enemy kills
	add_global_spawn_function("axis", ::track_flash_kill);

	foreach(player in level.players)
	player thread sur_challenge_think();
}

sur_challenge_think()
{
	self surHUD_disable("challenge");

	// wait till survival starts so all required player fields are available
	flag_wait("start_survival");

	while (1)
	{
		// randomly selects number of challenges for the current set, unique per player
		ch_array =[];	// due to string index, we can't randomize it
		foreach(ch in level.sur_ch)
		{
			if (ch.wave_active == 0)
				continue;
			if (ch.wave_inactive == 0)
			{
				if (level.current_wave >= ch.wave_active)
					ch_array[ch_array.size] = ch;
			}
			else
			{
				if (level.current_wave >= ch.wave_active && level.current_wave <= ch.wave_inactive)
					ch_array[ch_array.size] = ch;
			}
		}

		assertex(ch_array.size >= CONST_CHALLENGE_SET_NUM, "Not enough active challenges for this wave");

		// run challenge loops on players

		count = 0;
		ch_array = array_randomize(ch_array);
		self.selected_ch_array =[];
		self.completed_ch =[];

		// randomly select CONST_CHALLENGE_SET_NUM number of challenges
		foreach(challenge in ch_array)
		{
			if (count == CONST_CHALLENGE_SET_NUM)
				break;

			// player's copy
			self.selected_ch_array[challenge.ref] = spawnstruct();
			self.selected_ch_array[challenge.ref].index = count;	// times completed
			self.selected_ch_array[challenge.ref].struct = challenge;	// carry struct for data
			self.selected_ch_array[challenge.ref].animating = false;
			self.completed_ch[challenge.ref] = 0;	// init completion state

			assertex(isdefined(challenge.func), "No function pointer for challenge: " + challenge.ref);
			self thread[[challenge.func]](challenge.ref);
			count++;
		}

		//self thread monitor_challenge_set_completion();

		// animate UI: slide challenge cards
		self maps\_so_survival_challenge_h2mod::sur_hud_animate("challenge");
		level waittill("wave_ended");
		//self delaythread(2, ::surHUD_disable, "challenge");
		//self thread surHUD_disable("challenge");
		level waittill("wave_started");
		self maps\_so_survival_challenge_h2mod::sur_hud_animate("challenge");
		self notify("challenge_reset");
	}
}

challenge_func_director(sur_ch_ref)
{
	switch (sur_ch_ref)
	{
		case "sur_ch_headshot":
			return ::sur_ch_headshot;
		case "sur_ch_streak":
			return ::sur_ch_streak;
		case "sur_ch_stagger":
			return ::sur_ch_stagger;
		case "sur_ch_quadkill":
			return ::sur_ch_quadkill;
		case "sur_ch_knife":
			return ::sur_ch_knife;
		case "sur_ch_flash":
			return ::sur_ch_flash;
	}

	return undefined;
}

// ==== Generic Challenge Logic
sur_ch_generic(sur_ch_ref)
{
	self endon("death");
	self endon("challenge_reset");

	index = self.selected_ch_array[sur_ch_ref].index;
	assert(isdefined(index));
	requirement = ch_get_requirement(sur_ch_ref);
	xp_reward = ch_get_xp(sur_ch_ref);
	carry = ch_get_carry(sur_ch_ref);
	repeatable = ch_get_repeatable(sur_ch_ref);

	assert(isdefined(self.selected_ch_array));
	assert(isdefined(self.selected_ch_array[sur_ch_ref]));

	self.selected_ch_array[sur_ch_ref].completed = 0;
	self.selected_ch_array[sur_ch_ref].progress = 0;
	self thread setup_ch_progress_bar(index, sur_ch_ref);

	// if challenge is based on killing AI/Player
	victim = undefined;

	// repeatable challenge
	while (1)
	{
		while (self.selected_ch_array[sur_ch_ref].progress < requirement)
		{
			self waittill(sur_ch_ref, increment, victim);

			if (!isdefined(increment))
				increment = 1;

			if (increment < 0)
				self.selected_ch_array[sur_ch_ref].progress = 0;	// reset mechanism
			else
				self.selected_ch_array[sur_ch_ref].progress += increment;

			self thread ch_progress_bar_update(sur_ch_ref);	// update bar
		}

		// plays money fx when last guy killed for completion of a challenge
		if (isdefined(victim) && isAI(victim))
			playFx(level._effect["money"], victim.origin + (0, 0, 32));

		// reset progress
		self.selected_ch_array[sur_ch_ref].progress = 0;
		self.selected_ch_array[sur_ch_ref].completed++;
		reward = self.selected_ch_array[sur_ch_ref].completed* ch_get_xp(sur_ch_ref);

		givexp(sur_ch_ref, reward);

		self thread indicate_completion(sur_ch_ref, reward);

		// in case two challenges complete at the same time
		while (flag("challenge_monitor_busy"))
			wait 0.05;

		self notify("challenge_complete", sur_ch_ref);

		// update bar now that progress is empty, delay to get latest calculated data
		self delayThread(0.05, ::ch_progress_bar_update, sur_ch_ref);

		if (!repeatable)
			return;
	}
}

// generic challenge monitor for progress based on kills
generic_kill_monitor(sur_ch_ref, progress_increment)
{
	// self is player, ran on per player
	self endon("death");
	self endon("challenge_reset");

	while (1)
	{
		old_kills = self.stats["kills"];
		level waittill("specops_player_kill", attacker, victim, weaponName, killtype);

		// sentry kills do not count, neither is dead attacker or friendlies
		if (!isalive(attacker) || attacker != self)
		{
			continue;
		}

		waittillframeend;	// wait till self.stats[ "kills" ] is updated

		// update streak points
		if (old_kills<self.stats["kills"])
		{
			kills_delta = self.stats["kills"] - old_kills;

			for (i = 0; i < kills_delta; i++)
			{
				self notify(sur_ch_ref, progress_increment, victim);
				waittillframeend;
			}
		}
	}
}

/*
// ==== Side Kick

sur_ch_sidekick(sur_ch_ref)
{
	self endon("death");
	self endon("challenge_reset");

	self thread sur_ch_generic(sur_ch_ref);
	waittillframeend;

	while (1)
	{
		self waittill("xp_updated", type);
		if (isdefined(type) && type == "assist")
			self notify("sur_ch_sidekick", 1);
	}
}*/

// ==== Flash Banger!

sur_ch_flash(sur_ch_ref)
{
	self thread sur_ch_generic(sur_ch_ref);
}

// self is AI
track_flash_kill()
{
	level endon("special_op_terminated");

	if (!IsAI(self))
		return;

	while (1)
	{
		self waittill("death", attacker, type, weapon);

		if (!isdefined(attacker) || !isplayer(attacker))
			continue;

		if (self isFlashed() && (!isdefined(self.flash_killed) || !self.flash_killed))
		{
			self.flash_killed = true;
			attacker notify("sur_ch_flash", 1);
		}
	}
}

// ==== The Butcher!

sur_ch_knife(sur_ch_ref)
{
	self thread sur_ch_generic(sur_ch_ref);
}

// self is AI
track_melee_streak()
{
	level endon("special_op_terminated");

	if (!IsAI(self))
		return;

	while (1)
	{
		self waittill("death", attacker, type, weapon);

		if (!isdefined(attacker) || !isplayer(attacker))
			continue;

		if (isdefined(weapon) && weapontype(weapon) == "riotshield")
			continue;

		if (isdefined(type) && type == "MOD_MELEE")
			attacker notify("sur_ch_knife", 1);
		else
			attacker notify("sur_ch_knife", -1);
	}
}

// ==== Quad Pwnage!

sur_ch_quadkill(sur_ch_ref)
{
	self thread sur_ch_generic(sur_ch_ref);
}

// ==== Headshots

sur_ch_headshot(sur_ch_ref)
{
	self thread sur_ch_generic(sur_ch_ref);
}

/*
// ==== Executions

sur_ch_execution(sur_ch_ref)
{
	self endon("death");
	self endon("challenge_reset");

	self thread sur_ch_generic(sur_ch_ref);
	waittillframeend;	// vars needed below must be setup first above

	self thread execution_monitor(sur_ch_ref);
}

execution_monitor(sur_ch_ref) {}

*/
// ==== Killstreak Without Damage

sur_ch_streak(sur_ch_ref)
{
	self endon("death");
	self endon("challenge_reset");

	self thread sur_ch_generic(sur_ch_ref);
	waittillframeend;	// vars needed below must be setup first above

	self thread generic_kill_monitor(sur_ch_ref, 1);
	self thread streak_reset(sur_ch_ref);
}

// streak is reset when player gets damage
streak_reset(sur_ch_ref)
{
	self endon("death");
	self endon("challenge_reset");

	while (1)
	{
		self waittill("damage", amount, attacker);
		if (isdefined(attacker) && isAI(attacker))
			self notify(sur_ch_ref, -1);	// -1 to reset
	}
}

// ==== Kill Staggering

sur_ch_stagger(sur_ch_ref)
{
	self endon("death");
	self endon("challenge_reset");

	self thread sur_ch_generic(sur_ch_ref);
	waittillframeend;	// vars needed below must be setup first above

	self thread generic_kill_monitor(sur_ch_ref, CONST_STAGGER_KILLPOINTS);
	self thread stagger_decay(sur_ch_ref);
}

// decay stagger points per second
stagger_decay(sur_ch_ref)
{
	self endon("death");
	self endon("challenge_reset");
	level endon("wave_ended");

	sample_frequency = 5;	// per seconds (20 max)
	sample_frequency = min(20, sample_frequency);
	decay_point_per_sample = CONST_STAGGER_DECAY / sample_frequency;

	while (1)
	{
		// keep stagger points between waves
		grace_time = 2;	// once resumes, we give # seconds of grace time

		while (self.selected_ch_array[sur_ch_ref].progress == 0)
		{
			self waittill_any_timeout(grace_time, sur_ch_ref);
		}

		if (level.survival_wave_intermission)
		{
			level waittill("wave_started");
			wait grace_time;
		}

		for (i = 0; i < sample_frequency; i++)
		{
			wait 1 / sample_frequency;

			old_progress = self.selected_ch_array[sur_ch_ref].progress;
			self.selected_ch_array[sur_ch_ref].progress = max(0, old_progress - decay_point_per_sample);
			setdvar("sur_ch_stagger_progress", ch_progress_get_frac(sur_ch_ref));

			if (!self.selected_ch_array[sur_ch_ref].animating)
			{
				self thread ch_progress_bar_update_animate(sur_ch_ref);
			}
		}
	}
}

// ======================================================================
// UI STUFF
// ======================================================================

#define CONST_Y_OFFSET  -152
#define CONST_X_OFFSET  0

// progress bar for kill staggering of two stages
setup_ch_progress_bar(index, sur_ch_ref)
{
	self maps\_so_survival_challenge_h2mod::sur_hud_challenge_label(index, ch_get_name(sur_ch_ref));
	self thread ch_progress_bar_update(sur_ch_ref);
}

ch_progress_bar_update(sur_ch_ref)
{
	self.selected_ch_array[sur_ch_ref].animating = false;
	index = self.selected_ch_array[sur_ch_ref].index;
	progress = self.selected_ch_array[sur_ch_ref].progress;
	reward_x = self.selected_ch_array[sur_ch_ref].completed + 1;
	requirement = ch_get_requirement(sur_ch_ref);

	self maps\_so_survival_challenge_h2mod::sur_hud_challenge_reward(index, ch_get_xp(sur_ch_ref) * reward_x, reward_x);
	self maps\_so_survival_challenge_h2mod::sur_hud_challenge_progress(index, int((progress / requirement) * 100) / 100);
}

ch_progress_bar_update_animate(sur_ch_ref)
{
	self.selected_ch_array[sur_ch_ref].animating = true;
	index = self.selected_ch_array[sur_ch_ref].index;
	progress = self.selected_ch_array[sur_ch_ref].progress;
	reward_x = self.selected_ch_array[sur_ch_ref].completed + 1;
	requirement = ch_get_requirement(sur_ch_ref);

	self maps\_so_survival_challenge_h2mod::sur_hud_challenge_reward(index, ch_get_xp(sur_ch_ref) * reward_x, reward_x);
	self maps\_so_survival_challenge_h2mod::sur_hud_challenge_progress_animate(index, int((progress / requirement) * 100) / 100);
}

ch_progress_get_frac(sur_ch_ref)
{
	progress = self.selected_ch_array[sur_ch_ref].progress;
	requirement = ch_get_requirement(sur_ch_ref);
	return int((progress / requirement) * 100) / 100;
}

// ======================================================================
// UTILITIES
// ======================================================================

// TO DO: an icon that indicates completion and has number of times you completed it this wave
indicate_completion(sur_ch_ref, reward)
{
	if (IsDefined(self.doingNotify) && self.doingNotify)
	{
		while (self.doingNotify)
			wait(0.05);
	}

	//iprintlnbold("Challenge Complete: " + sur_ch_ref + " - " + times);
	splashData = SpawnStruct();
	splashData.duration = 2.5;
	splashData.sound = "survival_bonus_splash";
	splashData.type = "wave";
	splashData.title_font = "bank";
	splashData.playSoundLocally = true;
	splashData.zoomIn = true;
	splashData.zoomOut = true;
	splashData.fadeIn = true;
	splashData.fadeOut = true;
	splashData.title_glowColor = (0.85, 0.35, 0.15);
	splashData.title_color = (0.95, 0.95, 0.9);

	splashData.title = ch_get_splash(sur_ch_ref);
	splashData.title_set_value = reward;

	splashData.title_baseFontScale = 2;

	self splash_notify_message(splashData);
}

ch_exist(ref)
{
	return isdefined(level.sur_ch) && isdefined(level.sur_ch[ref]);
}

ch_get_index_by_ref(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].idx;

	return tablelookup(CH_TABLE, CH_REF, ref, CH_INDEX);
}

ch_get_ref_by_index(index)
{
	return tablelookup(CH_TABLE, CH_INDEX, index, CH_REF);
}

ch_get_name(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].name;

	return tablelookup(CH_TABLE, CH_REF, ref, CH_NAME);
}

ch_get_desc(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].desc;

	return tablelookup(CH_TABLE, CH_REF, ref, CH_DESC);
}

ch_get_splash(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].splash;

	return tablelookupistring(CH_TABLE, CH_REF, ref, CH_SPLASH);
}

ch_get_icon(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].icon;

	return tablelookup(CH_TABLE, CH_REF, ref, CH_ICON);
}

ch_get_requirement(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].requirement;

	return int(tablelookup(CH_TABLE, CH_REF, ref, CH_REQ));
}

ch_get_XP(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].XP;

	return int(tablelookup(CH_TABLE, CH_REF, ref, CH_XP));
}

ch_get_repeatable(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].repeatable;

	return int(tablelookup(CH_TABLE, CH_REF, ref, CH_REPEAT));
}

ch_get_carry(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].carry;

	return int(tablelookup(CH_TABLE, CH_REF, ref, CH_CARRY));
}

ch_get_wave_active(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].wave_active;

	return int(tablelookup(CH_TABLE, CH_REF, ref, CH_WAVE_ACTIVE));
}

ch_get_wave_inactive(ref)
{
	if (ch_exist(ref))
		return level.sur_ch[ref].wave_inactive;

	return int(tablelookup(CH_TABLE, CH_REF, ref, CH_WAVE_INACTIVE));
}







