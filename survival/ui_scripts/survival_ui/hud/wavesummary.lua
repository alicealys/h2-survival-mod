function addwavesummaryhud(parent)
    local hud = LUI.UIElement.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true
    })

    parent:addElement(hud)

    local textheight = 16
    local popupwidth = 300
    local popupheight = 212
    local summary = LUI.UIElement.new({
        topAnchor = true,
        leftAnchor = true,
        top = 300,
        left = 40,
        width = popupwidth,
        height = popupheight
    })

    local header = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        height = 30,
        material = RegisterMaterial("h2_popup_title_bg"),
    })

    local title = LUI.UIText.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true,
        top = 5 + 3,
        bottom = -5,
        font = CoD.TextSettings.TitleFontSmaller.Font,
    })

    title:setText(Engine.ToUpperCase(Engine.Localize("@SO_SURVIVAL_WAVE_PERFORMANCE")))
    header:addElement(title)

    local body = LUI.UIElement.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true,
        top = 30
    })

    local content = LUI.UIElement.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true,
    })

    summary:addElement(header)
    summary:addElement(body)
    body:addElement(content)

    local num = 0
    local addsummaryfield = function(name, field, label, novalue)
        local height = textheight + 10
        local offset = (height) * num

        local container = LUI.UIElement.new({
            leftAnchor = true,
            rightAnchor = true,
            topAnchor = true,
            height = height,
            top = offset,
            alpha = 1
        })

        local bg = LUI.UIImage.new({
            leftAnchor = true,
            rightAnchor = true,
            topAnchor = true,
            bottomAnchor = true,
            material = RegisterMaterial("black"),
            alpha = 0.7
        })

        container:addElement(bg)

        container:registerAnimationState("hide", {
            alpha = 0
        })

        local left = LUI.UIText.new({
            leftAnchor = true,
            topAnchor = true,
            height = textheight,
            font = CoD.TextSettings.TitleFontSmaller.Font,
            width = (popupwidth - 22) / 2,
            left = 10,
            top = (height - textheight) / 2 + 3,
            alignment = LUI.Alignment.Left
        })

        left:setText(Engine.ToUpperCase(Engine.Localize(name)))

        local valuetext = LUI.UIText.new({
            rightAnchor = true,
            topAnchor = true,
            height = textheight,
            font = CoD.TextSettings.TitleFontSmaller.Font,
            width = (popupwidth - 22) / 2,
            right = -85,
            top = (height - textheight) / 2 + 3,
            color = Colors.h2.yellow,
            alpha = novalue and 0 or 1,
            alignment = LUI.Alignment.Right
        })

        local bonus = LUI.UIText.new({
            rightAnchor = true,
            topAnchor = true,
            height = textheight,
            font = CoD.TextSettings.TitleFontSmaller.Font,
            width = (popupwidth - 22) / 2,
            right = -10,
            top = (height - textheight) / 2 + 3,
            color = Colors.mw3_green,
            alignment = LUI.Alignment.Right
        })

        local border = LUI.MenuBuilder.BuildRegisteredType("generic_border", {
            thickness = 0.1,
            border_red = Colors.generic_menu_frame_color.r - 0.2,
            border_green = Colors.generic_menu_frame_color.g - 0.2,
            border_blue = Colors.generic_menu_frame_color.b - 0.2
        })

        container:addElement(border)
        container:addElement(left)
        container:addElement(valuetext)
        container:addElement(bonus)
        content:addElement(container)

        num = num + 1

        function valuetext:setvalue(value)
            valuetext.value = value
            if (label) then
                valuetext:setText(Engine.Localize(label, value))
            else
                valuetext:setText(value)
            end
        end

        function bonus:setvalue(value, label)
            if (not value) then
                bonus:setText("")
            end

            bonus.value = value
            bonus:setText(Engine.Localize("@SO_SURVIVAL_PERFORMANCE_CREDIT_PLUS", value))
        end

        valuetext:setvalue(0)
        bonus:setvalue(0, "@SO_SURVIVAL_PERFORMANCE_CREDIT_PLUS")

        return {
            container = container,
            value = valuetext,
            bonus = bonus
        }
    end

    local fields = {}
    fields.time = addsummaryfield("@SO_SURVIVAL_PERFORMANCE_TIME", "time")
    fields.wavebonus = addsummaryfield("@SO_SURVIVAL_PERFORMANCE_WAVEBONUS", "wavebonus")
    fields.kill = addsummaryfield("@SO_SURVIVAL_PERFORMANCE_KILLS", "kill")
    fields.headshot = addsummaryfield("@SO_SURVIVAL_PERFORMANCE_HEADSHOT", "headshot")
    fields.accuracy = addsummaryfield("@SO_SURVIVAL_PERFORMANCE_ACCURACY", "accuracy", "@SO_SURVIVAL_PERFORMANCE_PERCENT")
    fields.damagetaken = addsummaryfield("@SO_SURVIVAL_PERFORMANCE_DAMAGETAKEN", "damagetaken")
    fields.total = addsummaryfield("@SO_SURVIVAL_PERFORMANCE_REWARD", "total", "@SO_SURVIVAL_CREDITS", true)

    summary:registerAnimationState("hide", {
        topAnchor = true,
        leftAnchor = true,
        top = 300,
        left = -500,
        width = popupwidth,
        height = popupheight
    })

    summary:animateToState("hide")
    hud:addElement(summary)

    local fieldnames = {
        "time",
        "wavebonus",
        "kill",
        "headshot",
        "accuracy",
        "damagetaken",
        "total",
    }

    local function rollvalues()
        local timer = LUI.UITimer.new(10, "update_values")
        if (summary.updatetimer) then
            summary.updatetimer:close()
            summary.updatetimer = nil
        end

        summary.updatetimer = timer
        
        for k, v in pairs(fields) do
            v.bonus.targetvalue = v.bonus.value
            v.bonus:setvalue(0)
            v.bonus.enableroll = false
            v.bonus.isdone = false
            v.bonus.currentvalue = 0
            v.container:animateToState("hide")
        end

        local frames = 0
        local index = 1
        local donecount = 0
        fields[fieldnames[index]].container:animateToState("default")
        fields[fieldnames[index]].bonus.enableroll = true

        summary:addElement(timer)
        summary:registerEventHandler("update_values", function()
            if (donecount >= #fieldnames) then
                summary.updatetimer:close()
                summary.updatetimer = nil
                return
            end

            frames = frames + 1
            if (frames >= 20) then
                frames = 0
                index = index + 1
                local name = fieldnames[index]
                if (name) then
                    fields[name].bonus.enableroll = true
                    fields[name].container:animateToState("default")
                end
            end

            for i = 1, #fieldnames do
                local field = fields[fieldnames[i]]
                if (field.bonus.enableroll) then
                    if (field.bonus.currentvalue == nil) then
                        field.bonus.currentvalue = 0
                    end
        
                    if (field.bonus.currentvalue < field.bonus.targetvalue) then
                        field.bonus.currentvalue = field.bonus.currentvalue + field.bonus.targetvalue / 100
                        field.bonus:setvalue(math.floor(field.bonus.currentvalue))
                    elseif (not field.bonus.isdone) then
                        field.bonus.isdone = true
                        field.bonus:setvalue(field.bonus.targetvalue)
                        donecount = donecount + 1
                    end
                end
            end
        end)
    end

    local function show()
        local timer = LUI.UITimer.new(10000, "hide_summary")
        summary:animateToState("default", 200)
        rollvalues()

        summary:addElement(timer)
        summary:registerEventHandler("hide_summary", function()
            timer:close()
            summary:animateToState("hide", 200)
        end)
    end

    parent:registerEventHandler("so_survival_event", function(element, event)
        local data = json.decode(event.data)
        if (data.name == "wave_end") then
            for k, v in pairs(data.stats) do
                if (fields[k]) then
                    fields[k].value:setvalue(v.value)
                    fields[k].bonus:setvalue(v.bonus)
                end
            end

            show()
        end
    end)

    return hud
end
