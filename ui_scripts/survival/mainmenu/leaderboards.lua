local ui = require("utils/ui")
local leaderboardsmenu = game:newmenu("survival_leaderboards_menu")

leaderboardsmenu:onnotify("open", function()
    local survivalmenu = game:getmenu("survival_menu")
    if (survivalmenu) then
        survivalmenu.ignoreevents = true
    end
end)

leaderboardsmenu:onnotify("close", function()
    local survivalmenu = game:getmenu("survival_menu")
    if (survivalmenu) then
        survivalmenu.ignoreevents = false
    end
end)

local width = 1000
local height = 800

local basex = (1920 / 2) - (width / 2)
local basey = (1080 / 2) - (height / 2)

local overlay = element:new()
overlay:setrect(0, 0, 1920, 1080)
overlay:setbackcolor(0, 0, 0, 0.3)

local background = element:new()
background:setrect(basex, basey + 45, width, height)
background:setbackcolor(0, 0, 0, 0.7)
background:setborderwidth(0.5)
background:setbordercolor(1, 1, 1, 0.3)

local header = element:new()
header:setrect(basex, basey, width, 40)
header:setbackcolor(0, 0, 0, 0.7)
header:setborderwidth(0.5)
header:setbordercolor(1, 1, 1, 0.3)

leaderboardsmenu:addchild(overlay)
leaderboardsmenu:addchild(background)
leaderboardsmenu:addchild(header)

