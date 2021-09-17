local testmenu = game:newmenu("_test_menu")
local cinematic = element:new()
cinematic:setrect(0, 0, 1920, 1080)
cinematic:setmaterial("cinematic")
cinematic:setbackcolor(1, 1, 1, 1)

local scrollbarback = element:new()
scrollbarback:setfont("bank", 30)
scrollbarback:setrect(500, 500, 500, 50)
scrollbarback:setcolor(0.8, 1, 0.8, 1)
scrollbarback.text_style = "rainbow"

testmenu:addchild(scrollbarback)
testmenu:open()

function hsvtorgb(hue, saturation, value)
	if (saturation == 0) then
		return value
	end

	local hue_sector = math.floor(hue / 60)
	local hue_sector_offset = (hue / 60) - hue_sector

	local p = value * (1 - saturation)
	local q = value * (1 - saturation * hue_sector_offset)
	local t = value * (1 - saturation * (1 - hue_sector_offset))

	if (hue_sector == 0) then
		return value, t, p
	elseif (hue_sector == 1) then
		return q, value, p
	elseif (hue_sector == 2) then
		return p, value, t
	elseif (hue_sector == 3) then
		return p, q, value
	elseif (hue_sector == 4) then
		return t, p, value
	elseif (hue_sector == 5) then
		return value, p, q
	end
end
