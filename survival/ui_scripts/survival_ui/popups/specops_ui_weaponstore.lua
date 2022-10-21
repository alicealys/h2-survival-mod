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

local function playerhasweapon(name)
    return game:sharedget("player_primary") == name or game:sharedget("player_secondary") == name
end

local function createweaponstore(title, targetclass)
    return function()
        local rows = {}

        for i = 0, Engine.TableGetRowCount(csv) do
            local type_ = Engine.TableLookupByRow(csv, i, cols.type)
            local class = Engine.TableLookupByRow(csv, i, cols.weaponclass)
            if (targetclass == class) then
                table.insert(rows, i)
            end
        end

        local popupwidth = 600
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
            local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
            for i = 1, #buttons do
                local hasweapon = playerhasweapon(buttons[i].name)
                local canafford = currentscore >= buttons[i].price

                if (hasweapon ~= buttons[i].hasweapon or canafford ~= buttons[i].canafford) then
                    updatebuttons()
                end
            end
        end)

        popup:addElement(LUI.UITimer.new(100, "check_buttons"))

        addbutton = function(row)
            local name = Engine.TableLookupByRow(csv, row, cols.name)
            local text = Engine.TableLookupByRow(csv, row, cols.namestring)
            local price = tonumber(Engine.TableLookupByRow(csv, row, cols.price))
            local canafford = currentscore >= price
            local hasweapon = playerhasweapon(name)

            local button = LUI.MenuBuilder.buildItems({
                type = "UIGenericButton",
                id = "button_id_" .. row,
                disabled = hasweapon or not canafford,
                properties = {
                    button_text = Engine.ToUpperCase(Engine.Localize(text)),
                    showLockOnDisable = not hasweapon and not canafford,
                    button_action_func = function()
                        player:notify("menuresponse", "specops_ui_weaponstore", name)
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
    
            if (hasweapon) then
                pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_ARMORY_OWNED")))
            else
                pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_CREDITS", price)))
            end

            container:addElement(pricetext)
        
            content:insertElement(button, 2)

            return {
                name = name,
                text = text,
                price = price,
                pricetext = pricetext,
                button = button,
                hasweapon = hasweapon,
                canafford = canafford
            }
        end
    
        for i = #rows, 1, -1 do
            table.insert(buttons, addbutton(rows[i]))
        end
    
        content:insertElement(header, 2)
    
        return popup
    end
end

local function weaponstore()
    local popupwidth = 600
    local title = "@SO_SURVIVAL_ARMORY_WEAPON"
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

    popup:registerEventHandler("menu_close", function()
        player:notify("unfreezecontrols")
    end)

    local addbutton = function(name, price, text, description, callback)
        local canafford = true
        local canbuy = true
        if (price) then
            canbuy = game:sharedget("can_buy_ammo") == "1"
            canafford = currentscore >= price
        end
        local button = LUI.MenuBuilder.buildItems({
            type = "UIGenericButton",
            id = "button_id_" .. name,
            disabled = price ~= nil and (not canafford or not canbuy) or false,
            properties = {
                button_text = Engine.ToUpperCase(Engine.Localize(text)),
                showLockOnDisable = not canafford,
                button_action_func = function()
                    if (type(callback) == "function") then
                        callback()
                    else
                        LUI.FlowManager.RequestAddMenu(nil, callback)
                    end
                end
            }
        })

        local onfocus = button.m_eventHandlers["gain_focus"]
        button:registerEventHandler("gain_focus", function(...)
            onfocus(...)
            descriptiontext:setText(Engine.Localize(description))
        end)

        local container = button:getFirstDescendentById("button")
        local textlabel = button:getFirstDescendentById("text_label")
        local state = textlabel:getAnimationStateInC("default")

        if (price ~= nil) then
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
    
            if (canbuy) then
                pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_CREDITS", price)))
            else
                pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_ARMORY_FULL")))
            end
    
            container:addElement(pricetext)
        end

        content:insertElement(button, 2)

        return {
            button = button,
            price = price,
            canbuy = canbuy,
            canafford = canafford
        }
    end

    addbutton("shotgun", nil, "@SO_SURVIVAL_ARMORY_WEAPON_SG_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_shotgun")
    addbutton("sniper", nil, "@SO_SURVIVAL_ARMORY_WEAPON_SR_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_sniper")
    addbutton("lmg", nil, "@SO_SURVIVAL_ARMORY_WEAPON_LMG_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_lmg")
    addbutton("smg", nil, "@SO_SURVIVAL_ARMORY_WEAPON_SMG_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_smg")
    addbutton("assaultrifle", nil, "@SO_SURVIVAL_ARMORY_WEAPON_ASR_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_assaultrifle")
    addbutton("machinepistol", nil, "@SO_SURVIVAL_ARMORY_WEAPON_MPISTOL_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_machinepistol")
    addbutton("pistol", nil, "@SO_SURVIVAL_ARMORY_WEAPON_PISTOL_GROUP", "@NULL_EMPTY", "specops_ui_weaponstore_pistol")

    local ammobutton = addbutton("ammo", 750, "@SO_SURVIVAL_AMMO_REFILL", "@SO_SURVIVAL_AMMO_REFILL_DESC", function()
        player:notify("menuresponse", "specops_ui_weaponstore", "ammo")
    end)

    popup:registerEventHandler("check_ammo_button", function()
        if (LUI.FlowManager.IsMenuTopmost(Engine.GetLuiRoot(), "specops_ui_weaponstore")) then
            currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
            local canafford = currentscore >= ammobutton.price
            local canbuy = game:sharedget("can_buy_ammo") == "1"
            if (canbuy ~= ammobutton.canbuy or canafford ~= ammobutton.canafford) then
                ammobutton.button:close()
                header:close()
    
                ammobutton = addbutton("ammo", 750, "@SO_SURVIVAL_AMMO_REFILL", "@SO_SURVIVAL_AMMO_REFILL_DESC", function()
                    player:notify("menuresponse", "specops_ui_weaponstore", "ammo")
                end)
    
                content:insertElement(header, 2)
            end
        end
    end)

    popup:addElement(LUI.UITimer.new(100, "check_ammo_button"))

    content:insertElement(header, 2)

    return popup
end

LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore", weaponstore)
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_pistol", createweaponstore("@SO_SURVIVAL_ARMORY_WEAPON_PISTOL_GROUP", "pistol"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_machinepistol", createweaponstore("@SO_SURVIVAL_ARMORY_WEAPON_MPISTOL_GROUP", "machinepistol"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_assaultrifle", createweaponstore("@SO_SURVIVAL_ARMORY_WEAPON_ASR_GROUP", "assaultrifle"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_smg", createweaponstore("@SO_SURVIVAL_ARMORY_WEAPON_SMG_GROUP", "smg"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_lmg", createweaponstore("@SO_SURVIVAL_ARMORY_WEAPON_LMG_GROUP", "lmg"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_sniper", createweaponstore("@SO_SURVIVAL_ARMORY_WEAPON_SR_GROUP", "sniper"))
LUI.MenuBuilder.registerPopupType("specops_ui_weaponstore_shotgun", createweaponstore("@SO_SURVIVAL_ARMORY_WEAPON_SG_GROUP", "shotgun"))
