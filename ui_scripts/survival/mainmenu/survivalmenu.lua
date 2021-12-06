local ui = require("utils/ui")

local maincampaign = LUI.MenuBuilder.m_types_build["main_campaign"]
LUI.MenuBuilder.m_types_build["main_campaign"] = function(a1, a2)
    local menu = maincampaign(a1, a2)
    local buttonlist = menu:getChildById("main_campaign_list")
    
    local button = menu:AddButton("@MENU_SP_SURVIVAL_MODE_CAPS", function()
        LUI.FlowManager.RequestAddMenu(nil, "survival_menu")
    end, nil, true, nil, {
        desc_text = "Play Survival."
    })

    buttonlist:removeElement(button)
    buttonlist:insertElement(button, 4)
    button.id = "survival_menu_button"

    local hintbox = menu.optionTextInfo
    local firstbutton = buttonlist:getfirstchild()
    hintbox:dispatchEventToRoot({
        name = "set_button_info_text",
        text = firstbutton.properties.desc_text,
        immediate = true
    })

    menu:CreateBottomDivider()
    menu:AddBottomDividerToList(buttonlist:getlastchild())

    menu.list.listHeight = 375
    menu:removeElement(menu.optionTextInfo)
    menu.optionTextInfo = LUI.Options.AddOptionTextInfo(menu)

    return menu
end

function survivalmenu(a1)
	local menu = LUI.MenuTemplate.new(a1, {
		menu_title = Engine.Localize("@MENU_SP_SURVIVAL_MODE_CAPS"),
		exclusiveController = 0,
        menu_width = 400,
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

    local changebackground = function(background)
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

    local mapnames = {
        "favela",
        "estate",
        "cliffhanger",
        "contingency",
        "airport"
    }

	local maps = {
        {
            value = "1",
            text = "Favela"
        },
        {
            value = "2",
            text = "Estate"
        },
        {
            value = "3",
            text = "Cliffhanger"
        },
        {
            value = "4",
            text = "Contingency"
        },
        {
            value = "5",
            text = "Terminal"
        }
    }
	
	local difficulties = {
        {
            value = "0",
            text = Engine.Localize("@MENU_RECRUIT")
        },
        {
            value = "1",
            text = Engine.Localize("@MENU_REGULAR")
        },
        {
            value = "2",
            text = Engine.Localize("@MENU_HARDENED")
        },
        {
            value = "3",
            text = Engine.Localize("@MENU_VETERAN")
        }
    }

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

    game:setdvar("survival_dummy", "")

    local getmap = function(index)
        return mapnames[index] or mapnames[1]
    end

    local mapname = "favela"
    local wave = 1
    local difficulty = 0

    local start = menu:AddButton("@MENU_START_GAME_CAPS", function()
        if (difficulty == 1) then
            Engine.Exec("difficultyMedium")
        elseif (difficulty == 2) then
            Engine.Exec("difficultyHard")
        elseif (difficulty == 3) then
            Engine.Exec("difficultyFu")
        else
            Engine.Exec("difficultyEasy")
        end

        game:setdvar("survival_start_wave", wave)
        Engine.Exec("map " .. mapname)
    end, nil, true, nil, {
        desc_text = Engine.Localize("@MENU_DESC_START_MATCH")
    })

    start:registerAnimationState("default", {
        left = -200,
        top = 0,
        height = 32,
        right = 10
    })

    local state = start:getAnimationStateInC("default")

    start:animateToState("default")

    local leaderboards = menu:AddButton("@LUA_MENU_LEADERBOARDS_CAPS", function()
    end, nil, true, nil, {
        desc_text = Engine.Localize("@MENU_SP_DESC_SO_LEADERBOARDS")
    })

    leaderboards:registerAnimationState("default", {
        left = -200,
        top = 0,
        height = 32,
        right = 10
    })
    
    leaderboards:animateToState("default")

    changebackground("mission_select_bg_" .. getmap(0))

	menu.id = "main_campaign_container"

    menu:AddBackButton(function(a1)
	    Engine.PlaySound(CoD.SFX.MenuBack)
	    LUI.FlowManager.RequestLeaveMenu(a1)
    end)

    LUI.Options.CreateOptionButton(menu, "survival_dummy", "@LUA_MENU_MAP_CAPS", "@MENU_SP_CHANGE_MAP_DESC", maps, nil, nil, function(value)
        mapname = getmap(tonumber(value))
        changebackground("mission_select_bg_" .. mapname)
    end)

    LUI.Options.CreateOptionButton(menu, "survival_dummy", "@LUA_MENU_DIFFICULTY", "Change the difficulty.", difficulties, nil, nil, function(value)
        difficulty = tonumber(value)
    end)

    LUI.Options.CreateOptionButton(menu, "survival_dummy", "WAVE", "Change the starting wave.", waves, nil, nil, function(value)
        wave = tonumber(value)
    end)

    menu.list.listHeight = 208
    menu.optionTextInfo = LUI.Options.AddOptionTextInfo(menu)

    return menu
end

LUI.MenuBuilder.m_types_build["survival_menu"] = survivalmenu

setmetatable(_G, {
    __index = function(t, k)
        return rawget(_G, k) or luiglobals[k]
    end
})

game:setdvar("survival_dummy", "")