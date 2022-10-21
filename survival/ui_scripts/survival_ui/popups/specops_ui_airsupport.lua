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

local function specialty()
    local rows = {}

    for i = 0, Engine.TableGetRowCount(csv) do
        local type_ = Engine.TableLookupByRow("sp/survival_armories.csv", i, cols.type)
        local name = Engine.TableLookupByRow("sp/survival_armories.csv", i, cols.name)
        if (type_ == "airsupport" and name:match("specialty_")) then
            table.insert(rows, i)
        end
    end

    local popupwidth = 600
    local title = "@SO_SURVIVAL_ARMORY_PERKS_CAPS"
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
        currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
        for i = 1, #buttons do
            local canbuy = game:sharedget("has_specialty_" .. buttons[i].name) ~= "1"
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
        local canbuy = game:sharedget("has_specialty_" .. name) ~= "1"
        local canafford = currentscore >= price

        local button = LUI.MenuBuilder.buildItems({
            type = "UIGenericButton",
            id = "button_id_" .. row,
            disabled = not canafford or not canbuy,
            properties = {
                button_text = Engine.ToUpperCase(Engine.Localize(text)),
                showLockOnDisable = not canafford and canbuy,
                button_action_func = function()
                    player:notify("menuresponse", "specops_ui_airsupport", name)
                    LUI.FlowManager.RequestLeaveMenu(nil, "specops_ui_specialty")
                    LUI.FlowManager.RequestLeaveMenu(nil, "specops_ui_airsupport")
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

    updatebuttons()

    return popup
end

local function airsupport()
    local rows = {}

    for i = 0, Engine.TableGetRowCount(csv) do
        local type_ = Engine.TableLookupByRow("sp/survival_armories.csv", i, cols.type)
        local name = Engine.TableLookupByRow("sp/survival_armories.csv", i, cols.name)
        if (type_ == "airsupport" and not name:match("specialty_")) then
            table.insert(rows, i)
        end
    end

    local popupwidth = 600
    local title = "@SO_SURVIVAL_ARMORY_AIRSUPPORT"
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

    local buttons = {}

    local addbutton = function(row)
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
                    player:notify("menuresponse", "specops_ui_airsupport", name)
                    LUI.FlowManager.RequestLeaveMenu(nil, "specops_ui_airsupport")
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

    local perkbutton = LUI.MenuBuilder.buildItems({
        type = "UIGenericButton",
        id = "button_id_specialties",
        properties = {
            button_text = Engine.ToUpperCase(Engine.Localize("SO_SURVIVAL_ARMORY_PERKS_TEMP_CAPS")),
            button_action_func = function()
                LUI.FlowManager.RequestAddMenu(nil, "specops_ui_specialty")
            end
        }
    })

    local perkbuttononfocus = perkbutton.m_eventHandlers["gain_focus"]
    perkbutton:registerEventHandler("gain_focus", function(...)
        perkbuttononfocus(...)
        descriptiontext:setText(Engine.Localize("SO_SURVIVAL_ARMORY_PERKS_TEMP_DESC"))
    end)

    content:insertElement(perkbutton, 2)

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

        perkbutton:close()
        content:insertElement(perkbutton, 2)

        header:close()
        content:insertElement(header, 2)
    end

    popup:registerEventHandler("check_buttons", function()
        if (LUI.FlowManager.IsMenuTopmost(Engine.GetLuiRoot(), "specops_ui_airsupport")) then
            local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
            for i = 1, #buttons do
                local canbuy = game:sharedget("can_buy_" .. buttons[i].name) == "1"
                local canafford = currentscore >= buttons[i].price
    
                if (canbuy ~= buttons[i].canbuy or canafford ~= buttons[i].canafford) then
                    updatebuttons()
                end
            end
        end
    end)

    popup:addElement(LUI.UITimer.new(100, "check_buttons"))

    popup:registerEventHandler("menu_close", function()
        player:notify("unfreezecontrols")
    end)

    content:insertElement(header, 2)

    return popup
end

LUI.MenuBuilder.registerPopupType("specops_ui_airsupport", airsupport)
LUI.MenuBuilder.registerPopupType("specops_ui_specialty", specialty)
