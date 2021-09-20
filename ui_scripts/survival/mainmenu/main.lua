local ui = require("utils/ui")
local survivalmenu = game:newmenuoverlay("survival_menu", "menu_xenon_install_complete")

local buttonindex = -1
function addbutton(text, onclick, onmouseenter)
    buttonindex = buttonindex + 1
    local button = ui.createbutton(survivalmenu, text, 101, 188 + 62 * buttonindex, 300)
    button.onclick = onclick
    button.onmouseenter = onmouseenter

    return button
end

function addsetting(text, settings, onclick, onmouseenter)
    buttonindex = buttonindex + 1
    local button = ui.createbutton(survivalmenu, text, 101, 188 + 62 * buttonindex, 600)

    local settingindex = 1
    local value = element:new()
    value.x = button.elements.area.x + button.elements.area.w - 250
    value.y = button.elements.area.y
    value.w = 200
    value.h = button.elements.area.h
    value.fontsize = button.elements.text.fontsize
    value.color = button.elements.text.color
    value:settext(settings[settingindex])
    value:settextoffset(0, 3)
    value:sethorzalign("center")
    value:setvertalign("center")

    button.onmouseenter = function()
        onmouseenter()
        value:setcolor(0.85, 0.8, 0.29, 1)
    end

    button.onmouseleave = function()
        value:setcolor(0.6, 0.6, 0.6, 1)
    end

    local left = element:new()
    left:setrect(value.x - 30, value.y + value.h / 2 - 9, 18, 18)
    left:setmaterial("h1_deco_option_scrollbar_arrows")
    left:setslice(1, 0, 0, 1)
    left:setbackcolor(0.6, 0.6, 0.6, 1)

    local leftarea = element:new()
    leftarea:setrect(value.x - 40, value.y, 40, value.h)

    leftarea:onnotify("mouseenter", function()
        game:playsound("h1_ui_menu_scroll")
        left:setbackcolor(1, 1, 1, 1)
    end)

    leftarea:onnotify("mouseleave", function()
        game:playsound("h1_ui_menu_scroll")
        left:setbackcolor(0.6, 0.6, 0.6, 1)
    end)
    
    leftarea:onnotify("click", function()
        if (settingindex > 1) then
            settingindex = settingindex - 1
        else
            settingindex = #settings
        end

        onclick(settingindex)
        value:settext(settings[settingindex])
    end)

    local right = element:new()
    right:setrect(value.x + value.w + 10, value.y + value.h / 2 - 9, 18, 18)
    right:setmaterial("h1_deco_option_scrollbar_arrows")
    right:setbackcolor(0.6, 0.6, 0.6, 1)

    local rightarea = element:new()
    rightarea:setrect(value.x + value.w, value.y, 40, value.h)

    rightarea:onnotify("mouseenter", function()
        game:playsound("h1_ui_menu_scroll")
        right:setbackcolor(1, 1, 1, 1)
    end)

    rightarea:onnotify("mouseleave", function()
        game:playsound("h1_ui_menu_scroll")
        right:setbackcolor(0.6, 0.6, 0.6, 1)
    end)

    rightarea:onnotify("click", function()
        if (settingindex < #settings) then
            settingindex = settingindex + 1
        else
            settingindex = 1
        end

        onclick(settingindex)
        value:settext(settings[settingindex])
    end)

    survivalmenu:addchild(value)
    survivalmenu:addchild(left)
    survivalmenu:addchild(leftarea)
    survivalmenu:addchild(right)
    survivalmenu:addchild(rightarea)
end

function addbackground()
    local cinematic = element:new()
    cinematic:setrect(0, 0, 1920, 1088)
    cinematic:setmaterial("cinematic")
    cinematic:setbackcolor(1, 1, 1, 1)
    
    local vignette = element:new()
    vignette:setmaterial("h1_ui_bg_vignette")
    vignette:setrect(0, 0, 1920, 1088)
    vignette:setbackcolor(1, 1, 1, 1)

    survivalmenu:addchild(cinematic)
    survivalmenu:addchild(vignette)
end

function addmainelements()

    local title = element:new()
    title:setrect(100, 80, 100, 100)
    title:setfont("bank", 60)
    title:setcolor(1, 1, 0.55, 1)
    title:setglowcolor(1, 1, 0.5, 0.1)
    title:settext("SURVIVAL")
    
    local deco1 = element:new()
    deco1:setrect(101, 141, 27, 1.5)
    deco1:setmaterial("gradient_fadein")
    deco1:setslice(0.9, 0, 1, 1)
    deco1:setbackcolor(0.6, 0.6, 0.6, 1)
    
    local deco2 = element:new()
    deco2:setrect(139, 141, 800, 1.5)
    deco2:setmaterial("gradient_fadein")
    deco2:setslice(1, 0, 0, 1)
    deco2:setbackcolor(0.6, 0.6, 0.6, 0.5)
    
    local deco3 = element:new()
    deco3:setrect(139, 1080 - 109.5, 800, 1.5)
    deco3:setmaterial("gradient_fadein")
    deco3:setslice(1, 0, 0, 1)
    deco3:setbackcolor(1, 1, 1, 0.5)

    local deco4 = element:new()
    deco4:setrect(139 + 842, 1080 - 109.5, 800, 1.5)
    deco4:setmaterial("gradient_fadein")
    deco4:setslice(0, 0, 1, 1)
    deco4:setbackcolor(1, 1, 1, 0.5)

    local deco5 = element:new()
    deco5:setrect(101, 1080 - 109, 27, 1)
    deco5:setslice(0, 0, 1, 1)
    deco5:setbackcolor(1, 1, 1, 0.5)

    local deco6 = element:new()
    deco6:setrect(1792, 1080 - 109, 27, 1)
    deco6:setslice(0, 0, 1, 1)
    deco6:setbackcolor(1, 1, 1, 0.5)

    local deco7 = element:new()
    deco7:setrect(101, 500, 27, 1)
    deco7:setbackcolor(1, 1, 1, 0.2)

    hintbox = element:new()
    hintbox:setrect(101, 520, 300, 80)
    hintbox:setbackcolor(0, 0, 0, 0.4)
    hintbox:sethorzalign("center")
    hintbox:setvertalign("center")
    hintbox:settext("Start a Survival game.")
    hintbox:setcolor(1, 1, 1, 0.6)
    hintbox.fontsize = 16

    esc = element:new()
    esc:setrect(101.5, 1080 - 84.5 - 20, 50, 26.5)
    esc:setmaterial("h2_btn_focused_rect_innerglow")
    esc:setbackcolor(1, 1, 1, 0.6)
    esc:setcolor(0.7, 0.7, 0.3, 0.6)
    esc:settext("ESC")
    esc:setborderwidth(20, 80, 0, 0)
    esc:sethorzalign("center")
    esc:setvertalign("center")
    esc:settextoffset(0, 2.5)

    esc:onnotify("mouseenter", function()
        game:playsound("h1_ui_menu_scroll")
        esctext:setcolor(1, 1, 1, 1)
        esc:setcolor(0.7, 0.7, 0.3, 1)
        esc:setbackcolor(1, 1, 1, 1)
    end)

    esc:onnotify("mouseleave", function()
        game:playsound("h1_ui_menu_scroll")
        esctext:setcolor(1, 1, 1, 0.6)
        esc:setcolor(0.7, 0.7, 0.3, 0.6)
        esc:setbackcolor(1, 1, 1, 0.6)
    end)

    esc:onnotify("click", function()
        game:playsound("h1_ui_menu_back")
        game:playmenuvideo("sp_menus_bg_regular")
        game:luiopen("campaign_main")
    end)
    
    esctext = element:new()
    esctext:setrect(167, 1080 - 84.5, 50, 26.5)
    esctext:setmaterial("h2_btn_focused_rect_innerglow")
    esctext:setcolor(1, 1, 1, 0.6)
    esctext:settext("Back")
    esctext:setvertalign("center")
    esctext:settextoffset(0, 3)

    local footer = element:new()
    footer:setrect(0, 1080 - 108, 1920, 108)
    footer:setbackcolor(0, 0, 0, 0.4)

    survivalmenu:addchild(title)
    survivalmenu:addchild(deco1)
    survivalmenu:addchild(deco2)
    survivalmenu:addchild(deco3)
    survivalmenu:addchild(deco4)
    survivalmenu:addchild(deco5)
    survivalmenu:addchild(deco6)
    survivalmenu:addchild(deco7)
    survivalmenu:addchild(hintbox)
    survivalmenu:addchild(footer)
    survivalmenu:addchild(esc)
    survivalmenu:addchild(esctext)
end

addbackground()

local background = element:new()
background:setrect(0, 0, 1920, 1080)
survivalmenu:addchild(background)

function changebackground(map)
    background:cancelanimations("background_fade", function()
        background:animate("background_fade", {
            backcolor = {r = 0, g = 0, b = 0, a = 1}
        }, 0)
    
        game:ontimeout(function()
            game:playmenuvideo("mission_select_bg_" .. string.lower(map))
            background:animate("background_fade", {
                backcolor = {r = 0, g = 0, b = 0, a = 0}
            }, 2000)
        end, 0)
    end)
end

addmainelements()

local selectedmap = 1
local maps = {
    "Favela",
    "Estate",
    "Cliffhanger",
    "Contingency"
}

local selecteddifficulty = 1
local difficulties = {
    "Recruit",
    "Regular",
    "Hard",
    "Veteran"
}

local selectedwavestart = 1
local waves = {
    "1",
    "5",
    "10",
    "20",
    "30",
    "50",
    "100"
}

local beautifulcornerdisabled = {
    "estate"
}

addbutton("start", function()
    if (selecteddifficulty == 1) then
        game:executecommand("difficultyeasy")
    elseif (selecteddifficulty == 2) then
        game:executecommand("difficultymedium")
    elseif (selecteddifficulty == 3) then
        game:executecommand("difficultyhard")
    else
        game:executecommand("difficultyfu")
    end

    local map = maps[selectedmap] or maps[1]
    game:setdvar("survival_start_wave", waves[selectedwavestart])
    game:setdvar("beautiful_corner", beautifulcornerdisabled[map] and 0 or 1)
    game:executecommand("map " .. map)
end, function()
    hintbox:settext("Start a Survival game.")
end)

local btn = nil
btn = addbutton("leaderboards", function()
    btn.unfocusimmediate()
    game:openmenu("survival_leaderboards_menu")
end, function()
    hintbox:settext("View the leaderboards.")
end)

addsetting("map", maps, function(index)
    if (selectedmap ~= index) then
        changebackground(maps[index])
    end
    selectedmap = index
end, function()
    hintbox:settext("Change the map.")
end)

addsetting("difficulty", difficulties, function(index)
    selecteddifficulty = index
end, function()
    hintbox:settext("Change the difficulty.")
end)

addsetting("wave", waves, function(index)
    selectedwavestart = index
end, function()
    hintbox:settext("Change the starting wave number.")
end)

local wasvisible = false
game:onframe(function()
    if (survivalmenu:isopen() and not wasvisible) then
        wasvisible = true
        esc:setbackcolor(0, 0, 0, 0)
        esc:setcolor(0, 0, 0, 0)
        esctext:setcolor(0, 0, 0, 0)

        game:ontimeout(function()
            esc:animate("esc_fadein", {
                color = {r = 0.7, g = 0.7, b = 0.3, a = 0.6},
                backcolor = {r = 1, g = 1, b = 2, a = 0.6}
            }, 200)

            esctext:animate("esc_fadein", {
                color = {r = 1, g = 1, b = 1, a = 0.6}
            }, 200)
        end, 200)

        changebackground(maps[selectedmap])
    elseif (not survivalmenu:isopen()) then
        wasvisible = false
    end
end)

game:onnotify("keydown", function(key)
    if (key == 27 and survivalmenu:isopen() and not survivalmenu.ignoreevents) then
        game:playsound("h1_ui_menu_back")
        game:playmenuvideo("sp_menus_bg_regular")
        game:luiopen("campaign_main")
    end
end)

survivalmenu:addcursor()