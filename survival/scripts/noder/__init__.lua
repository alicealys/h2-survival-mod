debug:reset()

function drawlinks(node)
    if (type(node.script_linkto) ~= "string") then
        return
    end

    local links = game:strtok(node.script_linkto, " ")
    for i = 1, #links do
        local other = game:scriptcall("common_scripts/utility", "getstruct", links[i], "script_linkname")
        if (other) then
            debug:addline(node.origin, other.origin, vector:new(1, 1, 0))
        end
    end
end

function draworiginalnodes()
    local nodes = game:scriptcall("common_scripts/utility", "getstructarray", "so_chopper_boss_path_struct", "script_noteworthy")
    print("NODES = ", #nodes)
    for i = 1, #nodes do
        drawlinks(nodes[i])
        debug:addsquare(nodes[i].origin, vector:new(1, 0, 0))
    end
end

-- distance from each node
local step = 800

-- radius from map center nodes have to be in
local radius = 6000

-- offset map corners
local minsyoffset = 8000
local minsxoffset = 7000
local maxsyoffset = -7000
local maxsxoffset = -2000

local nodeshift = vector:new(0, 0, 0)

local badzones = {
    {
        origin = vector:new(5550, 424, 0),
        radius = 600
    }
}

-- start distance
local startdist = 3000

local height = 1000

local traceoffset = 5000

function isclosetobadzone(origin)
    for i = 1, #badzones do
        if (game:distance2d(origin, badzones[i].origin) < badzones[i].radius) then
            return true
        end
    end

    return false
end

function heliheight(x, y)
    local origin = vector:new(x, y, traceoffset)
    local maxheight = 2000
    local pos = game:physicstrace(origin, origin + vector:new(0, 0, -10000)) + vector:new(0, 0, height)
    if (pos.z > maxheight) then

    end
    pos.z = maxheight
    return pos
end

function getbounds()
    local bounds = game:getentarray("minimap_corner", "targetname")
    local mins = vector:new(0, 0, 0)
    local maxs = vector:new(0, 0, 0)

    for i = 1, #bounds do
        if (mins.x > bounds[i].origin.x) then
            mins.x = bounds[i].origin.x
        end

        if (maxs.x < bounds[i].origin.x) then
            maxs.x = bounds[i].origin.x
        end

        if (mins.y > bounds[i].origin.y) then
            mins.y = bounds[i].origin.y
        end

        if (maxs.y < bounds[i].origin.y) then
            maxs.y = bounds[i].origin.y
        end
    end

    mins.x = mins.x + minsxoffset
    mins.y = mins.y + minsyoffset
    maxs.x = maxs.x + maxsxoffset
    maxs.y = maxs.y + maxsyoffset

    return mins, maxs
end

function generatenodes()
    local mins, maxs = getbounds()

    print("mins", mins.x, mins.y)
    print("maxs", maxs.x, maxs.y)

    local center = vector:new(
        (mins.x + maxs.x) / 2,
        (mins.y + maxs.y) / 2,
        0
    )

    print("center", center.x, center.y)

    local x = mins.x

    local nodes = {}

    while (x < maxs.x) do
        local y = mins.y
        while (y < maxs.y) do
            local trace = heliheight(x, y)
            trace = trace + nodeshift
            if (not isclosetobadzone(trace) and trace.x < maxs.x and trace.x > mins.x and trace.y < maxs.y and trace.y > mins.y) then
                debug:addsquare(trace, vector:new(0, 1, 1))
                table.insert(nodes, {
                    origin = trace,
                    links = {}
                })
            end

            y = y + step
        end

        x = x + step
    end

    for a = 0, 3 do
        local angle = a * (360 / 4) + 30
        local x = (radius + startdist) * game:cos(angle) + center.x
        local y = (radius + startdist) * game:sin(angle) + center.y
        local pos = heliheight(x, y)

        local distance = nil
        local closest = nil
        for i = 1, #nodes do
            if (not nodes[i].start_path) then
                local dist = game:distance2d(nodes[i].origin, pos)
                if (distance == nil or dist < distance) then
                    distance = dist
                    closest = i
                end
            end
        end

        debug:addsquare(pos, vector:new(1, 0, 0))
        debug:addline(pos, nodes[closest].origin, vector:new(0, 1, 0))

        table.insert(nodes, {
            start_path = true,
            origin = pos,
            links = {closest}
        })
    end

    return nodes
end

local linkcount = 0

function linknodes(nodes)
    for i = 1, #nodes do
        if (not nodes[i].start_path) then
            for o = 1, #nodes do
                if (#nodes[o].links <= 1 and not nodes[o].start_path and o ~= i and game:distance2d(nodes[i].origin, nodes[o].origin) <= step) then
                    local trace = game:physicstrace(nodes[i].origin, nodes[o].origin)
                    --if (game:distance2d(trace, nodes[o].origin) < 32) then
                        table.insert(nodes[i].links, o)
                        linkcount = linkcount + 1
                        debug:addline(nodes[i].origin, nodes[o].origin, vector:new(0, 1, 0))
                    --end
                end
            end
        end
    end
end

function writenodes(nodes)
    local buffer = ""

    local line = function(text)
        buffer = buffer .. text
        buffer = buffer .. "\n"
    end

    local field = function(name, value)
        line(string.format("\"%s\" \"%s\"", name, value))
    end

    for i = 1, #nodes do
        line("{")
        field("script_specialops", "1")
        field("script_noteworthy", "so_chopper_boss_path_struct")
        field("classname", "script_struct_heli")
        field("radius", tostring(step))
        field("origin", string.format("%f %f %f", nodes[i].origin.x, nodes[i].origin.y, nodes[i].origin.z))

        local links = ""
        for o = 1, #nodes[i].links do
            links = links .. string.format("_hnode_%i", nodes[i].links[o])
            if (o < #nodes[i].links) then
                links = links .. " "
            end
        end

        if (nodes[i].start_path) then
            field("targetname", "chopper_boss_path_start")
        else
            field("script_linkname", string.format("_hnode_%i", i))
        end

        field("script_linkto", links)
        field("script_stopnode", "1")
        line("}")
    end

    io.writefile(string.format("h2-mod/chopper_path_%s.mapents", level.script), buffer, false)
end

function connectpaths()
    --
    local nodes = generatenodes()
    linknodes(nodes)
    writenodes(nodes)
    print(string.format(
        "====== Node linking complete, total nodes: %i, total links: %i ==============", #nodes, linkcount))
end

function drawspawns()
    local spawns = game:getentarray("leader", "script_noteworthy")
    for i = 1, #spawns do
        debug:addsquare(spawns[i].origin, vector:new(0, 1, 0))
    end

    local spawns = game:scriptcall("common_scripts/utility", "getstructarray", "follower", "script_noteworthy")
    print("spawns", #spawns)
    for i = 1, #spawns do
        debug:addsquare(spawns[i].origin, vector:new(0, 1, 1))
    end
end

function generateuavpath()
    local center = vector:new(1730, 316, 0)
    local uavheight = 6500
    local uavradius = 7000

    local count = 16
    local step = 360 / count

    local prevnode = nil
    local createnode = function(targetname, i, target)
        local angle = i * step
    
        local x = uavradius * math.cos(angle * math.pi / 180)
        local y = uavradius * math.sin(angle * math.pi / 180)
        local z = uavheight
    
        local nodeorigin = vector:new(
            x + center.x,
            y + center.y,
            z + center.z
        )
        
        debug:addsquare(nodeorigin, vector:new(1, 1, 0))
        if (prevnode) then
            debug:addline(prevnode, nodeorigin, vector:new(1, 0, 0))
        end

        prevnode = nodeorigin

        local node = ""
        local line = function(field, fmt, ...)
            if (fmt == nil) then
                node = node .. field .. "\n"
            else
                node = node .. string.format("\"%s\" \"%s\"", field, string.format(fmt, ...)) .. "\n"
            end
        end
    
        line("{")
        line("angles", "0 %f 0", (angle + 90) % 360)
        line("origin", "%f %f %f", nodeorigin.x, nodeorigin.y, nodeorigin.z)
        line("targetname", "%s", targetname and targetname or "path_auto_" .. tostring(i))
        line("target", "%s", target and target or "path_auto_" .. tostring(i + 1))
        
        if (i == 1) then
            line("speed", "40")
            line("lookahead", "3")
            line("spawnflags", "1")
        end
    
        line ("classname", "info_vehicle_node_rotate")
        line("}")

        return node
    end

    local buffer = ""
    local line = function(field, fmt, ...)
        if (fmt == nil) then
            buffer = buffer .. field .. "\n"
        else
            buffer = buffer .. string.format("\"%s\" \"%s\"", field, string.format(fmt, ...)) .. "\n"
        end
    end

    line("{")
    line("classname", "script_struct")
    line("targetname", "uav_focus_point")
    line("origin", "%f %f %f", center.x, center.y, center.z)
    line("angles", "0 0 0")
    line("}")

    for i = 1, count do
        local targetname = i == 1 and "vnode_remotemissile_uav_start" or nil
        local target = i == count and "vnode_remotemissile_uav_start" or nil
        
        buffer = buffer .. createnode(targetname, i, target)
    end

    print("write file", #buffer)
    io.writefile(string.format("h2-mod/uav_path_%s.mapents", level.script), buffer, false)
end

game:ontimeout(function()
    if (game:getdvar("debug_drawhelinodes") == "1") then
        draworiginalnodes()
    end

    if (game:getdvar("debug_drawspawns") == "1") then
        drawspawns()
    end

    if (game:getdvar("heli_connectpaths") == "1") then
        connectpaths()
    end

    if (game:getdvar("uav_generatepath") == "1") then
        generateuavpath()
    end
end, 100)

