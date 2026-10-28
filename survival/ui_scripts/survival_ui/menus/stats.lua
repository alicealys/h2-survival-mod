require("common/xp")

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

