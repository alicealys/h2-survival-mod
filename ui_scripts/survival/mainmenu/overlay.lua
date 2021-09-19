local ui = require("utils/ui")

local overlay = game:newmenuoverlay("campaign_menu_overlay", "main_campaign")

local button = ui.createbutton(overlay, "survival", 500, 188, 360)
button.onclick = function()
    game:luiopen("menu_xenon_install_complete")
end

overlay:addcursor()