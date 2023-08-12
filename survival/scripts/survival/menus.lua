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
menus["specops_ui_upgradestore"] = {}

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

    local checkitem = function(armory, item)
        local cangive = player:scriptcall("maps/_so_survival_armory", "get_func_can_give", armory, item)
        local res = cangive(player, item)
        game:sharedset("can_buy_" .. item, res == 1 and "1" or "0")
    end

    checkitem("weapon", "ammo")
    checkitem("equipment", "fraggrenade")
    checkitem("equipment", "flash_grenade")
    checkitem("equipment", "claymore")
    checkitem("equipment", "rpg_survival")
    checkitem("equipment", "c4")
    checkitem("equipment", "iw5_riotshield_so")
    checkitem("equipment", "sentry")
    checkitem("equipment", "sentry_gl")
    checkitem("equipment", "remote_missile")
    checkitem("equipment", "precision_airstrike")
    checkitem("equipment", "laststand")
    checkitem("equipment", "armor")

    local perks = {
        "specialty_quickdraw",
        "specialty_bulletaccuracy",
        "specialty_stalker",
        "specialty_longersprint",
        "specialty_fastreload",
    }

    for i = 1, #perks do
        checkitem("airsupport", perks[i])
    end

    checkitem("airsupport", "friendly_support_delta")
    checkitem("airsupport", "friendly_support_riotshield")
end, 0):endon(level, "special_op_terminated")

level:onnotify("player_fired_remote_missile", function()
    if (player.supportitem == "remote_missile") then
        player.supportitem = nil
        player:setactionslot(4, "")
        player:setweaponhudiconoverride("actionslot4", "")
    end
end)

local function stripattachments(name)
    if (name == nil) then
        return name
    end

    local newname = ""
    for i = 1, #name do
        if (name:sub(i, i + 2) == "_mp") then
            return newname .. "_mp"
        end

        newname = newname .. name:sub(i, i)
    end

    return newname
end

player:onnotify("menuresponse", function(menu, response, extra)
    if (menus[menu] ~= nil) then
        local item = finditem(response)
        local price = tonumber(game:tablelookupbyrow(csv, item, cols.price))

        if (player.survival_credit < price) then
            return
        end

        local cangive = function(armory, response)
            local func = player:scriptcall("maps/_so_survival_armory", "get_func_can_give", armory, response)
            return func(player, response)
        end

        local giveitem = function(armory, response)
            local func = player:scriptcall("maps/_so_survival_armory", "get_func_give", armory, response)
            func(player, response)
            addscore(-price)
            player:playsound("survival_purchase")
        end

        local armorytypes = {
            ["specops_ui_weaponstore"] = "weapon",
            ["specops_ui_upgradestore"] = "weaponupgrade",
            ["specops_ui_equipmentstore"] = "equipment",
            ["specops_ui_airsupport"] = "airsupport",
        }

        local armory = armorytypes[menu]

        if (armory == "weaponupgrade" and extra ~= nil) then
            player.selected_weapon = game:sharedget("selected_weapon")
        end

        if (cangive(armory, response) == 0) then
            return
        end

        if (armory) then
            giveitem(armory, response)
        end
    end
end)

game:detour("_ID50736", "_ID46425", function()
    player._ID29480 = 4
end)

game:detour("_ID50736", "_ID54399", function() end)
game:detour("_ID50736", "_ID50531", function() end)
game:detour("_ID50736", "_ID47106", function() end)
game:detour("_ID50736", "_ID50882", function() end)
game:detour("_ID50736", "_ID52102", function() end)
game:detour("_ID50736", "_ID44738", function() end)

player:onnotify("unfreezecontrols", function()
    if (flag("slamzoom_finished")) then
        player:freezecontrols(false)
    end
end)

game:precachemodel("wpn_h1_grenade_smoke_burnt")
