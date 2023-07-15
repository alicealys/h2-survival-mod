Colors.mw3_green = {
    r = 153 / 255,
    g = 216 / 255,
    b = 153 / 255,
}

local togglepause = Engine.TogglePause
Engine.TogglePause = function(...)
    togglepause(...)
    if (not Engine.GetDvarBool("cl_paused")) then
        LUI.roots.UIRoot0:processEvent({
            name = "unpaused",
            dispatchChildren = true
        })
    end
end

local function addscorechallenges(hud)
    local leftoffset = 50
    local blurheight = 60
    local blurwidth = CoD.HudStandards.weaponBoxWidth
    local bgwidth = 300
    local padsize = 1
    local barwidth = 150
    local barwidthint = 150 - padsize * 2
    local topoffset = 575
    local barheight = 13
    local topblurheight = 150
    local textheight = 20
    local offsetfromtext = 4

    local challengeindex = 0
    local function createchallengebar(offset)
        challengeindex = challengeindex + 1

        local challenge = {}
        challenge.container = LUI.UIElement.new({
            topAnchor = true,
            leftAnchor = true,
            left = -500,
            top = topoffset + offset,
            height = textheight,
        })
    
        challenge.container:registerAnimationState("show", {
            topAnchor = true,
            leftAnchor = true,
            left = leftoffset,
            top = topoffset + offset,
            height = textheight,
        })
    
        challenge.text = LUI.UIText.new({
            topAnchor = true,
            leftAnchor = true,
            height = textheight,
            font = RegisterFont("fonts/bank.ttf", 50)
        })
    
        challenge.score = LUI.UIText.new({
            topAnchor = true,
            leftAnchor = true,
            left = barwidth + offsetfromtext,
            top = textheight,
            height = textheight,
            font = RegisterFont("fonts/bank.ttf", 50)
        })
    
        challenge.text:setTextStyle(CoD.TextStyle.Shadowed)
        challenge.score:setTextStyle(CoD.TextStyle.Shadowed)
    
        challenge.progressbar = {}
        challenge.progressbar.bg = LUI.UIImage.new({
            topAnchor = true,
            leftAnchor = true,
            top = textheight + offsetfromtext,
            height = barheight,
            width = barwidth,
            color = CoD.HudStandards.overlayTint,
            alpha = CoD.HudStandards.overlayAlpha,
            material = RegisterMaterial("white")
        })
    
        challenge.progressbar.bar = LUI.UIImage.new({
            topAnchor = true,
            leftAnchor = true,
            left = padsize,
            top = textheight + offsetfromtext + padsize,
            height = barheight - padsize * 2,
            width = barwidthint,
            alpha = 0.8,
            color = {
                r = 0.9,
                g = 0.9,
                b = 0.9,
            },
            material = RegisterMaterial("white")
        })
    
    
        challenge.text:registerAnimationState("highlight", {
            color = Colors.h2.yellow
        })
    
        challenge.score:registerAnimationState("highlight", {
            color = Colors.h2.yellow
        })
    
        challenge.progressbar.bar:registerAnimationState("highlight", {
            material = RegisterMaterial("h1_ui_progressbar_green")
        })
    
        challenge.text:registerAnimationState("un_highlight", {
            color = Colors.white
        })
    
        challenge.score:registerAnimationState("un_highlight", {
            color = Colors.white
        })
    
        challenge.progressbar.bar:registerAnimationState("un_highlight", {
            material = RegisterMaterial("white")
        })

        challenge.container:addElement(challenge.progressbar.bg)
        challenge.container:addElement(challenge.progressbar.bar)
        challenge.container:addElement(challenge.text)
        challenge.container:addElement(challenge.score)
        hud:addElement(challenge.container)

        local name = "challenge_" .. challengeindex .. "_"

        hud:registerEventHandler(name .. "set_percent", function(element, event)
            local value = tonumber(event.data)
            local width = barwidthint * value
            challenge.progressbar.bar:registerAnimationState("current_width", {
                topAnchor = true,
                leftAnchor = true,
                left = padsize,
                top = textheight + offsetfromtext + padsize,
                height = barheight - padsize * 2,
                width = math.floor(width),
            })
    
            challenge.progressbar.bar:animateToState("current_width", 50)
        end)
    
        local resettime = 20000
        local isstagger = false

        local function setpercentanimate(value)
            isstagger = true
            local width = math.floor(barwidthint * value)
            challenge.progressbar.bar:registerAnimationState("current_width", {
                topAnchor = true,
                leftAnchor = true,
                left = padsize,
                top = textheight + offsetfromtext + padsize,
                height = barheight - padsize * 2,
                width = width,
            })
    
            challenge.progressbar.bar:registerAnimationState("empty", {
                topAnchor = true,
                leftAnchor = true,
                left =  padsize,
                top = textheight + offsetfromtext + padsize,
                height = barheight - padsize * 2,
                width = 0,
            })
    
            challenge.progressbar.bar:animateToState("current_width")
            challenge.progressbar.bar:animateToState("empty", math.floor(width / barwidthint * resettime))
        end

        hud:registerEventHandler(name .. "unpaused", function(element, event)
            print("unpaused", isstagger)
            if (isstagger) then
                local value = tonumber(Engine.GetDvarString("sur_ch_stagger_progress"))
                setpercentanimate(value)
            end
        end)
    
        hud:registerEventHandler(name .. "set_percent_animate", function(element, event)
            local value = tonumber(event.data)
            setpercentanimate(value)
        end)

        hud:registerEventHandler(name .. "set_name", function(element, event)
            isstagger = false
            challenge.text:setText(Engine.Localize(event.data))
        end)

        hud:registerEventHandler(name .. "set_score", function(element, event)
            challenge.score:setText(Engine.Localize("@SO_SURVIVAL_CREDITS", event.data))
        end)
    
        hud:registerEventHandler(name .. "highlight", function(element, event)
            if (event.data == "1") then
                challenge.text:animateToState("highlight")
                challenge.score:animateToState("highlight")
                challenge.progressbar.bar:animateToState("highlight")
            else
                challenge.text:animateToState("un_highlight")
                challenge.score:animateToState("un_highlight")
                challenge.progressbar.bar:animateToState("un_highlight")
            end
        end)

        return challenge
    end

    local challenges = {}
    table.insert(challenges, createchallengebar(0))
    table.insert(challenges, createchallengebar(40))

    hud:registerEventHandler("unpaused", function()
        for i = 1, #challenges do
            hud:processEvent({
                name = "challenge_" .. i .. "_unpaused"
            })
        end
    end)

    hud:registerEventHandler("challenge_fade_in", function()
        for i = 1, #challenges do
            challenges[i].container:animateToState("default")
            challenges[i].progressbar.bar:animateToState("un_highlight")
            challenges[i].text:animateToState("un_highlight")
            challenges[i].score:animateToState("un_highlight")
        end

        local timer = LUI.UITimer.new(350, "show_second_challenge")
        if (hud.challengetimer ~= nil) then
            hud.challengetimer:close()
            hud.challengetimer = nil
        end

        hud.challengetimer = timer
        hud:addElement(timer)
        challenges[1].container:animateToState("show", 150)
        hud:registerEventHandler("show_second_challenge", function()
            hud.challengetimer:close()
            hud.challengetimer = nil
            challenges[2].container:animateToState("show", 150)
        end)
    end)
