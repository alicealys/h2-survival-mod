local health = game:newhudelem()
health.font = "objective"
health.fontscale = 1.2
health.y = 400
health.alignx = "center"
health.horzalign = "center"
health.label = "&Health: "
health.glowalpha = 0.3
health.hidewhendead = true
health.hidewheninmenu = true

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

game:oninterval(function()
    health:setvalue(player.health)
    local percentage = player.health / player.maxhealth
    local hue = percentage * 120
    health.glowcolor = vector:new(hsvtorgb(hue, 1, 1))
end, 0)