local map = {}

map.premain = function()

end

map.main = function()
    game:getentarray("trigger_multiple_slide", "classname"):foreach(entity.delete)

    enableallportalgroups()
    --startsurvival()
end

return map
