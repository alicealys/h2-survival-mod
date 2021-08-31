local map = {
    spawners = {},
    startweapon = "beretta",
    shotguns = {"ak47"},
    smgs = {"ak47"},
    rifles = {"ak47"},
    blackout = 3000
}

map.premain = function()
    -- Don't delete axis spawners
    game:detour("_ID43797", "_ID44261", function() end)
end

map.main = function()
    if (game:getdvar("beautiful_corner") == "" or game:getdvar("beautiful_corner") == "0") then
        print("'beautiful_corner' must be enabled on this map. restarting...")
        game:say("'beautiful_corner' must be enabled on this map. restarting...")
        game:setdvar("beautiful_corner", 1)
        game:executecommand("map contingency")
        return
    end
    
    require("spawner")
    require("objects/hintstring")
    require("objects/wallbuy")
    require("objects/ammo")

    function addspawner(origin)
        table.insert(map.spawners, createspawner(origin))
    end
    
    addspawner(vector:new(-15576.582031, -105.089211, 672.121094))
    addspawner(vector:new(-14753.866211, 1097.846558, 639.125000))
    addspawner(vector:new(-14986.534180, 1520.757812, 639.125000))
    addspawner(vector:new(-14457.393555, 2077.724609, 831.056824))
    addspawner(vector:new(-14098.955078, 787.125000, 655.506409))
    addspawner(vector:new(-14094.978516, 1024.234009, 647.083252))
    addspawner(vector:new(-13827.119141, 1598.279419, 639.125000))
    addspawner(vector:new(-13962.152344, 119.161217, 661.206116))
    addspawner(vector:new(-14929.577148, 135.399078, 692.421753))
    
    level.spawner = game:getent("stationary_group_with_dog_grp_2", "targetname")
    
    player:setorigin(vector:new(-16417.328125, 1013.035950, 935.076050))
    player:setplayerangles(vector:new(0.000000, -58.261227, 0.000000))
    
    game:oninterval(function()
        player:allowprone(true)
        player:allowcrouch(true)
        player:allowstand(true)
    end, 0)    
end

return map