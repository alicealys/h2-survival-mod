local map = {}

map.premain = function()

end

local function addclips()

end

game:precachemodel("defaultactor")

map.main = function()
    local spawners = game:getspawnerarray()
    for i = 1, #spawners do
        print("lol")
        game:spawn("script_model", spawners[i].origin ):setmodel("defaultactor")
    end

    game:getentarray("trigger_multiple_slide", "classname"):foreach(entity.delete)

    enableallportalgroups()
    --startsurvival()
end

return map
