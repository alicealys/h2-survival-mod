function frontend()
    require("menus/levelselect")
    require("menus/lobby")
    require("menus/personalization")
    require("menus/stats")

    CoD.Background.CampaignRegular = "survival_menu_bg"
    CoD.Background.Campaign = "survival_menu_bg"
    CoD.Background.CampaignHardened = "survival_menu_bg"
    CoD.Background.CampaignVeteran = "survival_menu_bg"
    CoD.Music.MainSPMusic = "mus_so_main_menu"

    for i = 1, #CoD.DifficultyList do
        CoD.DifficultyList[i].video = CoD.Background.CampaignRegular
    end

    PersistentBackground.ChangeBackground(nil, "survival_menu_bg")

    LUI.LevelSelect.IsAllLevelCompleted = function()
        return false
    end
    
    Engine.CanResumeGame = function()
        return false
    end
    
    local localize = Engine.Localize
    Engine.Localize = function(...)
        local args = {...}
        if (args[1] == "@MENU_SP_FOR_THE_RECORD") then
            return ""
        end
    
        if (args[1] == "@MENU_SP_CAMPAIGN") then
            return localize("@MENU_SP_SURVIVAL_MODE_CAPS")
        end
    
        return localize(unpack(args))
    end
    
    LUI.onmenuopen("main_campaign", function(menu)
        local buttonlist = menu:getChildById(menu.type .. "_list")
        buttonlist:removeElement(buttonlist:getFirstChild())
        buttonlist:removeElement(buttonlist:getFirstChild())
        buttonlist:removeElement(buttonlist:getFirstChild())
        buttonlist:removeElement(buttonlist:getFirstChild():getNextSibling())
    end)
    
    LUI.addmenubutton("main_campaign", {
        index = 1,
        text = "@MENU_SP_SURVIVAL_MODE_CAPS",
        description = Engine.Localize("@MENU_SP_SURVIVAL_MODE_DESC"),
        callback = function()
            LUI.FlowManager.RequestAddMenu(nil, "so_survival_lobby")
        end
    })

    Engine.SetDvarBool("bg_compassShowEnemies", false)
end

