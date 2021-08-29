require("utils/table")

local hudutils = require("utils/hud")
local map = require("maps/" .. game:getdvar("mapname"))

game:precacheshader("h2_hud_ssdd_stats_blur")

local hud = {}
hud.wave = game:newhudelem()
hud.wave.x = -85
hud.wave.y = 95
hud.wave.glowalpha = 0.1
hud.wave.hidewheninmenu = true
hud.wave.hidewhendead = true
hud.wave.glowcolor = vector:new(0, 1, 0)
hud.wave.color = vector:new(0.8, 1, 0.8)
hud.wave.font = "objective"
hud.wave.fontscale = 1.1

hud.enemies = game:newhudelem()
hud.enemies.x = -85
hud.enemies.y = 110
hud.enemies.glowalpha = 0.1
hud.enemies.hidewheninmenu = true
hud.enemies.hidewhendead = true
hud.enemies.glowcolor = vector:new(0, 1, 0)
hud.enemies.color = vector:new(0.8, 1, 0.8)
hud.enemies.font = "objective"
hud.enemies.fontscale = 1.1

hud.readyup = game:newhudelem()
hud.readyup.x = 400
hud.readyup.y = 180
hud.readyup.alpha = 0
hud.readyup.font = "objective"
hud.readyup.fontscale = 1
hud.readyup:settext("Double click ^3[{+activate}]^7 to ready up")

local baseenemycount = 24
local maxenemycount = 50

function getenemyhealth(round)
    return math.ceil(150 * (1.1 ^ (round - 1)))
end

function getenemycount(round)
    if (round >= 1 and round <= 4) then
        return math.ceil(baseenemycount * 0.2 * round)
    elseif (round >= 5 and round <= 9) then
        return baseenemycount
    elseif (round >= 10) then
        return math.ceil(baseenemycount * (round * 0.15))
    end
end

