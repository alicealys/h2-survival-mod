local map = {
    spawners = {},
    startweapon = "beretta",
    shotguns = {"ak47"},
    smgs = {"ak47"},
    rifles = {"ak47"},
    blackout = 3000
}

map.premain = function()
    game:detour("maps/ending", "main", function() end)
end

map.main = function()
    if (game:getdvar("beautiful_corner") == "" or game:getdvar("beautiful_corner") == "0") then
        print("'beautiful_corner' must be enabled on this map. restarting...")
        game:say("'beautiful_corner' must be enabled on this map. restarting...")
        game:setdvar("beautiful_corner", 1)
        game:executecommand("map ending")
        return
    end

    player:setviewmodel("viewhands_us_army")
end

return map