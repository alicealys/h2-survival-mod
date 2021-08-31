local mapfile = io.open(scriptdir() .. "/maps/" .. game:getdvar("mapname") .. ".lua", "r")
if (mapfile == nil) then
    print("[Survival] Map not supported")
    return
else
    mapfile:close()
end

local map = require("maps/" .. game:getdvar("mapname"))
map.premain()

__startlistener = game:oninterval(function()
    local players = game:getentarray("player", "classname")

    if (#players > 0) then
        player = players[1]
        __startlistener:clear()
        require("main")
    end
end, 0)