local map = {}

map.premain = function()

end

map.main = function()
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_dcemp_static")
    player:setempjammed(true)

    enableallportalgroups()
    --startsurvival()
end

return map
