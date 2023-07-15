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
    maxcount = 10,
    weaponclass = 11
}

local csv = "sp/survival_armories.csv"

local function playerhasweapon(weap)
    return game:sharedget("player_primary") == weap or game:sharedget("player_secondary") == weap
end

local function createequipmentstore()
    local entries = {}

    for i = 0, Engine.TableGetRowCount(csv) do
        local type_ = Engine.TableLookupByRow(csv, i, cols.type)
        if (type_ == "equipment") then
            local name = Engine.TableLookupByRow(csv, i, cols.name)
            local text = Engine.TableLookupByRow(csv, i, cols.namestring)
            local maxcount = tonumber(Engine.TableLookupByRow(csv, i, cols.maxcount))
            local price = tonumber(Engine.TableLookupByRow(csv, i, cols.price))
            local description = Engine.TableLookupByRow(csv, i, cols.descstring)
            local level = 0

            table.insert(entries, {
                row = i,
                name = name,
                text = text,
                price = price,
                maxcount = maxcount,
                description = description,
                level = level
            })
        end
    end
    
    local data = {
        entries = entries,
        getproperties = function(i)
            local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
            local currentlevel = tonumber(game:sharedget("survival_rank")) or 0

            local price = entries[i].price
            local canbuy = game:sharedget("can_buy_" .. entries[i].name) == "1"
            local canafford = currentscore >= price
            local isunlocked = currentlevel >= entries[i].level

            return {
                disabled = not canafford or not canbuy or not isunlocked,
                showlock = not isunlocked,
                isunlocked = isunlocked,
                canbuy = canbuy,
                canafford = canafford,
            }
        end,
        callback = function(entry)
            if ((entry.name == "rpg" or entry.name == "riotshield") and (not playerhasweapon(entry.name) and not playerhasweapon("none"))) then
                selecteditem = entry.name
                LUI.FlowManager.RequestPopupMenu(nil, "specops_ui_equipmentstore_confirm")
            else
                player:notify("menuresponse", "specops_ui_equipmentstore", entry.name)
            end
        end
    }

    local popup = storemenu.new("@SO_SURVIVAL_ARMORY_EQUIPMENT", data)()

    popup:registerEventHandler("menu_close", function()
        player:notify("unfreezecontrols")
    end)

    return popup
end

local function equipmentstoreconfirm()
    return LUI.MenuBuilder.BuildRegisteredType("generic_yesno_popup", {
		popup_title = Engine.Localize("@MENU_WARNING"),
		message_text = Engine.Localize("@SO_SURVIVAL_REPLACE_WEAPON_WARNING"),
		yes_action = function()
            player:notify("menuresponse", "specops_ui_equipmentstore", selecteditem)
        end,
		yes_text = Engine.Localize("@LUA_MENU_CONTINUE"),
		no_text = Engine.Localize("@LUA_MENU_CANCEL")
	})
end

LUI.MenuBuilder.registerPopupType("survival_armory_equipment", createequipmentstore)
LUI.MenuBuilder.registerPopupType("specops_ui_equipmentstore_confirm", equipmentstoreconfirm)
