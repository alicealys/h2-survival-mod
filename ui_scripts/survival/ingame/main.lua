require("ingame/weapons")
require("ingame/perks")

local shop = require("ingame/shop")
local menu = shop("shop_menu", "Shop")

function addmenu(name, menuname)
    local button = menu.additem(name)

    button.onclick = function()
        menu.menu:close()
        game:openmenu(menuname)
    end
end

addmenu("Weapons", "weapon_menu")
addmenu("Perks", "perk_menu")

menu.addcursor()

game:onnotify("keydown", function(key)
    if (key == 170 and game:getdvarint("cl_paused") == 0 and game:isingame()) then
        game:playsound("h1_ui_menu_accept")
        menu.menu:open()
    end
end)