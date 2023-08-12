require("common/xp")

local csv = "sp/survival_maps.csv"
local cols = {
	id = 0,
	mapname = 1,
	namestr = 2,
	descstr = 3,
	loadscreen = 4,
	video = 5,
	tier = 6,
	videobg = 7
}

local function createdivider(menu, text)
	local element = LUI.UIImage.new({
		leftAnchor = true,
		rightAnchor = true,
        topAnchor = true,
        bottomAnchor = false,
		left = 0,
		right = 0,
		top = 0,
		bottom = 0.5,
        material = RegisterMaterial("white"),
        color = {
            r = 0.5,
            g = 0.5,
            b = 0.5,
        }
	})

	element.scrollingToNext = true
	menu.list:addElement(element)
end

selectedmap = 0
local prevmap = Engine.GetDvarString("survival_prevmapid")
if (prevmap ~= nil) then
	selectedmap = tonumber(prevmap)

	if (selectedmap >= Engine.TableGetRowCount(csv)) then
		selectedmap = 0
	end
else
	selectedmap = 0
end

function addsurvivalbackground(menu)
	local black_state = CoD.CreateState(nil, nil, nil, nil, CoD.AnchorTypes.All)
	black_state.red = 0
	black_state.blue = 0
	black_state.green = 0
	black_state.alpha = 0
	black_state.left = -100
	black_state.right = 100
	black_state.top = -100
	black_state.bottom = 100

	local black = LUI.UIImage.new(black_state)
	black:setPriority(-1000)

	black:registerAnimationState("BlackScreen", {
		alpha = 1
	})

	black:registerAnimationState("Faded", {
		alpha = 0
	})

	menu:addElement(black)

	local currentbackground = nil
	local changebackground = function(background, isvideobg)
        if (currentbackground == background) then
            return
        end

        currentbackground = background

		if (isvideobg) then
			PersistentBackground.ChangeBackground(nil, background)
		else
			PersistentBackground.ChangeBackground(background, "")
			PersistentBackground.ChangeBackground(background, nil)
		end

		black:animateInSequence( {
			{
				"BlackScreen",
				0
			},
			{
				"Faded",
				2000
			}
		})
	end

	local selectedmapdata = getsurvivalmapatid(selectedmap)
	changebackground(selectedmapdata.video, selectedmapdata.videobg)
end

