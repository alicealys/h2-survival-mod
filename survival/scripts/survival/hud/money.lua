player.money = player.money or 500
player.totalscore = player.totalscore or 0

local x = -85
local y = 395
local fontscale = 1.4
local color = vector:new(0.8, 1, 0.8)
local glowalpha = 0.1

local icon = game:newclienthudelem(player)
icon.x = x
icon.y = y
icon.color = color
icon.glowalpha = glowalpha
icon.glowcolor = vector:new(0, 1, 0)
icon.hidewheninmenu = true
icon.hidewhendead = true
icon.font = "objective"
icon.fontscale = fontscale
icon.label = "&$"

local hudmoney = game:newclienthudelem(player)
hudmoney.x = x + 10
hudmoney.y = y
hudmoney.color = color
hudmoney.font = "objective"
hudmoney.glowalpha = glowalpha
hudmoney.glowcolor = vector:new(0, 1, 0)
hudmoney.hidewheninmenu = true
hudmoney.hidewhendead = true
hudmoney.fontscale = fontscale
hudmoney:setvalue(player.money)

local hudmoneyfx = game:newclienthudelem(player)
hudmoneyfx.x = x + 10
hudmoneyfx.y = y
hudmoneyfx.color = color
hudmoneyfx.font = "objective"
hudmoneyfx.glowalpha = glowalpha
hudmoneyfx.glowcolor = vector:new(0, 1, 0)
hudmoneyfx.hidewheninmenu = true
hudmoneyfx.hidewhendead = true
hudmoneyfx.fontscale = fontscale
hudmoneyfx.alpha = 0
hudmoneyfx:setvalue(player.money)

local previous = player.money

player.moneymultiplier = 1

local listeners = {}

table.insert(listeners, game:oninterval(function()
    game:sharedset("player_money", player.money .. "")

    hudmoney:setvalue(player.money)
    hudmoneyfx:setvalue(player.money)

    if (player.money > previous) then
        player.totalscore = player.totalscore + player.money - previous
    end
    
    if (previous ~= player.money) then
        hudmoney.alpha = 0
        hudmoneyfx.alpha = 1
        hudmoneyfx:setpulsefx(40, 1100, 0)

        local digits = #(player.money .. "")

        local movex = math.random(30, 70)
        local movey = math.random(20, 70) * (math.random(0, 1) == 1 and 1 or -1)

        local value = player.money - previous
        local glowcolor = value > 0 and vector:new(0, 1, 0) or vector:new(1, 0, 0)
        local color = value > 0 and vector:new(0.8, 1, 0.8) or vector:new(1, 0.8, 0.8)

        local difflabel = game:newclienthudelem(player)
        difflabel.x = x + 10 + (digits * 10)
        difflabel.y = y
        difflabel.color = color
        difflabel.font = "objective"
        difflabel.glowalpha = glowalpha
        difflabel.glowcolor = glowcolor
        difflabel.hidewheninmenu = true
        difflabel.hidewhendead = true
        difflabel.fontscale = fontscale
        difflabel:settext(value > 0 and "+ " or "- ")
        difflabel:moveovertime(1)
        difflabel:fadeovertime(1)
        difflabel.alpha = 0
        difflabel.x = x + 10 + movex
        difflabel.y = y + movey

        local diff = game:newclienthudelem(player)
        diff.x = x + 20 + (digits * 10)
        diff.y = y
        diff.color = color
        diff.font = "objective"
        diff.glowalpha = glowalpha
        diff.glowcolor = glowcolor
        diff.hidewheninmenu = true
        diff.hidewhendead = true
        diff.fontscale = fontscale
        diff:setvalue(math.abs(value))
        diff:moveovertime(1)
        diff:fadeovertime(1)
        diff.alpha = 0
        diff.x = x + 20 + movex
        diff.y = y + movey

        game:ontimeout(function()
            diff:destroy()
            difflabel:destroy()

            if (game:isdefined(hudmoney)) then
                hudmoney.alpha = 1
                hudmoneyfx.alpha = 0
            end
        end, 1000)
    end

    previous = player.money
end, 0))