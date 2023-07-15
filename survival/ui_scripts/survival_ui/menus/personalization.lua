math.randomseed(Engine.GetTimeUTC())
math.random(); math.random(); math.random()

local function getsurvivalsoundtracks()
    local soundtracks = {
        {
            text = "MENU_NONE",
            value = ""
        },
        {
            text = "LUA_MENU_RANDOM",
            value = "random"
        }
    }

    local csv = "sp/soundtracks.csv"
    local rows = Engine.TableGetRowCount(csv)

    for i = 0, rows - 1 do
        table.insert(soundtracks, {
            text = Engine.TableLookupByRow(csv, i, 1),
            value = Engine.TableLookupByRow(csv, i, 0),
        })
    end

    return soundtracks
end

local function getrandomsoundtrack()
    local csv = "sp/soundtracks.csv"
    local rows = Engine.TableGetRowCount(csv)
    return Engine.TableLookupByRow(csv, math.random(2, rows - 1), 0)
end

local viewhandscsv = "sp/viewhands.csv"
local viewhandscols = {
    value = 0,
    viewhandsplayer = 1,
    text = 2,
    rank = 3
}

local function getviewhandsname(viewhands)
    local rows = Engine.TableGetRowCount(viewhandscsv)
    for i = 0, rows - 1 do
        local value = Engine.TableLookupByRow(viewhandscsv, i, viewhandscols.value)
        local text = Engine.TableLookupByRow(viewhandscsv, i, viewhandscols.text)
        if (value == viewhands) then
            return Engine.Localize(text)
        end
    end

    return viewhands
end

local csvtotable = function(csv, cols)
    local rows = Engine.TableGetRowCount(csv)
    local data = {}
    for i = 0, rows - 1 do
        local row = {}
        for k, v in pairs(cols) do
            row[k] = Engine.TableLookupByRow(csv, i, cols[k])
        end

        table.insert(data, row)
    end
    return data
end

local function getstartingpistoldata()
    local data = {}
    local csv = "sp/survival_armories.csv"

    local cols = {
        id = 0,
        name = 1,
        type = 2,
        price = 3,
        namestring = 4,
        descstring = 5,
        imagename = 6,
        level = 7,
        attachments = 8,
        unk1 = 9,
        unk2 = 10,
        weaponclass = 11
    }    

    local rows = Engine.TableGetRowCount(csv)
    for i = 0, rows - 1 do
        local class = Engine.TableLookupByRow(csv, i, cols.weaponclass)
        local weapon = Engine.TableLookupByRow(csv, i, cols.name)
        local name = Engine.TableLookupByRow(csv, i, cols.namestring)
        local rank = Engine.TableLookupByRow(csv, i, cols.level)

        if (class == "pistol") then
            table.insert(data, {
                value = weapon,
                text = name,
                rank = rank
            })
        end
    end

    return data
end

local function getstartingpistolname(weapon)
    local data = getstartingpistoldata()
    for i = 1, #data do
        if (data[i].value == weapon) then
            return Engine.Localize(data[i].text)
        end
    end

    return weapon
end

local function selectionmenu(title, statfield, data, callback)
    return function(a1)
        local menu = LUI.MenuTemplate.new(a1, {
            menu_title = Engine.Localize(title),
            exclusiveController = 0,
            menu_width = 400,
            menu_height = 800,
            menu_top_indent = LUI.MenuTemplate.spMenuOffset,
            showTopRightSmallBar = true
        })
    
        local currentvalue = mods.stats.get(statfield)
        local currentrank = getrank()

        for i = 1, #data do
            local value = data[i].value
            local text = data[i].text
            local rank = tonumber(data[i].rank)
            local currentrank = getrank()
    
            local button = menu:AddButton(text, function()
                callback(data[i])
                LUI.FlowManager.RequestLeaveMenu(menu)
            end, currentrank < rank, nil, nil, {
                showLockOnDisable = true
            })

            local container = button:getFirstDescendentById("button")
            local textlabel = button:getFirstDescendentById("text_label")
            local state = textlabel:getAnimationStateInC("default")
    
            if (currentrank < rank) then
                local ranktext = LUI.UIText.new({
                    rightAnchor = true,
                    color = GenericButtonSettings.Common.text_default_color,
                    top = state.top,
                    right = -state.left - 50,
                    bottom = state.bottom,
                    width = 500,
                    alignment = LUI.Alignment.Right,
                    font = CoD.TextSettings.TitleFontTiny.Font,
                })
        
                ranktext:setText(Engine.Localize("@SO_SURVIVAL_ARMORY_LOCKED_LV", rank))
                local textlabel = button:getFirstDescendentById("text_label")
                container:addElement(ranktext)
            end

            if (value == currentvalue) then
                textlabel:registerAnimationState("default", {
                    color = Colors.h2.yellow
                })
        
                textlabel:animateToState("default")
            end
        end
    
        addsurvivalbackground(menu)
    
        menu:AddBackButton(function(a1)
            Engine.PlaySound(CoD.SFX.MenuBack)
            LUI.FlowManager.RequestLeaveMenu(a1)
        end)
    
        LUI.Options.InitScrollingList(menu.list)

        return menu
    end
