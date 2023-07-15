local createprogressbar = function(left, bottom, width)
    local barwidth = width
    local progressbar = LUI.UIElement.new({
        bottomAnchor = true,
        leftAnchor = true,
        width = barwidth,
        left = left,
        bottom = bottom,
        height = 15
    })

    local bg = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true,
        alpha = 0.55,
        color = Colors.grey_14,
    })

    local bar = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        bottomAnchor = true,
        width = 0,
        material = RegisterMaterial("h1_ui_progressbar_green")
    })

    progressbar.setprogress = function(fraction)
        bar:registerAnimationState("progress", {
            topAnchor = true,
            leftAnchor = true,
            bottomAnchor = true,
            width = fraction * (barwidth),
        })
        
        bar:animateToState("progress", 300)
    end

    progressbar:addElement(bg)
    progressbar:addElement(bar)
    progressbar:addElement(LUI.DecoFrame.new(nil, LUI.DecoFrame.Grey))

    return progressbar
end

local function addplayerprogression(menu, width)
    local rank, icon, max = getrank()
    local rankid = rank - 1
    local rankinfo = getrankinfo(rankid)
    local ranknext = max and getrankinfo(rankid) or getrankinfo(rankid + 1)
    local rankprev = max and getrankinfo(rankid - 1) or getrankinfo(rankid)

    local ranknextvalue = max and rank or rank + 1
    local rankprevvalue = max and rank - 1 or rank

    local xpmax = tonumber(rankinfo.xpmax)

    local height = 90
    local container = LUI.UIElement.new({
        leftAnchor = true,
        topAnchor = true,
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

    bg:addElement(LUI.DecoFrame.new(nil, LUI.DecoFrame.Black))

    local iconheight = 50
    local iconoffset = 5

    local iconleft = LUI.UIImage.new({
        topAnchor =  true,
        leftAnchor = true,
        left = 10,
        top = iconoffset,
        height = iconheight,
        width = iconheight,
        material = RegisterMaterial(rankprev.icon)
    })

    local iconright = LUI.UIImage.new({
        topAnchor =  true,
        rightAnchor = true,
        right = -10,
        top = iconoffset,
        height = iconheight,
        width = iconheight,
        material = RegisterMaterial(ranknext.icon)
    })

    local xptext = LUI.UIText.new({
        topAnchor = true,
        leftAnchor = true,
        left = 0,
        width = width,
        alignment = LUI.Alignment.Center,
        color = Colors.h2.yellow,
        top = 35,
        font = CoD.TextSettings.Font24.Font,
        height = CoD.TextSettings.Font24.Height,
    })
    
    local rankoffset = 60
    local rankleft = LUI.UIText.new({
        topAnchor = true,
        leftAnchor = true,
        left = rankoffset,
        width = width,
        color = {
            r = 0.8,
            g = 0.8,
            b = 0.8,
        },
        top = 25,
        font = CoD.TextSettings.Font24.Font,
        height = CoD.TextSettings.Font24.Height,
    })
    
    local rankright = LUI.UIText.new({
        topAnchor = true,
        rightAnchor = true,
        right = -rankoffset,
        width = width,
        color = {
            r = 0.8,
            g = 0.8,
            b = 0.8,
        },
        top = 25,
        font = CoD.TextSettings.Font24.Font,
        height = CoD.TextSettings.Font24.Height,
    })

    local ranknametext = LUI.UIText.new({
        topAnchor = true,
        leftAnchor = true,
        left = 0,
        width = width,
        alignment = LUI.Alignment.Center,
        color = {
            r = 0.8,
            g = 0.8,
            b = 0.8,
        },
        top = 15,
        font = CoD.TextSettings.Font24.Font,
        height = CoD.TextSettings.Font24.Height,
    })

    local currentxp = getxp()
    xptext:setText(Engine.Localize("@MENU_SP_X_SLASH_Y_XP", currentxp, xpmax))

    ranknametext:setText(Engine.Localize(rankinfo.namestrfull))

    local progressbar = createprogressbar(10, -10, width - 20)
    progressbar.setprogress(currentxp / xpmax)

    rankleft:setText(rankprevvalue)
    rankright:setText(ranknextvalue)

    container:addElement(bg)
    container:addElement(iconright)
    container:addElement(iconleft)
    container:addElement(progressbar)
    container:addElement(xptext)
    container:addElement(ranknametext)
    container:addElement(rankleft)
    container:addElement(rankright)
    menu.list:addElement(container)
end

LUI.MenuBuilder.registerType("so_survival_stats_main", function(a1)
	local menu = LUI.MenuTemplate.new(a1, {
		menu_title = Engine.Localize("@MENU_STATS_CAPS"),
		exclusiveController = 0,
		menu_width = 400,
		menu_height = 800,
		menu_top_indent = LUI.MenuTemplate.spMenuOffset,
		showTopRightSmallBar = true,
        spacing = 1,
	})

    local width = 400

    addplayerprogression(menu, width)

    local addentry = function(text, getstat)
        local height = 30
        local entry = LUI.UIElement.new({
            leftAnchor = true,
            topAnchor = true,
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

        bg:addElement(LUI.DecoFrame.new(nil, LUI.DecoFrame.Black))

        local label = LUI.UIText.new({
            topAnchor = true,
            leftAnchor = true,
            left = 20,
            color = {
                r = 0.8,
                g = 0.8,
                b = 0.8,
            },
            top = height / 2 - CoD.TextSettings.Font24.Height / 2 + 2,
            font = CoD.TextSettings.Font24.Font,
            height = CoD.TextSettings.Font24.Height,
        })

        local value = LUI.UIText.new({
            topAnchor = true,
            rightAnchor = true,
            right = -20,
            color = {
                r = 0.8,
                g = 0.8,
                b = 0.8,
            },
            top = height / 2 - CoD.TextSettings.Font24.Height / 2 + 2,
            font = CoD.TextSettings.Font24.Font,
            height = CoD.TextSettings.Font24.Height,
        })

        entry:addElement(bg)
        entry:addElement(label)
        entry:addElement(value)

        label:setText(Engine.Localize(text))

        local statvalue = tostring(getstat())
        if (type(statvalue) == "string") then
            value:setText(statvalue)
        end

        menu.list:addElement(entry)
    end

    local getstatfunc = function(stat)
        return function()
            return mods.stats.getstructor("career", stat, 0)
        end
    end

    local getaccuracy = function()
        local hits = getstatfunc("bullets_hit")()
        local total = math.max(1, getstatfunc("bullets_fired")())

        return Engine.Localize("@MENU_SP_STAT_NUM_PERCENT", string.format("%.2f", (hits / total) * 100))
    end

    addentry("@MENU_SP_KILLS_PRE", getstatfunc("kills"))
    addentry("@MENU_SP_KILLS_J_PRE", getstatfunc("kills_juggernaut"))
    addentry("@MENU_SP_HEADSHOTS_PRE", getstatfunc("headshots"))
    addentry("@MENU_SP_ACCURACY_PRE", getaccuracy)
    addentry("@MENU_SP_WAVES_SURVIVED_PRE", getstatfunc("waves_survived"))

    addsurvivalbackground(menu)

	menu:AddBackButton(function(a1)
		Engine.PlaySound(CoD.SFX.MenuBack)
		LUI.FlowManager.RequestLeaveMenu(a1)
	end)

    LUI.Options.InitScrollingList(menu.list)

	return menu
end)

