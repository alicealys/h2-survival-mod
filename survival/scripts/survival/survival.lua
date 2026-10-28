require("precache")
require("menus")
require("utils")

function addscore(score)
    player:scriptcall("maps/_so_survival_h2mod", "add_score", score)
end

function showwavesummary(rewardarray)
    local stats = {}
    local totalbonus = 0
    local keys = rewardarray:getkeys()
    for k, v in pairs(keys) do
        if (v ~= "total") then
            local value = player.performance[v]
            if (v == "time") then
                value = string.format("%.1f", player.performance[v] / 1000)
            end

            stats[v] = {
                value = value,
                bonus = rewardarray[v]
            }
        end
    end

    stats.total = {value = 0, bonus = rewardarray["total"]}

    game:luinotify("so_survival_event", json.encode({
        name = "wave_end",
        stats = stats
    }))
end

function showeogsummary()
    game:setdvar("ui_current_wave", level.current_wave)
    game:sharedset("eog_extra_data", json.encode({
        stats = {
            {
                name = "@SO_SURVIVAL_PERFORMANCE_KILLS",
                value = player.game_performance["kill"]
            }, 
            {
                name = "@SO_SURVIVAL_PERFORMANCE_HEADSHOT",
                value = player.game_performance["headshot"]
            },
            {
                name = "@SO_SURVIVAL_PERFORMANCE_ACCURACY",
                value = player.game_performance["accuracy"],
                label = "@SO_SURVIVAL_PERFORMANCE_PERCENT"
            },
            {
                spacer = true,
            },
            {
                name = "@SO_SURVIVAL_PERFORMANCE_TIME",
                value = math.floor(math.min(((level.challenge_end_time) - level.challenge_start_time), 86400000)),
                istimestamp = true
            },
            {
                name = "@SO_SURVIVAL_PERFORMANCE_SCORE",
                value = level.so_survival_score_func(level)
            }
        }
    }))

    game:luinotify("show_survival_hud", "0")
    game:ontimeout(function()
        game:executecommand("lui_open so_eog_summary")
    end, 2000)
end

level:onnotify("show_wave_summary", showwavesummary)
level:onnotify("show_eog_summary", showeogsummary)
