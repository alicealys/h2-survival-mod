local ui = require("utils/ui")
local survivalmenu = game:newmenuoverlay("survival_menu", "menu_xenon_install_complete")

local buttonindex = -1
function addbutton(text, callback)
    buttonindex = buttonindex + 1
    local button = ui.createbutton(survivalmenu, text, 101, 188 + 62 * buttonindex, 300)
    button.onclick = callback
end

function addsetting(text, settings, callback)
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
    value:settext(string.upper(settings[settingindex]))
    value:settextoffset(0, 3)
    value:sethorzalign("center")
    value:setvertalign("center")

    button.onmouseenter = function()
        value:setcolor(1, 1, 1, 1)
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
        end

        callback(settingindex)
        value:settext(string.upper(settings[settingindex]))
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
        end

        callback(settingindex)
        value:settext(string.upper(settings[settingindex]))
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
    
    local footer = element:new()
    footer:setrect(0, 1080 - 108, 1920, 108)
    footer:setbackcolor(0, 0, 0, 0.4)

    survivalmenu:addchild(title)
    survivalmenu:addchild(deco1)
    survivalmenu:addchild(deco2)
    survivalmenu:addchild(footer)
end

addbackground()
addmainelements()

local selectedmap = 1
local maps = {
    "favela",
    "estate",
    "cliffhanger",
    "contingency"
}

local selecteddifficulty = 1
local difficulties = {
    "recruit",
    "regular",
    "hard",
    "veteran"
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
end)

addsetting("map", maps, function(index)
    selectedmap = index
end)

addsetting("difficulty", difficulties, function(index)
    selecteddifficulty = index
end)

addsetting("wave", waves, function(index)
    selectedwavestart = index
end)

game:onnotify("keydown", function(key)
    if (key == 27 and survivalmenu:isopen()) then
        game:playsound("h1_ui_menu_back")
        game:luiopen("campaign_main")
    end
end)

survivalmenu:addcursor()