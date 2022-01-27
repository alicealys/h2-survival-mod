local shop = require("ingame/shop")
local maps = require("ingame/maps")
local menu = shop("weapon_menu", "Weapon Armory")

menu.close = function()
    menu.menu:close()
    game:openmenu("shop_menu")
end

local categories = {
    pistols = shop("weapon_pistols_menu", "Pistols"),
    shotguns = shop("weapon_shotguns_menu", "Shotguns"),
    smgs = shop("weapon_smgs_menu", "Submachine Guns"),
    rifles = shop("weapon_rifles_menu", "Assault Rifles"),
    lmgs = shop("weapon_lmgs_menu", "Light Machine Guns"),
    snipers = shop("weapon_snipers_menu", "Sniper Rifles"),
    explosives = shop("weapon_explosives_menu", "Explosives")
}

for k, v in pairs(categories) do
    v.close = function()
        v.menu:close()
        game:openmenu("weapon_menu")
    end
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

function addcategory(category, name)
    local button = menu.additem(name)
    button.onclick = function()
        menu.menu:close()
        game:openmenu(category)
    end
end

function addweapon(category, name, weapon, cost)
    local money = dvar("player_money")
    local button = category.additem(name)

    button.onclick = function()
        player:notify("buyweapon", weapon, cost)
    end

    game:onframe(function()
        if (money.int == nil) then
            button.showdisabled()
            return
        end
    
        button.elements.price:settext(cost .. "$")
    
        if (money.int < cost) then
            button.showdisabled()
            return
        end

        if (button.enabled ~= true) then
            button.showenabled()
        end
    end)
end

local mapname = game:getdvar("mapname")

if (maps[mapname] ~= nil) then
    for class, weapons in pairs(maps[mapname].weapons) do
        if (categories[class] ~= nil) then
            for i = 1, #weapons do
                categories[class].notempty = true
                addweapon(categories[class], weapons[i].name, weapons[i].weapon, weapons[i].cost)
            end

            categories[class].addcursor()
        end
    end
end

function addmaxammo()
    local money = dvar("player_money")
    local button = menu.additem("Max Ammo")

    button.onclick = function()
        player:notify("givemaxammo")
    end

    game:onframe(function()
        if (money.int == nil) then
            button.showdisabled()
            return
        end
    
        button.elements.price:settext("1500$")
    
        if (money.int < 1500) then
            button.showdisabled()
            return
        end

        if (button.enabled ~= true) then
            button.showenabled()
        end
    end)
end

addmaxammo()

local order = {"pistols", "shotguns", "smgs", "rifles", "lmgs", "snipers", "explosives"}
for i = 1, #order do
    local category = categories[order[i]]
    if (category.notempty == true) then
        addcategory(category.name, category.title)
    end
end

menu.addcursor()