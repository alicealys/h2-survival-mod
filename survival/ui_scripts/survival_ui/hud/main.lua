require("hud/score")
require("hud/wavesummary")
require("hud/perks")

local actionslotdef = LUI.MenuBuilder.m_definitions["actionSlotDef"]
LUI.MenuBuilder.m_definitions["actionSlotDef"] = function()
	local actionslot = actionslotdef()
    actionslot.states.default.left = 720
    return actionslot
end

local oncreate = function(menu)
    local createstate = CoD.CreateState
    CoD.CreateState = function(...)
        local args = {...}
        if (args[2] == 127.66 and args[3] == 12.670002) then
            CoD.CreateState = createstate
            return createstate(nil, 10, 235, nil, CoD.AnchorTypes.TopLeft)
        end

        return createstate(...)
    end

    LUI.sp_hud.ObjectivesFrame.AddMiniMap(menu)
    local minimap = menu.miniMapContainer:getFirstChild()

    minimap:registerAnimationState("hud_off", {
        alpha = 0
    })

    minimap:registerAnimationState("hud_on", {
        alpha = 1
    })

    local hudoff = menu.m_eventHandlers["hud_off"]
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

    addscorehud(menu)
    addwavesummaryhud(menu)
    addperkshud(menu)
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
