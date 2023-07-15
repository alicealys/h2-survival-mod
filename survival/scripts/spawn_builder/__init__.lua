do
    return
end

game:setdvar("survival_start_wave", 0)

local leadermodel = "body_shadow_co_assault"
local followermodel = "body_us_army_assault_a"

game:precachemodel(leadermodel)
game:precachemodel(followermodel)

debug:reset()

local spawns = {}

local addfollower = function(spawn, origin, angles)
    origin = game:getgroundposition(origin)
    local follower = game:spawn("script_model", origin)
    follower:setmodel(followermodel)
    table.insert(spawn.followers, {
        origin = origin,
        angles = angles,
        line = debug:addline(origin, spawn.leader.origin, vector:new(1, 1, 0)),
        model = follower
    })
end

local startspawn = function(origin, angles)
    local leader = game:spawn("script_model", origin)
    leader:setmodel(leadermodel)

    local spawn = {leader = {
        origin = origin,
        angles = angles,
        model = leader,
    }, followers = {}}
    
    return spawn
end

local popfollower = function(spawn)
    if (#spawn.followers == 0) then
        return
    end

    local follower = spawn.followers[#spawn.followers]
    table.remove(spawn.followers, #spawn.followers)
    follower.model:delete()
    debug:removeline(follower.line)
end

local deletespawn = function(spawn)
    while (#spawn.followers > 0) do
        popfollower(spawn)
    end

    local leader = spawn.leader
    leader.model:delete()
end
local currentspawn = nil

local savespawns = function()
    if (currentspawn ~= nil) then
        table.insert(spawns, currentspawn)
    end

    currentspawn = nil

    local buffer = ""
    local line = function(key, value)
        if (value == nil) then
            buffer = buffer .. key .. "\n"
        else
            buffer = buffer .. string.format("\"%s\" \"%s\"", key, value) .. "\n"
        end
    end

    for i = 1, #spawns do
        local targetname = string.format("spawn_auto_%i", i)

        line("{")
        line("classname", "script_struct")
        line("script_noteworthy", "leader")
        line("target", targetname)
        line("origin", string.format("%f %f %f", spawns[i].leader.origin.x, spawns[i].leader.origin.y, spawns[i].leader.origin.z))
        line("angles", string.format("0 %f 0", spawns[i].leader.angles.y))
        line("radius", "24")
        line("}")

        for o = 1, #spawns[i].followers do
            local origin = spawns[i].followers[o].origin
            local angles = spawns[i].followers[o].angles
            line("{")
            line("classname", "script_struct")
            line("script_noteworthy", "follower")
            line("targetname", targetname)
            line("origin", string.format("%f %f %f", origin.x, origin.y, origin.z))
            line("angles", string.format("0 %f 0", angles.y))
            line("radius", "24")
            line("}")
        end
    end

    local time = os.time()
    io.writefile(string.format("h2-mod/so-spawns/%s-spawns.mapents", tostring(time)), buffer, false)
end

player:notifyonplayercommand("new_spawn", "+activate")
player:notifyonplayercommand("add_follower", "+frag")
player:notifyonplayercommand("delete_follower", "+melee_zoom")
player:notifyonplayercommand("delete_spawn", "+reload")
player:notifyonplayercommand("save", "skip")

local text = function(text, y)
    local hudelem = game:newhudelem()
    hudelem.x = 100
    hudelem.y = y
    hudelem.font = "objective"
    hudelem.fontscale = 1
    hudelem:settext(text)
end

text("new_spawn ^3[{+activate}]", 100)
--text("add_follower ^3[{+frag}]", 120)
--text("delete_follower^3 [{+melee_zoom}]", 140)
text("delete_spawn^3 [{+reload}]", 120)
text("save^3 [{skip}]", 140)

player:onnotify("new_spawn", function()
    if (currentspawn ~= nil) then
        table.insert(spawns, currentspawn)
        currentspawn = nil
    end

    currentspawn = startspawn(player.origin, player.angles)

    local angles = player.angles
    addfollower(currentspawn, player.origin + (angles:toforward()) * 32, player.angles)
    addfollower(currentspawn, player.origin + ((angles + vector:new(0, 45, 0)):toforward()) * 32 * math.sqrt(2), player.angles)
    addfollower(currentspawn, player.origin + ((angles + vector:new(0, -45, 0)):toforward()) * 32 * math.sqrt(2), player.angles)
end)

--player:onnotify("add_follower", function()
--    if (currentspawn == nil) then
--        return
--    end
--
--    addfollower(currentspawn, player.origin)
--end)
--
--player:onnotify("delete_follower", function()
--    if (currentspawn == nil) then
--        return
--    end
--
--    popfollower(currentspawn)
--end)

player:onnotify("delete_spawn", function()
    if (currentspawn == nil) then
        return
    end

    deletespawn(currentspawn)
    currentspawn = nil
    if (#spawns) then
        currentspawn = spawns[#spawns]
        table.remove(spawns, #spawns)
    end
end)

player:onnotify("save", function()
    savespawns()
end)
