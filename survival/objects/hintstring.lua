require("utils/table")

local hintstrings = {}
local current = nil
local hudelems = {}
hudelems.text = game:newhudelem()
hudelems.text.alignx = "center"
hudelems.text.horzalign = "center"
hudelems.text.y = 300
hudelems.text.font = "objective"
hudelems.text.fontscale = 1

hudelems.subtext = game:newhudelem()
hudelems.subtext.alignx = "center"
hudelems.subtext.horzalign = "center"
hudelems.subtext.y = 315
hudelems.subtext.color = vector:new(0.7, 0.7, 0.7)
hudelems.subtext.font = "objective"
hudelems.subtext.fontscale = 1

hudelems.icon = game:newhudelem()
hudelems.icon.alignx = "center"
hudelems.icon.horzalign = "center"
hudelems.icon.y = 320

player:notifyonplayercommand("+activate", "+activate")
player:onnotify("+activate", function()
    if (current ~= nil) then
        current.entity:notify("trigger", player)
    end
end)

game:oninterval(function()
    local _end = player:getplayerangles():toforward() * 10000000
    local start = player:geteye()
    local trace = game:bullettrace(start, _end, false, player)
    local position = trace.position

    local filtered = table.filter(hintstrings, function(hintstring)
        return hintstring.enabled and game:distance2d(hintstring.entity.origin, player.origin) <= hintstring.radius 
            and (hintstring.lookatradius == nil or game:distance(hintstring.entity.origin, position) <= hintstring.lookatradius)
    end)
    
    if (#filtered == 0) then
        current = nil

        if (hudelems.visible) then
            hudelems.text:fadeovertime(0.1)
            hudelems.icon:fadeovertime(0.1)
            hudelems.subtext:fadeovertime(0.1)
            hudelems.text.alpha = 0
            hudelems.icon.alpha = 0
            hudelems.subtext.alpha = 0
            hudelems.subtext.alpha = 0
            hudelems.visible = false
        end

        return
    end

    table.sort(filtered, function(a, b)
        return game:distance(a.entity.origin, position) < game:distance(b.entity.origin, position)
    end)

    current = filtered[1]

    if (hudelems.visible == false) then
        hudelems.text:fadeovertime(0.1)
        hudelems.icon:fadeovertime(0.1)
        hudelems.subtext:fadeovertime(0.1)
    end

    if (type(filtered[1].icon) == "string") then
        hudelems.icon.y = 315
        hudelems.icon.alpha = 1
        hudelems.icon:setshader(filtered[1].icon, filtered[1].iconwidth or 50, filtered[1].iconheight or 50)
    else
        hudelems.icon.alpha = 0
    end

    if (type(filtered[1].subtext) == "string") then
        hudelems.icon.y = 320
        hudelems.subtext.alpha = 1
        hudelems.subtext:settext(filtered[1].subtext)
    else
        hudelems.subtext.alpha = 0
    end

    hudelems.text:settext(filtered[1].text)
    hudelems.text.alpha = 1

    hudelems.visible = true
end, 0)

function createhintstring(hintstring)
    hintstring.enabled = true
    table.insert(hintstrings, hintstring)
    return hintstring
end