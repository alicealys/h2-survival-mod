require("builder")
require("precache")
require("menus")
require("challenges")

game:detour("_ID42318", "main", function() end)
game:detour("_ID42476", "_ID27337", function()
    level:notify("kill_deaths_door_audio")
    game:scriptcall("_ID42465", "_ID23801", "deaths_door")
    game:scriptcall("_ID42494", "_ID34606", "bullet_large_fatal")
end)

game:setdvar("hud_showStance", 0)

deletenonspecialops({
    isspawner,
    isspawntrigger,
    istrigger,
    isflagtrigger,
    isweapon
})

settings = {
    wavedifficulty = {
        easy = 0,
        regular = 4,
        hardened = 10,
        veteran = 16
    }
}

local baseenemycount = 24
local maxenemycount = 32

local startwavedvar = game:getdvar("survival_wave_start")
currentwave = startwavedvar == "" and 0 or tonumber(startwavedvar)

game:setdvar("ai_count", maxenemycount)

armories = {}

function flyingintro()
    player:disableweapons()
    player:disableoffhandweapons()
    player:freezecontrols(true)

    local delay = 1.75
    local zoomheight = 3500
    local origin = player.origin
    player:playersetstreamorigin(origin)
    player.origin = origin + vector:new(0, 0, zoomheight)
    local ent = game:spawn("script_model", vector:new(69, 69, 69))
    ent:setmodel("tag_origin")
    ent.origin = player.origin
    ent.angles = player.angles
    player:playerlinkto(ent, nil, 1, 0, 0, 0, 0)
    ent.angles = vector:new(ent.angles.x + 89, ent.angles.y, 0)
    ent:moveto(origin + vector:new(0, 0, 0), delay, 0, delay)

    game:ontimeout(function()
        player:playsound("survival_slamzoom_out")
        game:ontimeout(function()
            game:visionsetnaked("end_game2", 0.25)
            ent:rotateto(vector:new(ent.angles.x - 89, ent.angles.y, 0), 0.5, 0.3, 0.2)
            game:ontimeout(function()
                game:visionsetnaked("estate", 1.0)
                game:ontimeout(function()
                    player:unlink()
                    player:enableweapons()
                    player:enableoffhandweapons()
                    player:freezecontrols(false)
                    player:playerclearstreamorigin()
                    player:notify("player_update_model")

                    game:ontimeout(function()
                        ent:delete()
                        flagset("slamzoom_finished")
                    end, 500)
                end, 500)
            end, 200)
        end, ms(delay - 0.55))
    end, 50)
end

function playerloadout()
    local weapons = {}

    player:takeallweapons()

    local function getitemindex(item, index)
        local indexvalue = index and "_" .. index or ""
        local value = game:tablelookup(survivalwavetable, 1, item .. indexvalue, 2)
        if (value == "" or value == nil) then
            return nil
        end

        local stock = tonumber(game:tablelookup(survivalwavetable, 1, item .. indexvalue, 3))
        return {item = value, stock = stock}
    end

    table.insert(weapons, getitemindex("weapon", 1))
    table.insert(weapons, getitemindex("weapon", 2))
    table.insert(weapons, getitemindex("weapon", 3))

    for i = 1, #weapons do
        if (weapons[i]) then
            player:giveweapon(weapons[i].item)
            player:switchtoweapon(weapons[i].item)
            if (weapons[i].stock == "max") then
                player:givemaxammo(weapons[i].item)
            else
                player:setweaponammostock(weapons[i].item, weapons[i].stock)
            end
        end
    end

    player:setoffhandprimaryclass("fraggrenade")
    player:setoffhandsecondaryclass("flash_grenade")

    local grenades = {}
    table.insert(grenades, getitemindex("grenade", 1))
    table.insert(grenades, getitemindex("grenade", 2))

    for i = 1, #grenades do
        if (grenades[i]) then
            player:setweaponammostock(grenades[i].item, grenades[i].stock)
        end
    end

    local equipment = getitemindex("equipment", 1)
    if (equipment) then
        player.hasselfrevive = 1
    end

    local armor = getitemindex("armor", 1)
    if (armor) then
        player.armorlevel = armor.stock
    end
end

function wavestartsplash()
    addsplash({
        text = "&SO_SURVIVAL_WAVE_TITLE",
        color = "blue",
        yoffset = -100,
        duration = 2000,
        sound = "survival_wave_start_splash"
    })
end

survivaltable = "sp/survival_waves.csv"
survivalwavetable = survivaltable
survivalarmorytable = "sp/survival_armories.csv"
if (game:tableexists("sp/custom_waves.csv") == 1) then
    survivalwavetable = "sp/custom_waves.csv"
end

function getwavedata()
    if (wavedata) then
        return wavedata
    end

    local wavenum = 1
    wavedata = {waves = {}}
    while (wavenum ~= nil) do
        wavenum = tonumber(game:tablelookup(survivalwavetable, 2, wavenum, 2))
        if (wavenum) then
            local isrepeating = game:tablelookup(survivalwavetable, 2, wavenum, 9) == "1"
            if (isrepeating and not wavedata.startrepeating) then
                wavedata.startrepeating = wavenum
                wavedata.repeatingwaves = 1
            elseif (isrepeating) then
                wavedata.repeatingwaves = wavedata.repeatingwaves + 1
            end

            table.insert(wavedata.waves, {
                num = wavenum,
                isrepeating = isrepeating
            })

            wavenum = wavenum + 1
        end
    end

    wavedata.endrepeating = wavedata.startrepeating + wavedata.repeatingwaves - 1
    return wavedata
