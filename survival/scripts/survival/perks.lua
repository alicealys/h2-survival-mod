local perks = {}

perks.fastreload = {
    cost = 3000,
    enabled = true,
    callback = function()
        perks.fastreload.enabled = false
        player:setperk("specialty_fastreload", true, true)
    end
}

perks.extrahealth = {
    cost = 1000,
    level = 0,
    enabled = true,
    callback = function()
        perks.extrahealth.level = perks.extrahealth.level + 1
        perks.extrahealth.cost = 1000 + perks.extrahealth.level * 1000
        player.armorlevel = player.armorlevel + 0.3

        if (perks.extrahealth.level >= 10) then
            perks.extrahealth.enabled = false
        end
    end 
}

perks.extradamage = {
    cost = 1000,
    level = 0,
    enabled = true,
    callback = function()
        perks.extradamage.level = perks.extradamage.level + 1
        perks.extradamage.cost = math.min(1000 * 2 ^ perks.extradamage.level, 50000)
        player.damage_multiplier = player.damage_multiplier + 0.3
    end 
}

game:oninterval(function()
    for k, v in pairs(perks) do
        game:sharedset("perks_" .. k .. "_enabled", v.enabled and "1" or "0")
        game:sharedset("perks_" .. k .. "_cost", v.cost .. "")

        if (v.level ~= nil) then
            game:sharedset("perks_" .. k .. "_level", v.level .. "")
        end
    end
end, 0)

player:onnotify("giveperk", function(perk)
    if (perks[perk] == nil or player.money < perks[perk].cost or perks[perk].enabled == false) then
        return
    end

    player.money = player.money - perks[perk].cost
    perks[perk].callback()
end)