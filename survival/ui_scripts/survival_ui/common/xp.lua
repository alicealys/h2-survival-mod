local rankcsv = "sp/ranktable.csv"
local rankcols = {
	rank = 0,
	name = 1,
	xpmin = 2,
	xpcount = 3,
	namestr = 4,
	namestrfull = 5,
	icon = 6,
	xpmax = 7,
}

function getrankforxp(xp)
	local rowcount = Engine.TableGetRowCount(rankcsv)
	for i = 2, rowcount do
		local rank = tonumber(Engine.TableLookupByRow(rankcsv, i, rankcols.rank))
		local xpmin = tonumber(Engine.TableLookupByRow(rankcsv, i, rankcols.xpmin))
		local xpmax = tonumber(Engine.TableLookupByRow(rankcsv, i, rankcols.xpmax))
		local icon = Engine.TableLookupByRow(rankcsv, i, rankcols.icon)

		if (xpmin ~= nil or xpcount ~= nil) then
			if (xp >= xpmin and xp < xpmax or (i == rowcount - 1)) then
				return (rank + 1), icon, (i == rowcount - 1)
			end
		end
	end

	return 0, "", false
end

function getrankinfo(r)
	local rowcount = Engine.TableGetRowCount(rankcsv)
	for i = 2, rowcount do
		local rank = tonumber(Engine.TableLookupByRow(rankcsv, i, rankcols.rank))
		if (rank == r) then
			local t = {}
			for k, v in pairs(rankcols) do
				t[k] = Engine.TableLookupByRow(rankcsv, i, v)
			end
			return t
		end
	end
	return {}
end

function getxp()
	return mods.stats.getor("experience", 0)
end

function getrank()
	return getrankforxp(getxp())
end

local createprogressbar = function(left, bottom, width)
    local barwidth = width
    local progressbar = LUI.UIElement.new({
        bottomAnchor = true,
        leftAnchor = true,
        width = barwidth,
        left = left,
        bottom = bottom,
        height = 15
    })

    local bg = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true,
        alpha = 0.55,
        color = Colors.grey_14,
    })

    local bar = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        bottomAnchor = true,
        width = 0,
        material = RegisterMaterial("h1_ui_progressbar_green")
    })

    progressbar.setprogress = function(fraction, disableanimation)
        bar:registerAnimationState("progress", {
            topAnchor = true,
            leftAnchor = true,
            bottomAnchor = true,
            width = fraction * (barwidth),
        })
        
        bar:animateToState("progress", disableanimation and 0 or 300)
    end

    progressbar:addElement(bg)
    progressbar:addElement(bar)
    progressbar:addElement(LUI.DecoFrame.new(nil, LUI.DecoFrame.Grey))

    return progressbar
end

function addplayerprogression(menu, width, disableanimation, left, top)
    local rank, icon, max = getrank()
    local rankid = rank - 1
    local rankinfo = getrankinfo(rankid)
    local ranknext = max and getrankinfo(rankid) or getrankinfo(rankid + 1)
    local rankprev = max and getrankinfo(rankid - 1) or getrankinfo(rankid)

    local ranknextvalue = max and rank or rank + 1
    local rankprevvalue = max and rank - 1 or rank

    local xpmax = tonumber(rankinfo.xpmax)

    local height = 90
    local container = LUI.UIElement.new({
        leftAnchor = true,
        topAnchor = true,
        width = width,
        height = height,
        left = left,
        top = top
    })

    local bg = LUI.UIImage.new({
        topAnchor = true,
        leftAnchor = true,
        rightAnchor = true,
        bottomAnchor = true,
        color = Colors.black,
        material = RegisterMaterial("white"),
        alpha = 0.55,
    })

    bg:addElement(LUI.DecoFrame.new(nil, LUI.DecoFrame.Black))

    local iconheight = 50
    local iconoffset = 5

    local iconleft = LUI.UIImage.new({
        topAnchor =  true,
        leftAnchor = true,
        left = 10,
        top = iconoffset,
        height = iconheight,
        width = iconheight,
        material = RegisterMaterial(rankprev.icon)
    })

    local iconright = LUI.UIImage.new({
        topAnchor =  true,
        rightAnchor = true,
        right = -10,
        top = iconoffset,
        height = iconheight,
        width = iconheight,
        material = RegisterMaterial(ranknext.icon)
    })

    local xptext = LUI.UIText.new({
        topAnchor = true,
        leftAnchor = true,
        left = 0,
        width = width,
        alignment = LUI.Alignment.Center,
        color = Colors.h2.yellow,
        top = 35,
        font = CoD.TextSettings.Font24.Font,
        height = CoD.TextSettings.Font24.Height,
    })
    
    local rankoffset = 60
    local rankleft = LUI.UIText.new({
        topAnchor = true,
        leftAnchor = true,
        left = rankoffset,
        width = width,
        color = {
            r = 0.8,
            g = 0.8,
            b = 0.8,
        },
        top = 25,
        font = CoD.TextSettings.Font24.Font,
        height = CoD.TextSettings.Font24.Height,
    })
    
    local rankright = LUI.UIText.new({
        topAnchor = true,
        rightAnchor = true,
        right = -rankoffset,
        width = width,
        color = {
            r = 0.8,
            g = 0.8,
            b = 0.8,
        },
        top = 25,
        font = CoD.TextSettings.Font24.Font,
        height = CoD.TextSettings.Font24.Height,
    })

    local ranknametext = LUI.UIText.new({
        topAnchor = true,
        leftAnchor = true,
        left = 0,
        width = width,
        alignment = LUI.Alignment.Center,
        color = {
            r = 0.8,
            g = 0.8,
            b = 0.8,
        },
        top = 15,
        font = CoD.TextSettings.Font24.Font,
        height = CoD.TextSettings.Font24.Height,
    })

    local currentxp = getxp()
    xptext:setText(Engine.Localize("@MENU_SP_X_SLASH_Y_XP", currentxp, xpmax))

    ranknametext:setText(Engine.Localize(rankinfo.namestrfull))

    local progressbar = createprogressbar(10, -10, width - 20)
    progressbar.setprogress((currentxp - rankinfo.xpmin) / (xpmax - rankinfo.xpmin), disableanimation)

    rankleft:setText(rankprevvalue)
    rankright:setText(ranknextvalue)

    container:addElement(bg)
    container:addElement(iconright)
    container:addElement(iconleft)
    container:addElement(progressbar)
    container:addElement(xptext)
    container:addElement(ranknametext)
    container:addElement(rankleft)
    container:addElement(rankright)

    if (menu.list) then
        menu.list:addElement(container)
    else
        menu:addElement(container)
    end
end