local shop = require("ingame/shop")
local menu = shop("perk_menu", "Perks")

menu.close = function()
    menu.menu:close()
    game:openmenu("shop_menu")
end

function dvar(name)
    local t = {}

    setmetatable(t, {
        ["__index"] = function(t, key)
            if (key == "int") then
                return game:getdvarint(name)
            elseif (key == "float") then
                return game:getdvarfloat(name)
            else
                return game:getdvar(name)
            end
        end,
    })

    return t
end

function addperk(name, perk)
    local cost = dvar("perks_" .. perk .. "_cost")
    local enabled = dvar("perks_" .. perk .. "_enabled")
    local level = dvar("perks_" .. perk .. "_level")
    local money = dvar("player_money")

    local button = menu.additem(name)

    button.onclick = function()
        player:notify("giveperk", perk)
    end

    game:onframe(function()
        if (money.int == nil or cost.int == nil or enabled.int == nil or enabled.int == 0) then
            button.showdisabled()
            return
        end
    
        button.elements.price:settext(cost.int .. "$")
        if (level.int == nil or level.int == 0) then
            button.elements.text:settext(string.upper(name))
        else
            button.elements.text:settext(string.upper(name) .. " (LEVEL " .. level.int + 1 .. ")")
        end
    
        if (money.int < cost.int) then
            button.showdisabled()
            return
        end
    
        if (not button.enabled) then
            button.showenabled()
        end
    end)
end

addperk("Fast Reload", "fastreload")
addperk("Armor", "extrahealth")
addperk("Extra Damage", "extradamage")

menu.addcursor()