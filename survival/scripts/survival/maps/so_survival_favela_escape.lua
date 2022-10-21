local map = {}

map.premain = function()
    game:getentarray():foreach(function(ent)
        if (ent.model == "h2_favela_escape_truck_fence_clean_a") then
            ent:delete()
        end
    end)

    game:getentarray("sbmodel_airliner_flyby", "targetname"):foreach(entity.delete)

    game:precachemodel("h1_me_door_wood_painted")
    game:visionsetnaked("favela_escape", 0)

    game:getent("sbmodel_market_door_1", "targetname"):delete()
    game:getent("sbmodel_vista1_door1", "targetname"):delete()
    game:getent("pf0_auto7013", "targetname"):delete()

    local brush = game:getent("pf0_auto7014", "targetname")
    brush.origin = vector:new(0, 0, -100000)

    local door = game:spawn("script_model", vector:new(-2515.680420, -1538.391724, 1036.596436))
    door:setmodel("h1_me_door_wood_painted")
    door.angles = vector:new(0, -270, 0)

    local doorcol = game:spawn("script_model", vector:new(-2515.680420, -1539.391724, 1086.596436))
    doorcol:clonebrushmodeltoscriptmodel(brush)

    local col1 = game:spawn("script_model", vector:new(6368.233887, 51.760971, 1053.604370))
    col1.angles = vector:new(0.000000, 83.053589, 0.000000)
    local col2 = game:spawn("script_model", vector:new(6349.233887, -8.239029, 1053.604370))
    col2.angles = vector:new(0.000000, 72.053589, 0.000000)
    local col3 = game:spawn("script_model", vector:new(6356.696289, 11.948925, 1055.381226))
    col3.angles = vector:new(0.000000, 72.053589, 0.000000)

    col1:clonebrushmodeltoscriptmodel(brush)
    col2:clonebrushmodeltoscriptmodel(brush)
    col3:clonebrushmodeltoscriptmodel(brush)
end

map.main = function()
    game:scriptcall("maps/_compass", "setupminimap", "compass_map_favela_escape")
    enableallportalgroups()
    startsurvival()
end

return map
