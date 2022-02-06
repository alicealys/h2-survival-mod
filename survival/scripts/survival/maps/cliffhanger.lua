local map = {
    spawners = {},
    startweapon = "usp",
    shotguns = {"spas12"},
    smgs = {"ump45_reflex", "kriss_reflex", "p90"},
    rifles = {"ak47_arctic", "aug_reflex_arctic"},
    blackout = 3000
}

map.premain = function()
    game:setdvar("beautiful_corner", 1)

    -- Don't delete axis spawners
    game:detour("_ID43797", "_ID44261", function() end)
end

function initbreachabledoor()
    local door = game:getent("hanger_entrance_door", "targetname")
    local doorcollision = game:getent("hangar_door", "targetname")
    local doorcost = 2000

    local hintstring = createhintstring({
        text = string.format("Press ^3[{+activate}]^7 to breach Door (Cost: %i)", doorcost),
        entity = door,
        height = 100,
        radius = 50
    })

    local listener = nil
    listener = door:onnotify("trigger", function()
        if (player.money < doorcost) then
            player:playlocalsound("ui_tk_click_error")
            return
        end

        listener:clear()
        hintstring.enabled = false

        player.money = player.money - doorcost

        local c4origin = game:spawn("script_origin", door.origin)

        local c4 = game:spawn("script_model", c4origin.origin + vector:new(-1.5, 1.5, 50))
        c4.angles = vector:new(90, 135, 0)
        c4:setmodel("h2_weapon_c4")
        c4:playsound("wpn_semtex_warn_beep")
        c4:playsound("c4_bounce_metal")

        local c4_2 = game:spawn("script_model", c4origin.origin + vector:new(1.5, -1.5, 50))
        c4_2:setmodel("h2_weapon_c4")
        c4_2.angles = vector:new(90, -45, 0)

        game:ontimeout(function()
            local fx = game:loadfx("fx/explosions/c4exp_default")
            game:playfx(fx, c4.origin)
            c4origin:playsound("h1_c4_explosion_main")

            game:radiusdamage(c4.origin, 100, 10, 30, player)
            game:radiusdamage(c4_2.origin, 100, 10, 30, player)

            c4:delete()
            c4_2:delete()
            door:delete()
            doorcollision:delete()

            game:ontimeout(function()
                c4origin:delete()
            end, 0)
        end, 2000)
    end)
end

function inithangardoors()
    local doors = {}

    local function create(origin)
        local originent = game:spawn("script_origin", origin)
        local doorcost = 3000
    
        local hintstring = createhintstring({
            text = string.format("Press ^3[{+activate}]^7 to open Hangar Doors (Cost: %i)", doorcost),
            entity = originent,
            height = 200,
            radius = 50
        })
    
        local listener = originent:onnotify("trigger", function()
            if (player.money < doorcost) then
                player:playlocalsound("ui_tk_click_error")
                return
            end
    
            for i = 1, #doors do
                doors[i].hintstring.enabled = false
                doors[i].listener:clear()
            end
    
            player.money = player.money - doorcost
    
            game:scriptcall("maps/cliffhanger_code", "_ID49460")
        end)

        table.insert(doors, {
            hintstring = hintstring,
            listener = listener
        })
    end

    create(vector:new(-8756.822266, -26180.500000, 896.125000))
    create(vector:new(-8803.828125, -26134.041016, 898.125000))
end

function initcollisions()
    local function createcollision(origin)
        for i = 0, 4 do
            local collision = game:getentbynum(1324 + i)
            local ent = game:spawn("script_model", origin + vector:new(0, 0, 40))
            ent.angles = vector:new(0, 35, 0)
            ent:clonebrushmodeltoscriptmodel(collision)
        end
    end

    createcollision(vector:new(-9280.500000, -27395.246094, 896.125000))
    createcollision(vector:new(-9283.166016, -27535.556641, 896.125000))
    createcollision(vector:new(-9285.351563, -27673.646484, 896.125000))
    createcollision(vector:new(-9290.045898, -27818.257813, 896.125000))
    createcollision(vector:new(-9293.863281, -27957.257813, 896.125000))
    createcollision(vector:new(-9297.341797, -28104.677734, 896.125000))
    createcollision(vector:new(-9297.714844, -28255.900391, 896.125000))
