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

overlay:onnotify("open", function()
    local maincampaign = findelement("main_campaign_container")
    local buttonlist = maincampaign:getChildById("main_campaign_list")
    local button = maincampaign:AddButton("@MENU_SP_SURVIVAL_MODE_CAPS", function()
        game:luiopen("menu_xenon_install_complete")
    end, nil, true, nil, {
        desc_text = "Play Survival."
    })

    buttonlist:removeElement(button)
    buttonlist:insertElement(button, 4)

    local hintbox = maincampaign.optionTextInfo
    local firstbutton = buttonlist:getfirstchild()
    hintbox:dispatchEventToRoot({
        name = "set_button_info_text",
        text = firstbutton.properties.desc_text,
        immediate = true
    })

    maincampaign:CreateBottomDivider()
    maincampaign:AddBottomDividerToList(buttonlist:getlastchild())

    maincampaign.list.listHeight = 375
    maincampaign:removeElement(maincampaign.optionTextInfo)
    maincampaign.optionTextInfo = LUI.Options.AddOptionTextInfo(maincampaign)
end)