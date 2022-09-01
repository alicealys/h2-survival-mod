local types = {
    helinodes = 1,
    armories = 2,

}

local initcallbacks = {
    [types.helinodes] = inithelinoder
}

function initbuilder()
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
        local trace = game:bullettrace(player:geteye(), lookat, true, player)

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
            local origin = string.format("%f %f %f", nodes[i].origin.x, nodes[i].origin.y, nodes[i].origin.z)
            io.writefile("nodes.txt", origin, true)
        end
    end)
end
