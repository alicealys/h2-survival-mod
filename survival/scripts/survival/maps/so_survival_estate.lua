local map = {}

map.premain = function()

end

map.main = function()
    game:getent("dsm_obj", "targetname"):delete()
    game:getent("dsm", "targetname"):delete()
    
    local clips = game:getentarray("window_clip", "targetname")
    clips:foreach(entity.delete)

    game:scriptcall("maps/_compass", "setupminimap", "compass_map_estate")

    enableallportalgroups()
    startsurvival()
end

return map
