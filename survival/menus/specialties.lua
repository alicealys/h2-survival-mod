return {
    width = 400,
    height = 310,
    background = vector:new(0.3, 0.35, 0.27),
    backgroundopacity = 1,
    cursorcolor = vector:new(0.51, 0.53, 0.51),
    title = "Specialties",
    titlebackground = vector:new(0.17, 0.19, 0.18),
    titlegradient = vector:new(0, 0, 0),
    onopen = function(player)
        player:freezecontrols(true)
    end,
    onclose = function(player)
        game:ontimeout(function()
            player:freezecontrols(false)
        end, 100)
    end,
    canopen = function(player)
        return true
    end,
    buttons = {
        {
            text = {
                "OK"
            },
            onrender = function(player, button)
            end,
            callback = function(player)
                player:_closemenu()
            end
        }
    }
}