end

map.main = function()
    if (game:getdvar("beautiful_corner") == "" or game:getdvar("beautiful_corner") == "0") then
        print("'beautiful_corner' must be enabled on this map. restarting...")
        game:say("'beautiful_corner' must be enabled on this map. restarting...")
        game:setdvar("beautiful_corner", 1)
        game:executecommand("map cliffhanger")
        return
    end
    
    require("spawner")
    require("objects/hintstring")
    require("objects/wallbuy")
    require("objects/ammo")

    function addspawner(origin)
        table.insert(map.spawners, createspawner(origin))
    end

    addspawner(vector:new(-5732.660645, -24851.964844, 988.870972))
    addspawner(vector:new(-5982.639648, -25451.957031, 993.004822))
    addspawner(vector:new(-5602.523438, -25446.818359, 1130.125000))
    addspawner(vector:new(-5676.208008, -25898.931641, 1003.581604))
    addspawner(vector:new(-5390.399414, -26090.697266, 978.595459))
    addspawner(vector:new(-5105.494629, -26044.455078, 950.558777))
    addspawner(vector:new(-4776.113281, -26025.052734, 963.125000))
    addspawner(vector:new(-4730.425293, -26167.474609, 962.901306))
    addspawner(vector:new(-4659.139160, -26356.718750, 964.622437))
    addspawner(vector:new(-4821.502930, -26451.919922, 963.706482))
    addspawner(vector:new(-4687.521484, -26561.035156, 969.238281))
    addspawner(vector:new(-4694.364746, -26936.203125, 930.286865))
    addspawner(vector:new(-4283.703613, -27354.806641, 1018.822510))
    addspawner(vector:new(-3872.341553, -27370.792969, 1061.344971))
    addspawner(vector:new(-4573.842285, -25831.212891, 958.134521))
    addspawner(vector:new(-4760.741699, -25604.980469, 956.032288))
    addspawner(vector:new(-4608.719238, -24414.355469, 981.125000))
    addspawner(vector:new(-4155.460938, -24265.089844, 966.348022))
    addspawner(vector:new(-3811.384033, -23942.785156, 968.279480))
    addspawner(vector:new(-3385.344727, -24360.470703, 961.729797))
    addspawner(vector:new(-3062.447510, -24584.501953, 967.189636))
    addspawner(vector:new(-6149.228516, -26984.175781, 896.125000))
    addspawner(vector:new(-6512.345703, -26833.785156, 897.720459))
    addspawner(vector:new(-7359.155762, -26703.933594, 896.125000))
    addspawner(vector:new(-7344.679688, -26248.623047, 896.125000))
    addspawner(vector:new(-7851.328125, -26657.830078, 897.438293))
    addspawner(vector:new(-8396.559570, -26642.613281, 896.125000))
    addspawner(vector:new(-9130.098633, -26436.830078, 910.134460))
    addspawner(vector:new(-9371.647461, -27003.015625, 896.625000))
    addspawner(vector:new(-9006.476562, -27196.257812, 899.966553))
    addspawner(vector:new(-5036.784180, -27733.611328, 896.125000))
    addspawner(vector:new(-5067.337891, -27550.847656, 896.125000))
    addspawner(vector:new(-4948.454102, -27317.238281, 896.125000))
    addspawner(vector:new(-4900.755371, -27547.052734, 896.125000))
    
    createammocache(vector:new(-5068.610840, -26547.687500, 1033.015503), 1500)

    inithangardoors()
    initbreachabledoor()
    initcollisions()

    level.spawner = game:getent("hill_attack_spawner", "targetname")
    
    player:setorigin(vector:new(-4867.337891, -24972.884766, 1007.124939))
    player:setplayerangles(vector:new(0.000000, -176.960098, 0.000000))
    
    game:oninterval(function()
        player:allowprone(true)
        player:allowcrouch(true)
        player:allowstand(true)
    end, 0)
end

return map