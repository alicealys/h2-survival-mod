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
        game:executecommand("map invasion")
        return
    end
    
    require("spawner")
    require("objects/hintstring")
    require("objects/wallbuy")
    require("objects/ammo")

    function addspawner(origin)
        table.insert(map.spawners, createspawner(origin))
    end
    
    function findentity(callback, value, type)
        local ents = nil
        if (value and type) then
            ents = game:getentarray(value, type)
        else
            ents = game:getentarray()
        end

        for i = 1, #ents do
            if (callback(ents[i])) then
                return ents[i]
            end
        end
    end

    addspawner(vector:new(-1051.799561, -5579.372559, 2316.214111))
    
    local spawners = game:getspawnerarray()
    print(#spawners)
    for i = 1, #spawners do
        --print(spawners[i].classname, spawners[i].targetname)
    end
    
    -- sentry_minigun  misc_turret     sentry_minigun
    local ents = game:getentarray()
    for i = 1, #ents do
        if (ents[i].classname == "misc_turret" or ents[i].classname:match("weapon") or ents[i].classname == "trigger_radius") then
            ents[i]:delete()
        end
    end

    local ammocache = game:getent("ammo_cache", "targetname")
    local ammocachetrigger = findentity(function(ent)
        return ent ~= ammocache and ent.origin.x == ammocache.origin.x and ent.origin.x == ammocache.origin.x
    end, "script_model", "classname")
    if (ammocachetrigger) then
        createammocache(ammocachetrigger.origin, 1500)
        ammocachetrigger:delete()
    end

    player:onnotify("weapon_fired", function()
        level.struct[45535] = true
        game:scriptcall("maps/invasion", "_ID47707", player)
    end)

    level.spawner = game:getent("bank_nates_attackers", "targetname")
    
    player:setorigin(vector:new(370.983093, -5150.671875, 2614.125000))
    player:setplayerangles(vector:new(0.000000, 147.443344, 0.000000))
    
    game:oninterval(function()
        player:allowprone(true)
        player:allowcrouch(true)
        player:allowstand(true)
    end, 0)    
end

return map