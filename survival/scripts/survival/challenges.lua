local csv = "sp/survival_challenge.csv"

function getnumchallenges()
    return 6
end

local currentchallenge = {
    {
        name = ""
    },
    {
        name = ""
    }
}

local inwave = false

local challenges = {}

local function getchallengewave(name)
    return tonumber(game:tablelookup(csv, 1, name, 10))
end

local function getchallenges()
    for i = 1, getnumchallenges() do
        local challenge = game:tablelookupbyrow(csv, i, 1)
        local wave = getchallengewave(challenge)
        if (currentwave >= wave) then
            table.insert(challenges, challenge)
        end
    end
end

local function getrandomchallenges()
    local challengescopy = {}
    for i = 1, #challenges do
        table.insert(challengescopy, challenges[i])
    end

    local challenge1 = challengescopy[game:randomint(#challengescopy) + 1]
    local challenge2 = challenge1
    while (challenge2 == challenge1) do
        challenge2 = challengescopy[game:randomint(#challengescopy) + 1]
    end

    return challenge1, challenge2
end

local function getchallengestring(name)
    return game:tablelookup(csv, 1, name, 2)
end

local function getchallengebasescore(name)
    return tonumber(game:tablelookup(csv, 1, name, 7))
end

local function getchallengetarget(name)
    return tonumber(game:tablelookup(csv, 1, name, 6))
end

local function getchallengesplash(name)
    return game:tablelookup(csv, 1, name, 4)
end

local function challengenotifyname(index, notify)
    return "challenge_" .. index .. "_" .. notify
end

local function setchallenge(index, challenge)
    currentchallenge[index].name = challenge
    currentchallenge[index].value = 0
    currentchallenge[index].level = 1
    currentchallenge[index].count = 0
    currentchallenge[index].progress = 0
    currentchallenge[index].targetcount = getchallengetarget(challenge)
    currentchallenge[index].basescore = getchallengebasescore(challenge)
    currentchallenge[index].currentscore = currentchallenge[index].basescore
    local str = getchallengestring(challenge)
    game:luinotify(challengenotifyname(index, "set_name"), str)
    game:luinotify(challengenotifyname(index, "set_score"), currentchallenge[index].basescore .. "")
end

local function setchallengeprogress(index, progress)
    game:luinotify(challengenotifyname(index, "set_percent"), tostring(progress))
end

local function setchallengeprogressdescrease(index, progress)
    currentchallenge[index].progress = progress
    game:luinotify(challengenotifyname(index, "set_percent_animate"), tostring(progress))
end

local function setchallengescore(index, score)
    currentchallenge[index].currentscore = score
    game:luinotify(challengenotifyname(index, "set_score"), tostring(score))
end

local function setchallengestring(index, str)
    currentchallenge[index].str = str
    game:luinotify(challengenotifyname(index, "set_name"), str)
end

local function setchallengehighlited(index)
    game:luinotify(challengenotifyname(index, "highlight"), "")
end

local challengecallbacks = {}
challengecallbacks["sur_ch_headshot"] = {}
challengecallbacks["sur_ch_streak"] = {}
challengecallbacks["sur_ch_stagger"] = {}
challengecallbacks["sur_ch_quadkill"] = {}
challengecallbacks["sur_ch_knife"] = {}
challengecallbacks["sur_ch_flash"] = {}

local function challengeevent(event, ...)
    if (not inwave) then
        return
    end

    for i = 1, #currentchallenge do
        if (challengecallbacks[currentchallenge[i].name][event]) then
            challengecallbacks[currentchallenge[i].name][event](i, ...)
        end
    end
end

local function increasechallengecount(index)
    currentchallenge[index].count = currentchallenge[index].count + 1
    if (currentchallenge[index].count >= currentchallenge[index].targetcount) then
        setchallengehighlited(index)

        addscore(currentchallenge[index].currentscore)
        addsplash({
            text = "&" .. getchallengesplash(currentchallenge[index].name),
            color = "orange",
            yoffset = -100,
            duration = 2000,
            sound = "survival_bonus_splash",
            value = currentchallenge[index].currentscore
        })

        currentchallenge[index].level = currentchallenge[index].level + 1
        currentchallenge[index].count = 0

        local nextscore = currentchallenge[index].basescore * currentchallenge[index].level

        setchallengescore(index, nextscore)
        setchallengeprogress(index, 0)
    else
        setchallengeprogress(index, (currentchallenge[index].count / currentchallenge[index].targetcount))
    end
end

local function resetchallengeprogress(index)
    currentchallenge[index].count = 0
    setchallengeprogress(index, 0)
end

challengecallbacks["sur_ch_streak"]["killed_enemy"] = increasechallengecount
challengecallbacks["sur_ch_streak"]["damage"] = function(index, damage, attacker)
    if (attacker ~= player and attacker.classname ~= "worldspawn") then
        resetchallengeprogress(index)
    end
end

challengecallbacks["sur_ch_headshot"]["headshot"] = increasechallengecount
challengecallbacks["sur_ch_knife"]["killed_enemy"] = function(index, guy)
    if (guy.lastmod == "MOD_MELEE") then
        increasechallengecount(index)
    else
        resetchallengeprogress(index)
    end
end

local staggertimeout = nil
local staggerinterval = nil
local starteddecreasing = false
local staggerchallengeindex = nil

local function clearstaggerinterval()
    if (staggerinterval) then
        staggerinterval:clear()
        staggerinterval = nil
    end

    if (staggertimeout) then
        staggertimeout:clear()
        staggertimeout = nil
    end

    starteddecreasing = false

    if (staggerchallengeindex) then
        game:luinotify(challengenotifyname(staggerchallengeindex, "set_stagger"), "0")
        setchallengeprogress(staggerchallengeindex, currentchallenge[staggerchallengeindex].progress)
        staggerchallengeindex = nil
    end
end

challengecallbacks["sur_ch_stagger"]["killed_enemy"] = function(index)
    if (staggertimeout == nil) then
        staggerchallengeindex = index
        staggertimeout = game:ontimeout(function()
            starteddecreasing = true
            setchallengeprogressdescrease(index, currentchallenge[staggerchallengeindex].progress)
            game:luinotify(challengenotifyname(staggerchallengeindex, "set_stagger"), "1")
            staggerinterval = game:oninterval(function()
                local step = 1 / 20000 * 50
                currentchallenge[staggerchallengeindex].progress = currentchallenge[staggerchallengeindex].progress - step
                if (currentchallenge[staggerchallengeindex].progress < 0) then
                    currentchallenge[staggerchallengeindex].progress = 0
                    game:setdvar("sur_ch_stagger_progress", currentchallenge[staggerchallengeindex].progress)
                    clearstaggerinterval()
                else
                    game:setdvar("sur_ch_stagger_progress", currentchallenge[staggerchallengeindex].progress)
                end
            end, 0)
        end, 3000)
    end

    currentchallenge[index].progress = currentchallenge[index].progress + (1 / 4)
    if (currentchallenge[index].progress >= 1.0) then
        setchallengehighlited(index)

        addscore(currentchallenge[index].currentscore)
        addsplash({
            text = "&" .. getchallengesplash(currentchallenge[index].name),
            color = "orange",
            yoffset = -100,
            duration = 2000,
            sound = "survival_bonus_splash",
            value = currentchallenge[index].currentscore
        })

        currentchallenge[index].level = currentchallenge[index].level + 1
        currentchallenge[index].progress = 0

        local nextscore = currentchallenge[index].basescore * currentchallenge[index].level

        setchallengescore(index, nextscore)
    end

    if (starteddecreasing) then
        setchallengeprogressdescrease(index, currentchallenge[index].progress)
        game:luinotify(challengenotifyname(staggerchallengeindex, "set_stagger"), "1")
        game:setdvar("sur_ch_stagger_progress", currentchallenge[staggerchallengeindex].progress)
    else
        setchallengeprogress(index, currentchallenge[index].progress)
        game:setdvar("sur_ch_stagger_progress", currentchallenge[staggerchallengeindex].progress)
    end
end

challengecallbacks["sur_ch_flash"]["killed_enemy"] = function(index, guy)
    if (guy:isflashed()) then
        increasechallengecount(index)
    end
end

local quadkilltimeout = nil
local quadkillnum = 0
challengecallbacks["sur_ch_quadkill"]["killed_enemy"] = function(index, guy)
    if (quadkilltimeout == nil) then
        quadkillnum = 0
        quadkilltimeout = game:ontimeout(function()
            quadkilltimeout = nil
            quadkillnum = 0
        end, 0)
    end

    quadkillnum = quadkillnum + 1
    if (quadkillnum >= 4) then
        quadkillnum = 0
        increasechallengecount(index)
    end
end

local function registerevent(notify)
    player:onnotify(notify, function(...)
        challengeevent(notify, ...)
    end)
end

registerevent("killed_enemy")
registerevent("damage")
registerevent("headshot")

level:onnotify("wave_started", function()
    inwave = true
    getchallenges()

    game:luinotify("challenge_fade_in", "")
    game:luinotify("challenge_1_set_percent", "0")
    game:luinotify("challenge_2_set_percent", "0")

    local challenge1, challenge2 = getrandomchallenges()
    setchallenge(1, challenge1)
    setchallenge(2, challenge2)
end)

level:onnotify("wave_ended", function()
    clearstaggerinterval()
    inwave = false
end)