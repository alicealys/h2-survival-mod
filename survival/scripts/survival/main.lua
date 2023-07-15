game:setdvar("ui_so_besttime", 0)
game:setdvar("ui_so_new_star", 0)
game:setdvar("ui_so_show_difficulty", 1)
game:setdvar("ui_so_show_minimap", 1)   

game:setdvar("scr_autoRespawn", 0)
game:setdvar("ui_deadquote", "")
game:setdvar("beautiful_corner", 0)

game:setdvar("specialops", 0)
game:setdvar("arcademode", 0)
game:setdvar("limited_mode", 0)

game:sharedset("eog_extra_data", "")

local s = require("survival")
if (game:getdvar("so_debug") == "1") then
    print(s)
end
