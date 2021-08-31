local spacing = " - ^3"

return {
    width = 400,
    height = 310,
    background = vector:new(0.3, 0.35, 0.27),
    backgroundopacity = 1,
    cursorcolor = vector:new(0.51, 0.53, 0.51),
    title = "Air Support",
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
                "TEST - ^3$500",
            },
            onrender = function(player, button)
                for i = 1, #button do
                    button[i].alpha = player.money < 500 and 0.5 or 1
                end
            end,
            callback = function(player)
                if (player.money < 500) then
                    return
                end

                player.money = player.money - 500

                player:_closemenu()
            end
        },
        {
            text = {
                "Close"
            },
            onrender = function(player, button)
            end,
            callback = function(player)
                player:_closemenu()
            end
        }
    }
}