function getenemyweapon(round)
    if (round <= 3) then
        return map.shotguns[math.random(#map.shotguns)]
    elseif (round > 3 and round < 8) then
        return map.smgs[math.random(#map.smgs)]
    else
        return map.rifles[math.random(#map.rifles)]
    end
end

function entity:giveactorweapon(weapon)
    local previousmodel = game:getweaponmodel(self.weapon)
    local newmodel = game:getweaponmodel(weapon)

    self.weapon = weapon

    self:detach(previousmodel, "tag_weapon_right")
    self:attach(newmodel, "tag_weapon_right")
end

function getclosestspawners()
    local spawners = table.filter(map.spawners, function(spawner)
        local passed = game:sighttracepassed(player:geteye(), spawner.origin + vector:new(0, 0, 30))
        return passed == 0
    end)

    table.sort(spawners, function(a, b)
        return game:distance(a.origin, player.origin) < game:distance(b.origin, player.origin)
    end)

    local result = {}
    for i = 1, math.min(#spawners, 5) do
        table.insert(result, spawners[i])
    end

    return result
end

function centertext(text)
    local hudelem = game:newhudelem()
    hudelem.horzalign = "center"
    hudelem.alignx = "center"
    hudelem.y = 50
    hudelem.font = "bigfixed"
    hudelem.fontscale = 1.2
    hudelem.glowalpha = 0.3
    hudelem.glowcolor = vector:new(0, 0, 1)
    hudelem:settext(text)
    hudelem:setpulsefx(40, 4000, 600)

    game:ontimeout(function()
        hudelem:destroy()
    end, 5000)
end

local round = 0
function startround()
    round = round + 1

    hud.enemies.label = "&Enemies remaining: "
    hud.wave.label = "&Wave "
    hud.wave:setvalue(round)

    game:setdiscordstate("Playing Survival on Wave " .. round)

    local max = getenemycount(round)
    local health = getenemyhealth(round)

    local currentenemys = 0
    local spawnedenemys = 0
    local killedenemys = 0
    
    local function spawnenemy()
        local spawners = getclosestspawners()
        local spawner = spawners[math.random(#spawners)]
        
        local enemyweapon = getenemyweapon(round)
        local enemy = spawner:spawn()
        enemy.health = health
        enemy.maxhealth = health
        enemy.accuracy = 1.2 ^ round
        enemy.combatmode = "combat"
        enemy.dropweapon = false
        enemy:setgoalentity(player)

        local previousweapon = enemy.weapon
        
        game:ontimeout(function()
            enemy:giveactorweapon(enemyweapon)
        end, 0)

        currentenemys = currentenemys + 1
        spawnedenemys = spawnedenemys + 1

        local droplistener = enemy:onnotify("weapon_dropped", function(weapon)
            if (weapon.model ~= game:getweaponmodel(enemyweapon)) then
                weapon:delete()
            end
        end)

        enemy:onnotifyonce("death", function()
            pcall(function()
                enemy:dropweapon(enemyweapon, "right")
            end)

            game:ontimeout(function()
                droplistener:clear()
            end, 10000)

            enemy:detach(game:getweaponmodel(enemyweapon), "tag_weapon_right")

            killedenemys = killedenemys + 1
            currentenemys = currentenemys - 1

            if (killedenemys >= max) then
                centertext("Wave " .. round .. " Cleared!")
                player:playlocalsound("h1_arcademode_ending_mission_pts")
            end
        end)
    end

    local hudinterval = nil
    hudinterval = game:oninterval(function()
        hud.enemies:setvalue(max - killedenemys)
    end, 0)

    local interval = nil
    interval = game:oninterval(function()
        if (killedenemys >= max) then
            interval:clear()
            hudinterval:clear()

            startrounddelay(30)
            return
        end

        if (currentenemys >= maxenemycount or spawnedenemys >= max) then
            return
        end

        spawnenemy()
    end, 1000)
end

function startrounddelay(delay)
    local timer = game:newhudelem()
    timer.horzalign = "center"
    timer.alignx = "center"
    timer.y = 227
    timer.font = "objective"
    timer.fontscale = 2

    local keylistener = nil
    keylistener = player:onnotify("activate", function()
        local listener = nil

        listener = player:onnotify("activate", function()
            listener:clear()
            keylistener:clear()

            if (delay <= 5) then
                return
            end

            hud.readyup:fadeovertime(0.5)
            hud.readyup.alpha = 0

            delay = 5

            hud.wave:setvalue(delay)
            timer:setvalue(delay)
        end)

        game:ontimeout(function()
            listener:clear()
        end, 500)
    end)

    hud.wave.label = "&Next wave in: "
    hud.enemies.label = "&Enemies remaining: "
    hud.enemies:setvalue(0)
    hud.wave:setvalue(delay)

    local callback = function()
        keylistener:clear()

        hud.wave.label = "&Wave "
        hud.wave:setvalue(round + 1)

        centertext("Enemies Inbound!") 
        player:playlocalsound("arcademode_kill_streak_lost")
        timer:destroy()

        game:ontimeout(function()
            startround()
        end, 1000)
    end

    if (delay == 0 or delay == nil) then
        hud.wave.label = "&Wave "
        callback()
        return
    end

    hud.readyup:fadeovertime(0.5)
    hud.readyup.alpha = 1

    local interval = nil
    interval = game:oninterval(function()
        delay = delay - 1
        hud.wave:setvalue(delay)

        if (delay <= 5) then
            hud.readyup:fadeovertime(0.5)
            hud.readyup.alpha = 0

            keylistener:clear()
            player:playlocalsound("ui_mouse_click")
            timer:setvalue(delay)
        end

        if (delay <= 0) then
            interval:clear()
            callback()
        end
    end, 1000)
end

player:notifyonplayercommand("activate", "+activate")
player.money = 500

player:onnotify("killed_enemy", function()
    player.money = player.money + 100
end)

player:onnotify("damaged_enemy", function()
    player.money = player.money + 10
end)

player:onnotify("death", function()
    game:ontimeout(function()
        game:executecommand("fast_restart") 
    end, 5000)
end)

game:oninterval(function()
    local weaponslist = player:getweaponslistprimaries()
    local current = player:getcurrentweapon()
    local found = table.find(weaponslist, current)

    if (found ~= nil) then
        player.lastusedprimary = found
    end
end, 0)

game:ontimeout(function()
    game:setdiscordstate("Playing Survival on Wave 1")

    local black = game:newhudelem()
    black.sort = 1
    black.x = -200
    black.y = 0
    black.alpha = 1
    black:setshader("white", 1000, 1000)
    black.color = vector:new(0, 0, 0)
    
    local interval = game:oninterval(function()
        player:freezecontrols(true)
    end, 0)
    
    player:takeweapon(player:getweaponslistprimaries()[2])
    game:ontimeout(function()
        interval:clear()
    
        player:freezecontrols(false)
        player:switchtoweapon("beretta")

        level:notify("start")
        level.started = true
    
        black:fadeovertime(1)
        black.alpha = 0
    
        game:ontimeout(function()
            black:destroy()
        end, 1000)
    
        game:ontimeout(function()
            require("hud/money")
            require("hud/xp")
            require("hud/kills")
            startrounddelay(0)
        end, 2000)
    end, 10000)
end, 0)