function ingame()
    local function cleanstr(str)
        return str:sub(2, #str - 1)
    end

    local mapname = Engine.GetDvarString("mapname")
    local mapnamestr = "@SPECIAL_OPS_" .. Engine.ToUpperCase(mapname)
    local discordstatus = cleanstr(Engine.Localize("@PRESENCE_PLAYINGSO_SURVIVAL", mapnamestr))
    Engine.Exec("setdiscorddetails " .. discordstatus)

    Engine.SetDvarBool("bg_compassShowEnemies", true)

    require("popups/storemenu")
    require("popups/eog_summary")
    require("popups/specops_ui_weaponstore")
    require("popups/specops_ui_equipmentstore")
    require("popups/specops_ui_airsupport")
    require("hud/main")

    LUI.sp_hud.PauseMenu.canChangeDifficulty = function() return false end
    LUI.sp_hud.PauseMenu.canLowerDifficulty = function() return false end
    LUI.sp_hud.ObjectivesFrame.AddIntelAndDifficulty = function() end
    LUI.sp_hud.ObjectivesFrame.canShowMinimap = function() 
        return tonumber(Engine.GetDvarString("ui_so_show_minimap")) == 1
    end

    local getdvarbool = Engine.GetDvarBool
    Engine.GetDvarBool = function(...)
        local args = {...}
        if (args[1] == "specialops") then
            return true
        end

        if (args[1] == "limited_mode") then
            return true
        end

        if (args[1] == "hud_showStance" or args[1] == "hud_showstance") then
            return false
        end

        return getdvarbool(...)
    end

    isNoRussian = function()
        return false
    end

    LUI.sp_hud.Objectives.OnOpenObjectives = function() end
    LUI.sp_hud.Objectives.OnCloseObjectives = function() end
end

if (Engine.InFrontend()) then
    frontend()
else
    ingame()
end

if (Engine.GetBinding("skip") == Engine.LocalizeLong("KEY_UNBOUND")) then
    Engine.Exec("bind F5 skip")
end

LUI.ActionsControls.CreateOptions = function(a1)
    LUI.Options.CreateControlProfileDataButton(
        a1, 
        "autoWeaponSwitch",
        "profile_toggleAutoWeaponSwitch",
        nil, "LUA_MENU_AUTO_WEAPON_SWITCH",
        "LUA_MENU_AUTO_WEAPON_SWITCH_DESC", 
        {
		    {
			    text = "@LUA_MENU_DISABLED",
			    value = false
		    },
		    {
			    text = "@LUA_MENU_ENABLED",
			    value = true
		    }
	    }
    )

	LUI.Options.CreateControlBindButton(a1, "@MENU_FIRE_WEAPON", "@MENU_FIRE_WEAPON_DESC", "+attack")
	LUI.Options.CreateControlBindButton(a1, "@MENU_AIM_DOWN_THE_SIGHT", "@MENU_AIM_DOWN_THE_SIGHT_DESC", "+toggleads_throw")
	LUI.Options.CreateControlBindButton(a1, "@MENU_HOLD_AIM_DOWN_SIGHT", "@MENU_HOLD_AIM_DOWN_SIGHT_DESC", "+speed_throw")
	LUI.Options.CreateControlBindButton(a1, "@MENU_RELOAD_WEAPON", "@MENU_RELOAD_WEAPON_DESC", "+reload")
	LUI.Options.CreateControlBindButton(a1, "@MENU_SWITCH_WEAPON", "@MENU_SWITCH_WEAPON_DESC", "weapnext")
	LUI.Options.CreateControlBindButton(a1, "@MENU_MELEEATTACK", "@MENU_MELEEATTACK_DESC", "+melee_zoom")

	if (not Engine.IsMultiplayer()) then
		LUI.Options.CreateControlBindButton(a1, "@MENU_ABILITY_FRAG_GRENADE", "@MENU_ABILITY_FRAG_GRENADE_DESC", "+frag")
		LUI.Options.CreateControlBindButton(a1, "@MENU_ABILITY_SPECIAL_GRENADE", "@MENU_ABILITY_SPECIAL_GRENADE_DESC", "+smoke")
		LUI.Options.CreateControlBindButton(a1, "@MENU_USE_DROP", "@MENU_USE_DROP_DESC", "+activate")
		LUI.Options.CreateControlBindButton(a1, "@MENU_ABILITY_NVG", "@MENU_ABILITY_NVG_DESC", "+actionslot 1")
		LUI.Options.CreateControlBindButton(a1, "@MENU_WEAPON_ATTACHMENT", "@MENU_WEAPON_ATTACHMENT_DESC", "+actionslot 3")
		LUI.Options.CreateControlBindButton(a1, "@MENU_PRIMARY_INVENTORY", "@MENU_PRIMARY_INVENTORY_DESC", "+actionslot 4")
		LUI.Options.CreateControlBindButton(a1, "@MENU_SECONDARY_INVENTORY", "@MENU_SECONDARY_INVENTORY_DESC", "+actionslot 2")
		LUI.Options.CreateControlBindButton(a1, "@MENU_INSPECT_WEAPON", "@MENU_INSPECT_WEAPON_DESC", "weapinspect")
		LUI.Options.CreateControlBindButton(a1, "@MENU_SHOW_OBJECTIVES", "@MENU_SHOW_OBJECTIVES_DESC", "+scores")
        LUI.Options.CreateControlBindButton(a1, "@MENU_NEXT_WAVE", "@MENU_NEXT_WAVE_DESC", "skip")
	else
		LUI.Options.CreateControlBindButton(a1, "@MENU_FRAG_EQUIPMENT", "@MENU_FRAG_EQUIPMENT_DESC", "+frag")
		LUI.Options.CreateControlBindButton(a1, "@MENU_THROW_SPECIAL_GRENADE", "@MENU_THROW_SPECIAL_GRENADE_DESC", "+smoke")
		LUI.Options.CreateControlBindButton(a1, "@MENU_USE", "@MENU_USE_DESC", "+activate")
		LUI.Options.CreateControlBindButton(a1, "@MENU_ABILITY_NVG", "@MENU_ABILITY_NVG_DESC", "+actionslot 1")
		LUI.Options.CreateControlBindButton(a1, "@MENU_WEAPON_ATTACHMENT", "@MENU_WEAPON_ATTACHMENT_DESC", "+actionslot 3")
		LUI.Options.CreateControlBindButton(a1, "@MENU_KILLSTREAK_REWARD_SLOT_GIMME", "@MENU_KILLSTREAK_REWARD_SLOT_GIMME_DESC", "+actionslot 4")
		LUI.Options.CreateControlBindButton(a1, "@MENU_INSPECT_WEAPON", "@MENU_INSPECT_WEAPON_DESC", "weapinspect")
		LUI.Options.CreateControlBindButton(a1, "@MENU_SHOW_SCORESMENU", "@MENU_SHOW_SCORESMENU_DESC", "+scores")
	end

	LUI.Options.InitScrollingList(a1.list, nil)
end