end

getwavedata()

function getrelativewave()
    local wavedata = getwavedata()
    if (currentwave <= wavedata.endrepeating) then
        return currentwave
    end

    return (((currentwave - wavedata.endrepeating) -1 ) & (wavedata.repeatingwaves - 1)) + wavedata.startrepeating
end

function getwaveenemycount()
    return tonumber(game:tablelookup(survivalwavetable, 2, getrelativewave(), 4))
end

function getwavedifficulty()
    return game:tablelookup(survivalwavetable, 2,  getrelativewave(), 3)
end

function getwavespecialenemies()
    return game:strtok(game:tablelookup(survivalwavetable, 2,  getrelativewave(), 5), " ")
end

function getpointsforenemytype(enemytype)
    return tonumber(game:tablelookup(survivaltable, 1, enemytype, 9))
end

function getweaponclipcount(weapon)
    local res = game:tablelookup(survivalarmorytable, 1, weapon, 9)
    if (res == "") then
        return 0
    end

    return tonumber(game:strtok(res, " ")[2])
end

function getenemyaccuracy(enemytype)
    local multiplier = 1.0 + currentwave * 0.2
    local baseaccuracy = game:tablelookup(survivaltable, 1, enemytype, 11)
    if (not baseaccuracy or tonumber(baseaccuracy) == nil) then
        return nil
    end

    return tonumber(baseaccuracy) * multiplier
end

function getenemyhealth(enemytype)
    local multiplier = 1.0 + currentwave * 0.1
    local basehealth = game:tablelookup(survivaltable, 1, enemytype, 7)
    if (not basehealth or tonumber(basehealth) == nil) then
        return nil
    end

    return game:int(game:int(basehealth) * multiplier)
end

function getenemyspeed(enemytype)
    local multiplier = 1.0 + currentwave * 0.05
    local basespeed = game:tablelookup(survivaltable, 1, enemytype, 8)
    if (not basespeed or tonumber(basespeed) == nil) then
        return nil
    end

    return math.min(tonumber(basespeed) * multiplier, 1.5)
end

function getwavespecialenemycount(enemytype)
    local specialenemies = getwavespecialenemies()
    local index = nil
    for i = 1, #specialenemies do
        if (specialenemies[i] == enemytype) then
            index = 1
            break
        end
    end

    if (index == nil) then
        return 0
    end

    local count = game:strtok(game:tablelookup(survivalwavetable, 2,  getrelativewave(), 6), " ")
    return tonumber(count[index])
end

function getwavebosses()
    local jug = game:tablelookup(survivalwavetable, 2,  getrelativewave(), 7)
    if (jug == "") then
        local chopper = game:tablelookup(survivalwavetable, 2,  getrelativewave(), 8)
        if (chopper == "") then
            return array:new()
        end

        return game:strtok(chopper, " ")
    end

    return game:strtok(jug, " ")
end

