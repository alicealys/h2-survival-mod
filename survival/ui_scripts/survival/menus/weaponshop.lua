local mapname = game:getdvar("mapname")
local maps = require("maps")

local classnames = {
    pistols = "Pistols",
    shotguns = "Shotguns",
    smgs = "Submachine Guns",
    rifles =  "Assault Rifles",
    lmgs = "Light Machine Guns",
    snipers = "Sniper Rifles",
    explosives = "Explosives"
}

function classmenuname(class)
    return "survival_weapon_shop_" .. class .. "_menu"
end

function addcategory(class, title, callback)
    LUI.MenuBuilder.registerType(classmenuname(class), function(a1)
        local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
        LUI.MenuTemplate.InitInGameBkg = function() end
    
        local menu = LUI.MenuTemplate.new(a1, {
            menu_title = title,
            exclusiveController = 0,
            menu_width = 400,
            menu_top_indent = LUI.MenuTemplate.spMenuOffset,
            showTopRightSmallBar = true
        })

        callback(menu)
    
        LUI.MenuTemplate.InitInGameBkg = InitInGameBkg
    
        addmoneytext(menu)
        menu:AddBackButton()
    
        return menu
    end)
end

LUI.MenuBuilder.registerType("survival_weapon_shop_menu", function(a1)
    local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
    LUI.MenuTemplate.InitInGameBkg = function() end

    local menu = LUI.MenuTemplate.new(a1, {
        menu_title = "Weapon Armory",
        exclusiveController = 0,
        menu_width = 400,
        menu_top_indent = LUI.MenuTemplate.spMenuOffset,
        showTopRightSmallBar = true
    })

    LUI.MenuTemplate.InitInGameBkg = InitInGameBkg

    local order = {"pistols", "shotguns", "smgs", "rifles", "lmgs", "snipers", "explosives"}
    for _, class in pairs(order) do
        if (maps[mapname].weapons[class] and #maps[mapname].weapons[class] > 0) then
            menu:AddButton(classnames[class], function()
                LUI.FlowManager.RequestAddMenu(nil, classmenuname(class))
            end)
        end
    end

    addmoneytext(menu)
    menu:AddBackButton()

    return menu
end)

local money = sharedvalue("player_money")

if (maps[mapname] ~= nil) then
    for class, weapons in pairs(maps[mapname].weapons) do
        addcategory(class, classnames[class], function(menu)
            for i = 1, #weapons do
                local name = weapons[i].weapon
                local displayname = game:getweapondisplayname(name)
                displayname = #displayname > 0 and displayname or weapons[i].name
                local cost = weapons[i].cost

                local button = nil
                local update = function()
                    if (money.int < cost and not button.disabled) then
                        disablebutton(button, true)
                    elseif (money.int >= cost and button.disabled) then
                        disablebutton(button, false)
                    end
                end

                button = addbuybutton(menu, {
                    text = displayname,
                    cost = cost,
                    disabled = money.int < cost,
                    callback = function()
                        if (money.int - cost < cost and not button.disabled) then
                            disablebutton(button, true)
                        elseif (money.int - cost >= cost and button.disabled) then
                            disablebutton(button, false)
                        end

                        player:notify("buyweapon", name, cost)
                        update()
                    end
                })

                button:registerEventHandler("update_money", function()
                    update()
                end)

                button:addElement(LUI.UITimer.new(50, "update_money"))
            end
        end)
    end
end