end

LUI.MenuBuilder.registerType("so_survival_personalization_viewhands",
    selectionmenu("@SO_SURVIVAL_MENU_VIEWHANDS_CAPS", "viewhands", csvtotable(viewhandscsv, viewhandscols), 
        function(data)
            mods.stats.set("viewhands", data.value)
            mods.stats.set("viewhands_player", data.viewhandsplayer)
        end
    )
)

LUI.MenuBuilder.registerType("so_survival_personalization_pistol",
    selectionmenu("@SO_SURVIVAL_MENU_STARTING_PISTOL_CAPS", "starting_pistol", getstartingpistoldata(), 
        function(data)
            mods.stats.set("starting_pistol", data.value)
        end
    )
)

LUI.MenuBuilder.registerType("so_survival_personalization_main", function(a1)
	local menu = LUI.MenuTemplate.new(a1, {
		menu_title = Engine.Localize("@LUA_MENU_PERSONALIZATION_CAPS"),
		exclusiveController = 0,
		menu_width = 400,
		menu_height = 800,
		menu_top_indent = LUI.MenuTemplate.spMenuOffset,
		showTopRightSmallBar = true
	})

	menu:AddButton("@SO_SURVIVAL_MENU_VIEWHANDS_CAPS", "so_survival_personalization_viewhands", nil, nil, nil, {
        desc_text = Engine.Localize("@SO_SURVIVAL_MENU_VIEWHANDS_DESC"),
		variant = GenericButtonSettings.Variants.Info,
		button_display_func = function()
            return getviewhandsname(mods.stats.getor("viewhands", "viewmodel_base_viewhands"))
		end
	})

    menu:AddButton("@SO_SURVIVAL_MENU_STARTING_PISTOL_CAPS", "so_survival_personalization_pistol", nil, nil, nil, {
        desc_text = Engine.Localize("@SO_SURVIVAL_MENU_STARTING_PISTOL_DESC"),
		variant = GenericButtonSettings.Variants.Info,
		button_display_func = function()
			return getstartingpistolname(mods.stats.getor("starting_pistol", "h2_beretta_mp"))
		end
	})

    Engine.SetDvarFromString("so_survival_soundtrack", mods.stats.getor("custom_soundtrack", ""))
    LUI.Options.CreateOptionButton(
        menu,
        "so_survival_soundtrack",
        "@SO_SURVIVAL_MENU_SOUNDTRACK",
        "@SO_SURVIVAL_MENU_SOUNDTRACK_DESC",
        getsurvivalsoundtracks(),
        nil, nil,
        function(value)
            if (value == "") then
                Engine.PlayMusic(CoD.Music.MainSPMusic)
            elseif (value == "random") then
                Engine.PlayMusic(getrandomsoundtrack())
            end

            Engine.PlayMusic(value)
            mods.stats.set("custom_soundtrack", value)
        end
    )

    addsurvivalbackground(menu)

	menu:AddBackButton(function(a1)
        Engine.PlayMusic(CoD.Music.MainSPMusic)
		Engine.PlaySound(CoD.SFX.MenuBack)
		LUI.FlowManager.RequestLeaveMenu(a1)
	end)

    LUI.Options.InitScrollingList(menu.list)
	LUI.Options.AddOptionTextInfo(menu)

	return menu
end)

