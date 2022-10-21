function addperkshud(parent)
    local hud = LUI.UIElement.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true
    })

    parent:addElement(hud)

    local addanimationstates = function(element)
        element:registerAnimationState("hide", {
            alpha = 0
        })

        element:registerAnimationState("show", {
            alpha = 1
        })

        element:animateToState("hide")
    end

    local laststand = LUI.UIImage.new({
        bottomAnchor = true,
        leftAnchor = true,
        height = 60,
        width = 60,
        left = 320,
        bottom = -15,
        alpha = 1,
        material = RegisterMaterial("specialty_pistoldeath")
    })

    hud:addElement(laststand)
   
    local perk = LUI.UIImage.new({
        bottomAnchor = true,
        leftAnchor = true,
        height = 60,
        width = 60,
        left = 400,
        bottom = -15,
        alpha = 1,
        material = RegisterMaterial("specialty_fastreload")
    })

    hud:addElement(perk)

    local armor = LUI.UIImage.new({
        bottomAnchor = true,
        leftAnchor = true,
        height = 60,
        width = 60,
        left = 560,
        bottom = -15,
        alpha = 1,
        material = RegisterMaterial("specialty_armorvest")
    })

    armor:registerAnimationState("zoom", {
        bottomAnchor = true,
        leftAnchor = true,
        height = 70,
        width = 70,
        left = 555,
        bottom = -10,
        alpha = 1,
        material = RegisterMaterial("specialty_armorvest")
    })

    local armorlevellabel = LUI.UIText.new({
        bottomAnchor = true,
        leftAnchor = true,
        height = 20,
        width = 60,
        left = 490,
        bottom = -35,
        alpha = 1,
        alignment = LUI.Alignment.Right,
        font = RegisterFont("fonts/bank.ttf", 30)
    })

    armorlevellabel:setText(Engine.Localize("SO_SURVIVAL_ARMOR_POINTS", ""))

    local armorlevel = LUI.UIText.new({
        bottomAnchor = true,
        leftAnchor = true,
        height = 20,
        width = 60,
        left = 630,
        bottom = -35,
        alpha = 1,
        alignment = LUI.Alignment.Left,
        font = RegisterFont("fonts/bank.ttf", 30)
    })

    armorlevel:setText("250")

    addanimationstates(laststand)
    addanimationstates(perk)
    addanimationstates(armor)
    addanimationstates(armorlevel)
    addanimationstates(armorlevellabel)

    hud:registerEventHandler("set_armor_level", function(element, event)
        if (hud.hidearmortimer) then
            hud.hidearmortimer:close()
            hud.hidearmortimer = nil
        end
        
        local value = tonumber(event.data)

        if (value <= 0) then
            armorlevellabel:animateToState("hide")
            armorlevel:animateToState("hide")
            armor:animateToState("hide")
        else
            armor:animateToState("show", 100)
            armorlevel:animateToState("show", 100)
            armorlevellabel:animateToState("show", 100)
            armorlevel:setText(value)

            armor:animateInSequence({
                {
                    "default",
                    0
                },
                {
                    "zoom",
                    100
                },
                {
                    "default",
                    100
                }
            })

            hud.hidearmortimer = LUI.UITimer.new(3000, "hide_armor")
            hud:addElement(hud.hidearmortimer)

            hud:registerEventHandler("hide_armor", function()
                armorlevel:animateToState("hide", 1000)
                armorlevellabel:animateToState("hide", 1000)
            end)
        end
    end)

    hud:registerEventHandler("set_perk", function(element, event)
        if (event.data == "") then
            perk:animateToState("hide")
        else
            perk:animateToState("show")
            perk:setImage(RegisterMaterial(event.data))
        end
    end)

    hud:registerEventHandler("toggle_laststand", function(element, event)
        if (event.data == "1") then
            laststand:animateToState("show")
        else
            laststand:animateToState("hide")
        end
    end)

    armorlevel:setTextStyle(CoD.TextStyle.Shadowed)
    armorlevellabel:setTextStyle(CoD.TextStyle.Shadowed)

    hud:addElement(armor)
    hud:addElement(armorlevel)
    hud:addElement(armorlevellabel)
end
