local map = {}

map.premain = function()

end

local function addclips()
    local brushmodel = game:getent("oval_office_door_clip", "targetname")
    brushmodel.origin = vector:new(0, 0, -100000)

    local spawnclip = function(origin)
        local clip1 = game:spawn("script_model", origin)
        clip1:clonebrushmodeltoscriptmodel(brushmodel)
        clip1.angles = vector:new(0, 38, 0)

        local clip2 = game:spawn("script_model", origin + vector:new(0, 0, 120))
        clip2:clonebrushmodeltoscriptmodel(brushmodel)
        clip2.angles = vector:new(0, 38, 0)
        
        local model = game:spawn("script_model", origin)
        model:setmodel("com_barrier_tall1")
    end

    spawnclip(vector:new(-7010, 7250, -680))
    spawnclip(vector:new(-7105, 7250, -680))
    spawnclip(vector:new(-7200, 7250, -680))

    brushmodel:delete()
end

map.main = function()
    game:precachemodel("com_barrier_tall1")

    useclosestspawnpoints = true

    addclips()

    game:scriptcall("maps/_compass", "setupminimap", "compass_map_dcemp_static")
    player:setempjammed(true)

    game:getentarray("door", "targetname"):foreach(entity.delete)
    local kitchendoor = game:getent("whitehouse_kitchen_door", "targetname")
    game:getentarray(kitchendoor.target, "targetname"):foreach(entity.delete)
    kitchendoor:delete()

    enableallportalgroups()
    startsurvival()
end

return map