local function loadmaplist()
	local maps = {}

	for i = 0, Engine.TableGetRowCount(csv) do
		local map = {
			id = tonumber(Engine.TableLookupByRow(csv, i, cols.id)),
			name = Engine.TableLookupByRow(csv, i, cols.mapname),
			namestr = Engine.TableLookupByRow(csv, i, cols.namestr),
			descstr = Engine.TableLookupByRow(csv, i, cols.descstr),
			loadscreen = Engine.TableLookupByRow(csv, i, cols.loadscreen),
			video = Engine.TableLookupByRow(csv, i, cols.video),
			tier = tonumber(Engine.TableLookupByRow(csv, i, cols.tier)),
			videobg = Engine.TableLookupByRow(csv, i, cols.videobg) == "1",
		}

		local basemap = map.name:sub(#"so_survival_" + 1, #map.name)

		if (map.id ~= nil and game:fastfileexists(map.name)) then
			map.available = game:fastfileexists(basemap)
			map.availablen = map.available and 1 or 0
			table.insert(maps, map)
		end
	end

	table.sort(maps, function(a, b)
		if (a.availablen == b.availablen) then
			return a.name < b.name
		end

		return a.availablen > b.availablen
	end)

	return maps
end

local maplist_ = nil
function getsurvivalmaplist()
	if (maplist_ == nil) then
		maplist_ = loadmaplist()
	end
	return maplist_
end

function getsurvivalmapatid(id)
	local maps = getsurvivalmaplist()

	for i = 1, #maps do
		if (maps[i].id == id) then
			return maps[i]
		end
	end

	return nil
end

local function startmap(id)
	local data = getsurvivalmapatid(id)
   	Engine.SetDvarBool("cl_disableMapMovies", true)
    Engine.Exec("map " .. data.name)
end

local function addplayer(menu)
	local width = 400
	local height = GenericButtonSettings.Styles.FlatButton.height

	local player = LUI.UIElement.new({
		topAnchor = true,
		rightAnchor = true,
		right = 0,
		top = 100,
		width = width,
		height = height,
	})

	local bg = LUI.UIImage.new({
		topAnchor = true,
		leftAnchor = true,
		rightAnchor = true,
		bottomAnchor = true,
		color = Colors.black,
		material = RegisterMaterial("white"),
        alpha = 0.55,
	})

	bg:addElement(LUI.DecoFrame.new(nil, LUI.DecoFrame.Grey))

	local playername = LUI.UIText.new({
		topAnchor = true,
		leftAnchor = true,
		left = 20,
		color = {
			r = 0.9,
			g = 0.9,
			b = 0.9,
		},
		top = height / 2 - CoD.TextSettings.Font24.Height / 2 + 2,
		font = CoD.TextSettings.Font24.Font,
		height = CoD.TextSettings.Font24.Height,
	})

	local rank, icon = getrankforxp(getxp())

	local iconheight = height - 5
	local rankicon = LUI.UIImage.new({
		topAnchor = true,
		rightAnchor = true,
		right = -40,
		material = RegisterMaterial(icon),
		top = height / 2 - iconheight / 2,
		height = iconheight,
		width = iconheight,
	})

	local rankvalue = LUI.UIText.new({
		topAnchor = true,
		rightAnchor = true,
		right = -20,
		color = {
			r = 0.9,
			g = 0.9,
			b = 0.9,
		},
		top = height / 2 - CoD.TextSettings.Font24.Height / 2 + 2,
		font = CoD.TextSettings.Font24.Font,
		height = CoD.TextSettings.Font24.Height,
	})

	rankvalue:setText(rank)
	playername:setText(Engine.GetDvarString("name"))
	player:addElement(bg)
	player:addElement(playername)
	player:addElement(rankicon)
	player:addElement(rankvalue)

	menu:addElement(player)
end

LUI.MenuBuilder.registerType("so_survival_gamesetup", function(a1)
	local menu = LUI.MenuTemplate.new(a1, {
		menu_title = Engine.Localize("@LUA_MENU_GAME_SETUP_CAPS"),
		exclusiveController = 0,
		menu_width = 400,
		menu_height = 800,
		menu_top_indent = LUI.MenuTemplate.spMenuOffset,
		showTopRightSmallBar = true
	})

	local waves = {
		{
			value = "1",
			text = "1"
		},
		{
			value = "5",
			text = "5"
		},
		{
			value = "10",
			text = "10"
		},
		{
			value = "20",
			text = "20"
		},
		{
			value = "50",
			text = "50"
		},
		{
			value = "100",
			text = "100"
		}
	}

	if (Engine.GetDvarString("survival_start_wave") == nil) then
		Engine.SetDvarFromString("survival_start_wave", "1")
	end

	LUI.Options.CreateOptionButton(menu, 
		"survival_start_wave", 
		"@LUA_MENU_WAVE_CAPS", 
		"@LUA_MENU_WAVE_DESC", 
		waves
	)

	menu:AddButton("@MENU_MAP", "so_survival_mapselect", nil, nil, nil, {
		variant = GenericButtonSettings.Variants.Info,
		button_display_func = function()
			local selectedmapdata = getsurvivalmapatid(selectedmap)
			return Engine.Localize(selectedmapdata.namestr)
		end
	})

	local black_state = CoD.CreateState(nil, nil, nil, nil, CoD.AnchorTypes.All)
	black_state.red = 0
	black_state.blue = 0
	black_state.green = 0
	black_state.alpha = 0
	black_state.left = -100
	black_state.right = 100
	black_state.top = -100
	black_state.bottom = 100

	local black = LUI.UIImage.new(black_state)
	black:setPriority(-1000)

	black:registerAnimationState("BlackScreen", {
		alpha = 1
	})

	black:registerAnimationState("Faded", {
		alpha = 0
	})

	menu:addElement(black)

	local currentbackground = nil
	local changebackground = function(background, isvideobg)
        if (currentbackground == background) then
            return
        end

        currentbackground = background

		if (isvideobg) then
			PersistentBackground.ChangeBackground(nil, background)
		else
			PersistentBackground.ChangeBackground(background, "")
			PersistentBackground.ChangeBackground(background, nil)
		end

		black:animateInSequence( {
			{
				"BlackScreen",
				0
			},
			{
				"Faded",
				2000
			}
		})
	end

	local selectedmapdata = getsurvivalmapatid(selectedmap)
	changebackground(selectedmapdata.video, selectedmapdata.videobg)

	menu:AddBackButton(function(a1)
		Engine.PlaySound(CoD.SFX.MenuBack)
		LUI.FlowManager.RequestLeaveMenu(a1)
	end)

    LUI.Options.InitScrollingList(menu.list)

	return menu
end)


LUI.MenuBuilder.registerType("so_survival_lobby", function(a1)
	local menu = LUI.MenuTemplate.new(a1, {
		menu_title = Engine.Localize("@MENU_SP_SURVIVAL_MODE_CAPS"),
		exclusiveController = 0,
		menu_width = 240,
		menu_height = 800,
		menu_top_indent = LUI.MenuTemplate.spMenuOffset,
		showTopRightSmallBar = true
	})

	local black_state = CoD.CreateState(nil, nil, nil, nil, CoD.AnchorTypes.All)
	black_state.red = 0
	black_state.blue = 0
	black_state.green = 0
	black_state.alpha = 0
	black_state.left = -100
	black_state.right = 100
	black_state.top = -100
	black_state.bottom = 100

	local black = LUI.UIImage.new(black_state)
	black:setPriority(-1000)

	black:registerAnimationState("BlackScreen", {
		alpha = 1
	})

	black:registerAnimationState("Faded", {
		alpha = 0
	})

	menu:addElement(black)

	addplayer(menu)

	local currentbackground = nil
	local changebackground = function(background, isvideobg)
        if (currentbackground == background) then
            return
        end

        currentbackground = background

		if (isvideobg) then
			PersistentBackground.ChangeBackground(nil, background)
		else
			PersistentBackground.ChangeBackground(background, "")
			PersistentBackground.ChangeBackground(background, nil)
		end

		black:animateInSequence( {
			{
				"BlackScreen",
				0
			},
			{
				"Faded",
				2000
			}
		})
	end

	black:animateInSequence( {
		{
			"BlackScreen",
			0
		},
		{
			"Faded",
			2000
		}
	})

	local selectedmapdata = getsurvivalmapatid(selectedmap)
	changebackground(selectedmapdata.video, selectedmapdata.videobg)

	local startbutton = menu:AddButton("@LUA_MENU_START_GAME", function()
		Engine.SetDvarFromString("survival_prevmapid", selectedmap)
		startmap(selectedmap)
	end)

	menu:AddButton("@LUA_MENU_GAME_SETUP_CAPS", "so_survival_gamesetup")
	menu:AddButton("@MENU_STATS_CAPS", "so_survival_stats_main")
	menu:AddButton("@LUA_MENU_PERSONALIZATION_CAPS", "so_survival_personalization_main")

	menu:AddBackButton(function(a1)
		Engine.PlaySound(CoD.SFX.MenuBack)
		LUI.FlowManager.RequestLeaveMenu(a1)
	end)

	menu.optionTextInfo = LUI.Options.AddOptionTextInfo(menu)
    LUI.Options.InitScrollingList(menu.list)

	return menu
end)
