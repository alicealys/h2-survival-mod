local types = {
    helinodes = 1,
    armories = 2,
}

game:ontimeout(function()
    local spawners = game:getentarray("info_enemy_spawnpoint", "classname")
    for i = 1, #spawners do
        local nodes = game:getnodesinradius(spawners[i].origin, 128)
        if (#nodes < 1) then
            print("delete", spawners[i].origin)
            spawners[i]:delete()
        end
    end
end, 0)

function f()
    game:ontimeout(function()
        local spawners = game:getentarray("info_enemy_spawnpoint", "classname")
        player:notifyonplayercommand("next_add", "+actionslot 1")
        player:notifyonplayercommand("next", "+actionslot 2")
        player:notifyonplayercommand("dump", "+actionslot 3")
        local validspawners = {}
        local index = 1
    
        player:setorigin(spawners[index].origin)
        player:onnotify("next_add", function()
            if (index > #spawners) then
                game:iprintlnbold("FINISHED")
                return
            end
    
            table.insert(validspawners, spawners[index])
            index = index + 1
            if (index > #spawners) then
                game:iprintlnbold("FINISHED")
                return
            end
    
            player:setorigin(spawners[index].origin)
        end)
    
        player:onnotify("next", function()
            if (index > #spawners) then
                game:iprintlnbold("FINISHED")
                return
            end
    
            index = index + 1
            if (index > #spawners) then
                game:iprintlnbold("FINISHED")
                return
            end
    
            player:setorigin(spawners[index].origin)
        end)
    
        player:onnotify("dump", function()
            io.writefile("vspawners.txt", "", false)
    
            local line = function(text)
                io.writefile("vspawners.txt", text .. "\n", true)
            end
        
            print(#validspawners)
            for i = 1, #validspawners do
                line("{")
                line(string.format("\"origin\" \"%f %f %f\"", validspawners[i].origin.x, validspawners[i].origin.y, validspawners[i].origin.z))
                line("\"classname\" \"info_enemy_spawnpoint\"")
                line("\"script_specialops\" \"1\"")
                line("}")
            end
        end)
    
        local hud = game:newhudelem()
        hud:settext("[{+actionslot 1}] next_add, [{+actionslot 2}] next, [{+actionslot 3}] dump, ")
        hud.x = 100
        hud.y = 100
    end, 500)
end

function s()
    io.writefile("bspawners.txt", "", false)
    
    player:notifyonplayercommand("create_spawner", "+actionslot 1")
    player:onnotify("create_spawner", function()
        local line = function(text)
            io.writefile("bspawners.txt", text .. "\n", true)
        end
    
        game:iprintlnbold("added spawner")
    
        line("{")
        line(string.format("\"origin\" \"%f %f %f\"", player.origin.x, player.origin.y, player.origin.z))
        line("\"classname\" \"info_enemy_spawnpoint\"")
        line("\"script_specialops\" \"1\"")
        line("}")
    end)
end

local initcallbacks = {
    [types.helinodes] = inithelinoder
}

function inithelinoder()
    local nodes = {}
    player:notifyonplayercommand("spawn_node", "+activate")
    player:notifyonplayercommand("remove_node", "+actionslot 4")
    player:notifyonplayercommand("dump_nodes", "+actionslot 3")

    local controls = game:newhudelem()
    controls.x = 100
    controls.y = 100
    controls.font = "bank"
    controls:settext("^1Spawn node: [{+activate}]\nRemove node (look at) [{+actionslot 4}], Dump nodes [{+actionslot 3}]")

    local preview = game:spawn("script_model", player.origin)
    preview:setmodel("vehicle_little_bird_armed")

    game:oninterval(function()
        local lookat = player:getplayerangles():toforward() * 10000000000
        local trace = game:bullettrace(player:geteye(), lookat, false, player)
        local origin = trace.position + vector:new(0, 0, 1000)
        preview.origin = origin
    end, 0)

    local nodeid = 0
    player:onnotify("spawn_node", function()
        --local origin = player.origin
        local lookat = player:getplayerangles():toforward() * 10000000000
        local trace = game:bullettrace(player:geteye(), lookat, false, player)
        local origin = trace.position + vector:new(0, 0, 1000)

        local model = game:spawn("script_model", origin)
        model:setmodel("vehicle_little_bird_armed")
        nodeid = nodeid + 1
        local id = nodeid
        game:iprintln("added node " .. tostring(id) .. " " .. tostring(origin))
        model.ishelinode = true
        model.nodeid = nodeid
        table.insert(nodes, {
            nodeid = nodeid,
            model = model,
            origin = origin
        })
    end)

    player:onnotify("remove_node", function()
        local lookat = player:getplayerangles():toforward() * 10000000000
        local trace = game:bullettrace(player:geteye(), lookat, true, preview)

        if (trace.entity and trace.entity.ishelinode) then
            for i = 1, #nodes do
                if (nodes[i].nodeid == trace.entity.nodeid) then
                    game:iprintln("removed node " .. tostring(trace.entity.nodeid))
                    trace.entity:delete()
                    table.remove(nodes, i)
                    break
                end
            end
        end
    end)

    player:onnotify("dump_nodes", function()
        io.writefile("nodes.txt", "", false)
        for i = 1, #nodes do
            local origin = string.format("%f %f %f\n", nodes[i].origin.x, nodes[i].origin.y, nodes[i].origin.z)
            io.writefile("nodes.txt", origin, true)
        end
    end)
end

function initbuilder()

end
