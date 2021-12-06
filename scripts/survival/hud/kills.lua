function createprogressbar(x, y, width, height)
    local background = game:newhudelem()
    background.x = x
    background.y = y
    background.alpha = 0.5
    background.hidewhendead = true
    background.hidewheninmenu = true
    background.color = vector:new(1, 1, 1)
    background:setshader("h1_hud_tutorial_blur", width, height)

    local maxwidth = width
    local maxheight = height

    local minwidth = 10

    local topborder = game:newhudelem()
    topborder.x = x
    topborder.y = y - 1
    topborder.alpha = 0.3
    topborder.color = vector:new(0, 0, 0)
    topborder.hidewhendead = true
    topborder.hidewheninmenu = true
    topborder:setshader("h1_hud_tutorial_blur", width, 1)

    local bottomborder = game:newhudelem()
    bottomborder.x = x
    bottomborder.y = y + height
    bottomborder.alpha = 0.3
    bottomborder.color = vector:new(0, 0, 0)
    bottomborder.hidewhendead = true
    bottomborder.hidewheninmenu = true
    bottomborder:setshader("h1_hud_tutorial_blur", width, 1)

    local bar = game:newhudelem()
    bar.x = x
    bar.y = y
    bar.sort = 10
    bar.alpha = 0.8
    bar.color = vector:new(0, 0.8, 0)
    bar.hidewhendead = true
    bar.hidewheninmenu = true
    bar:setshader("h1_hud_tutorial_blur", minwidth, maxheight)

    local progressbar = {
        percentage = 0,
        bar = bar,
        background = background,
        onprogress = function() end
    }

    local interval = nil

    function progressbar.setpercentage(percentage, overtime)
        if (interval ~= nil) then
            interval:clear()
        end

        percentage = math.max(0, math.min(percentage, 100))
        progressbar.percentage = percentage

        local newwidth = math.max(minwidth, math.ceil((percentage / 100) * maxwidth))

        if (overtime ~= nil) then
            bar:scaleovertime(overtime, newwidth, maxheight)
        else
            bar:setshader("h1_hud_tutorial_blur", newwidth, maxheight)
        end

        progressbar.onprogress(progressbar.percentage)
    end

    function progressbar.resetovertime(delay)
        if (interval ~= nil) then
            interval:clear()
        end

        local time = delay * progressbar.percentage
        bar:scaleovertime(time, minwidth, maxheight)

        interval = game:oninterval(function()
            if (progressbar.percentage > 0) then
                progressbar.percentage = progressbar.percentage - 1
                progressbar.onprogress(progressbar.percentage)
            else
                interval:clear()
            end
        end, math.floor(delay * 1000))
    end

    progressbar.setpercentage(0)

    return progressbar
end

local headshots = createprogressbar(-85, 340, 100, 12)
headshots.level = 1
headshots.step = 25

headshots.title = game:newhudelem()
headshots.title.x = -85
headshots.title.y = 325
headshots.title.font = "objective"
headshots.title.fontscale = 1
headshots.title.hidewhendead = true
headshots.title.hidewheninmenu = true
headshots.title.glowcolor = vector:new(0, 1, 0)
headshots.title.color = vector:new(0.8, 1, 0.8)
headshots.title.glowalpha = 0.1
headshots.title.label = "&Headshots"

headshots.money = game:newhudelem()
headshots.money.x = 20
headshots.money.y = 340
headshots.money.font = "objective"
headshots.money.fontscale = 1
headshots.money.label = "&$"
headshots.money.hidewhendead = true
headshots.money.hidewheninmenu = true
headshots.money.glowcolor = vector:new(0, 1, 0)
headshots.money.color = vector:new(0.8, 1, 0.8)
headshots.money.glowalpha = 0.1
headshots.money:setvalue(500)

headshots.onprogress = function(percentage)
    if (percentage >= 100) then
        player.money = player.money + headshots.level * 500

        headshots.setpercentage(0)
        headshots.level = headshots.level + 1
        headshots.money:setvalue(headshots.level * 500)
    elseif (percentage > 0) then
        if (headshots.timeout ~= nil) then
            headshots.timeout:clear()
        end

        headshots.timeout = game:ontimeout(function()
            if (headshots.level > 1) then
                headshots.level = 1
                headshots.money:setvalue(headshots.level * 500)
            end

            headshots.setpercentage(0, 0.5)
        end, 15000)
    end
end

player:onnotify("headshot", function()
    local step = math.ceil(100 / (headshots.level + 3))
    headshots.setpercentage(headshots.percentage + headshots.step, 0.2)
end)

local killstreak = createprogressbar(-85, 375, 100, 12)
killstreak.level = 1

killstreak.title = game:newhudelem()
killstreak.title.x = -85
killstreak.title.y = 360
killstreak.title.font = "objective"
killstreak.title.fontscale = 1
killstreak.title.glowcolor = vector:new(0, 1, 0)
killstreak.title.color = vector:new(0.8, 1, 0.8)
killstreak.title.hidewhendead = true
killstreak.title.hidewheninmenu = true
killstreak.title.glowalpha = 0.1
killstreak.title.label = "&Rampage"

killstreak.money = game:newhudelem()
killstreak.money.x = 20
killstreak.money.y = 375
killstreak.money.font = "objective"
killstreak.money.fontscale = 1
killstreak.money.label = "&$"
killstreak.money.hidewhendead = true
killstreak.money.hidewheninmenu = true
killstreak.money.glowcolor = vector:new(0, 1, 0)
killstreak.money.color = vector:new(0.8, 1, 0.8)
killstreak.money.glowalpha = 0.1
killstreak.money:setvalue(500)

killstreak.onprogress = function(percentage)
    if (percentage >= 100) then
        player.money = player.money + killstreak.level * 500

        killstreak.setpercentage(0)
        killstreak.level = killstreak.level + 1
        killstreak.money:setvalue(killstreak.level * 500)
    elseif (percentage == 0) then
        killstreak.timeout = game:ontimeout(function()
            if (killstreak.level > 1) then
                killstreak.level = 1
                killstreak.money:setvalue(killstreak.level * 500)
                killstreak.onprogress(0)
            end
        end, 5000)
    elseif (percentage > 0) then
        if (killstreak.timeout ~= nil) then
            killstreak.timeout:clear()
        end
    end
end

player:onnotify("killed_enemy", function()
    local step = math.ceil(100 / (killstreak.level + 4))
    killstreak.setpercentage(killstreak.percentage + step)
    killstreak.resetovertime(0.2)
end)