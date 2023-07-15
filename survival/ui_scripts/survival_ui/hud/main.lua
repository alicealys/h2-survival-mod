require("hud/score")
require("hud/wavesummary")
require("hud/perks")
require("hud/laststand")

local actionslotdef = LUI.MenuBuilder.m_definitions["actionSlotDef"]
LUI.MenuBuilder.m_definitions["actionSlotDef"] = function()
	local actionslot = actionslotdef()
    actionslot.states.default.left = 720
    return actionslot
end

local objectivesframe = package.loaded["LUI.sp_hud.ObjectivesFrame"]

f0_local0 = 0.58
f0_local1 = 0.6
f0_local2 = 23
local f0_local3 = 0
local f0_local4 = 4
local f0_local5 = nil
local f0_local6 = PauseMenuAnimationSettings.MapGlitch.DurationIn / 7
local f0_local7 = {
	Styles = {
		Minimap = {
			Top = 155.66 - DesignGridDims.vert_gutter + f0_local3,
			Right = DesignGridDims.horz_gutter - 54.66,
			BackgroundWidth = 206,
			BackgroundHeight = 206,
			Width = 178,
			Height = 178
		},
		MapInfos = {
			Top = 6 + f0_local3,
			Right = DesignGridDims.horz_gutter - 71,
			Spacing = 20
		},
		ObjectiveBox = {
			Top = 118.66 - DesignGridDims.vert_gutter + f0_local3,
			Left = GenericMenuDims.menu_width_standard + 122
		},
		ObjectiveTitle = {
			Top = 7 + f0_local3,
			Left = 0,
			Width = 500
		},
		ObjectiveList = {
			Top = 38.16 + f0_local2 + f0_local3,
			Left = 19,
			Width = 500
		}
	}
}

objectivesframe.RefreshMinimapObjectives = function(root, f22_arg1 )
	if objectivesframe.updateMinimapVisibility() then
		local f22_local0 = Engine.GetPlayerObjectivePositions( f0_local7.Styles.Minimap.Width / 1.5, f0_local7.Styles.Minimap.Height / 1.5 )
		if f22_local0 then
			for f22_local1 = 1, #f22_local0, 1 do
				local posx = f22_local0[f22_local1].x * 1.5
				local posy = f22_local0[f22_local1].y * 1.5

				if root.objectiveCount < f22_local1 then
					root.mapBlipPulse:addPulse({
						name = "objective_" .. f22_local1,
						posX = posx,
						posY = posy,
						anchor = CoD.AnchorTypes.None,
						useContainer = f22_arg1,
                        material = "compass_objpoint_helicopter",
                        pulseCount = 0,
                        initialSize = 50,
                        finalSize = 50,
					})

                    local icon = root.mapBlipPulse:getLastChild()
                    icon:registerEventHandler("blip_timer", function(element, event)
                        local v1 = event.props.posX - event.props.initialSize / 2
                        local v2 = event.props.posY - event.props.initialSize / 2
                        local v3 = event.props.posX - event.props.finalSize / 2
                        local v4 = event.props.posY - event.props.finalSize / 2

                        local state = CoD.CreateState(v1, v2, v1 + event.props.initialSize, v2 + event.props.initialSize, event.props.anchor)
                        state.material = RegisterMaterial(event.props.material)
                        state.alpha = 1

                        if (not element.image) then
                            element.image = LUI.UIImage.new(state)
                            element.image.name = event.props.name .. "_blip_icon_" .. event.tag
                            element.image.id = nil
                            element:addElement(element.image)
                        end
                    end)
				end
				local found = false
				local icon = root.mapBlipPulse:getFirstChild()
				while (icon ~= nil and not found) do
					if string.find(icon.id, f22_local1 .. "_container" ) then
						icon:setLeftRight( false, false, posx, posx + 1 )
						icon:setTopBottom( false, false, posy, posy + 1 )
						found = true
					else
						icon = icon:getNextSibling()
					end
				end
			end
			root.objectiveCount = #f22_local0
		else
			root.mapBlipPulse:clearAll()
			root.objectiveCount = 0
		end
	end
end

