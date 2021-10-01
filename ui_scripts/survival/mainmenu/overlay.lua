local ui = require("utils/ui")

function findelement(id, root)
    root = root or game:getluiroot()

    local first = root:getfirstchild()
    while (first) do
        if (first.id == id) then
            return first
        end

        local found = findelement(id, first)
        if (found) then
            return found
        end

        first = first:getnextsibling()
    end
end

function userdata_:findelement(id)
    local first = self:getfirstchild()
    while (first) do
        if (first.id == id) then
            return first
        end

        local found = findelement(id, first)
        if (found) then
            return found
        end

        first = first:getnextsibling()
    end
end

local overlay = game:newmenuoverlay("main_campaign_overlay", "main_campaign")
local wasopen = false
game:onframe(function()
    local open = overlay:isopen()
    if (open and not wasopen) then
        wasopen = true
        overlay:notify("open")
    elseif (not open) then
        wasopen = false
    end
end)

local area = element:new()
area:setrect(100, 437, 361, 48)
overlay:addchild(area)

area:onnotify("click", function()
    game:luiopen("menu_xenon_install_complete")
end)

area:onnotify("mouseenter", function()
    local maincampaign = findelement("main_campaign_container")
    local hintbox = maincampaign:getlastchild():getprevioussibling()
    local text = hintbox:getfirstchild()
end)

overlay:onnotify("open", function()
    local intel = findelement("main_campaign_button_4")
    local intelbutton = intel:getfirstchild()
    intel.m_eventHandlers.button_action = nil
    intel.properties.desc_text = "Play Survival."
    intel:findelement("text_label"):settextinc("SURVIVAL")
end)