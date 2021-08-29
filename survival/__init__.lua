local mapfile = io.open("maps/" .. game:getdvar("mapname"), "r")
if (mapfile == nil) then
    print("[Survival] Map not supported")
    return
else
    mapfile:close()
end

__startlistener = game:oninterval(function()
    local players = game:getentarray("player", "classname")

    if (#players > 0) then
        player = players[1]
        __startlistener:clear()
        require("main")
    end
end, 0)