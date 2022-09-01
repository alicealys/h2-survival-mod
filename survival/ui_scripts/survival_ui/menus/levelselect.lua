local csv = "sp/survival_maps.csv"
local cols = {
	index = 0,
	mapname = 1,
	namestr = 2,
	descstr = 3,
	loadscreen = 4,
	video = 5,
	tier = 6
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

local function startmap(map, name, desc)
    Engine.SetDvarBool("cl_disableMapMovies", true)
    Engine.SetDvarBool("cl_enableCustomLoadscreen", true)

	Engine.SetDvarString("cl_loadscreenImage", "loadscreen_" .. map)
    Engine.SetDvarString("cl_loadscreenTitle", Engine.LocalizeLong(name))
    Engine.SetDvarString("cl_loadscreenDesc", Engine.LocalizeLong(desc))
    Engine.SetDvarString("cl_loadscreenObjIcon", "")
    Engine.SetDvarString("cl_loadscreenObj", "")

    Engine.Exec("map " .. map)
end

LUI.MenuBuilder.registerType("so_survival_mapselect", function(a1)
	local menu = LUI.MenuTemplate.new(a1, {
		menu_title = Engine.Localize("@MENU_SP_SURVIVAL_MODE_CAPS"),
		exclusiveController = 0,
		menu_width = 400,
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

	local currentbackground = nil
	local changebackground = function(background)
        if (currentbackground == background) then
            return
        end

        currentbackground = background

		PersistentBackground.ChangeBackground(nil, background)
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

    local lastsection = nil
	local count = Engine.TableGetRowCount(csv)
	for i = 0, count - 1 do
		local name = Engine.TableLookupByRow(csv, i, cols.mapname)
		local namestr = Engine.TableLookupByRow(csv, i, cols.namestr)
		local descstr = Engine.TableLookupByRow(csv, i, cols.descstr)
		local video = Engine.TableLookupByRow(csv, i, cols.video)
		local tier = Engine.TableLookupByRow(csv, i, cols.tier)

        if (lastsection ~= nil and lastsection ~= tier) then
            createdivider(menu, "")
        end

		local button = menu:AddButton(namestr, function()
            startmap(name, namestr, descstr)
        end)

		button:registerEventHandler("button_over", function()
        	changebackground(video)
        end)
	end

	if (count > 0) then
		local video = Engine.TableLookupByRow(csv, 0, cols.video)
		changebackground(video)
	end

	menu:AddBackButton(function(a1)
		Engine.PlaySound(CoD.SFX.MenuBack)
		LUI.FlowManager.RequestLeaveMenu(a1)
	end)

    LUI.Options.InitScrollingList(menu.list)

	return menu
end)
