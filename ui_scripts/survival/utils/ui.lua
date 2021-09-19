local ui = {}

local buttons = {}
ui.createbutton = function(menu, text, x, y, w)
    local h = 48

    local focused = {}
    local unfocused = {}
    local elements = {}

    local button = {
        enabled = true,
        elements = elements,
        focused = focused,
        unfocused = unfocused,
        onmouseover = function() end,
        onmouseleave = function() end,
        onmouseenter = function() end,
        onclick = function() end,
    }

    table.insert(buttons, button)

    elements.area = element:new()
    elements.area:setrect(x, y, w, h)
    elements.area:onnotify("mouseenter", function()
        if (not button.enabled) then
            return
        end

        if (type(button.onmouseenter) == "function") then
            button.onmouseenter()
        end

        focused.dotpattern:setmaterial("h2_btn_dot_pattern")
        focused.dotpattern:setbackcolor(1, 1, 1, 1)
        elements.text:setcolor(1, 1, 1, 1)
        game:playsound("h1_ui_menu_scroll")

        for i = 1, #buttons do
            for k, v in pairs(buttons[i].focused) do
                v:cancelanimations("hover_focus")
                v:setbackcolor(0, 0, 0, 0)
            end
        end

        for k, v in pairs(focused) do
            v:setbackcolor(1, 1, 1, 1)
        end
    end)

    elements.area:onnotify("mouseleave", function()
        if (not button.enabled) then
            return
        end

        if (type(button.onmouseleave) == "function") then
            button.onmouseleave()
        end

        elements.text:setcolor(0.6, 0.6, 0.6, 1)
        button.unfocus()
    end)

    elements.area:onnotify("mouseover", function()
        if (not button.enabled) then
            return
        end

        if (type(button.onmouseover) == "function") then
            button.onmouseover()
        end
    end)

    button.unfocusimmediate = function()
        game:ontimeout(function()
            focused.dotpattern:setbackcolor(0, 0, 0, 0)
        end, 0)

        for k, v in pairs(focused) do
            if (v ~= focused.dotpattern) then
                v:setbackcolor(0, 0, 0, 0)
            end
        end
    end

    button.unfocus = function()
        game:ontimeout(function()
            focused.dotpattern:setbackcolor(0, 0, 0, 0)
        end, 0)

        for k, v in pairs(focused) do
            if (v ~= focused.dotpattern) then
                v:animate("hover_focus", {
                    backcolor = {
                        r = 0,
                        g = 0,
                        b = 0,
                        a = 0,
                    }
                }, 100)
            end
        end
    end

    elements.area:onnotify("click", function()
        if (not button.enabled) then
            return
        end

        if (type(button.onclick) == "function") then
            button.onclick()
        end

        game:playsound("h1_ui_menu_accept")
    end)

    elements.text = element:new()
    elements.text:settext(string.upper(text))
    elements.text:setrect(x, y, w, h)
    elements.text:setvertalign("center")
    elements.text:setcolor(0.6, 0.6, 0.6, 1)
    elements.text:settextoffset(40, 3)
    elements.text:setfont("default", 22)

    unfocused.right = element:new()
    unfocused.right:setrect(x + w - 18, y, 18, h)
    unfocused.right:setslice(0.66, 0, 1.008, 1)
    unfocused.right:setmaterial("h2_btn_unfocused")

    unfocused.left = element:new()
    unfocused.left:setrect(x, y, 18, h)
    unfocused.left:setslice(0.008, 0, 0.33, 1)
    unfocused.left:setmaterial("h2_btn_unfocused")

    unfocused.center = element:new()
    unfocused.center:setrect(x + 18, y, w - 36, h)
    unfocused.center:setslice(0.33, 0, 0.66, 1)
    unfocused.center:setmaterial("h2_btn_unfocused")

    focused.right = element:new()
    focused.right:setrect(x + w - 18, y, 18, h)
    focused.right:setslice(0.66, 0, 1, 1)
    focused.right:setmaterial("h2_btn_focused_stroke")

    focused.left = element:new()
    focused.left:setrect(x, y, 18, h)
    focused.left:setslice(0, 0, 0.33, 1)
    focused.left:setmaterial("h2_btn_focused_stroke")

    focused.center = element:new()
    focused.center:setrect(x + 18, y, w - 36, h)
    focused.center:setslice(0.33, 0, 0.66, 1)
    focused.center:setmaterial("h2_btn_focused_stroke")

    focused.outerglowright = element:new()
    focused.outerglowright:setrect(x + w - 16, y - 12, 32, h * 1.5)
    focused.outerglowright:setslice(0.66, 0, 1, 1)
    focused.outerglowright:setmaterial("h2_btn_focused_outerglow")

    focused.outerglowleft = element:new()
    focused.outerglowleft:setrect(x - 24, y - 12, 48, h * 1.5)
    focused.outerglowleft:setslice(0, 0, 0.33, 1)
    focused.outerglowleft:setmaterial("h2_btn_focused_outerglow")

    focused.outerglowcenter = element:new()
    focused.outerglowcenter:setrect(x + 24, y - 12, w - 40, h * 1.5)
    focused.outerglowcenter:setslice(0.33, 0, 0.66, 1)
    focused.outerglowcenter:setmaterial("h2_btn_focused_outerglow")

    focused.dotpattern = element:new()
    focused.dotpattern:setrect(x, y, w, h - 5)
    focused.dotpattern:setslice(0, 0, math.min(1, w / 1000), 0.8)
    focused.dotpattern:setmaterial("white")

    for k, v in pairs(unfocused) do
        v:setbackcolor(1, 1, 1, 1)
        menu:addchild(v)
    end

    for k, v in pairs(focused) do
        v:setbackcolor(0, 0, 0, 0)
        menu:addchild(v)
    end

    for k, v in pairs(elements) do
        menu:addchild(v)
    end

    return button
end

function menu:addcursor()
    self.cursor = true

    local cursor = element:new()
    cursor:setrect(10, 10, 128, 128)
    cursor:setmaterial("ui_cursor")
    cursor:setbackcolor(1, 1, 1, 1)

    game:onframe(function()
        local mouse = game:getmouseposition()
        cursor:setrect(mouse.x - 45, mouse.y - 38, 98, 98)
    end)

    self:addchild(cursor)
end

return ui