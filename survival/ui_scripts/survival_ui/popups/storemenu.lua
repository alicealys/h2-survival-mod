storemenu = {}

storemenu.new = function(title, data)
    return function()
        local popupwidth = 600
        local popup = LUI.MenuBuilder.BuildRegisteredType("generic_confirmation_popup", {
            popup_title = Engine.Localize(title),
            popup_width = popupwidth,
            popup_title_alignment = LUI.Alignment.Center
        })

        popup:getFirstDescendentById("spacer"):close()

        local descriptiontext = popup:getFirstDescendentById("message_text_id")
        local contentlist = popup:getFirstDescendentById("generic_selectionList_content_id")
        local spacing = contentlist:getAnimationStateInC("default").spacing

        local leveltextstring = Engine.Localize("SO_SURVIVAL_ARMORY_LOCKED_LV", tonumber(game:sharedget("survival_rank")) + 1)
        local _, _, textwidth = GetTextDimensions(leveltextstring, CoD.TextSettings.Font24.Font, CoD.TextSettings.Font24.Height)

        local levelimage = LUI.UIImage.new({
            rightAnchor = true,
            topAnchor = true,
            top = 2,
            right = -textwidth - 28,
            width = 26,
            height = 25,
            material = RegisterMaterial(game:sharedget("survival_rank_icon"))
        })

        local leveltext = LUI.UIText.new({
            leftAnchor = true,
            topAnchor = true,
            top = 7,
            left = 575 - textwidth,
            width = 100,
            height = 20,
            alignment = LUI.Alignment.Left,
            font = CoD.TextSettings.Font24.Font,
        })

        leveltext:setText(leveltextstring)

        popup:getFirstDescendentById("generic_selectionList_window_id"):addElement(levelimage)
        popup:getFirstDescendentById("generic_selectionList_window_id"):addElement(leveltext)

        local scrollinglistproperties = {
            rows = 10
        }

        local listcontainer = nil
        local listindex = 0
        local createlist = function()
            if (listcontainer) then
                contentlist:removeElement(listcontainer)
                listcontainer = nil
            end
            
            listcontainer = LUI.UIElement.new({
                topAnchor = true,
                leftAnchor = true,
                rightAnchor = true,
                height = math.min(#data.entries, scrollinglistproperties.rows) * (33 + spacing)
            })

            contentlist:insertElement(listcontainer, 2)

            local list = LUI.UIVerticalList.build(nil, {
                defaultState = {
                    topAnchor = true,
                    leftAnchor = true,
                    bottomAnchor = true,
                    width = popupwidth - (#data.entries > scrollinglistproperties.rows and 40 or 20),
                    spacing = spacing,
                },
                noWrap = true,
                blockRepeatWrap = true
            })

            collectgarbage("collect")

            listcontainer:addElement(list)
            return list
        end

        local content = createlist()
        local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
    
        local header = LUI.UIElement.new({
            leftAnchor = true,
            topAnchor = true,
            rightAnchor = true,
            height = 30
        })

        local buttons = {}

        local createbutton = function(i, entry, properties)
            local disabled = properties.disabled
            local showlock = properties.showlock

            local button = LUI.MenuBuilder.buildItems({
                type = "UIGenericButton",
                id = "button_id_" .. i,
                disabled = disabled,
                properties = {
                    button_text = Engine.ToUpperCase(Engine.Localize(entry.text)),
                    showLockOnDisable = false,
                    button_action_func = function()
                        local properties = data.getproperties(i)
                        if (properties.canupgrade and not properties.canbuy) then
                            if (entry.upgrade) then
                                entry.upgrade()
                            elseif (data.upgrade) then
                                data.upgrade(entry)
                            end
                        else
                            if (entry.callback) then
                                entry.callback()
                            elseif (data.callback) then
                                data.callback(entry)
                            end
                        end
                    end
                }
            })

            local lock = LUI.UIImage.new({
                topAnchor = false,
                bottomAnchor = false,
                leftAnchor = false,
                rightAnchor = true,
                right = -14,
                width = 16,
                height = 16,
                material = RegisterMaterial(CoD.Material.LockedIcon)
            })

            button.lock = lock
            button:addElement(lock)

            button.lock:registerAnimationState("show", {
                alpha = 1
            })

            button.lock:registerAnimationState("hide", {
                alpha = 0
            })

            if (not properties.locked) then
                button.lock:animateToState("hide")
            end

            local onfocus = button.m_eventHandlers["gain_focus"]
            button:registerEventHandler("gain_focus", function(...)
                onfocus(...)
                descriptiontext:setText(Engine.Localize(entry.description))
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

            pricetext:registerAnimationState("red", {
                color = Colors.s1Hud_bright_red
            })

            pricetext:registerAnimationState("yellow", {
                color = Colors.h2.yellow
            })
    
            pricetext:registerAnimationState("red_focus", {
                color = Colors.s1Hud_bright_red
            })

            pricetext:registerEventHandler("gain_focus", function()
                if (pricetext.red) then
                    pricetext:animateToState("red_focus")
                elseif (pricetext.yellow) then
                    pricetext:animateToState("yellow")
                else
                    pricetext:animateToState("focus")
                end
            end)
            pricetext:registerEventHandler("lose_focus", function()
                if (pricetext.red) then
                    pricetext:animateToState("red")
                elseif (pricetext.yellow) then
                    pricetext:animateToState("yellow")
                else
                    pricetext:animateToState("default")
                end
            end)

            button.pricetext = pricetext
            container:addElement(pricetext)

            return button
        end

        local function updatebutton(index, properties)
            if (buttons[index].button.notbutton) then
                return
            end

            local entry = buttons[index].entry
            local pricetext = buttons[index].button.pricetext

            pricetext:animateToState("default")

            buttons[index].properties = properties
            pricetext.red = false
            pricetext.yellow = false

            if (entry.price) then
                if (not properties.isunlocked) then
                    pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_ARMORY_LOCKED_LV", entry.level)))
                elseif (not properties.canbuy) then
                    if (properties.canupgrade) then
                        pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_ARMORY_UPGRADE")))
                        pricetext:animateToState("yellow")
                        pricetext.yellow = true
                    elseif (properties.unavailable) then
                        pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_ARMORY_NA")))
                    else
                        if (entry.maxcount ~= nil) then
                            pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_ARMORY_FULL")))
                        else
                            pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_ARMORY_OWNED")))
                        end
                    end
                else
                    if (properties.canbuy and not properties.canafford) then
                        pricetext.red = true
                        pricetext:animateToState("red")
                    end
                    pricetext:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_CREDITS", entry.price)))
                end
            end

            if (not properties.isunlocked) then
                buttons[index].button.lock:animateToState("show")
            else
                buttons[index].button.lock:animateToState("hide")
            end

            local element = buttons[index].button
            element.disabled = properties.disabled
            local buttoncontainer = element:getFirstDescendentById("buttonContainer")

            if (properties.disabled) then
                buttoncontainer:processEvent({
                    name = "disable"
                })
            else
                buttoncontainer:processEvent({
                    name = "enable"
                })
            end

            LUI.H2ButtonBackground.LostFocusLocked(buttoncontainer)
        end

        popup:registerEventHandler("check_buttons", function()
            local currentscore = tonumber(Engine.GetDvarInt("ui_current_score"))
            for i = 1, #buttons do
                local properties = data.getproperties(i)
                if (not buttons[i].notbutton) then
                    for k, v in pairs(properties) do
                        if (properties[k] ~= buttons[i].properties[k]) then
                            updatebutton(i, properties)
                            break
                        end
                    end
                end
            end
        end)

        popup:addElement(LUI.UITimer.new(200, "check_buttons"))

        local addbutton = function(i, entry)
            local properties = data.getproperties(i)
            local button = nil
            if (not entry.isseparator) then
                button = createbutton(i, entry, properties)
            else
                button = LUI.UIElement.new({
                    topAnchor = true,
                    leftAnchor = true,
                    width = 100,
                    height = 25
                })

                local text = LUI.UIText.new({
                    bottomAnchor = true,
                    leftAnchor = true,
                    width = 100,
                    color = Colors.window_title_text_color,
                    height = CoD.TextSettings.Font21.Height,
                    font = CoD.TextSettings.Font21.Font
                })

                button:addElement(text)
                text:setText(Engine.Localize(entry.text))
                button.notbutton = true
            end

            content:addElement(button)

            return {
                entry = entry,
                button = button,
                properties = properties
            }
        end
    
        for i = 1, #data.entries do
            local button = addbutton(i, data.entries[i])
            table.insert(buttons, button)
            if (button.entry.price) then
                updatebutton(i, button.properties)
            end
        end
    
        LUI.Options.InitScrollingList(content, nil, scrollinglistproperties)
    
        return popup
    end
end
