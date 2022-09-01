local cols = {
    id = 0,
    name = 1,
    type = 2,
    price = 3,
    namestring = 4,
    descstring = 5,
    imagename = 6,
    level = 7,
    attachments = 8,
    unk1 = 9,
    unk2 = 10,
    weaponclass = 11
}

local csv = "sp/survival_armories.csv"

local menus = {}

menus["specops_ui_weaponstore"] = {}
menus["specops_ui_equipmentstore"] = {}
menus["specops_ui_airsupport"] = {}

local function addweapon(n, f)
    menus["specops_ui_weaponstore"][n] = f
end

local function addequipment(n, f)
    menus["specops_ui_equipmentstore"][n] = f
end

local function addairsupport(n, f)
    menus["specops_ui_airsupport"][n] = f
end

local finditem = function(name)
    return game:tablelookuprownum(csv, cols.name, name)
end

game:oninterval(function()
    local primaries = player:getweaponslistprimaries()
    if (primaries[1]) then
        game:sharedset("player_primary", primaries[1])
    else
        game:sharedset("player_primary", "none")
    end

    if (primaries[2]) then
        game:sharedset("player_secondary", primaries[2])
    else
        game:sharedset("player_secondary", "none")
    end

    game:sharedset("can_buy_ammo", "0")
    for i = 1, #primaries do
        local clip = player:getweaponammoclip(primaries[i])
        local stock = player:getweaponammostock(primaries[i])
        local defaultclip = game:weaponclipsize(primaries[i])
        local defaultstock = game:weaponmaxammo(primaries[i])

        if (clip < defaultclip or stock < defaultstock) then
            game:sharedset("can_buy_ammo", "1")
            break
        end
    end

    local checkweapon = function(weaponname, maxcount, var, clip, weapononly)
        if (weapononly) then
            if (player:hasweapon(weaponname) == 1) then
                game:sharedset(var, "0")
            else
                game:sharedset(var, "1")
            end
        else
            if (player:hasweapon(weaponname) == 0) then
                game:sharedset(var, "1")
            end
    
            local stock = (not clip and 0 or player:getweaponammoclip(weaponname)) + player:getweaponammostock(weaponname)
            if (stock >= maxcount) then
                game:sharedset(var, "0")
            else
                game:sharedset(var, "1")
            end
        end
    end

    checkweapon("fraggrenade", 4, "can_buy_fraggrenade", false)
    checkweapon("flash_grenade", 4, "can_buy_flash_grenade", false)
    checkweapon("claymore", 10, "can_buy_claymore", false)
    checkweapon("rpg", 4, "can_buy_rpg", true)
    checkweapon("c4", 10, "can_buy_c4", false)
    checkweapon("riotshield", 1, "can_buy_riotshield", false, true)

    if (player.supportitem ~= nil) then
        game:sharedset("can_buy_sentry_gl", "0")
        game:sharedset("can_buy_sentry", "0")
        game:sharedset("can_buy_remote_missile", "0")
        game:sharedset("can_buy_precision_airstrike", "0")
        game:sharedset("can_buy_friendly_support_delta", "0")
        game:sharedset("can_buy_friendly_support_riotshield", "0")
    else
        if (level._ID44698 == nil or #level._ID44698 >= 2) then
            game:sharedset("can_buy_sentry_gl", "0")
            game:sharedset("can_buy_sentry", "0")
        else
            game:sharedset("can_buy_sentry_gl", "1")
            game:sharedset("can_buy_sentry", "1")
        end

        game:sharedset("can_buy_remote_missile", "1")
        game:sharedset("can_buy_precision_airstrike", "0") -- unimplemented
        game:sharedset("can_buy_friendly_support_delta", "0") -- unimplemented
        game:sharedset("can_buy_friendly_support_riotshield", "0") -- unimplemented
    end

    if (player.hasselfrevive == 1) then
        game:sharedset("can_buy_laststand", "0")
    else
        game:sharedset("can_buy_laststand", "0") -- unimplemented
    end

    if (player.armorlevel == nil or player.armorlevel < 250) then
        game:sharedset("can_buy_armor", "1")
    else
        game:sharedset("can_buy_armor", "0")
    end

    local perks = {
        "specialty_quickdraw",
        "specialty_bulletaccuracy",
        "specialty_stalker",
        "specialty_longersprint",
        "specialty_fastreload",
    }

    for i = 1, #perks do
        if (player:hasperk(perks[i], true, true) == 1) then
            game:sharedset("has_specialty_" .. perks[i], "1")
        else
            game:sharedset("has_specialty_" .. perks[i], "0")
        end
    end

end, 0):endon(level, "special_op_terminated")

local function watchsentry(sentry)
    sentry:onnotifyonce("death", function()
        radiodialogue("so_hq_sentry_down")
        game:ontimeout(function()
            if (defined(sentry)) then
                sentry:delete()
            end
        end, 20000)
    end)

    local lasthit = 0
    local totaldamage = 0
    local timediff = 0
    local start = game:gettime()
    local lasttimesaid = 0

    sentry:onnotify("damage", function(damage, attacker)
        if (defined(attacker) and attacker ~= player) then
            local now = game:gettime()
            totaldamage = totaldamage + damage
            timediff = timediff + now - start
            start = now

            if (timediff < 3000 and totaldamage > 300) then
                if (game:distancesquared(sentry.origin, player.origin) < 500 ^ 2 and (now - lasttimesaid) > 15000) then
                    radiodialogue("so_hq_sentry_underattack")
                    lasttimesaid = now
                end

                timediff = 0
                totaldamage = 0
            end

            if (timediff >= 3000) then
                timediff = 0
                totaldamage = 0
            end
        end
    end):endon(sentry, "death")
end

player:notifyonplayercommand("actionslot4", "+actionslot 4")

player:onnotify("actionslot4", function()
    if (player.supportitem == nil) then
        return
    end

    local sentry = nil

    if (player.supportitem == "sentry") then
        sentry = game:spawnturret("misc_turret", player.origin, "sentry_minigun")
        sentry.isourturret = true
        sentry:setmodel("sentry_minigun")
        sentry:scriptcall("_ID53924", "_ID46055", "sentry_minigun")
        sentry:notify("trigger", player)
    end

    if (player.supportitem == "sentry_gl") then
        sentry = game:spawnturret("misc_turret", player.origin, "sentry_gun")
        sentry.isourturret = true
        sentry:setmodel("sentry_grenade_launcher")
        sentry:scriptcall("_ID53924", "_ID46055", "sentry_gun")
        sentry:notify("trigger", player)
    end

    if (not sentry) then
        return
    end

    player:onnotifyonce("placingSentry", function()
        watchsentry(player._ID26734)
    end)

    player.supportitem = nil
    player:setweaponhudiconoverride("actionslot4", "")
end)

function giveweapon(weapon, giveammo)
    if (player:hasweapon(weapon) == 1) then
        return false
    end

    local primaries = player:getweaponslistprimaries()
    if (#primaries >= 2) then
        player:takeweapon(player:getcurrentweapon())
    end

    player:giveweapon(weapon)
    if (giveammo == nil or giveammo == true) then
        player:givestartammo(weapon)
    end
    player:switchtoweapon(weapon)
end

level:onnotify("player_fired_remote_missile", function()
    if (player.supportitem == "remote_missile") then
        player.supportitem = nil
        player:setactionslot(4, "")
        player:setweaponhudiconoverride("actionslot4", "")
    end
end)

player:onnotify("menuresponse", function(menu, response)
    if (menus[menu] ~= nil) then
        local item = finditem(response)
        local price = tonumber(game:tablelookupbyrow(csv, item, cols.price))

        if (currentscore < price) then
            return
        end

        local checkres = function(res)
            if (res == nil or res == true) then
                addscore(-price)
                player:playsound("survival_purchase")
            end
        end

        if (menu == "specops_ui_weaponstore" and menus[menu][response] == nil) then
            local res = giveweapon(response)
            checkres(res)
        elseif (menus[menu][response] ~= nil) then
            local res = menus[menu][response](item, response)
            checkres(res)
        end
    end
end)

addweapon("ammo", function()
    local primaries = player:getweaponslistprimaries()
    for i = 1, #primaries do
        player:givemaxammo(primaries[i])
        player:setweaponammoclip(primaries[i], 999)
    end
end)

addequipment("fraggrenade", function(item, name)
    local stock = player:getweaponammostock("fraggrenade")
    if (stock >= 4) then
        return false
    end

    player:setoffhandprimaryclass("fraggrenade")
    player:giveweapon("fraggrenade")
    player:givemaxammo("fraggrenade")
end)

addequipment("flash_grenade", function(item, name)
    local stock = player:getweaponammostock("flash_grenade")
    if (stock >= 4) then
        return false
    end

    player:setoffhandsecondaryclass("flash_grenade")
    player:giveweapon("flash_grenade")
    player:givemaxammo("flash_grenade")
end)

addequipment("claymore", function(item, name)
    local stock = player:getweaponammostock("claymore")
    if (stock >= 10) then
        return false
    end

    player:setactionslot(1, "weapon", "claymore")
    player:giveweapon("claymore")
    player:setweaponammostock("claymore", stock + 5)
end)

addequipment("c4", function(item, name)
    local stock = player:getweaponammostock("c4")
    if (stock >= 10) then
        return false
    end

    player:setactionslot(2, "weapon", "c4")
    player:giveweapon("c4")
    player:setweaponammostock("c4", stock + 5)
end)

addequipment("rpg", function(item, name)
    local stock = player:getweaponammostock("rpg") + player:getweaponammoclip("rpg")
    local hasrpg = player:hasweapon("rpg") == 1

    if (stock >= 4) then
        return false
    end

    giveweapon("rpg", false)

    if (hasrpg) then
        player:setweaponammostock("rpg", stock + 2)
    else
        player:setweaponammostock("rpg", 1)
    end
end)

addequipment("riotshield", function(item, name)
    if (player:hasweapon("riotshield") == 1) then
        return false
    end

    giveweapon("riotshield")
end)

addequipment("sentry", function(item, name)
    if (player.supportitem ~= nil) then
        return false
    end

    if (#level._ID44698 >= 2) then
        return
    end

    player:setweaponhudiconoverride("actionslot4", "dpad_killstreak_sentry_gun_static_frontend")
    player:setactionslot(4, "")
    player.supportitem = "sentry"
end)

addequipment("sentry_gl", function(item, name)
    if (player.supportitem ~= nil) then
        return false
    end

    if (#level._ID44698 >= 2) then
        return
    end

    player:setweaponhudiconoverride("actionslot4", "dpad_killstreak_sentry_gun_static_frontend")
    player:setactionslot(4, "")
    player.supportitem = "sentry_gl"
end)

addequipment("armor", function(item, name)
    if (player.armorlevel ~= nil and player.armorlevel >= 250) then
        return false
    end

    game:luinotify("set_armor_level", "250")
    player.armorlevel = 250
end)

addairsupport("remote_missile", function()
    if (player.supportitem ~= nil) then
        return false
    end

    player.supportitem = "remote_missile"
    if (not gavedetonator) then
        gavedetonator = true
        player._ID29480 = 4
        player:scriptcall("_ID50736", "_ID44738", "remote_missile_detonator")
    else
        player:setactionslot(4, "weapon", "remote_missile_detonator")
        player:setweaponhudiconoverride("actionslot4", "dpad_killstreak_hellfire_missile")
    end
end)

game:detour("_ID50736", "_ID46425", function()
    player._ID29480 = 4
end)

local function setperk(perk, icon)
    if (player.currentperk) then
        player:unsetperk(player.currentperk, true, true)
    end

    player.currentperk = perk
    player:setperk(player.currentperk, true, true)
    game:luinotify("set_perk", icon or perk)
end

addairsupport("specialty_quickdraw", function()
    setperk("specialty_quickdraw", "specialty_quickdraw_frontend")
end)

addairsupport("specialty_bulletaccuracy", function()
    setperk("specialty_bulletaccuracy")
end)

addairsupport("specialty_stalker", function()
    setperk("specialty_stalker", "specialty_stalker_frontend")
end)

addairsupport("specialty_longersprint", function()
    setperk("specialty_longersprint")
end)

addairsupport("specialty_fastreload", function()
    setperk("specialty_fastreload")
end)

game:detour("_ID50736", "_ID54399", function() end)
game:detour("_ID50736", "_ID50531", function() end)
game:detour("_ID50736", "_ID47106", function() end)
game:detour("_ID50736", "_ID50882", function() end)
game:detour("_ID50736", "_ID52102", function() end)
game:detour("_ID50736", "_ID44738", function() end)

player.armorlevel = 0
game:oninterval(function()
    if (previousarmor ~= player.armorlevel) then
        game:luinotify("set_armor_level", tostring(player.armorlevel))
        previousarmor = player.armorlevel
    end
end, 0):endon(level, "special_op_terminated")

player:onnotify("damage", function(damage)
    local var1 = game:int(game:min(100, player.health + damage))

    if (player.armorlevel > 0) then
        local var10 = player.armorlevel - damage
        local var11 = game:int(game:max(0, 0 - var10))

        if (var11 == 0) then
            player.armorlevel = player.armorlevel - damage
            player:setnormalhealth(1)
        else
            local var12 = game:int(game:max(1, game:min(100, var1 - var11))) / 100
            player:setnormalhealth(var12)
            player.armorlevel = 0
        end

        player:notify("health_update")
    end
end)

player:onnotify("unfreezecontrols", function()
    if (flag("slamzoom_finished")) then
        player:freezecontrols(false)
    end
end)

local airdropfx = game:loadfx("fx/smoke/signal_smoke_red_estate")
game:precachemodel("wpn_h1_grenade_smoke_burnt")

player:onnotify("grenade_fire", function(grenade, name)
    if (name == "airdrop_marker") then
        grenade:onnotifyonce("explode", function(origin)
            --[[local helispawner = game:getent("airdrop_heli_spawner", "targetname")
            local spawnpoint = getrandomhelispawnpos()
            helispawner.origin = spawnpoint

            local target = game:getent("airdrop_origin", "targetname")
            target.origin = origin
            local heli = game:scriptcall("_ID42411", "_ID35195", "airdrop_heli_spawner")

            heli:neargoalnotifydist(1000)
            heli:setvehgoalpos(origin + vector:new(0, 0, 1000))
            heli:onnotifyonce("near_goal", function()
                heli:vehicle_setspeedimmediate(40, 0, 20)
                heli:neargoalnotifydist(100)

                heli:onnotifyonce("near_goal", function()
                    local carepackage = game:spawn("script_model", heli.origin + vector:new(0, 0, -50))
                    carepackage:setmodel("com_plasticcase_green_big")
                    carepackage:launch(vector:new(0, 0, 0))
                    carepackage:solid()
                    carepackage:makehard()

                    game:ontimeout(function()
                        heli:vehicle_setspeed(200, 20, 10)
                        heli:setvehgoalpos(spawnpoint)
                        
                    end, 1000)
                end)
            end)

            local model = game:spawn("script_model", origin)
            model.angles = vector:new(90, 0, 0)
            model:setmodel("wpn_h1_grenade_smoke_burnt")
            local fx = game:spawnfx(airdropfx, origin)
            game:triggerfx(fx)
    
            game:ontimeout(function()
                model:delete()
                fx:delete()
            end, 15000)--]]
        end)
    end
end)
