pcall(function()
    player:notify("unfreezecontrols")
end)

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

local function createmenu(title, specialty)
    return function()
        local entries = {}

        if (not specialty) then
            table.insert(entries, {
                name = "perks",
                text = "@SO_SURVIVAL_ARMORY_PERKS_TEMP_CAPS",
                description = "@SO_SURVIVAL_ARMORY_PERKS_TEMP_DESC",
                callback = function()
                    LUI.FlowManager.RequestAddMenu(nil, "specops_ui_specialty")
                end
            })
        end

        for i = 0, Engine.TableGetRowCount(csv) do
            local type_ = Engine.TableLookupByRow("sp/survival_armories.csv", i, cols.type)
            local name = Engine.TableLookupByRow("sp/survival_armories.csv", i, cols.name)
    
            local filter = name:match("specialty_")
            if (not specialty) then
                filter = not filter
            end
    
            if (type_ == "airsupport" and filter) then
                table.insert(entries, {
                    isitem = true,
                    name = Engine.TableLookupByRow(csv, i, cols.name),
                    text = Engine.TableLookupByRow(csv, i, cols.namestring),
                    price = tonumber(Engine.TableLookupByRow(csv, i, cols.price)),
                    description = Engine.TableLookupByRow(csv, i, cols.descstring),
                    level = tonumber(Engine.TableLookupByRow(csv, i, cols.level))
                })
            end
        end
    
        local data = {
            entries = entries,
            getproperties = function(i)
                if (not entries[i].isitem) then
                    return {
                        disabled = false,
                        showlock = false,
                        isunlocked = true,
                        canafford = true,
                        canbuy = true,
                    }
                end

                local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
                local currentlevel = tonumber(game:sharedget("survival_rank")) or 0
                
                local price = entries[i].price
                local name = entries[i].name
                local canbuy = game:sharedget("can_buy_" .. name) == "1"
                local canafford = currentscore >= price
                local isunlocked = currentlevel >= entries[i].level

                return {
                    disabled = not canafford or not canbuy or not isunlocked,
                    showlock = not isunlocked,
                    isunlocked = isunlocked,
                    canbuy = canbuy,
                    canafford = canafford
                }
            end,
            callback = function(entry)
                player:notify("menuresponse", "specops_ui_airsupport", entry.name)
                LUI.FlowManager.RequestLeaveMenu(nil, "specops_ui_specialty")
                LUI.FlowManager.RequestLeaveMenu(nil, "specops_ui_airsupport")
            end
        }
    
        local popup = storemenu.new(title, data)()

        if (not specialty) then
            popup:registerEventHandler("menu_close", function()
                player:notify("unfreezecontrols")
            end)
        end
    
        return popup
    end
end

LUI.MenuBuilder.registerPopupType("survival_armory_airsupport", createmenu("@SO_SURVIVAL_ARMORY_AIRSUPPORT", false))
LUI.MenuBuilder.registerPopupType("specops_ui_specialty", createmenu("@SO_SURVIVAL_ARMORY_PERKS_CAPS", true))