local tabs = {}
function addtab(name, callback)
    local tab = {}
    tab.focused = false
    
    tab.text = element:new()
    tab.text:settext(string.upper(name))
    tab.text:sethorzalign("center")
    tab.text:setvertalign("center")
    tab.text:settextoffset(0, 3)
    tab.text:setcolor(0.6, 0.6, 0.6, 1)
    tab.text:setbordercolor(1, 1, 1, 0.3)
    tab.text.fontsize = 16

    tab.focusright = element:new()
    tab.focusright:setmaterial("h2_btn_focused_rect_innerglow")
    tab.focusright:setslice(0, 0, 0.33, 1)
    tab.focusright:setbackcolor(0, 0, 0, 0)

    tab.focuscenter = element:new()
    tab.focuscenter:setmaterial("h2_btn_focused_rect_innerglow")
    tab.focuscenter:setslice(0.33, 0, 0.66, 1)
    tab.focuscenter:setbackcolor(0, 0, 0, 0)

    tab.focusleft = element:new()
    tab.focusleft:setmaterial("h2_btn_focused_rect_innerglow")
    tab.focusleft:setslice(0.66, 0, 1, 1)
    tab.focusleft:setbackcolor(0, 0, 0, 0)

    table.insert(tabs, tab)

    local focused = false
    tab.text:onnotify("mouseenter", function()
        game:playsound("h1_ui_menu_scroll")
        tab.text:setcolor(1, 1, 1, 1)
    end)

    tab.text:onnotify("mouseleave", function()
        game:playsound("h1_ui_menu_scroll")

        if (tab.focused) then
            return
        end

        tab.text:setcolor(0.6, 0.6, 0.6, 1)
    end)

    tab.focus = function(sound)
        if (type(callback) == "function") then
            callback()
        end

        for i = 1, #tabs do
            tabs[i].focused = false
            if (tabs[i] ~= tab) then
                tabs[i].text:animate("tab_fade", {
                    color = {r = 0.6, g = 0.6, b = 0.6, a = 1}
                }, 100)

                tabs[i].focusleft:animate("tab_fade", {
                    backcolor = {r = 1, g = 1, b = 1, a = 0}
                }, 100)

                tabs[i].focusright:animate("tab_fade", {
                    backcolor = {r = 1, g = 1, b = 1, a = 0}
                }, 100)

                tabs[i].focuscenter:animate("tab_fade", {
                    backcolor = {r = 1, g = 1, b = 1, a = 0}
                }, 100)
            end
        end

        if (sound) then
            game:playsound("h1_ui_menu_accept")
        end
        tab.focused = true
        tab.text:setcolor(1, 1, 1, 1)
        tab.focusleft:setbackcolor(1, 1, 1, 1)
        tab.focusright:setbackcolor(1, 1, 1, 1)
        tab.focuscenter:setbackcolor(1, 1, 1, 1)
        tab.text:animate("tab_fade", {
            color = {r = 1, g = 1, b = 1, a = 1}
        }, 100)
    end

    tab.text:onnotify("click", function()
        tab.focus(true)
    end)

    local tabindex = #tabs
    local tabwidth = width / #tabs
    local tabx = header.x + tabwidth * (tabindex - 1)

    for i = 1, #tabs do
        local _tabx = header.x + tabwidth * (i - 1)
        tabs[i].text:setrect(_tabx, header.y, tabwidth, header.h)
        tabs[i].focusright:setrect(_tabx - 1, header.y, 30, header.h + 2)
        tabs[i].focusleft:setrect(_tabx + tabs[i].text.w - 26, header.y, 30, header.h + 2)
        tabs[i].focuscenter:setrect(_tabx + 29, header.y, tabs[i].text.w - 55, header.h + 2)

        if (i == #tabs) then
            tabs[i].text:setborderwidth(0, 0, 0, 0)
        else
            tabs[i].text:setborderwidth(0, 0.5, 0, 0)
        end
    end

    leaderboardsmenu:addchild(tab.text)
    leaderboardsmenu:addchild(tab.focusright)
    leaderboardsmenu:addchild(tab.focusleft)
    leaderboardsmenu:addchild(tab.focuscenter)

    return tab
end

game:onnotify("keydown", function(key)
    if (key == 27 and leaderboardsmenu:isopen()) then
        game:playsound("h1_ui_menu_back")
        leaderboardsmenu:close()
    end
end)

local itemheight = (height - 90) / 12
local items = {}
function additem()
    local item = {}

    item.elements = {}
    item.unfocused = {}
    item.focused = {}

    item.elements.area = element:new()
    item.elements.area:setrect(background.x, background.y + #items * 50, background.w, 50)
    item.elements.area:setbordercolor(1, 1, 1, 0.3)
    item.elements.area:setborderwidth(0, 0, 0.5, 0)

    item.elements.name = element:new()
    item.elements.name:setrect(background.x, background.y + #items * 50, background.w - 200 * 3, 50)
    item.elements.name:setvertalign("center")
    item.elements.name:settextoffset(20, 3)
    item.elements.name:setcolor(0.6, 0.6, 0.6, 1)
    item.elements.name:setborderwidth(0, 0.5, 0, 0)
    item.elements.name:setbordercolor(1, 1, 1, 0.3)

    for i = 1, 3 do
        local key = "value" .. i
        item.elements[key] = element:new()
        item.elements[key]:setrect(background.x + background.w - (200 * i), background.y + #items * 50, 200, 50)
        item.elements[key]:setvertalign("center")
        item.elements[key]:settextoffset(10, 3)
        item.elements[key]:setcolor(0.6, 0.6, 0.6, 1)

        if (i > 1) then
            item.elements[key]:setborderwidth(0, 0.5, 0, 0)
            item.elements[key]:setbordercolor(1, 1, 1, 0.3)
        end
    end

    for k, v in pairs(item.elements) do
        leaderboardsmenu:addchild(v)
    end

    table.insert(items, item)

    return item
end

local itemheader = additem()
itemheader.elements.name:setcolor(0.8, 0.8, 0.8, 1)
itemheader.elements.value1:setcolor(0.8, 0.8, 0.8, 1)
itemheader.elements.value2:setcolor(0.8, 0.8, 0.8, 1)
itemheader.elements.value3:setcolor(0.8, 0.8, 0.8, 1)

for i = 0, 14 do
    additem()
end

local database = require("database")
local data = database.read()

local maps = {
    favela = "Favela",
    estate = "Estate",
    cliffhanger = "Cliffhanger",
    contingency = "Contingency",
    airport = "Terminal"
}

function resetheader()
    for i = 1, #items do
        for k, v in pairs(items[i].elements) do
            v:settext("")
            if (v ~= items[i].elements.area) then
                v:setborderwidth(0)
            end
        end
    end
end

addtab("Recent games", function()
    resetheader()

    itemheader.elements.name:settext("MAP")
    itemheader.elements.value1:settext("WAVE")
    itemheader.elements.value2:settext("KILLS")
    itemheader.elements.value3:settext("SCORE")
    itemheader.elements.name:setborderwidth(0, 0.5, 0)
    itemheader.elements.value1:setborderwidth(0, 0.5, 0)
    itemheader.elements.value2:setborderwidth(0, 0.5, 0)
    itemheader.elements.value3:setborderwidth(0, 0.5, 0)

    local itemindex = 1
    local start = 1

    table.sort(data.matches, function(a, b)
        return a.time > b.time
    end)

    for i = start, start - 1 + math.min(#data.matches, #items) do
        itemindex = itemindex + 1
        items[itemindex].elements.name:settext(maps[data.matches[i].map] or data.matches[i].map)
        items[itemindex].elements.value1:settext(data.matches[i].wave .. "")
        items[itemindex].elements.value2:settext(data.matches[i].kills .. "")
        items[itemindex].elements.value3:settext(data.matches[i].score .. "")
        items[itemindex].elements.name:setborderwidth(0, 0.5, 0, 0)
        items[itemindex].elements.value1:setborderwidth(0, 0.5, 0, 0)
        items[itemindex].elements.value2:setborderwidth(0, 0.5, 0, 0)
        items[itemindex].elements.value3:setborderwidth(0, 0.5, 0, 0)
    end
end).focus(false)

addtab("Highest wave", function()
    resetheader()

    itemheader.elements.name:settext("NAME")
    itemheader.elements.value1:settext("WAVE")
    itemheader.elements.value2:setborderwidth(0, 0.5, 0, 0)

    items[2].elements.name:settext(string.format("%s (You)", game:getdvar("name")))
    items[2].elements.value1:settext(data.records.wave .. "")
    items[2].elements.value2:setborderwidth(0, 0.5, 0, 0)
end)

addtab("Total Score", function()
    resetheader()

    itemheader.elements.name:settext("NAME")
    itemheader.elements.value1:settext("SCORE")
    itemheader.elements.value2:setborderwidth(0, 0.5, 0, 0)

    items[2].elements.name:settext(string.format("%s (You)", game:getdvar("name")))
    items[2].elements.value1:settext(data.total.score .. "")
    items[2].elements.value2:setborderwidth(0, 0.5, 0, 0)
end)

addtab("Total Kills", function()
    resetheader()

    itemheader.elements.name:settext("NAME")
    itemheader.elements.value1:settext("KILLS")
    itemheader.elements.value2:setborderwidth(0, 0.5, 0, 0)

    items[2].elements.name:settext(string.format("%s (You)", game:getdvar("name")))
    items[2].elements.value1:settext(data.total.kills .. "")
    items[2].elements.value2:setborderwidth(0, 0.5, 0, 0)
end)

addtab("Total Deaths", function()
    resetheader()

    itemheader.elements.name:settext("NAME")
    itemheader.elements.value1:settext("DEATHS")
    itemheader.elements.value2:setborderwidth(0, 0.5, 0, 0)

    items[2].elements.name:settext(string.format("%s (You)", game:getdvar("name")))
    items[2].elements.value1:settext(data.total.deaths .. "")
    items[2].elements.value2:setborderwidth(0, 0.5, 0, 0)
end)

leaderboardsmenu:addcursor()