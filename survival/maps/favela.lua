if (game:getdvar("beautiful_corner") == "0") then
    print("'beautiful_corner' must be enabled on this map. restarting...")
    game:setdvar("beautiful_corner", 1)
    game:executecommand("fast_restart")
    return
end

