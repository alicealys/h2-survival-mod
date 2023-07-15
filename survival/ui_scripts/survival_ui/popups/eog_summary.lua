local current = "0"

function formattime(msec)
    return string.format("%d:%02d.%02d", math.floor(msec / 1000 / 60), math.floor(msec / 1000) % 60, (msec % 1000) / 10)
end

function eogsummary()
    Engine.PlaySound("so_ingame_summary")

    local success = false
    local wave = tonumber(Engine.GetDvarString("ui_current_wave")) or 0

    local popupwidth = 500
    local title = "@SO_SURVIVAL_SURVIVED_TO_WAVE"
	local popup = LUI.MenuBuilder.BuildRegisteredType("generic_yesno_popup", {
		popup_title = Engine.Localize(title, wave),
		message_text = "",
        popup_width = popupwidth,
        padding_top = 10,
        cancel_means_no = false,
        popup_title_alignment = LUI.Alignment.Center,
		yes_action = function()
            Engine.Exec("lui_restart; fast_restart")
		end,
		no_action = function()
            Engine.Exec("disconnect")
		end
	})

    local deadquote = ""

    local content = popup:getFirstDescendentById("generic_selectionList_content_id")
    local body = LUI.UIElement.new({
        width = popupwidth - 22,
        height = deadquote ~= "" and 130 or 50
    })

    local deadquotetext = LUI.UIText.new({
        leftAnchor = true,
        topAnchor = true,
        rightAnchor = true,
        height = CoD.TextSettings.TitleFontSmaller.Height,
        font = CoD.TextSettings.TitleFontSmaller.Font,
        alignment = LUI.Alignment.Center
    })

    if (deadquote ~= "") then
        deadquotetext:setText(Engine.Localize(deadquote))
        body:addElement(deadquotetext)
    end

    local num = 0
    local addstat = function(name, value, noborder)
        local height = 30
        local offset = (height + 5) * num + (deadquote ~= "" and 80 or 0)

        local container = LUI.UIElement.new({
            leftAnchor = true,
            rightAnchor = true,
            topAnchor = true,
            height = height,
            top = offset,
        })

        local left = LUI.UIText.new({
            leftAnchor = true,
            topAnchor = true,
            height = CoD.TextSettings.TitleFontSmaller.Height,
            font = CoD.TextSettings.TitleFontSmaller.Font,
            width = (popupwidth - 22) / 2,
            left = 5,
            top = (height - CoD.TextSettings.TitleFontSmaller.Height) / 2 + 3,
            alignment = LUI.Alignment.Left
        })

        left:setText(Engine.ToUpperCase(name))

        local right = LUI.UIText.new({
            rightAnchor = true,
            topAnchor = true,
            height = CoD.TextSettings.TitleFontSmaller.Height,
            font = CoD.TextSettings.TitleFontSmaller.Font,
            width = (popupwidth - 22) / 2,
            right = -5,
            top = (height - CoD.TextSettings.TitleFontSmaller.Height) / 2 + 3,
            alignment = LUI.Alignment.Right
        })

        right:setText(value)

        local border = LUI.MenuBuilder.BuildRegisteredType("generic_border", {
            thickness = 0.1,
            border_red = Colors.generic_menu_frame_color.r - 0.2,
            border_green = Colors.generic_menu_frame_color.g - 0.2,
            border_blue = Colors.generic_menu_frame_color.b - 0.2
        })

        if (not noborder) then
            container:addElement(border)
        end

        container:addElement(left)
        container:addElement(right)
        body:addElement(container)

        num = num + 1
    end
    
    local extradata = game:sharedget("eog_extra_data")
    if (extradata ~= "") then
        extradata = json.decode(extradata)
    end

    if (type(extradata) ~= "table") then
        extradata = {}
    end

    content:getFirstDescendentById("spacer"):close()

    local extraheight = -30

    if (type(extradata.stats) == "table") then
        for i = 1, #extradata.stats do
            local stat = extradata.stats[i]
            if (type(stat) == "table" and not stat.spacer and stat.name and stat.value) then
                local value = stat.value
                if (stat.istimestamp and type(value) == "number") then
                    value = formattime(value)
                end
    
                if (stat.isvaluelocalized) then
                    local values = type(stat.values) == "table" and stat.values or {}
                    addstat(Engine.Localize(stat.name), Engine.Localize(value, table.unpack(values)))
                elseif (stat.label) then
                    addstat(Engine.Localize(stat.name), Engine.Localize(stat.label, value))
                else
                    addstat(Engine.Localize(stat.name), value)
                end
    
                extraheight = extraheight + 35
            elseif (stat.spacer) then
                addstat("", "", true)
                extraheight = extraheight + (stat.height or 35)
            end
        end
    end

    body:registerAnimationState("default", {
        width = popupwidth - 22,
        height = (deadquote ~= "" and 80 or 0) + extraheight + 5
    })
    body:animateToState("default")

    content:insertElement(body, 1)

    popup:registerEventHandler("menu_close", function()
        Engine.Exec("lui_restart; fast_restart")
    end)

    local yesbutton = popup:getFirstDescendentById("yes_button_id")
    local yestext = yesbutton:getFirstDescendentById("text_label")
    yestext:setText(Engine.Localize("SPECIAL_OPS_UI_PLAY_AGAIN"))

    local nobutton = yesbutton:getNextSibling()
    local notext = nobutton:getFirstDescendentById("text_label")
    notext:setText(Engine.Localize("SPECIAL_OPS_UI_RETURN_TO_SPECIALOPS"))

    return popup
end

LUI.MenuBuilder.registerType("so_eog_summary", eogsummary)
