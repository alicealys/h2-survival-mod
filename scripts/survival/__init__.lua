local mapfile = io.open(scriptdir() .. "/maps/" .. game:getdvar("mapname") .. ".lua", "r")
if (mapfile == nil) then
    print("[Survival] Map not supported")
    return
else
    mapfile:close()
end

local map = require("maps/" .. game:getdvar("mapname"))
map.premain()

game:ontimeout(function()
    require("main")
end, 0)