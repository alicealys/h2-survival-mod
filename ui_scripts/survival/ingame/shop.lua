local visible = {r = 1, g = 1, b = 1, a = 1}
local hidden = {r = 0, g = 0, b = 0, a = 0}

return function(name, titletext)
    local buttons = {}
    local createbutton = function(menu, text, x, y, w)
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
        unfocused.right:setslice(0.66, 0, 1, 1)
        unfocused.right:setmaterial("h2_btn_unfocused")
    
        unfocused.left = element:new()
        unfocused.left:setrect(x, y, 18, h)
        unfocused.left:setslice(0, 0, 0.33, 1)
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

    local shopmenu = game:newmenu(name)
    shopmenu.cursor = true

    local menu = {}
    menu.title = titletext
    menu.name = name
    menu.close = function()
        shopmenu:close()
    end

    local width = 800
    local height = 800
    local basex = 1920 / 2 - width / 2
    local basey = 50

    local body = element:new()
    body:setbackcolor(0, 0, 0, 0.8)
    body:setrect(basex, basey + 50, width, height)
    body:sethorzalign("center")
    body:setborderwidth(0.5)
    body:setbordercolor(1, 1, 1, 0.2)
    
    local title = element:new()
    title:settext(string.upper(titletext))
    title:setborderwidth(0.5, 0.5, 0, 0.5)
    title:settextoffset(10, 3.5)
    title:setbordercolor(1, 1, 1, 0.2)
    title:setfont("default", 30)
    title:setbackcolor(0, 0, 0, 0.7)
    title:setvertalign("center")
    title:setrect(basex, basey, width, 50)
    title:setslice(0.5, 0.5, 1, 1)
    
    local footer = element:new()
    footer:setborderwidth(0, 0.5, 0.5, 0.5)
    footer:setbordercolor(1, 1, 1, 0.2)
    footer:setfont("default", 30)
    footer:setbackcolor(0, 0, 0, 0.7)
    footer:setvertalign("center")
    footer:setrect(basex, basey + height + 50, width, 50)
    footer:setslice(0.5, 0.5, 1, 1)
    
    local footerbutton = element:new()
    footerbutton:settext("ESC")
    footerbutton:setrect(basex + 10, basey + height + 60, 60, 30)
    footerbutton:setmaterial("h2_btn_focused_rect_innerglow")
    footerbutton:setbackcolor(1, 1, 1, 0.6)
    footerbutton:setvertalign("center")
    footerbutton:sethorzalign("center")
    footerbutton:settextoffset(0, 3)
    footerbutton:setcolor(0.7, 0.7, 0.3, 0.6)
    
    local footerbuttontext = element:new()
    footerbuttontext:settext("Back")
    footerbuttontext:setrect(basex + 10, basey + height + 60, 130, 30)
    footerbuttontext:setvertalign("center")
    footerbuttontext:setcolor(1, 1, 1, 0.6)
    footerbuttontext:settextoffset(72, 3)
    
    footerbuttontext:onnotify("mouseenter", function()
        game:playsound("h1_ui_menu_scroll")
        footerbutton:setcolor(0.7, 0.7, 0.3, 1)
        footerbutton:setbackcolor(1, 1, 1, 1)
        footerbuttontext:setcolor(1, 1, 1, 1)
    end)
    
    footerbuttontext:onnotify("mouseleave", function()
        footerbutton:setcolor(0.7, 0.7, 0.3, 0.6)
        footerbutton:setbackcolor(1, 1, 1, 0.6)
        footerbuttontext:setcolor(1, 1, 1, 0.6)
    end)
    
    footerbuttontext:onnotify("click", function()
        menu.close()
    end)
    
    local scrollbarback = element:new()
    scrollbarback:setmaterial("ui_scrollbar")
    scrollbarback:setrect(basex + width - 25, basey + 70, 20, height - 40)
    scrollbarback:setbackcolor(0, 0, 0, 0.5)
    
    local scrollbararea = element:new()
    scrollbararea:setrect(basex + width - 20, basey + 70, 10, 50)
    
    local scrollbarthumb = element:new()
    scrollbarthumb:setmaterial("ui_scrollbar")
    scrollbarthumb:setrect(basex + width - 25, basey + 70, 20, 50)
    scrollbarthumb:setbackcolor(1, 1, 1, 1)
    
    local scrollindex = -1
    local point = {x = 0, y = 0}
    local down = false
    local weapons = {}
    local weaponheight = (height - 90) / 12
    
    scrollbararea:onnotify("mouseenter", function(x, y)
        scrollbarthumb:setmaterial("h2_scrollbar_fill_selected")
        scrollbarthumb.x = basex + width - 20
        scrollbarthumb.w = 10
    end)
    
    function inrect(x, y, rect)
        return (x > rect.x and x < rect.x + rect.w and y > rect.y and y < rect.y + rect.h)
    end
    
    scrollbararea:onnotify("mouseleave", function(x, y)
        if (down) then
            return
        end
    
        scrollbarthumb:setmaterial("ui_scrollbar")
        scrollbarthumb.x = basex + width - 25
        scrollbarthumb.w = 20
    end)
    
    scrollbararea:onnotify("mousedown", function(x, y)
        down = true
        point.x = x
        point.y = y
    
        scrollbarthumb:setmaterial("h2_scrollbar_fill_selected")
        scrollbarthumb.x = basex + width - 20
        scrollbarthumb.w = 10
    end)
    
    game:onnotify("mouseup", function()
        down = false
    
        local mouse = game:getmouseposition()
        if (inrect(mouse.x, mouse.y, scrollbararea:getrect())) then
            return
        end
    
        scrollbarthumb:setmaterial("ui_scrollbar")
        scrollbarthumb.x = basex + width - 25
        scrollbarthumb.w = 20
    end)
    
    game:onnotify("mousemove", function(x, y)
        if (not down) then
            return
        end
    
        local diff = y - point.y
        local abs = math.abs(diff)
    
        if (abs > weaponheight) then
            point.x = x
            point.y = y
    
            if (scrollindex > -#weapons + 12 and diff > 0) then
                scrollindex = scrollindex + (diff > 0 and -1 or 1)
            elseif (scrollindex < -1 and diff < 0) then
                scrollindex = scrollindex + (diff > 0 and -1 or 1)
            end
        end
    end)

    local cursor = element:new()
    cursor:setrect(-100, -100, 98, 98)
    cursor:setmaterial("ui_cursor")
    cursor:setbackcolor(1, 1, 1, 1)
    
    shopmenu:addchild(footer)
    shopmenu:addchild(footerbutton)
    shopmenu:addchild(footerbuttontext)
    shopmenu:addchild(title)
    shopmenu:addchild(body)
    shopmenu:addchild(scrollbarback)
    shopmenu:addchild(scrollbarthumb)
    shopmenu:addchild(scrollbararea)
    
    game:onframe(function()
        local mouse = game:getmouseposition()
        cursor:setrect(mouse.x - 45, mouse.y - 38, 98, 98)
    end)

    local updatescroll = function(time)
        time = time or 100
    
        local weaponsheight = math.max(#weapons - 13, 0) * weaponheight
        local scrollbarheight = (height - 40) - weaponsheight
        scrollbarthumb.h = scrollbarheight
        scrollbarthumb.y = basey + 70 + -1 * (scrollindex + 1) * weaponheight
        
        scrollbararea.y = scrollbarthumb.y
        scrollbararea.h = scrollbarthumb.h
    
        if (shopmenu:isopen()) then
            game:playsound("h1_ui_menu_scroll")
        end
    
        for i = 1, #weapons do
            local index = scrollindex + i
            weapons[i].unfocus()
    
            for k, v in pairs(weapons[i].elements) do
                v:cancelanimations("scroll")
                v:cancelanimations("scroll_fadeout")
            end
    
            for k, v in pairs(weapons[i].unfocused) do
                v:cancelanimations("scroll")
                v:cancelanimations("scroll_fadeout")
            end
    
            for k, v in pairs(weapons[i].focused) do
                v:cancelanimations("scroll")
                v:cancelanimations("scroll_fadeout")
            end
    
            game:ontimeout(function()
                for k, v in pairs(weapons[i].elements) do
                    v:animate("scroll", {
                        y = basey + 70 + index * weaponheight
                    }, time)
        
                    if (v == weapons[i].elements.text or v == weapons[i].elements.price) then
                        if (index < 0 or index > 12) then
                            weapons[i].enabled = false
                            v:animate("scroll_fadeout", {
                                color = hidden,
                            }, time)
                        elseif (v.color.r ~= 0.6) then
                            weapons[i].enabled = true
                            v:animate("scroll_fadeout", {
                                color = {r = 0.6, g = 0.6, b = 0.6, a = 1},
                            }, time)
                        end
                    end
                end
        
                for k, v in pairs(weapons[i].unfocused) do
                    v:animate("scroll", {
                        y = basey + 70 + index * weaponheight
                    }, time)
        
                    if (index < 0 or index > 12) then
                        v:animate("scroll_fadeout", {
                            backcolor = hidden,
                            color = hidden,
                        }, time)
                    elseif (v.backcolor.r ~= 1) then
                        v:animate("scroll_fadeout", {
                            backcolor = visible,
                            color = visible,
                        }, time)
                    end
                end
    
                for k, v in pairs(weapons[i].focused) do
                    local offset = 0
                    if (v == weapons[i].focused.outerglowcenter or v == weapons[i].focused.outerglowright or v == weapons[i].focused.outerglowleft) then
                        offset = 12
                    end
                    
                    v:animate("scroll", {
                        y = basey + 70 + index * weaponheight - offset
                    }, time)
                end
            end, 0)
        end
    end
    
    updatescroll(0)

    local previousscroll = nil
    game:oninterval(function()
        if (previousscroll ~= scrollindex) then
            previousscroll = scrollindex
            updatescroll()
        end
    end, 50)
    
    game:onnotify("scrolldown", function()
        if (not shopmenu:isopen()) then
            return
        end
    
        if (scrollindex > -#weapons + 12) then
            scrollindex = scrollindex - 1
        end
    end)
    
    game:onnotify("scrollup", function()
        if (not shopmenu:isopen()) then
            return
        end
    
        if (scrollindex < -1) then
            scrollindex = scrollindex + 1
        end
    end)
    
    game:onnotify("keydown", function(key)
        if (key == 27 and shopmenu:isopen()) then
            menu.close()
        end
    end)

    local additem = function(name)
        local button = createbutton(shopmenu, name, basex + 20, basey + 70 + #weapons * weaponheight, width - 50)
        button.elements.price = element:new()
        button.elements.price:setrect(basex + 20, basey + 70 + #weapons * weaponheight, width - 40, 48)
        button.elements.price:setvertalign("center")
        button.elements.price:sethorzalign("right")
        button.elements.price:settextoffset(-40, 3)
        button.elements.price:setcolor(0.6, 0.6, 0.6, 1)
        button.elements.price:setfont("default", 22)
    
        shopmenu:addchild(button.elements.price)
    
        button.onmouseover = function()
            button.elements.price:setcolor(1, 1, 1, 1)
            button.elements.text:setcolor(1, 1, 1, 1)
        end
    
        button.onmouseleave = function()
            button.elements.price:setcolor(0.6, 0.6, 0.6, 1)
            button.elements.text:setcolor(0.6, 0.6, 0.6, 1)
        end
    
        button.showenabled = function()
            button.elements.text:setcolor(0.6, 0.6, 0.6, 1)
            button.elements.price:setcolor(0.6, 0.6, 0.6, 1)
            button.unfocused.left:setmaterial("h2_btn_unfocused")
            button.unfocused.center:setmaterial("h2_btn_unfocused")
            button.unfocused.right:setmaterial("h2_btn_unfocused")
            button.enabled = true
        end
    
        button.showdisabled = function()
            button.elements.price:setcolor(0.4, 0.4, 0.4, 1)
            button.elements.text:setcolor(0.4, 0.4, 0.4, 1)
            button.unfocused.left:setmaterial("h2_btn_unfocused_locked")
            button.unfocused.center:setmaterial("h2_btn_unfocused_locked")
            button.unfocused.right:setmaterial("h2_btn_unfocused_locked")
            button.enabled = false
            button.unfocusimmediate()
        end
    
        table.insert(weapons, button)
        
        return button
    end

    game:onframe(function()
        if (game:getdvarint("cl_paused") == 1 and shopmenu:isopen()) then
            shopmenu:close()
        end
    end)

    menu.addcursor = function()
        shopmenu:addchild(cursor)
    end
    menu.menu = shopmenu
    menu.additem = additem

    return menu
end