local function hud_()
    local menucontainer = LUI.UIElement.new({
        leftAnchor = true,
        topAnchor = true,
        width = 1280,
        height = 720
    })
    
    menucontainer:registerAnimationState("hud_on", {
        alpha = 1
    })
    
    menucontainer:registerAnimationState("hud_off", {
        alpha = 0
    })

    menucontainer:registerAnimationState("on", {
        alpha = 1
    })

    menucontainer:registerAnimationState("off", {
        alpha = 0
    })

    menucontainer:registerEventHandler("show_survival_hud", function(element, event)
        if (event.data == "1") then
            menucontainer:animateToState("on", 100)
        else
            menucontainer:animateToState("off", 100)
        end
    end)

    addscorehud(menucontainer)
    addwavesummaryhud(menucontainer)
    addperkshud(menucontainer)
    addlaststandhud(menucontainer)

    return menucontainer
end

LUI.MenuBuilder.registerType("hud_survival", hud_)

local weaponinfo = LUI.MenuBuilder.m_definitions["WeaponInfoHudDef"]
LUI.MenuBuilder.m_definitions["WeaponInfoHudDef"] = function ()
    local def = weaponinfo()
    table.insert(def.children, {
        type = "hud_survival"
    })
    
    return def
end

--[[
LUI.roots.UIRoot0:registerEventHandler("_gc__", function()
    collectgarbage()
    collectgarbage()
    printmemoryusage()

end)
LUI.roots.UIRoot0:addElement(LUI.UITimer.new(400, "_gc__"))--]]

local minimapmenu = nil
do
    local refresh = LUI.sp_hud.ObjectivesFrame.RefreshMinimapObjectives
    LUI.sp_hud.ObjectivesFrame.RefreshMinimapObjectives = function(a1, a2)
        local count = Engine.GetPlayerObjectivePositions(0, 0)
        if (count and minimapmenu.miniMapContainer and minimapmenu.miniMapContainer.miniMapIcons and #count < minimapmenu.miniMapContainer.miniMapIcons.objectiveCount) then
            minimapmenu.miniMapContainer.miniMapIcons.mapBlipPulse:clearAll()
            minimapmenu.miniMapContainer.miniMapIcons.objectiveCount = 0
        end
    
        refresh(a1, a2)
    end
end

local oncreate = function(menu)
    minimapmenu = menu

    local createstate = CoD.CreateState
    CoD.CreateState = function(...)
        local args = {...}
        if (args[2] == 127.66 and args[3] == 12.670002) then
            CoD.CreateState = createstate
            return createstate(nil, 10, 235, nil, CoD.AnchorTypes.TopLeft)
        end

        return createstate(...)
    end

    LUI.sp_hud.ObjectivesFrame.AddMiniMap(menu, true)
    CoD.CreateState = createstate
    local minimap = menu.miniMapContainer:getFirstChild()

    minimap:registerAnimationState("hud_off", {
        alpha = 0
    })

    minimap:registerAnimationState("hud_on", {
        alpha = 1
    })

    minimap.hud_off = false
    minimap.showing_message = false

    minimap:addElement(LUI.UITimer.new(100, "_update"))
    minimap:registerEventHandler("_update", function()
        minimap.showing_message = Game.IsShowingGameMessages(0)
        if (not minimap.showing_message and not minimap.hud_off) then
            minimap:animateToState("hud_on")
        else
            minimap:animateToState("hud_off")
        end
    end)

    minimap:registerEventHandler("game_message", function()
        if (Game.IsShowingGameMessages(0)) then
            minimap:animateToState("hud_off")
            minimap.showing_message = true
        end
    end)
end

local compassdef = LUI.MenuBuilder.m_definitions["CompassHudDef"]
LUI.MenuBuilder.m_definitions["CompassHudDef"] = function()
	local compass = compassdef()
    compass.states.default = {
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true
    }
    
    for i = 1, #compass.children do
        compass.children[i].states.default = {alpha = 0}
    end

    table.insert(compass.children, {
        type = "UIElement",
        states = {
            default = {
                topAnchor = true,
                leftAnchor = true,
                rightAnchor = true,
                bottomAnchor = true,
            },
            hud_off = {
                alpha = 0
            },
            hud_on = {
                alpha = 1
            }
        },
        handlers = {
            menu_create = oncreate
        }
    })
    return compass
end
