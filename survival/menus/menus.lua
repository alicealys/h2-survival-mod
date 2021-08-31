local menus = {}
menus["deployables"] = require("menus/deployables")
menus["airsupport"] = require("menus/airsupport")
menus["specialties"] = require("menus/specialties")

local menustates = {}

player:notifyonplayercommand("+scrollup", "+attack")
player:notifyonplayercommand("-scrollup", "-attack")
player:notifyonplayercommand("+scrolldown", "+speed_throw")
player:notifyonplayercommand("-scrolldown", "-speed_throw")

player:notifyonplayercommand("+scrolldown", "+toggleads")
player:notifyonplayercommand("-scrolldown", "-toggleads")

player:notifyonplayercommand("select", "+activate")

function entity:_closemenu()
    local entnum = self:getentitynumber()

    if (menustates[entnum] == nil) then
        return
    end

    for k, v in pairs(menustates[entnum].openmenus) do
        if (v ~= nil and v.close ~= nil) then
            v.close()
        end

        menustates[entnum].openmenus[k] = nil
    end

    menustates[entnum].currentmenu = nil
end

game:precacheshader("h1_ui_divider_gradient_left")

function entity:_openmenu(_name)
    local menu = menus[_name]

    if (menu == nil or not menu.canopen(self)) then
        return
    end

    self:_closemenu()

    local entnum = self:getentitynumber()

    if (menustates[entnum] == nil) then
        menustates[entnum] = {}
        menustates[entnum].openmenus = {}
    end

    menustates[entnum].currentmenu = _name

    local opened = {}
    opened.elems = {}

    menustates[entnum].openmenus[_name] = opened

    local starty = 240 - (menu.height / 2)
    local startx = 320 - menu.width / 2

    local listeners = {}

    local margin = 5
    local fontheight = 20
    local titleheight = 25
    local rows = math.min(#menu.buttons, math.ceil(menu.height / fontheight) - 1)

    local buttons = {}

    local index = 0
    local relativeindex = 0

    local titlebackground = game:newclienthudelem(self)
    titlebackground.x = startx
    titlebackground.y = starty
    titlebackground.sort = 2
    titlebackground.color = menu.titlebackground
    titlebackground:setshader("white", math.floor(menu.width), titleheight)
    table.insert(opened.elems, titlebackground)

    local titlegradient = game:newclienthudelem(self)
    titlegradient.x = startx
    titlegradient.y = starty + titleheight
    titlegradient.sort = 2
    titlegradient.color = menu.titlegradient
    titlegradient:setshader("h1_ui_divider_gradient_left", math.floor(menu.width), margin)
    table.insert(opened.elems, titlegradient)

    local title = game:newclienthudelem(self)
    title.x = startx + margin
    title.y = starty + math.ceil((titleheight - fontheight) / 2)
    title.sort = 3
    title.font = "objective"
    title.fontscale = 1.5
    title:settext(menu.title)
    table.insert(opened.elems, title)

    local background = game:newclienthudelem(self)
    background.y = starty
    background.x = 320 - (menu.width / 2)
    background:setshader("white", menu.width, menu.height)
    background.color = menu.background
    background.alpha = menu.backgroundopacity
    table.insert(opened.elems, background)

    starty = starty + fontheight + margin * 1.5

    local cursor = game:newclienthudelem(self)
    cursor.x = startx
    cursor.y = starty + margin
    cursor.alpha = 0.5
    cursor.sort = 2
    cursor.color = menu.cursorcolor
    cursor:setshader("white", math.floor(menu.width), fontheight)
    table.insert(opened.elems, cursor)

    local thumbheight = math.floor((menu.height - margin * 4) / (#menu.buttons - rows))

    local thumb = game:newclienthudelem(self)
    thumb.x = startx + menu.width - margin
    thumb.y = starty + margin
    thumb.alpha = 0.5
    thumb.sort = 3
    thumb:setshader("white", math.floor(margin / 2), thumbheight)
    table.insert(opened.elems, thumb)

    local buttons = {}

    for i = 1, rows do
        local button = {}

        local spacing = math.floor(menu.width / (#menu.buttons[i].text))

        for o = 1, #menu.buttons[i].text do
            button[o] = game:newclienthudelem(self)
            button[o].x = startx + margin * 2 + spacing * (o - 1)
            button[o].y = starty + (i - 1) * fontheight + margin * 1.5
            button[o].fontscale = 1.2
            button[o].font = "objective"
            button[o].sort = 10
            button[o]:settext(menu.buttons[i].text[o])
            button[o].text = menu.buttons[i].text[o]

            table.insert(opened.elems, button[o])
        end

        table.insert(buttons, button)
    end

    local updatecursor = function()
        cursor:moveovertime(0.1)
        thumb:moveovertime(0.1)

        cursor.y = starty + (relativeindex) * fontheight + margin
        thumb.y = starty + (index) * thumbheight + margin
    end

    local updatetext = function()
        for i = 1, rows do
            local button = menu.buttons[i + index]

            for o = 1, #button.text do
                local text = (button and button.text and button.text[o]) or ""

                buttons[i][o]:settext(text)
                buttons[i][o].text = text
            end

            if (button ~= nil and button.onrender) then
                button.onrender(self, buttons[i])
            end
        end
    end

    updatetext()

    local down = function()
        relativeindex = relativeindex + 1

        if (relativeindex > rows - 1) then
            index = index + 1

            if (index > #menu.buttons - rows) then
                index = 0
                relativeindex = 0

                updatetext()
                updatecursor()
                return
            end

            updatetext()
        end

        relativeindex = math.max(0, math.min(relativeindex, rows - 1))

        updatecursor()
    end

    local up = function()
        relativeindex = relativeindex - 1

        if (relativeindex < 0) then
            index = index - 1

            if (index < 0) then
                index = #menu.buttons - rows
                relativeindex = rows - 1

                updatetext()
                updatecursor()
                return
            end

            updatetext()
        end

        relativeindex = math.max(0, math.min(relativeindex, rows - 1))

        updatecursor()
    end

    local listeners = {}

    table.insert(listeners, self:onnotify("select", function()
        local button = menu.buttons[index + relativeindex + 1]

        if (button == nil or button.callback == nil) then
            return
        end

        button.callback(self)
    end))

    table.insert(listeners, self:onnotify("+scrolldown", function()
        down()

        local keylisteners = {}

        table.insert(keylisteners, game:ontimeout(function()
            table.insert(keylisteners, game:oninterval(function()
                down()
            end, 100))
        end, 400))

        table.insert(keylisteners, self:onnotifyonce("+scrollup", function()
            for i = 1, #keylisteners do
                keylisteners[i]:clear()
            end
        end))

        table.insert(keylisteners, self:onnotifyonce("-scrolldown", function()
            for i = 1, #keylisteners do
                keylisteners[i]:clear()
            end
        end))

        table.insert(keylisteners, self:onnotifyonce("disconnect", function()
            for i = 1, #keylisteners do
                keylisteners[i]:clear()
            end
        end))
    end))

    table.insert(listeners, self:onnotify("+scrollup", function()
        up()

        local keylisteners = {}

        table.insert(keylisteners, game:ontimeout(function()
            table.insert(keylisteners, game:oninterval(function()
                up()
            end, 100))
        end, 400))

        table.insert(keylisteners, self:onnotifyonce("+scrolldown", function()
            for i = 1, #keylisteners do
                keylisteners[i]:clear()
            end
        end))

        table.insert(keylisteners, self:onnotifyonce("-scrollup", function()
            for i = 1, #keylisteners do
                keylisteners[i]:clear()
            end
        end))

        table.insert(keylisteners, self:onnotifyonce("disconnect", function()
            for i = 1, #keylisteners do
                keylisteners[i]:clear()
            end
        end))
    end))

    table.insert(listeners, self:onnotify("reload", function()
        self:_closemenu(_name)
    end))

    table.insert(listeners, self:onnotifyonce("disconnect", function()
        for i = 1, #listeners do
            listeners[i]:clear()
        end
    end))

    menu.onopen(self)

    opened.close = function()
        menu.onclose(self)

        for i = 1, #listeners do
            listeners[i]:clear()
        end

        for i = 1, #opened.elems do
            opened.elems[i]:destroy()
        end

        opened.elems = {}
    end
end

function menuexists(menu)
    return menus[menu] ~= nil
end

function entity:getmenustate()
    local entnum = self:getentitynumber()

    return menustates[entnum]
end