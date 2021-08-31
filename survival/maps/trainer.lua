local map = {
    spawners = {},
    startweapon = "deserteagle",
    shotguns = {"m4_grunt"},
    smgs = {"m4_grunt"},
    rifles = {"m4_grunt"},
    blackout = 3000
}

map.premain = function()
end

map.main = function()
    if (game:getdvar("beautiful_corner") == "" or game:getdvar("beautiful_corner") == "0") then
        print("'beautiful_corner' must be enabled on this map. restarting...")
        game:say("'beautiful_corner' must be enabled on this map. restarting...")
        game:setdvar("beautiful_corner", 1)
        game:executecommand("map ending")
        return
    end

    game:oninterval(function()
        player:allowstand(true)
        player:allowcrouch(true)
        player:allowprone(true)
    end, 0)
end

return map