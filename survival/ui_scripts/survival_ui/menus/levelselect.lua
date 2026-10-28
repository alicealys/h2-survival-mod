local csv = "sp/survival_maps.csv"
local cols = {
	index = 0,
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

LUI.MenuBuilder.registerType("so_survival_mapselect", function(a1)
	local menu = LUI.MenuTemplate.new(a1, {
		menu_title = Engine.ToUpperCase(Engine.Localize("@MENU_MAPS")),
		exclusiveController = 0,
		menu_width = 240,
		menu_height = 900,
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

	local previewwidth = 468
	local previewx = 320
	local previewy = 105
	local stencilratio = 1.5

	local previewcontainerstate = CoD.CreateState( GenericMenuDims.menu_right_standard + 12, 61, nil, nil, CoD.AnchorTypes.TopLeft )
	previewcontainerstate.width = previewwidth
	previewcontainerstate.height = 410
	local previewcontainer = LUI.UIElement.new(previewcontainerstate)

	local bg = LUI.MenuBuilder.BuildRegisteredType( "generic_menu_background" )
	bg:addElement(LUI.DecoFrame.new(CoD.CreateState( 0, 0, 0, 0, CoD.AnchorTypes.All ), LUI.DecoFrame.Grey))

	local imagemaskstate = CoD.CreateState( 3 + 0.5, 8.5, -3 + 0.5, nil, CoD.AnchorTypes.TopLeftRight )
	imagemaskstate.height = (previewwidth - 2 * 3) * 0.71
	local imagemask = LUI.UIElement.new(imagemaskstate)
	imagemask:setUseStencil(true)

	local mapimagestate = CoD.CreateState( -17, 25, 25, nil, CoD.AnchorTypes.TopLeftRight )
	mapimagestate.height = previewwidth / 1.5
	local mapimage = LUI.UIImage.new(mapimagestate)
	mapimage:setUseStencil(true)

	local textfont = CoD.TextSettings.BodyFontVeryTiny
	local thewordoffsetx = 37
	local thewordoffsety = 230
	
	local _, _, dimwidth, _ = GetTextDimensions( Engine.Localize( "@LUA_MENU_MAP_CAPS" ), textfont.Font, textfont.Height )
	local themapwordstate = CoD.CreateState( thewordoffsetx, thewordoffsety, dimwidth * 2.08 + thewordoffsetx, thewordoffsety + textfont.Height * 1.75, CoD.AnchorTypes.TopLeft )
	themapwordstate.alpha = 0.7
	themapwordstate.color = {
		r = 0,
		b = 0,
		g = 0
	}
	mapimage:addElement( LUI.UIImage.new(themapwordstate))

	local themapwordtext = LUI.UIText.new({
		topAnchor = true,
		alignment = LUI.Alignment.Left,
		width = 462 - 20,
		top = thewordoffsety + 5.5,
		left = -204,
		height = textfont.Height,
		font = textfont.Font
	})

	mapimage:addElement(themapwordtext)
	themapwordtext:setText(Engine.Localize("@LUA_MENU_MAP_CAPS"))

	local mapnamestate = {
		topAnchor = true,
		width = 462 - 20 + 2,
		left = -214 + 2,
		alignment = LUI.Alignment.Left
	}

	local mapnamefont = CoD.TextSettings.Font46
	mapnamestate.top = 286
	mapnamestate.height = mapnamefont.Height
	mapnamestate.font = mapnamefont.Font
	local mapname = LUI.UIText.new(mapnamestate)
	mapname:setTextStyle(CoD.TextStyle.Shadowed)

	mapnamestate.top = 349
	mapnamestate.height = 14
	mapnamestate.font = mapnamefont.Font
	mapnamestate.alignment = LUI.AdjustAlignmentForLanguage(LUI.Alignment.Left)
	local mapdesc = LUI.UIText.new(mapnamestate)

	mapnamestate.top = 385
	mapnamestate.height = 14
	mapnamestate.font = mapnamefont.Font
	mapnamestate.alignment = LUI.AdjustAlignmentForLanguage(LUI.Alignment.Left)
	local mapbest = LUI.UIText.new(mapnamestate)

	imagemask:addElement(mapimage)
	imagemask:addElement(mapname)
	previewcontainer:addElement(bg)
	previewcontainer:addElement(imagemask)
	previewcontainer:addElement(mapdesc)
	previewcontainer:addElement(mapbest)
	menu:addElement(previewcontainer)

	local getbestwave = function(name)
		return mods.stats.getor("best_wave", name, 0)
	end

    local lastsection = nil
	local count = Engine.TableGetRowCount(csv)
	local maplist = getsurvivalmaplist()
	for i = 1, #maplist do
		local mapdata = maplist[i]

        if (lastsection ~= nil and lastsection ~= tier) then
            createdivider(menu, "")
        end

		if (i == selectedmap) then
			mapimage:setImage(RegisterMaterial(mapdata.loadscreen))
			mapname:setText(Engine.ToUpperCase(Engine.Localize(mapdata.namestr)))
			mapdesc:setText(Engine.Localize(mapdata.descstr))
		end

		local button = menu:AddButton(mapdata.namestr, function()
			selectedmap = mapdata.id
			LUI.FlowManager.RequestLeaveMenu(menu)
		end, not mapdata.available)

		local textlabel = button:getFirstDescendentById("text_label")

		if (selectedmap == mapdata.id) then
			textlabel:registerAnimationState("default", {
				color = Colors.h2.yellow
			})
	
			textlabel:animateToState("default")
		end


		local gainfocus = button.m_eventHandlers["gain_focus"]
		button.m_eventHandlers["gain_focus"] = function(element, event)
			gainfocus(element, event)
			mapimage:setImage(RegisterMaterial(mapdata.loadscreen))
			mapname:setText(Engine.ToUpperCase(Engine.Localize(mapdata.namestr)))
			mapdesc:setText(Engine.Localize(mapdata.descstr))

			local best = getbestwave(mapdata.name)
			if (best > 0) then
				mapbest:setText(Engine.Localize("@SPECIAL_OPS_BEST_WAVE", best))
			else
				mapbest:setText(Engine.Localize("@SPECIAL_OPS_BEST_WAVE", "@SO_SURVIVAL_ARMORY_NA"))
			end
		end
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
