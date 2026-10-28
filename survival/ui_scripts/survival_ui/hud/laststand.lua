local function vectorlerp(v1, v2, t)
    local lerpvec = {
        r = v1.r + (v2.r - v1.r) * t,
        g = v1.g + (v2.g - v1.g) * t,
        b = v1.b + (v2.b - v1.b) * t
    }
    
    return lerpvec
end

function addlaststandhud(parent)
    local hud = LUI.UIElement.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true
    })

    hud:registerAnimationState("hide", {
        alpha = 0
    })

    hud:registerAnimationState("show", {
        alpha = 1
    })

    local function createlaststandbar(offset)
        local laststand = {}

        local barwidth = 190
        local barheight = 15
        local padsize = 1
        local bottom = -195
        local iconoffset = -barwidth - 0
        local barwidthint = barwidth - padsize * 2

        laststand.container = LUI.UIElement.new({
            topAnchor = true,
            leftAnchor = true,
            rightAnchor = true,
            bottomAnchor = true,
        })

        laststand.icon = LUI.UIImage.new({
            leftAnchor = true,
            topAnchor = true,
            top = 720 + bottom - 32,
            left = 1280 / 2 - barwidth / 2 - 75,
            height = 50,
            width = 50,
            material = RegisterMaterial("specialty_pistoldeath")
        })

        laststand.progressbar = {}
        laststand.progressbar.bg = LUI.UIImage.new({
            leftAnchor = true,
            bottomAnchor = true,
            bottom = bottom,
            left = 1280 / 2 - barwidth / 2,
            height = barheight,
            width = barwidth,
            color = CoD.HudStandards.overlayTint,
            alpha = CoD.HudStandards.overlayAlpha,
            material = RegisterMaterial("white")
        })

        local barstate = {
            leftAnchor = true,
            bottomAnchor = true,
            bottom = bottom - padsize,
            left = 1280 / 2 - barwidth / 2 + padsize,
            height = barheight - padsize * 2,
            width = 0,
            alpha = 0.8,
            color = {
                r = 1,
                g = 0,  
                b = 0,
            },
            material = RegisterMaterial("white")
        }
    
        laststand.progressbar.bar = LUI.UIImage.new({
            leftAnchor = true,
            bottomAnchor = true,
            bottom = bottom - padsize,
            left = 1280 / 2 - barwidth / 2 + padsize,
            height = barheight - padsize * 2,
            width = 0,
            alpha = 0.8,
            color = {
                r = 1,
                g = 0,  
                b = 0,
            },
            material = RegisterMaterial("white")
        })

        laststand.container:addElement(laststand.progressbar.bg)
        laststand.container:addElement(laststand.progressbar.bar)
        laststand.container:addElement(laststand.icon)
        hud:addElement(laststand.container)
    
        local resettime = 20000

        local function setpercentanimate(value)
            local width = math.floor(barwidthint * value)

            local lightred = {r = 1, g = 0.4, b = 0.4}
            local red = {r = 1, g = 0, b = 0}
            local color = vectorlerp(red, lightred, value)

            laststand.progressbar.bar:registerAnimationState("current_width", {
                leftAnchor = true,
                bottomAnchor = true,
                bottom = bottom - padsize,
                left = 1280 / 2 - barwidth / 2 + padsize,
                height = barheight - padsize * 2,
                alpha = 0.8,
                color = color,
                material = RegisterMaterial("white"),
                width = width,
            })
    
            laststand.progressbar.bar:animateToState("current_width", 50)
        end

        laststand.setpercentanimate = setpercentanimate

        return laststand
    end

    local laststand = createlaststandbar()

    hud:registerEventHandler("set_laststand_percent", function(element, event)
        local value = tonumber(event.data)
        laststand.setpercentanimate(value)
    end)

    hud:registerEventHandler("toggle_laststand_bar", function(element, event)
        local show = event.data == "1"
        if (show) then
            hud:animateToState("show")

        else
            hud:animateToState("hide")
        end
    end)

    hud:animateToState("hide")

    parent:addElement(hud)
end