function getclosestspawners()
    local difficulty = getwavedifficulty()
    local targetname = difficulty .. "_guys"
    local spawners = game:getentarray(targetname, "targetname")
    local closest = game:scriptcall("common_scripts/utility", "_ID15566", player.origin, spawners, nil, nil, nil, 1000)

    local result = {}
    for i = 1, math.min(#closest, 10) do
        table.insert(result, closest[i])
    end

    return result
end

function getwavearmoryunlock()
    return game:tablelookup(survivalwavetable, 2, currentwave, 10):gsub("%s+", "")
end

function waveendsplash()
    addsplash({
        text = "&SO_SURVIVAL_WAVE_SUCCESS_TITLE",
        value = currentwave,
        yoffset = -100,
        color = "blue",
        duration = 2000,
        sound = "survival_wave_end_splash"
    })
end

function starttimer()
    skipelement = createhuditem(-2, hudxpos(), "&SO_SURVIVAL_READY_UP")
    skipelement.fontscale = 1

    local timeleft = 30
    skipelement:setvalue(timeleft)

    local interval = nil
    interval = game:oninterval(function()
        timeleft = timeleft - 1
        if (timeleft <= 5) then
            skipelement:destroy()
            skipelement = nil
            interval:clear()
            player:notify("survival_player_ready")
        else
            skipelement:setvalue(timeleft)
        end
    end, 1000)
    interval:endon(player, "survival_player_ready")
end

currentscore = 0
local totalstats = {
    starttime = 0,
    kills = 0,
    headshots = 0,
    score = 0,
    wave = 0,
    accuracy = 0,
    damagetaken = 0,
    shotsfired = 0,
    shotshit = 0
}

local wavestats = {}
function resetwavestats()
    wavestats = {
        starttime = 0,
        kills = 0,
        headshots = 0,
        score = 0,
        wave = 0,
        accuracy = 0,
        damagetaken = 0,
        shotsfired = 0,
        shotshit = 0
    }
end

resetwavestats()

function calculatebonuses()
    local bonuses = {}
    bonuses.headshots = wavestats.headshots * 20
    bonuses.accuracy = math.floor(math.max(wavestats.accuracy - 25, 0))  * 3
    bonuses.damagetaken = math.floor(math.max(400 - wavestats.damagetaken * 2, 0))
    bonuses.kills = wavestats.kills * 20
    bonuses.time = math.floor(math.max(90 - math.floor(wavestats.timems / 1000), 0) * 2)
    bonuses.wave = 25 * currentwave
    return bonuses
end

function waveend()
    if (flag("special_op_terminated")) then
        return
    end

    level:notify("wave_ended")

    musicstop(10)

    game:setsaveddvar("bg_compassShowEnemies", 0)

    wavestats.timems = game:gettime() - wavestats.starttime
    wavestats.time = string.format("%.1f", wavestats.timems / 1000)
    wavestats.accuracy = math.floor(wavestats.shotshit / math.max(1, wavestats.shotsfired) * 100)

    local bonuses = calculatebonuses()

    local stats = {}
    local totalbonus = 0
    for k, v in pairs(wavestats) do
        stats[k] = {
            value = v,
            bonus = bonuses[k]
        }

        if (bonuses[k]) then
            totalbonus = totalbonus + bonuses[k]
        end
    end

    stats.wavebonus = {value = 0, bonus = totalbonus}

    game:luinotify("so_survival_event", json.encode({
        name = "wave_end",
        stats = stats 
    }))

    addscore(totalbonus)
    waveendsplash()

    local armory = getwavearmoryunlock()
    if (armory ~= nil and armory ~= "") then
        if (armories[armory]) then
            armories[armory].enable()
        end
    else
        game:ontimeout(function()
            radiodialogue("so_hq_wave_over_flavor")
        end, 1000)
    end

    game:ontimeout(function()
        starttimer()
        player:onnotifyonceany(function()
            if (skipelement) then
                skipelement:destroy()
                skipelement = nil
            end
    
            local countdown = game:newhudelem()
            countdown.alignx = "center"
            countdown.aligny = "middle"
            countdown.horzalign = "center"
            countdown.vertalign = "middle"
            countdown.font = "bankshadow"
            countdown.fontscale = 2
            countdown.hidewhendead = true
            countdown.hidewheninmenu = true
    
            local pulse = function()
                if (flag("special_op_terminated")) then
                    return
                end

                countdown:changefontscaleovertime(2 * 0.05)
                countdown.fontscale = 3

                game:ontimeout(function()
                    countdown:changefontscaleovertime(4 * 0.05)
                    countdown.fontscale = 2
                end, ms(2 * 0.05))
            end

            local timeleft = 5
            countdown:setvalue(timeleft)
            pulse()
    
            player:playlocalsound("countdown_beep")
            local interval = nil
            interval = game:oninterval(function()
                if (flag("special_op_terminated")) then
                    return
                end

                timeleft = timeleft - 1
                countdown:setvalue(timeleft)
                pulse()
    
                if (timeleft <= 0) then
                    countdown:destroy()
                    interval:clear()
                    wavestart()
                else
                    player:playlocalsound("countdown_beep")
                end
            end, 1000)

            interval:endon(level, "special_op_terminated")
        end, "survival_player_ready", 25000)
    end, 4000)
end

player:onnotify("damage", function(damage, attacker)
    if (attacker ~= player) then
        wavestats.damagetaken = wavestats.damagetaken + damage
    end
end)

player:onnotify("weapon_fired", function()
    wavestats.shotsfired = wavestats.shotsfired + 1
    totalstats.shotsfired = totalstats.shotsfired + 1
end)

local scorebuffer = 0
function addscore(score)
    scorebuffer = scorebuffer + score
    currentscore = currentscore + score
    game:setdvar("ui_current_score", currentscore)
    wavestats.score = wavestats.score + score
    totalstats.score = totalstats.score + score
    print(totalstats.score)
end

game:oninterval(function()
    if (scorebuffer ~= 0) then
        game:luinotify("add_score", tostring(scorebuffer))
        scorebuffer = 0
    end
end, 0):endon(level, "special_op_terminated")

local srcspawners = game:getentarray("info_enemy_spawnpoint", "classname")

function getspawnpoints(mindist)
    local srcspawners = game:getentarray("info_enemy_spawnpoint", "classname")
    local spawners = nil
    print(#srcspawners)
    useclosestspawnpoints = true
    if (useclosestspawnpoints) then
        mindist = nil
        spawners = game:scriptcall("common_scripts/utility", "get_array_of_closest", player.origin, srcspawners, nil, nil, 3000, 1500)
    else
        spawners = srcspawners
    end

    local filtered = array:new()
    for i = 1, #spawners do
        if (mindist == nil or game:distance(spawners[i].origin, player.origin) > mindist) then
            filtered:push(spawners[i])
        end
    end

    return filtered
end

local endflags = {}

function addflag()
    table.insert(endflags, false)
    return #endflags
end

function setflag(index)
    endflags[index] = true
    for i = 1, #endflags do
        if (endflags[i] == false) then
            return
        end
    end

    waveend()
end

function setenemyproperties(ent, enemytype)
    ent:scriptcall("_ID48289", "_ID53152") -- predator hud target

    local health = getenemyhealth(enemytype)
    local speed = getenemyspeed(enemytype)
    local accuracy = getenemyaccuracy(enemytype)
    local xp = getpointsforenemytype(enemytype)

    if (health) then
        ent.maxhealth = health
        ent.health = ent.maxhealth
    end

    if (speed) then
        ent.speed = speed
    end

    if (accuracy) then
        ent.accuracy = accuracy
    end

    if (xp) then
        ent.xp = xp
    end
end

function spawnguys(enemycount, target, difficulty)
    local guysflag = addflag()

    local difficulty = getwavedifficulty()
    local regularguyscount = getwaveenemycount()
    local specialguys = getwavespecialenemies()
    local regularspawner = game:getent(difficulty .. "_spawner", "targetname")
    local spawners = {}

    for i = 1, regularguyscount do
        table.insert(spawners, regularspawner)
    end

    for i = 1, #specialguys do
        local count = getwavespecialenemycount(specialguys[i])
        for o = 1, count do
            local spawner = game:getent(specialguys[i] .. "_spawner", "targetname")
            table.insert(spawners, spawner)
        end
    end

    spawners = shuffle(spawners)

    local target = #spawners
    local spawncount = #spawners
    local killedcount = 0
    local spawnindex = 0

    local spawn = nil
    spawn = function()
        local spawnpoints = getspawnpoints(800)
        if (#spawnpoints == 0) then
            game:ontimeout(spawn, ms(game:randomfloatrange(0.1, 0.5)))
            return
        end

        if (#spawners == 0) then
            return
        end

        spawnindex = spawnindex + 1
        if (spawnindex > #spawners) then
            spawnindex = 1
        end

        local spawner = spawners[spawnindex]
        local spawnpoint = spawnpoints[game:randomint(#spawnpoints) + 1]

        local enemies = game:getaispeciesarray("axis", "all")
        if (#enemies >= maxenemycount) then
            return
        end

        spawner.origin = spawnpoint.origin
        spawner.count = 1000

        spawner:spawnai(false, function(guy)
            if (defined(guy)) then
                table.remove(spawners, spawnindex)

                local enemytype = game:getsubstr(spawner.targetname, 0, #spawner.targetname - #"_spawner")
                setenemyproperties(guy, enemytype)

                local lasthit = nil
                
                guy:onnotifyonceany(function()
                    if (flag("special_op_terminated")) then
                        return
                    end

                    killedcount = killedcount + 1
                    enemydeath(guy)
                    addscore(guy.xp)

                    if (killedcount == target) then
                        setflag(guysflag)
                    end
                end, "death", "pain_death")

                guy:onnotify("damage", function(damage, attacker, a3, a4, a5, a6, a7, bone)
                    lasthit = bone

                    if (guy.counthits == 0) then
                        return
                    end

                    guy.counthits = false
                    game:ontimeout(function()
                        guy.counthits = true
                    end, 0):endon(guy, "death")

                    wavestats.shotshit = wavestats.shotshit + 1
                    totalstats.shotshit = totalstats.shotshit + 1
                end):endon(guy, "death")

                guy:onnotifyonce("weapon_dropped", function(weapon)
                    if (weapon == nil or not defined(weapon)) then
                        return
                    end

                    local name = weapon.classname:sub(#"weapon_" + 1)
                    weapon:itemweaponsetammo(getweaponclipcount(name), 0)
                end)

                guy:followplayer()
            end

            if (#spawners > 0) then
                game:ontimeout(spawn, ms(game:randomfloatrange(0.1, 0.5)))
            end
        end)
    end

    game:ontimeout(spawn, 100)
end

game:onentitydamage(function(self_, inflictor, attacker, damage, mod, weapon, dir, hitloc)
    self_.lastmod = mod
    self_.lasthitloc = hitloc

    if (mod == "MOD_MELEE" and game:isai(attacker) == 1) then
        return 40
    end

    if (self_.invulnerable == 1) then
        return 0
    end

    if (self_.vehicletype == "littlebird") then
        if (attacker ~= nil and attacker:getlinkedparent()) then
            local parent = attacker:getlinkedparent()
            if (parent.vehicletype == "littlebird") then
                return 0
            end
        end
    end

    if (self_.isourturret == true and attacker.isourturret == true) then
        return 0
    end

    if (self_.vehicletype == "mi17") then
        return 0
    end
end)

local previousangle = 0
function getrandomhelispawnpos()
    local center = game:getent("info_map_center", "classname")
    local angle = 0
    while (math.abs(angle - previousangle) < 45) do
        angle = game:randomintrange(0, 360)
    end

    local xdiff = game:cos(angle) * center.radius * 1
    local ydiff = game:sin(angle) * center.radius * 1

    local origin = vector:new(
        center.origin.x + xdiff,
        center.origin.y + ydiff,
        center.origin.z + 1000
    )

    return origin
end

game:precacheshader("javelin_hud_target")

local objectiveindex = 2
function addobjectiveonentity(ent, icon)
    ent.objectiveindex = objectiveindex
    objectiveindex = objectiveindex + 1

    game:objective_add(ent.objectiveindex, "none")
    game:objective_state_nomessage(ent.objectiveindex, "current")
    game:objective_onentity(ent.objectiveindex, ent)

    ent:onnotifyonce("death", function()
        game:objective_delete(ent.objectiveindex)
    end)

    if (icon) then
        game:objective_icon(ent.objectiveindex, icon)
    end
end

function spawnchopper()
    local heliendflag = addflag()
    level._ID3644 = game:cos(180) -- set heli fov

    local spawner = game:getent("chopper_spawner", "targetname")
    spawner.count = 100000

    local count = 0
    local targetcount = 1
    local alivecount = targetcount

    local spawnchopperinternal = function()
        spawner.origin = getrandomhelispawnpos()
        local heli = game:scriptcall("_ID42508", "_ID35681", "chopper_spawner")
        if (not heli) then
            return
        end

        addobjectiveonentity(heli)

        local helitarget = game:getent("little_bird_target", "targetname")
        helitarget.origin = heli.origin

        count = count + 1

        for i = 1, #heli._ID23512 do
            local turret = heli._ID23512[i]
            turret:scriptcall("_ID42413", "_ID39304", "manual")
            turret:setmode("manual")
            turret:setbottomarc(180)
        end
    
        heli._ID11585 = true
        game:ontimeout(function()
            game:scriptcall("_ID42508", "_ID4977", heli)
            setenemyproperties(heli, "chopper")
        end, 100)

        heli:onnotifyonce("death", function()
            local points = getpointsforenemytype("chopper")
            addscore(points)
            enemydeath(heli)
            setflag(heliendflag)
        end)
        
        heli:onnotify("damage", function(damage, attacker)
            if (attacker == player) then
                player:scriptcall("_ID42279", "_ID39695", heli)
            end

            wavestats.shotshit = wavestats.shotshit + 1
            totalstats.shotshit = totalstats.shotshit + 1
        end):endon(heli, "death")
    end

    local interval = nil
    interval = game:oninterval(function()
        if (count >= targetcount) then
            interval:clear()
            return
        end

        spawnchopperinternal()
    end, 0)
end

function enemydeath(guy)
    if (guy.lasthitloc == "head" or guy.lasthitloc == "helmet") then
        wavestats.headshots = wavestats.headshots + 1
        totalstats.headshots = totalstats.headshots + 1
        player:notify("headshot")
    end

    player:notify("killed_enemy", guy)
    wavestats.kills = wavestats.kills + 1
    totalstats.kills = totalstats.kills + 1
    wavestats.shotshit = wavestats.shotshit + 1
    totalstats.shotshit = totalstats.shotshit + 1
end

function entity:followplayer()
    if (not findbestnodeinterval) then
        findbestnodeinterval = game:oninterval(function()
            local radius = 128
            local nodes = game:getnodesinradiussorted(game:getgroundposition(player.origin), 2000)
            if (#nodes > 0) then
                local dist = game:distance2d(nodes[1].origin, player.origin)
                player.farawayfromnodes = dist > 128
                player.bestnode = nodes[1]
            end

        end, 1000)
    end

    game:oninterval(function()
        self.goalradius = 256
        --if (player.farawayfromnodes == 1 and player.bestnode ~= nil) then
            --print("going to closest node")
            --self:setgoalnode(player.bestnode)
        --else
            --print("going to player")
            self:setgoalpos(player.origin)
        --end
    end, 0):endon(self, "death")
end

function spawnjuggernaut(enemytype, landingpos)
    local juggendflag = addflag()

    local count = 0
    local targetcount = 1

    local spawnjugger = function()
        local spawnertargetname = enemytype .. "_heli_spawner"

        local helispawner = game:getent(spawnertargetname, "targetname")
        helispawner.origin = getrandomhelispawnpos()

        local endpos = game:getent(enemytype .. "_end_pos", "script_noteworthy")
        endpos.origin = helispawner.origin

        local heli = game:scriptcall("_ID42411", "_ID35196", spawnertargetname)
        if (heli) then
            count = count + 1
        else
            return
        end

        local unloadpos = game:getent(enemytype .. "_unload_pos", "script_noteworthy")
        unloadpos.origin = landingpos

        local rider = heli._ID29965[1]
        rider.invulnerable = true
        heli:onnotifyonce("unloaded", function()
            rider.invulnerable = false
            rider:followplayer()
            setenemyproperties(rider, enemytype)
        end)

        heli:onnotifyonce("unloading", function()
            local trace = game:getgroundposition(rider.origin + vector:new(0, 0, -200))
            game:playfx(fx["smoke"], trace)
        end)

        rider:onnotifyonce("death", function()
            local points = getpointsforenemytype(enemytype)
            addscore(points)
            enemydeath(rider)
            setflag(juggendflag)
        end)

        rider:onnotify("damage", function(damage, attacker)
            if (attacker == player) then
                player:scriptcall("_ID42279", "_ID39695", rider)
            end

            wavestats.shotshit = wavestats.shotshit + 1
            totalstats.shotshit = totalstats.shotshit + 1
        end):endon(rider, "death")
    end

    local interval = nil
    interval = game:oninterval(function()
        if (count >= targetcount) then
            interval:clear()
            return
        end

        spawnjugger()
    end, 0)
end

function spawnbosses(bosses)
    local numchoppers = 0
    local numjuggs = 0
    local juglandingzones = game:getentarray("jug_land_zone", "targetname")
    local landingzoneindex = 1

    for i = 1, #bosses do
        if (bosses[i] == "chopper") then
            spawnchopper()
            numchoppers = numchoppers + 1
        else
            numjuggs = numjuggs + 1
            spawnjuggernaut(bosses[i], juglandingzones[landingzoneindex].origin)
            landingzoneindex = landingzoneindex + 1
        end
    end

    if (numjuggs > 0) then
        musicloop("mus_so_survival_boss_music_02")

        if (numjuggs > 1) then
            radiodialogue("so_hq_enemy_intel_boss_transport_many")
        else
            radiodialogue("so_hq_enemy_intel_boss_transport")
        end
    else
        musicloop("mus_so_survival_boss_music_01")
    end

    if (numchoppers > 0) then
        if (numchoppers > 1) then
            radiodialogue("so_hq_boss_intel_chopper_many")
        else
            radiodialogue("so_hq_boss_intel_chopper")
        end
    end
end

function wavestart(callback)
    game:setdvar("ai_accuracy_attackerCountDecrease", 1)
    game:setdvar("ai_accuracy_attackerCountMax", 0)

    resetwavestats()

    if (flag("special_op_terminated")) then
        return
    end

    game:ontimeout(function()
        game:setsaveddvar("bg_compassShowEnemies", 1)
    end, 5000)

    endflags = {}

    currentwave = currentwave + 1
    wavestats.starttime = game:gettime()
    wavestats.wave = currentwave
    wavestartsplash()

    game:luinotify("set_wave_num", tostring(currentwave))

    level:notify("wave_started")

    local bosses = getwavebosses()
    local specialenemies = getwavespecialenemies()

    if (#bosses > 0) then
        spawnbosses(bosses)
    end

    local difficulty = getwavedifficulty()
        
    if (#specialenemies > 0) then
        radiodialogue("so_hq_enemy_intel_" .. specialenemies[1])
    elseif (#specialenemies == 0 and currentwave > 1 and difficulty ~= "") then
        radiodialogue("so_hq_enemy_intel_generic")
    end

    if (difficulty ~= "") then
        spawnguys()
    end
end

function intromusic()
    if (currentwave ~= 0) then
        return
    end

    game:musicplay("mus_so_survival_regular_music")
    game:ontimeout(function()
        game:musicstop(10)
    end, 5000)
end

function startwaves()
    starttime = game:gettime()

    if (currentwave == 0) then
        player:playlocalsound("arcademode_zerodeaths")

        game:ontimeout(function()
            radiodialogue("so_hq_mission_intro_sp")
        end, 1000)
    end

    wavestart()
end

function seteogdata()
    musicstop()

    game:setdvar("ui_current_wave", currentwave)
    game:sharedset("eog_extra_data", json.encode({
        stats = {
            {
                name = "@SO_SURVIVAL_PERFORMANCE_KILLS",
                value = totalstats.kills
            }, 
            {
                name = "@SO_SURVIVAL_PERFORMANCE_HEADSHOT",
                value = totalstats.headshots
            },
            {
                name = "@SO_SURVIVAL_PERFORMANCE_ACCURACY",
                value = math.floor(totalstats.shotshit / math.max(1, totalstats.shotsfired) * 100),
                label = "@SO_SURVIVAL_PERFORMANCE_PERCENT"
            },
            {
                spacer = true,
            },
            {
                name = "@SO_SURVIVAL_PERFORMANCE_TIME",
                value = starttime and (game:gettime() - starttime) or 0,
                istimestamp = true
            },
            {
                name = "@SO_SURVIVAL_PERFORMANCE_SCORE",
                value = totalstats.score
            }
        }
    }))
end

function uav()
    level._ID49526 = game:spawn("script_model", vector:new(0, 0, 0))
    level._ID49526:setmodel("vehicle_ucav")
    level._ID39406 = game:spawn("script_model", level._ID49526.origin)
    level._ID39406:setmodel("tag_origin")
    uavrigaiming()

    player:onnotify("exiting_uav_control", function()
        enableallportalgroups()
        level:notify("draw_target_end")
    end)
end

function ac130()
    local ac130model = game:spawn("script_model", vector:new(0, 0, 0))
    ac130model:setmodel("vehicle_ac130_low")

    local center = game:getent("info_map_center", "classname")
    local radius = center.radius + 400
    local speed = 4
    local points = {}

    for angle = 360, 0, -1 do
        local x = center.origin.x + radius * game:cos(angle)
        local y = center.origin.y + radius * game:sin(angle)
        table.insert(points, vector:new(x, y, center.height + 5000))
    end

    ac130model.origin = points[1]
    ac130model.angles = vector:new(0, -90, 25)
    local index = 2

    local movetonode = nil
    movetonode = function()
        if (index > #points) then
            index = 2
        end

        ac130model:moveto(points[index], 0.1 * speed)
        game:ontimeout(function()
            movetonode()
        end, 50 * speed)

        index = index + 1
    end

    game:oninterval(function()
        if (ac130target) then
            local origin = ac130model:gettagorigin("tag_40mm")
            local missile = game:magicbullet("ac130_40mm", origin, ac130target)
        end
    end, 300)

    game:oninterval(function()
        local rotateindex = index + 1
        if (rotateindex > #points) then
            rotateindex = 1 
        end

        local angles = game:vectortoangles(points[rotateindex] - ac130model.origin)
        angles.z = 30
        ac130model:rotateto(angles, 0.5)
    end, 0)

    movetonode()
end

function uavrigaiming()
    if (defined(level._ID45535)) then
        return
    end

    local center = game:getent("info_map_center", "classname")
    local radius = center.radius
    local speed = 2
    local points = {}

    for angle = 0, 360, 1 do
        local x = center.origin.x + radius * game:cos(angle)
        local y = center.origin.y + radius * game:sin(angle)
        table.insert(points, vector:new(x, y, center.height))
    end

    local uavmodel = level._ID49526
    uavmodel.origin = points[1]
    uavmodel:playloopsound("uav_engine_loop")
    uavmodel:setmodel("vehicle_ucav")

    local index = 2

    local interval = game:oninterval(function()
        local pointindex = index + 1
        if (pointindex > #points) then
            pointindex = 2
        end

        local angles = game:vectortoangles(center.origin - level._ID39406.origin)
        level._ID39406:moveto(uavmodel.origin, 0.10, 0, 0)
        level._ID39406:rotateto(angles, 0.10, 0, 0)
    end, 0)

    local movetonode = nil
    movetonode = function()
        if (index > #points) then
            index = 2
        end

        uavmodel:moveto(points[index], 0.1 * speed)
        game:ontimeout(function()
            movetonode()
        end, 50 * speed)

        index = index + 1
    end

    game:oninterval(function()
        local rotateindex = index + 1
        if (rotateindex > #points) then
            rotateindex = 1 
        end

        local angles = game:vectortoangles(points[rotateindex] - uavmodel.origin)
        uavmodel:rotateto(angles, 0.5)
    end, 0)

    movetonode()

    interval:endon(level, "uav_destroyed")
    interval:endon(level._ID49526, "death")
end

function addexplosive(ent, tag, originoffset, anglesoffset)
    originoffset = originoffset or vector:new(0, 0, 0)
    anglesoffset = anglesoffset or vector:new(0, 0, 0)

    local model = game:spawn("script_model", ent:gettagorigin(tag) + originoffset)
    model:setmodel("h2_weapon_c4")
    model:linkto(ent, tag, originoffset, anglesoffset)

    if (not defined(ent.explosives)) then
        ent.explosives = array:new()
    end

    ent.explosives:push(model)
end

function unlinkanddelete(ent)
    ent:unlink()
    game:ontimeout(function()
        if (defined(ent)) then
            ent:delete()
        end
    end, 0):endon(ent, "death")
end

function explosivethread(ent, waittime, interval)
    ent:onnotifyonceany(function()
        ent:notify("force_c4_detonate")

        if (not defined(ent.explosives) or #ent.explosives == 0) then
            return
        end

        for i = 1, #ent.explosives do
            game:playfxontag(fx["martyrdom_dlight_red"], ent.explosives[i], "tag_fx")
            game:playfxontag(fx["martyrdom_red_blink"], ent.explosives[i], "tag_fx")
        end

        local explosives = ent.explosives
        ent.explosives = nil
        game:badplace_cylinder("", waittime, explosives[1].origin, 144, 144, "axis", "allies")
        local waittime2 = math.max(waittime - 1.5, 0)

        local f1 = function()
            explosives[1]:playsound("semtex_warning_so")
            local var6 = false

            if (waittime > 0.25) then
                waittime = waittime - 0.25
                var6 = true
            end

            game:ontimeout(function()
                for i = 1, #explosives do
                    if (defined(explosives[i])) then
                        game:stopfxontag(fx["martyrdom_red_blink"], explosives[i], "tag_fx")
                    end
                end

                local f2 = function()
                    local sorted = game:sortbydistance(explosives, explosives[1].origin + vector:new(0, 0, -120))
                    local i = 0

                    local iter = nil
                    iter = function()
                        i = i + 1
                        if (i > #sorted) then
                            return
                        end

                        if (not defined(sorted[i])) then
                            return
                        end

                        game:playfx(fx["martyrdom_c4_explosion"], sorted[i].origin)
                        sorted[i]:playsound("h1_c4_explosion_main", "sound_done")
                        game:physicsexplosioncylinder(sorted[i], 256, 1, 2)
                        game:earthquake(0.4, 0.8, sorted[i].origin, 600)
                        game:stopfxontag(fx["martyrdom_dlight_red"], sorted[i], "tag_fx")

                        sorted[i]:radiusdamage(sorted[i].origin, 192, 100, 50, nil, "MOD_EXPLOSIVE")
                        unlinkanddelete(sorted[i])

                        game:ontimeout(iter, ms(interval))
                    end

                    iter()
                end

                if (var6) then
                    game:ontimeout(f2, ms(0.25))
                else
                    f2()
                end
            end, ms(waittime))
        end

        if (waittime2 > 0) then
            waittime = waittime - waittime2
            game:ontimeout(f1, ms(waittime2))
        else
            f1()
        end
    end, "pain_death", "death", "long_death", "force_c4_detonate")
end

function setupspawners()
    local dogspawner = game:getent("dog_splode_spawner", "targetname")
    if (dogspawner) then
        dogspawner:onnotify("spawned", function(dog)
            dog.badplaceawereness = 0
            dog.grenadeawareness = 0

            addexplosive(dog, "j_hip_base_ri", vector:new(6, 6, -3), vector:new(0, 0, 0))
            addexplosive(dog, "j_hip_base_le", vector:new(-6, -6, 3), vector:new(0, 0, 0))
            explosivethread(dog, 3, 0.4)
        end)
    end

    local martyrdomspawner = game:getent("martyrdom_spawner", "targetname")
    if (martyrdomspawner) then
        martyrdomspawner:onnotify("spawned", function(guy)
            addexplosive(guy, "j_spine4", vector:new(0, 6, 0), vector:new(0, 0, -90))
            addexplosive(guy, "tag_stowed_back", vector:new(0, 1, 5), vector:new(80, 90, 0))
            explosivethread(guy, 3, 0.4)
        end)
    end

    -- temporary
    local chemicalspawner = game:getent("chemical_spawner", "targetname")
    if (chemicalspawner) then
        chemicalspawner:onnotify("spawned", function(guy)
            addexplosive(guy, "j_spine4", vector:new(0, 6, 0), vector:new(0, 0, -90))
            addexplosive(guy, "tag_stowed_back", vector:new(0, 1, 5), vector:new(80, 90, 0))
            explosivethread(guy, 3, 0.4)
        end)
    end
end

function detonate(entity)
    if (game:isplayer(entity) == 1) then
        return
    end

    entity:detonate()
end

function loadfx()
    fx = {}

    fx["martyrdom_c4_explosion"] = game:loadfx("fx/explosions/grenadeexp_default")
    fx["martyrdom_dlight_red"] = game:loadfx("vfx/lights/light_c4_blink")
    fx["martyrdom_red_blink"] = game:loadfx("vfx/lights/aircraft_light_red_blink")
    fx["smoke"] = game:loadfx("fx/smoke/smoke_grenade")

    game:precachemodel("vehicle_ac130_low")

    level.smokefx = game:loadfx("fx/smoke/signal_smoke_airdrop")
end

function spawnarmories()
    local spawnarmory = function(name, menu, hintstring, icon)
        local origin = game:getent("armory_" .. name .. "_origin", "targetname")
        local box = game:spawn("script_model", origin.origin)
        local laptop = game:spawn("script_model", origin.origin + vector:new(0, 0, 30))
        local laptopclosed = game:spawn("script_model", origin.origin + vector:new(0, 0, 30))

        box.angles = origin.angles + vector:new(0, -90, 0)
        laptop.angles = origin.angles + vector:new(0, 0, 0)
        laptopclosed.angles = origin.angles + vector:new(0, 0, 0)

        box:setmodel("com_plasticcase_green_big")
        laptop:setmodel("com_laptop_open")
        laptopclosed:setmodel("com_laptop_close")

        laptop:hide()

        local armory = {}

        local iconhud = game:newhudelem()
        iconhud:setshader(icon, 10, 10)
        iconhud.x = laptop.origin.x
        iconhud.y = laptop.origin.y
        iconhud.z = laptop.origin.z
        iconhud.hidewhendead = true
        iconhud.hidewheninmenu = true
        iconhud:setwaypoint(false, true)
        iconhud.alpha = 0

        local enabled = false
        armory.enable = function()
            if (enabled) then
                return
            end

            enabled = true

            game:ontimeout(function()
                if (name == "airsupport") then
                    radiodialogue("so_hq_armory_open_airstrike")
                else
                    radiodialogue("so_hq_armory_open_" .. name)
                end
            end, 1000)

            iconhud.alpha = 1

            laptopclosed:hide()
            laptop:show()
            laptop:makeusable()
            laptop:sethintstring(hintstring)

            laptop:onnotify("trigger", function()
                if (name == "airsupport" and player.supportitem ~= nil) then
                    game:iprintlnbold("&SO_SURVIVAL_DPAD_RIGHT_SLOT_FULL")
                    return
                end

                player:freezecontrols(true)
                game:executecommand("lui_open " .. menu)
            end)
        end
        
        return armory
    end

    armories.weapon = spawnarmory("weapon", "specops_ui_weaponstore", "&SO_SURVIVAL_ARMORY_USE_WEAPON", "hud_icon_m9beretta")
    armories.equipment = spawnarmory("equipment", "specops_ui_equipmentstore", "&SO_SURVIVAL_ARMORY_USE_EQUIPMENT", "hud_us_grenade")
    armories.airsupport = spawnarmory("airsupport", "specops_ui_airsupport", "&SO_SURVIVAL_ARMORY_USE_AIRSUPPORT", "compass_objpoint_airstrike")
end

function startsurvival()
    loadfx()

    --level._ID20913 = false
    game:scriptcall("animscripts/dog/dog_init", "_ID19886")

    level._ID15361 = 2
    level._ID47489._ID45626 = 20 -- predator view angle range

    game:scriptcall("_ID42323", "_ID32417", "viewhands_player_tf141")
    player:notifyonplayercommand("survival_player_ready", "skip")

    game:overridedvarint("specialops", 1)
    game:overridedvarint("so_survival", 1)

    game:setsaveddvar("bg_compassShowEnemies", 1)
    game:setdvar("ui_current_score", 0)

    -- disable sentry pickup anim
    game:detour("_ID53924", "h2_sentry_pickup", function(sentry)
        sentry:setsentrycarrier(player)
        player:disableweapons()
    end)

    local builder = game:getdvarint("so_map_builder")
    if (builder > 0) then
        initbuilder(builder)
        return
    end

    playerloadout()
    setplayerpos()

    enableescapewarning()
    enableescapefailure()

    flyingintro()

    setupspawners()
    spawnarmories()

    flagwait("slamzoom_finished", function()
        uav()
        ac130()

        game:objective_add(1, "current", "&SO_SURVIVAL_SURVIVAL_OBJECTIVE")

        intromusic()
        game:ontimeout(startwaves, 4000)
    end)
end
