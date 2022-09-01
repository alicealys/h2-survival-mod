local mapfile = io.open(scriptdir() .. "/maps/" .. game:getdvar("mapname") .. ".lua", "r")
if (not mapfile) then
    print("[SURVIVAL] Map not found")
    return
end

mapfile:close()

game:setdvar("ui_so_besttime", 0)
game:setdvar("ui_so_new_star", 0)
game:setdvar("ui_so_show_difficulty", 1)
game:setdvar("ui_so_show_minimap", 1)

game:setdvar("r_fog", 1)

game:setdvar("scr_autoRespawn", 0)
game:setdvar("ui_deadquote", "")
game:setdvar("beautiful_corner", 0)

game:setdvar("specialops", 0)
game:setdvar("arcademode", 0)
game:setdvar("limited_mode", 0)

game:sharedset("eog_extra_data", "")

local levelmapname = game:getdvar("mapname")
mapname = game:getdvar("mapname")

local s = require("survival")
if (game:getdvar("so_debug") == "1") then
    print(s)
end

map = require("maps/" .. mapname)

if (game:getdvar("so_debug") == "1") then
    print(map)
end

local black = game:newhudelem()
black:setshader("black", 1000, 1000)
black.x = -120
black.y = 0
black:fadeovertime(1)
black.alpha = 0

game:overridedvarint("g_gameskill", 1)

-- set_custom_gameskill_func
level._ID9544 = function()
    game:scriptcall("_ID42298", "_ID34935")
end

gameskill = game:getdvarint("g_gameskill")

map.premain()
mainhook = game:detour(string.format("maps/%s", game:getdvar("mapname")), "main", function()
    mainhook.invoke(level)
    map.main()
end)
