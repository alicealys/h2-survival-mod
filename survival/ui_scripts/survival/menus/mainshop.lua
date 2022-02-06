local maps = require("maps")
local mapname = Engine.GetDvarString("mapname")
print(mapname)
if (not maps[mapname]) then
    return
end

local buttonlabelfactory = LUI.UIGenericButton.ButtonLabelFactory
local buttonlabelstate = nil
LUI.UIGenericButton.ButtonLabelFactory = function(...)
    local args = {...}
    buttonlabelstate = args[1]
    return buttonlabelfactory(table.unpack(args))
end

function addbuybutton(menu, data)
    local button = menu:AddButton("$_" .. data.text, function()
        data.callback()
    end, data.disabled)
    
    buttonlabelstate.align = LUI.Alignment.Right
    local costlabel = LUI.UIGenericButton.ButtonLabelFactory(buttonlabelstate, 
        data.cost .. "$", button)
    button:addElement(costlabel)

    button.costlabel = costlabel

    return button
end

function sharedvalue(name)
    local t = {}

    setmetatable(t, {
        ["__index"] = function(t, key)
            local value = game:sharedget(name)

            if (key == "int") then
                if (value == "") then
                    return 0
                end

                return math.floor(tonumber(value))
            elseif (key == "float") then
                if (value == "") then
                    return 0
                end

                return tonumber(value)
            else
                return value
            end
        end,
    })

    return t
end

require("menus/weaponshop")
require("menus/perkshop")

function disablebutton(button, disable)
    button:processEvent({
        name = "lose_focus",
        immediate = true,
        dispatchChildren = true
    })

    button.disabled = disable

    button:processEvent({
        name = "gain_focus",
        immediate = true,
        dispatchChildren = true
    })

    button:processEvent({
        name = "lose_focus",
        immediate = true,
        dispatchChildren = true
    })
end

local money = sharedvalue("player_money")
function addmoneytext(menu)
    local text = LUI.UIText.new({
        bottom = -50,
        bottomAnchor = true,
        leftAnchor = true,
        textStyle = CoD.TextStyle.Shadowed,
        font = CoD.TextSettings.TitleFont.Font,
        height = 30
    })

    text:setTextStyle(CoD.TextStyle.MW2Title)
    text:setText("$" .. money.int)

    text:addEventHandler("update_money", function()
        text:setText("$" .. money.int)
    end)

    text:addElement(LUI.UITimer.new(50, "update_money"))
    menu:addElement(text)
end

LUI.MenuBuilder.registerType("survival_main_shop_menu", function(a1)
    local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
    LUI.MenuTemplate.InitInGameBkg = function() end

    local menu = LUI.MenuTemplate.new(a1, {
        menu_title = "Shop",
        exclusiveController = 0,
        menu_width = 400,
        menu_top_indent = LUI.MenuTemplate.spMenuOffset,
        showTopRightSmallBar = true
    })

    LUI.MenuTemplate.InitInGameBkg = InitInGameBkg

    menu:AddButton("Weapons", function()
        LUI.FlowManager.RequestAddMenu(nil, "survival_weapon_shop_menu")
    end, nil, true, nil, {
        desc_text = "Open the weapon shop"
    })

    menu:AddButton("Perks", function()
        LUI.FlowManager.RequestAddMenu(nil, "survival_perk_shop_menu")
    end, nil, true, nil, {
        desc_text = "Open the perk shop"
    })

    addmoneytext(menu)
    menu:AddBackButton()

    return menu
end)

game:onnotify("keydown", function(key)
    if (key == 170 and game:getdvarint("cl_paused") == 0 and not Engine.InFrontend()) then
        Engine.PlaySound("h1_ui_menu_accept")
        LUI.FlowManager.RequestAddMenu(nil, "survival_main_shop_menu")
    end
end)