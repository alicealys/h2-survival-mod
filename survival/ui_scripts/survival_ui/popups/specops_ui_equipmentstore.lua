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

local function equipmentstore()
    local rows = {}

    for i = 0, Engine.TableGetRowCount(csv) do
        local type_ = Engine.TableLookupByRow(csv, i, cols.type)
        if (type_ == "equipment") then
            table.insert(rows, i)
        end
    end

    local popupwidth = 600
    local title = "@SO_SURVIVAL_ARMORY_EQUIPMENT"
	local popup = LUI.MenuBuilder.BuildRegisteredType("generic_confirmation_popup", {
		popup_title = Engine.Localize(title),
        popup_width = popupwidth,
        popup_title_alignment = LUI.Alignment.Center
	})

    popup:getFirstDescendentById("spacer"):close()

    local descriptiontext = popup:getFirstDescendentById("message_text_id")
    local content = popup:getFirstDescendentById("generic_selectionList_content_id")
    local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))

    local header = LUI.UIElement.new({
        leftAnchor = true,
        topAnchor = true,
        rightAnchor = true,
        height = 30
    })

    local addbutton = nil
    local buttons = {}

    local function updatebuttons()
        popup:registerEventHandler("update_buttons", nil)

        currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))

        for i = 1, #buttons do
            buttons[i].button:close()
        end

        buttons = {}
        for i = #rows, 1, -1 do
            table.insert(buttons, addbutton(rows[i]))
        end

        header:close()
        content:insertElement(header, 2)
    end

    popup:registerEventHandler("check_buttons", function()
        local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
        for i = 1, #buttons do
            local canbuy = game:sharedget("can_buy_" .. buttons[i].name) == "1"
            local canafford = currentscore >= buttons[i].price

            if (canbuy ~= buttons[i].canbuy or canafford ~= buttons[i].canafford) then
                updatebuttons()
            end
        end
    end)

    popup:addElement(LUI.UITimer.new(100, "check_buttons"))

    addbutton = function(row)
        local name = Engine.TableLookupByRow(csv, row, cols.name)
        local text = Engine.TableLookupByRow(csv, row, cols.namestring)
        local maxcount = tonumber(Engine.TableLookupByRow(csv, row, cols.maxcount))
        local price = tonumber(Engine.TableLookupByRow(csv, row, cols.price))
        local canbuy = game:sharedget("can_buy_" .. name) == "1"
        local canafford = currentscore >= price

        local button = LUI.MenuBuilder.buildItems({
            type = "UIGenericButton",
            id = "button_id_" .. row,
            disabled = not canafford or not canbuy,
            properties = {
                button_text = Engine.ToUpperCase(Engine.Localize(text)),
                showLockOnDisable = not canafford and canbuy,
                button_action_func = function()
                    if ((name == "rpg" or name == "riotshield") and (not playerhasweapon(name) and not playerhasweapon("none"))) then
                        selecteditem = name
                        LUI.FlowManager.RequestPopupMenu(nil, "specops_ui_equipmentstore_confirm")
                    else
                        player:notify("menuresponse", "specops_ui_equipmentstore", name)
                    end
                end
            }
        })

        local onfocus = button.m_eventHandlers["gain_focus"]
        button:registerEventHandler("gain_focus", function(...)
            onfocus(...)
            local description = Engine.TableLookupByRow(csv, row, cols.descstring)
            descriptiontext:setText(Engine.Localize(description))
        end)

        local container = button:getFirstDescendentById("button")
        local textlabel = button:getFirstDescendentById("text_label")
        local state = textlabel:getAnimationStateInC("default")

        local pricetext = LUI.UIText.new({
            rightAnchor = true,
            color = GenericButtonSettings.Common.text_default_color,
            top = state.top,
            right = -state.left - 50,
            bottom = state.bottom,
            width = 500,
            alignment = LUI.Alignment.Right,
            font = CoD.TextSettings.TitleFontTiny.Font,
        })

        pricetext:registerAnimationState("focus", {
            color = GenericButtonSettings.Common.text_focus_color
        })

        pricetext:registerEventHandler("gain_focus", MBh.AnimateToState("focus"))
        pricetext:registerEventHandler("lose_focus", MBh.AnimateToState("default"))

        if (not canbuy) then
            if (maxcount > 1) then
                pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_ARMORY_FULL")))
            else
                pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_ARMORY_OWNED")))
            end
        else
            pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_CREDITS", price)))
        end

        container:addElement(pricetext)
    
        content:insertElement(button, 2)

        return {
            name = name,
            button = button,
            canbuy = canbuy,
            price = price,
            canafford = canafford
        }
    end

    for i = #rows, 1, -1 do
        table.insert(buttons, addbutton(rows[i]))
    end

    popup:registerEventHandler("menu_close", function()
        player:notify("unfreezecontrols")
    end)

    content:insertElement(header, 2)

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

LUI.MenuBuilder.registerPopupType("specops_ui_equipmentstore", equipmentstore)
LUI.MenuBuilder.registerPopupType("specops_ui_equipmentstore_confirm", equipmentstoreconfirm)
