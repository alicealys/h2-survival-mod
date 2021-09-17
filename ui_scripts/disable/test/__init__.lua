local test = game:newmenu("test")
test.cursor = true

local box = element:new()

box:sethorzalign("center")
box:setvertalign("center")
box:setrect(1200, 1000, 300, 100)
box:setbackcolor(0, 0, 0, 0.5)
box:setbordercolor(1.0, 1.0, 1.0, 0.5)
box:setborderwidth(2, 2, 2, 2)
box:settext("Hello world!")
box:setfont("defaultBold", 32)

local button1 = element:new()
button1:setrect(136, 500, 10, 64)
button1:setbackcolor(1, 1, 1, 1)
button1:setslice(0, 0.66, 0.33, 1)
button1:setmaterial("h2_btn_focused_stroke")

local button2 = element:new()
button2:setrect(136, 500, 10, 64)
button2:setbackcolor(1, 1, 1, 1)
button2:setslice(0.33, 0.66, 0.66, 1)
button2:setmaterial("h2_btn_focused_stroke")

local button3 = element:new()
button3:setrect(136 + 480 - 25, 500 + 64 - 25, 24, 24)
button3:setbackcolor(1, 1, 1, 1)
button3:setslice(0.66, 0.66, 1, 1)
button3:setmaterial("h2_btn_focused_stroke")

local function createbutton(menu, text, x, y)
    local w = 360
    local h = 48

    local focused = {}
    local unfocused = {}
    local elements = {}

    elements.area = element:new()
    elements.area:setrect(x, y, w, h)
    elements.area:onnotify("mouseenter", function()
        game:playsound("h1_ui_menu_scroll")
        focused.dotpattern:setmaterial("h2_btn_dot_pattern")
        elements.text:setcolor(1, 1, 1, 1)

        for k, v in pairs(focused) do
            v:setbackcolor(1, 1, 1, 1)
        end
    end)

    elements.area:onnotify("mouseleave", function()
        focused.dotpattern:setmaterial("white")
        elements.text:setcolor(0.6, 0.6, 0.6, 1)

        for k, v in pairs(focused) do
            v:setbackcolor(0, 0, 0, 0)
        end
    end)

    elements.area:onnotify("click", function()
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
    focused.dotpattern:setslice(0, 0, 0.36, 0.8)
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
end

local cursor = element:new()
cursor:setrect(10, 10, 128, 128)
cursor:setmaterial("ui_cursor")
cursor:setbackcolor(1, 1, 1, 1)

test:addchild(box)

createbutton(test, "fed", 500, 188)

local mousedown = false
local offsetx = 0
local offsety = 0

box:onnotify("mousedown", function(x, y)
    local rect = box:getrect()
    offsetx = rect.x - x
    offsety = rect.y - y

    mousedown = true
end)

box:onnotify("mouseenter", function()
    box:setcolor(1.0, 1.0, 1.0, 1.0)
    box:setbordercolor(1.0, 1.0, 1.0, 1.0)
end)

box:setcolor(1.0, 1.0, 1.0, 0.5)

box:onnotify("mouseleave", function()
    box:setcolor(1.0, 1.0, 1.0, 0.5)
    box:setbordercolor(1.0, 1.0, 1.0, 0.5)
end)

game:onnotify("keydown", function(key)
    if (key == 169) then
        game:openmenu("test")
    end
end)

game:onnotify("mouseup", function()
    mousedown = false
end)

game:onnotify("mousemove", function(mousex, mousey)
    if (mousedown) then
        local rect = box:getrect()
        
        local x = math.max(0, math.min(1920, mousex + offsetx, 1920 - rect.w))
        local y = math.max(0, math.min(1080, mousey + offsety, 1080 - rect.h))

        box:setrect(x, y, 300, 100)
    end
end)

game:onframe(function()
    local mouse = game:getmouseposition()
    cursor:setrect(mouse.x - 45, mouse.y - 38, 98, 98)
end)

test:addchild(cursor)