end

function addscorehud(parent)
    local hud = LUI.UIElement.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true
    })

    parent:addElement(hud)

    local wavenum = LUI.UIText.new({
        leftAnchor = true,
        topAnchor = true,
        height = 25,
        top = 215,
        left = 40,
        alpha = 0,
        font = RegisterFont("fonts/bank.ttf", 30)
    })

    wavenum:setTextStyle(CoD.TextStyle.Shadowed)

    wavenum:registerAnimationState("show", {
        alpha = 1,
    })

    wavenum:registerEventHandler("set_wave_num", function (element, event)
        wavenum:animateToState("show")
        wavenum:setText(Engine.Localize("@SO_SURVIVAL_WAVE_TIME", event.data))
    end)

    hud:addElement(wavenum)

    local scoresplash = LUI.UIText.new({
        leftAnchor = true,
        rightAnchor = true,
        topAnchor = true,
        aligment = LUI.Alignment.Center,
        top = 250,
        height = 30,
        alpha = 1,
        color = Colors.mw3_green,
        font = RegisterFont("fonts/bank.ttf", 30)
    })

    scoresplash:registerAnimationState("move", {
        bottomAnchor = true,
        leftAnchor = true,
        left = 50,
        bottom = -20,
        height = 40,
        alpha = 0
    })

    scoresplash:registerAnimationState("big", {
        leftAnchor = true,
        rightAnchor = true,
        topAnchor = true,
        aligment = LUI.Alignment.Center,
        top = 240,
        height = 50,
        alpha = 1,
    })

    scoresplash:registerAnimationState("normal", {
        leftAnchor = true,
        rightAnchor = true,
        topAnchor = true,
        aligment = LUI.Alignment.Center,
        top = 250,
        height = 30,
        alpha = 1,
    })

    scoresplash.currentvalue = 0

    scoresplash:setTextStyle(CoD.TextStyle.Shadowed)

    local score = LUI.UIText.new({
        bottomAnchor = true,
        leftAnchor = true,
        left = 20,
        bottom = -20,
        height = 40,
        color = Colors.white,
        font = RegisterFont("fonts/bank.ttf", 30)
    })

    local leftoffset = 50
    local blurheight = 60
    local blurwidth = CoD.HudStandards.weaponBoxWidth
    local topoffset = 660
    local topblurheight = 150

    local blur = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        left = leftoffset - 10,
        top = topoffset,
        width = blurwidth,
        height = blurheight,
        alpha = CoD.HudStandards.blurAlpha,
        material = RegisterMaterial("h1_hud_weapwidget_blur") -- h1_hud_weapwidget_blur
    })
    
    local topblur = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        left = leftoffset - 10,
        top = topoffset - topblurheight + 1,
        width = CoD.HudStandards.weaponBoxWidth,
        height = topblurheight,
        alpha = CoD.HudStandards.blurAlpha,
        material = RegisterMaterial("h1_hud_weapwidget_blur") -- h1_hud_weapwidget_blur
    })

    local topborder = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        left = leftoffset - 10,
        top = topoffset - topblurheight,
        width = CoD.HudStandards.weaponBoxWidth,
        height = topblurheight,
        color = CoD.HudStandards.overlayTint,
        alpha = CoD.HudStandards.overlayAlpha,
        material = RegisterMaterial("h1_hud_weapwidget_border_bottom")
    })

    local border = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        left = leftoffset - 10,
        top = topoffset,
        width = CoD.HudStandards.weaponBoxWidth,
        height = blurheight,
        color = CoD.HudStandards.overlayTint,
        alpha = CoD.HudStandards.overlayAlpha,
        material = RegisterMaterial("h1_hud_weapwidget_border")
    })

    blur:setup9SliceImage(1, 0, 1, 1)
    topblur:setup9SliceImage(1, 0, 1, 0)
    border:setup9SliceImageNoScale(1, 0, 1, 1)
    topborder:setup9SliceImageNoScale(1, 0, 1, 1)
    hud:addElement(blur)
    hud:addElement(border)
    hud:addElement(topblur)
    hud:addElement(topborder)

    addscorechallenges(hud)

    score:registerAnimationState("focused", {
        topAnchor = true,
        leftAnchor = true,
        left = leftoffset,
        top = topoffset,
        height = 35,
        color = Colors.mw3_green,
    })

    score:registerAnimationState("unfocused", {
        topAnchor = true,
        leftAnchor = true,
        left = leftoffset,
        top = topoffset,
        height = 35,
        color = Colors.white,
    })

    score:addElement(LUI.UITimer.new(10, "update_value"))
    score:registerEventHandler("update_value", function()
        if (score.currentvalue == nil or score.targetvalue == nil) then
            score:animateToState("unfocused")
            return
        end

        if (score.currentvalue < score.targetvalue) then
            score:animateToState("focused")
            score.currentvalue = score.currentvalue + score.step * 10
        elseif (score.targetvalue) then
            score:animateToState("unfocused")
            score.currentvalue = score.targetvalue
            score.targetvalue = nil
        end

        score:setText(Engine.Localize("@SO_SURVIVAL_CREDITS", math.floor(score.currentvalue)))
    end)

    score.currentvalue = tonumber(Engine.GetDvarString("ui_current_score")) or 0

    function score:addvalue(value)
        score:animateToState("focused")

        score.currentvalue = tonumber(Engine.GetDvarString("ui_current_score")) - value
        score.targetvalue = score.currentvalue + value
        score.step = (score.targetvalue - score.currentvalue) / 1000

        score:setText(Engine.Localize("@SO_SURVIVAL_CREDITS", math.floor(score.currentvalue)))
    end

    function scoresplash:addvalue(value)
        scoresplash:animateToState("default")
        scoresplash.currentvalue = scoresplash.currentvalue + value
        scoresplash:setText("+" .. tostring(scoresplash.currentvalue))

        scoresplash:animateInSequence({
            {
                "normal",
                0
            },
            {
                "big",
                50
            },
            {
                "normal",
                100
            }
        })

        if (scoresplash.timer) then
            scoresplash.timer:close()
            scoresplash.timer = nil
        end

        if (scoresplash.endtimer) then
            scoresplash.endtimer:close()
            scoresplash.endtimer = nil
        end

        local timer = LUI.UITimer.new(1000, "move_score")
        scoresplash.timer = timer
        scoresplash:addElement(timer)
        scoresplash:registerEventHandler("move_score", function()
            scoresplash:removeElement(scoresplash.timer)
            scoresplash.timer = nil
            
            scoresplash:animateToState("move", 300)

            local endtimer = LUI.UITimer.new(300, "finished")
            scoresplash.endtimer = endtimer
            scoresplash:addElement(endtimer)

            scoresplash:registerEventHandler("finished", function()
                scoresplash:removeElement(endtimer)
                scoresplash.endtimer = nil

                score:addvalue(scoresplash.currentvalue)
                scoresplash.currentvalue = 0
            end)
        end)
    end
    
    score:registerEventHandler("add_score", function(element, event)
        local value = tonumber(event.data)
        if (value > 0) then
            scoresplash:addvalue(value)
        else
            score:addvalue(value)
        end
    end)

    score:registerEventHandler("reset_score", function(element, event)
        score.currentvalue = 0
        score:setText(Engine.Localize("@SO_SURVIVAL_CREDITS", 0))
    end)

    score:setText(Engine.Localize("@SO_SURVIVAL_CREDITS", score.currentvalue))
    score:setTextStyle(CoD.TextStyle.Shadowed)

    hud:addElement(score)
    hud:addElement(scoresplash)
end
