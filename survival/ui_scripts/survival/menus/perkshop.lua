local perks = {
    {
        name = "fastreload",
        displayname = "Fast Reload"
    },
    {
        name = "extrahealth",
        displayname = "Armor"
    },
    {
        name = "extradamage",
        displayname = "Extra Damage"
    }
}

local money = sharedvalue("player_money")

LUI.MenuBuilder.registerType("survival_perk_shop_menu", function(a1)
    local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
    LUI.MenuTemplate.InitInGameBkg = function() end

    local menu = LUI.MenuTemplate.new(a1, {
        menu_title = "Weapon Armory",
        exclusiveController = 0,
        menu_width = 400,
        menu_top_indent = LUI.MenuTemplate.spMenuOffset,
        showTopRightSmallBar = true
    })

    LUI.MenuTemplate.InitInGameBkg = InitInGameBkg

    for _, perk in pairs(perks) do
        local cost = sharedvalue("perks_" .. perk.name .. "_cost")
        local enabled = sharedvalue("perks_" .. perk.name .. "_enabled")
        local level = sharedvalue("perks_" .. perk.name .. "_level")
        local money = sharedvalue("player_money")

        local button = nil

        local text = function()
            if (level.int == nil or level.int == 0) then
                return string.upper(perk.displayname)
            else
                return string.upper(perk.displayname) .. " (LEVEL " .. level.int + 1 .. ")"
            end
        end

        local update = function()
            if (enabled.int == 0) then
                if (not button.disabled) then
                    disablebutton(button, true)
                end
            else
                if (money.int < cost.int and not button.disabled) then
                    disablebutton(button, true)
                elseif (money.int >= cost.int and button.disabled) then
                    disablebutton(button, false)
                end
            end

            button.costlabel:setText(cost.int .. "$")
            button:setText(text())
        end

        button = addbuybutton(menu, {
            text = text(),
            cost = cost.int,
            disabled = money.int < cost.int or enabled.int == 0,
            callback = function()
                if (money.int - cost.int < cost.int and not button.disabled) then
                    disablebutton(button, true)
                elseif (money.int - cost.int >= cost.int and button.disabled) then
                    disablebutton(button, false)
                end

                player:notify("giveperk", perk.name)
                update()
            end
        })

        
        button:registerEventHandler("update_money", function()
            update()
        end)

        button:addElement(LUI.UITimer.new(50, "update_money"))
    end

    addmoneytext(menu)
    menu:AddBackButton()

    return menu
end)