local map = {
    spawners = {},
    startweapon = "beretta",
    shotguns = {"striker", "spas12"},
    smgs = {"mp5_silencer", "ump45_reflex", "tmp", "tmp_reflex", "ump45_eotech", "mp5_reflex"},
    rifles = {"m16_acog", "tavor_mars", "scar_h_reflex", "scar_h_grenadier", "fn2000_reflex", "m240", "scar_h_acog"},
    blackout = 3000
}

function opendoors()
    local doors = {}
    doors.left = game:getent("intro_elevator_door_left", "targetname")
    doors.right = game:getent("intro_elevator_door_right", "targetname")

    doors.left.closepos = doors.left.origin
    doors.right.closepos = doors.right.origin

    local dist = vector:new(-38, 0, 0)

    doors.left.openpos = doors.left.origin - dist
    doors.right.openpos = doors.right.origin + dist

    doors.left.snd = game:spawn("script_origin", doors.left.closepos)
    doors.right.snd = game:spawn("script_origin", doors.right.closepos)

    doors.left.snd:playsound("elev_door_open")

    doors.left:connectpaths()
    doors.right:connectpaths()

    local speed = 14
    local dist = math.abs(game:distance(doors.left.openpos, doors.left.closepos))
    local movetime = (dist / speed) * 0.5

    doors.left:moveto(doors.left.openpos, movetime, movetime * 0.1, movetime * 0.25)
    doors.right:moveto(doors.right.openpos, movetime, movetime * 0.1, movetime * 0.25)
end

function deletecivilians()
    local spawners = game:getspawnerteamarray("allies")
    for i = 1, #spawners do
        spawners[i]:delete()
    end

    local spawners = game:getspawnerteamarray("neutral")
    for i = 1, #spawners do
        spawners[i]:delete()
    end
end

map.premain = function()
    game:setdvar("beautiful_corner", 1)

    -- Don't delete axis spawners
    game:detour("maps/airport_beautiful_corner", "_ID54482", function() end)
    game:detour("_ID43797", "init", function() end)
end

map.main = function()
    game:ontimeout(opendoors, 3300)

    deletecivilians()

    local ents = game:getentarray()
    for i = 1, #ents do
        if (ents[i].team == "allies" and ents[i] ~= player) then
            ents[i]:delete()
        elseif (ents[i].classname and ents[i].classname:match("trigger") and not ents[i].classname:match("metal_detector")) then
            ents[i]:delete()
        end
    end

    require("spawner")
    require("objects/hintstring")
    require("objects/wallbuy")
    require("objects/ammo")

    function addspawner(origin)
        table.insert(map.spawners, createspawner(origin))
    end

    addspawner(vector:new(3165.927246, 3143.088379, 320.125000))
    addspawner(vector:new(2995.774902, 3501.907959, 320.125000))
    addspawner(vector:new(3257.520020, 3828.285400, 320.125000))
    addspawner(vector:new(3235.889160, 4156.064941, 320.125000))
    addspawner(vector:new(3294.618652, 4869.876465, 320.125000))
    addspawner(vector:new(2700.714600, 5213.301270, 320.125000))
    addspawner(vector:new(2700.843750, 4796.940918, 320.125000))
    addspawner(vector:new(2200.968506, 5193.553223, 320.125000))
    addspawner(vector:new(2214.406738, 5076.493164, 320.125000))
    addspawner(vector:new(2223.698242, 4956.506836, 320.125000))
    addspawner(vector:new(2026.508057, 4747.156738, 320.125000))
    addspawner(vector:new(2423.913818, 4039.261719, 64.125000))
    addspawner(vector:new(2649.902588, 4040.363770, 64.125000))
    addspawner(vector:new(2899.109375, 3942.806885, 64.125000))
    addspawner(vector:new(2986.513428, 4453.218262, 64.125000))
    addspawner(vector:new(3638.275391, 3828.230469, 64.125000))
    addspawner(vector:new(3428.758057, 3462.091797, 64.125000))
    addspawner(vector:new(2897.169189, 3219.595703, 64.125000))
    addspawner(vector:new(2554.711182, 3255.044189, 64.125000))
    addspawner(vector:new(2310.940186, 3296.476074, 64.125000))
    addspawner(vector:new(2155.107910, 3565.162598, 64.125000))
    addspawner(vector:new(1996.633667, 3609.314697, 64.125000))
    addspawner(vector:new(1975.341797, 3817.880127, 64.125000))
    addspawner(vector:new(1956.368652, 4158.912109, 64.125000))
    addspawner(vector:new(1966.981689, 4448.877930, 64.125000))
    addspawner(vector:new(3908.404053, 4346.089844, 320.125000))
    addspawner(vector:new(3918.312012, 3808.289795, 320.125000))
    addspawner(vector:new(3998.023926, 3029.246826, 320.125000))
    addspawner(vector:new(4173.866211, 3041.655518, 320.125000))
    addspawner(vector:new(4411.883789, 3237.865967, 320.125000))
    addspawner(vector:new(4855.417480, 3043.814209, 320.125000))
    addspawner(vector:new(5216.873047, 2707.292236, 320.125000))
    addspawner(vector:new(4693.317383, 2607.081787, 320.125000))
    addspawner(vector:new(4595.620605, 2701.302490, 320.125000))
    addspawner(vector:new(4065.779541, 2710.999756, 320.125000))
    addspawner(vector:new(4067.674316, 2601.282715, 320.125000))
    addspawner(vector:new(4121.455566, 2104.088379, 321.125000))
    addspawner(vector:new(4569.534668, 2061.333252, 320.125000))
    addspawner(vector:new(4481.021484, 2309.442627, 320.125000))
    addspawner(vector:new(5580.764648, 1600.221436, 64.125000))
    
    level.spawner = game:getent("actor_enemy_FSB_AR", "classname")

    player:allowprone(true)
    player:allowcrouch(true)
    player:allowstand(true)  
end

return map