require("objects/hintstring")

function createammocache(origin, cost)
    local entity = game:spawn("script_origin", origin)

    local hintstring = createhintstring({
        radius = 100,
        entity = entity,
        lookatradius = 30,
        text = string.format("Press ^3[{+activate}]^7 for ammo (Cost: %i)", cost)
    })

    entity:onnotify("trigger", function()
        if (player.money < cost) then
            player:playlocalsound("ui_tk_click_error")
            return
        end

        player.money = player.money - cost
        local weapons = player:getweaponslistall()
        for i = 1, #weapons do
            player:givemaxammo(weapons[i])
            player:setweaponammoclip(weapons[i], 1000)
        end
    end)
end