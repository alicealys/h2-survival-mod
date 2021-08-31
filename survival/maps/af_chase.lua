local map = {
    spawners = {},
    startweapon = "beretta",
    shotguns = {"m240"},
    smgs = {"m240"},
    rifles = {"m240"},
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
        game:executecommand("map af_chase")
        return
    end
    
    require("spawner")
    require("objects/hintstring")
    require("objects/wallbuy")
    require("objects/ammo")

    function addspawner(origin)
        table.insert(map.spawners, createspawner(origin))
    end

    addspawner(vector:new(27727.693359, 35636.476562, -9908.715820))
    
    local spawners = game:getspawnerarray()
    print(#spawners)
    for i = 1, #spawners do
        print(spawners[i].classname, spawners[i].targetname)
    end

    level.spawner = game:getent("pf1_auto1699", "targetname")
    
    player:setorigin(vector:new(28943, 35464, -9898))
    player:setplayerangles(vector:new(0.000000, 50, 0.000000))
    
    game:oninterval(function()
        player:allowprone(true)
        player:allowcrouch(true)
        player:allowstand(true)
    end, 0)    
end

return map