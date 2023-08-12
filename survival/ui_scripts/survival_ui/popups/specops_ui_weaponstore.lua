require("LUI.LUIScrollingVerticalList")

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

function splitstring(input, sep)
    if (sep == nil) then
        sep = "%s"
    end

    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end

    return t
end

local function stripattachments(name)
    if (name == nil or name == "") then
        return name
    end

    local split = splitstring(name, "_")
    if (#split < 3) then
        return name
    end

    return string.format("%s_%s_%s", split[1], split[2], split[3])
end

local function getbaseattachment(weapon, attachment)
    local attachcols = {
        weapon = 0,
        base = 1,
        override = 2
    }
    
    local attachoverridecsv = "mp/attachoverrides.csv"
    local rows = Engine.TableGetRowCount(attachoverridecsv)

    for i = 0, rows - 1 do
        local ovverideweapon = Engine.TableLookupByRow(attachoverridecsv, i, attachcols.weapon)
        local override = Engine.TableLookupByRow(attachoverridecsv, i, attachcols.override)

        if (override == attachment and ovverideweapon == weapon) then
            return Engine.TableLookupByRow(attachoverridecsv, i, attachcols.base)
        end
    end

    return attachment
end

local function maptable(t, f)
    local nt = {}
    for k, v in pairs(t) do
        nt[k] = f(t[k])
    end
    return nt
end

local function getattachments(weapon)
    local attachments = {}
    local baseweap = stripattachments(weapon)
    local attachmentsstring = weapon:sub(#baseweap + 2, #weapon)

    local mapfunc = function(attachment)
        return getbaseattachment(baseweap, attachment)
    end

    return maptable(splitstring(attachmentsstring, "_"), mapfunc)
end

local function playerhasweapon(name)
    return stripattachments(game:sharedget("player_primary")) == name or stripattachments(game:sharedget("player_secondary")) == name
end

local function getweapon(name)
    if (stripattachments(game:sharedget("player_primary")) == name) then
        return game:sharedget("player_primary")
    end

    if (stripattachments(game:sharedget("player_secondary")) == name) then
        return game:sharedget("player_secondary")
    end
end

local function attachmentavailable(weapon, attachment)
    for i = 0, Engine.TableGetRowCount(csv) do
        local type_ = Engine.TableLookupByRow(csv, i, cols.type)
        local name = Engine.TableLookupByRow(csv, i, cols.name)
        local attachmentsstring = Engine.TableLookupByRow(csv, i, cols.attachments)
        if (type_ == "weapon" and name == weapon) then
            local attachments = splitstring(attachmentsstring, " ")
            for o = 1, #attachments do
                if (attachments[o] == attachment) then
                    return true
                end
            end
        end
    end

    return false
end

local arrayjoin = function(t, sep)
    local buffer = ""
    for i = 1, #t do
        buffer = buffer .. t[i] .. sep
    end
    return buffer
end

local function getavailableattachments(weapon)
    for i = 0, Engine.TableGetRowCount(csv) do
        local type_ = Engine.TableLookupByRow(csv, i, cols.type)
        local name = Engine.TableLookupByRow(csv, i, cols.name)
        local attachmentsstring = Engine.TableLookupByRow(csv, i, cols.attachments)
        if (type_ == "weapon" and name == weapon) then
            local available = splitstring(attachmentsstring, " ")
            local current = getweapon(weapon)
            if (current == nil) then
                return available
            end

            local currentattachments = getattachments(current)
            local actuallyavailable = {}

            for o = 1, #available do
                local found = false
                for k = 1, #currentattachments do
                    if (currentattachments[k] == available[o]) then
                        found = true
                    end
                end

                if (not found) then
                    table.insert(actuallyavailable, available[o])
                end
            end

            return actuallyavailable
        end
    end

    return {}
end

local function hasattachment(weapon, attachment)
    local primary = game:sharedget("player_primary")
    local primary_ = stripattachments(game:sharedget("player_primary"))
    local secondary = game:sharedget("player_secondary")
    local secondary_ = stripattachments(game:sharedget("player_secondary"))

    local currentweapon = nil
    if (weapon == primary_) then
        currentweapon = primary
    elseif (weapon == secondary_) then
        currentweapon = secondary
    else
        return false
    end

    local attachments = getattachments(currentweapon)
    for i = 1, #attachments do
        if (attachments[i] == attachment) then
            return true
        end
    end

    return false
end

local function createweaponclassstore(title, targetclass)
    local entries = {}

    for i = 0, Engine.TableGetRowCount(csv) do
        local type_ = Engine.TableLookupByRow(csv, i, cols.type)
        local class = Engine.TableLookupByRow(csv, i, cols.weaponclass)

        if (targetclass == class) then
            local name = Engine.TableLookupByRow(csv, i, cols.name)
            local text = Engine.TableLookupByRow(csv, i, cols.namestring)
            local price = tonumber(Engine.TableLookupByRow(csv, i, cols.price))
            local description = Engine.TableLookupByRow(csv, i, cols.descstring)
            local level = tonumber(Engine.TableLookupByRow(csv, i, cols.level))

            table.insert(entries, {
                row = i,
                name = name,
                text = text,
                price = price,
                level = level,
                description = description
            })
        end
    end

    local data = {
        entries = entries,
        getproperties = function(i)
            local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
            local currentlevel = tonumber(game:sharedget("survival_rank")) or 0
            local price = tonumber(Engine.TableLookupByRow(csv, entries[i].row, cols.price))
            local canafford = currentscore >= price
            local hasweapon = playerhasweapon(entries[i].name)
            local isunlocked = currentlevel >= entries[i].level
            local canupgrade = #getavailableattachments(entries[i].name) > 0

            return {
                disabled = (not canupgrade and hasweapon) or (not canafford and (not hasweapon or not canupgrade)) or not isunlocked,
                showlock = not isunlocked,
                isunlocked = isunlocked,
                canafford = canafford,
                canbuy = not hasweapon,
                canupgrade = canupgrade,
            }
        end,
        upgrade = function(entry)
            game:sharedset("selected_weapon", entry.name)
            LUI.FlowManager.RequestAddMenu(nil, "specops_ui_upgradestore", nil, nil, nil, {
                weapon = entry.name,
                text = entry.text
            })
        end,
        callback = function(entry)
            player:notify("menuresponse", "specops_ui_weaponstore", entry.name)
        end
    }

    return storemenu.new(title, data)
end

local function createweaponstore()
    local entries = {
        {
            name = "ammo",
            text = "@SO_SURVIVAL_AMMO_REFILL",
            price = 750,
            description = "@SO_SURVIVAL_AMMO_REFILL_DESC",
            isitem = true,
            maxcount = 1,
        }
    }

    local addmenuentry = function(name, title, description, menu)
        table.insert(entries, {
            name = name,
            title = title,
            text = title,
            description = description,
            menu = menu,
            getproperties = function()
                return {
                    disabled = false,
                    showlock = false,
                    canbuy = true,
                    canafford = true,
                    isunlocked = true,
                }
            end
        })
    end

    addmenuentry("shotgun", "@SO_SURVIVAL_ARMORY_WEAPON_SG_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_shotgun")
    addmenuentry("sniper", "@SO_SURVIVAL_ARMORY_WEAPON_SR_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_sniper")
    addmenuentry("lmg", "@SO_SURVIVAL_ARMORY_WEAPON_LMG_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_lmg")
    addmenuentry("smg", "@SO_SURVIVAL_ARMORY_WEAPON_SMG_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_smg")
    addmenuentry("assaultrifle", "@SO_SURVIVAL_ARMORY_WEAPON_ASR_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_assaultrifle")
    addmenuentry("machinepistol", "@SO_SURVIVAL_ARMORY_WEAPON_MPISTOL_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_machinepistol")
    addmenuentry("pistol", "@SO_SURVIVAL_ARMORY_WEAPON_PISTOL_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_pistol")

    local data = {
        entries = entries,
        getproperties = function(i)
            local entry = entries[i]
            if (entry.getproperties) then
                return entry.getproperties()
            end

            local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
            local canbuy = game:sharedget("can_buy_ammo") == "1"
            local canafford = currentscore >= entry.price
            
            return {
                disabled = entry.price ~= nil and (not canafford or not canbuy) or false,
                showlock = not canafford,
                canbuy = canbuy,
                canafford = canafford,
                isunlocked = true,
            } 
        end,
        callback = function(entry)
            if (entry.isitem) then
                player:notify("menuresponse", "specops_ui_weaponstore", entry.name)
            else
                LUI.FlowManager.RequestAddMenu(nil, entry.menu)
            end
        end
    }

    local popup = storemenu.new("@SO_SURVIVAL_ARMORY_WEAPON", data)()

    popup:registerEventHandler("menu_close", function()
        player:notify("unfreezecontrols")
    end)

    return popup
end

local function upgradestore(a, args)
    local entries = {}

    local addtype = function(itemtype) 
        for i = 0, Engine.TableGetRowCount(csv) do
            local type_ = Engine.TableLookupByRow(csv, i, cols.type)
            local class = Engine.TableLookupByRow(csv, i, cols.weaponclass)
            local price = tonumber(Engine.TableLookupByRow(csv, i, cols.price))
    
            if (type_ == itemtype and price ~= 0) then
                local name = Engine.TableLookupByRow(csv, i, cols.name)
                local text = Engine.TableLookupByRow(csv, i, cols.namestring)
                local description = Engine.TableLookupByRow(csv, i, cols.descstring)
                local level = tonumber(Engine.TableLookupByRow(csv, i, cols.level))
    
                table.insert(entries, {
                    row = i,
                    name = name,
                    text = text,
                    price = price,
                    level = level,
                    description = description
                })
            end
        end
    end

    local addseparator = function(text)
        table.insert(entries, {
            isseparator = true,
            text = text
        })
    end

    addseparator("SO_SURVIVAL_ATTACHMENT_SCOPE")
    addtype("scope")
    addseparator("SO_SURVIVAL_ATTACHMENT_UNDERBARREL")
    addtype("main")

    local data = {
        entries = entries,
        getproperties = function(i)
            local entry = entries[i]
            if (entry.getproperties) then
                return entry.getproperties()
            end

            if (entry.isseparator) then
                return {}
            end

            local currentlevel = tonumber(game:sharedget("survival_rank")) or 0
            local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
            local canafford = currentscore >= entry.price
            local canbuy = not hasattachment(args.weapon, entry.name)
            local isunlocked = currentlevel >= entry.level
            local available = attachmentavailable(args.weapon, entry.name)

            return {
                disabled = (not available) or (not canbuy) or not canafford or not isunlocked,
                showlock = not isunlocked,
                unavailable = not available,
                isunlocked = isunlocked,
                canbuy = canbuy and available,
                canafford = canafford,
            } 
        end,
        callback = function(entry)
            player:notify("menuresponse", "specops_ui_upgradestore", entry.name, args.weapon)
        end
    }

    local title = string.el(Engine.Localize(args.text) .. " " .. Engine.Localize("@SO_SURVIVAL_ARMORY_WEAPON_ATTACHMENT"))
    local popup = storemenu.new(title, data)()

    popup:registerEventHandler("menu_close", function()
        player:notify("unfreezecontrols")
    end)

    return popup
end

LUI.MenuBuilder.registerPopupType("survival_armory_weapon", createweaponstore)
LUI.MenuBuilder.registerPopupType("specops_ui_upgradestore", upgradestore)
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_pistol", createweaponclassstore("@SO_SURVIVAL_ARMORY_WEAPON_PISTOL_GROUP", "pistol"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_machinepistol", createweaponclassstore("@SO_SURVIVAL_ARMORY_WEAPON_MPISTOL_GROUP", "machinepistol"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_assaultrifle", createweaponclassstore("@SO_SURVIVAL_ARMORY_WEAPON_ASR_GROUP", "assaultrifle"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_smg", createweaponclassstore("@SO_SURVIVAL_ARMORY_WEAPON_SMG_GROUP", "smg"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_lmg", createweaponclassstore("@SO_SURVIVAL_ARMORY_WEAPON_LMG_GROUP", "lmg"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_sniper", createweaponclassstore("@SO_SURVIVAL_ARMORY_WEAPON_SR_GROUP", "sniper"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_shotgun", createweaponclassstore("@SO_SURVIVAL_ARMORY_WEAPON_SG_GROUP", "shotgun"))
