local colors = {
    {color = vector:new(1, 1, 1), glowcolor = vector:new(0, 1, 0)},
    {color = vector:new(1, 1, 0), glowcolor = vector:new(1, 0, 0)},
    {color = vector:new(0, 0, 0), glowcolor = vector:new(1, 0, 0)},
    {color = vector:new(0, 0, 0), glowcolor = vector:new(0, 0, 1)},
}

function newhudelem(fields)
    local hudelem = game:newhudelem()

    for k, v in pairs(fields) do
        hudelem[k] = v
    end

    return hudelem
end

function getcolor(kills)
    if (kills > #colors) then
        kills = #colors
    end

    return colors[kills]
end

local multikills = 0
local timeout = 10

local previousmultikills = 0

local killpoints = game:newhudelem()
killpoints.alignx = "center"
killpoints.horzalign = "center"
killpoints.glowalpha = 0.3
killpoints.font = "objective"
killpoints.fontscale = 1.5
killpoints.alpha = 0
killpoints.glowcolor = vector:new(1, 1, 0)
killpoints.y = 180
killpoints.label = "&+"

game:oninterval(function()
    if (timeout > 0) then
        timeout = timeout - 1
    else
        multikills = 0
    end

    previousmultikills = multikills
end, 1000)

local showmultikill = function()
    killpoints.alpha = 1
    killpoints:setvalue(multikills * 100)
    killpoints:setpulsefx(40, 2000, 600)
end

player:onnotify("killed_enemy", function()
    timeout = 3
    multikills = multikills + 1
    showmultikill()
end)