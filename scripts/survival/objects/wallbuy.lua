require("objects/hintstring")

local hudicons = {
	["40mm_grenade"] = "hud_icon_40mm_grenade",
	["aa12"] = "hud_icon_aa12",
	["ak47"] = "hud_icon_ak47",
	["ak47_acog"] = "hud_icon_ak47_acog",
	["ak47_eotech"] = "hud_icon_ak47_eotech",
	["ak47_grenadier"] = "hud_icon_ak47_grenadier",
	["ak47_reflex"] = "hud_icon_ak47_reflex",
	["ak47_shotgun"] = "hud_icon_ak47_shotgun",
	["barrett"] = "hud_icon_barrett50cal",
	["bayonet"] = "hud_icon_bayonet",
	["m4"] = "hud_icon_benelli_m4",
	["c4"] = "hud_icon_c4",
	["cheytac"] = "hud_icon_cheytac",
	["claymore"] = "hud_icon_claymore",
	["cobra"] = "hud_icon_cobra",
	["coltanaconda"] = "hud_icon_colt_anaconda",
	["deserteagle"] = "hud_icon_desert_eagle",
	["dragunov"] = "hud_icon_dragunov",
	["famas"] = "hud_icon_famas",
	["famas_eotech"] = "hud_icon_famas_eotech",
	["famas_reflex"] = "hud_icon_famas_reflex",
	["fn2000_acog"] = "hud_icon_fn2000_acog",
	["fn2000_eotech"] = "hud_icon_fn2000_eotech",
	["fn2000_reflex"] = "hud_icon_fn2000_reflex",
	["fn2000_thermal"] = "hud_icon_fn2000_thermal",
	["glock"] = "hud_icon_glock",
	["javelin"] = "hud_icon_javelin",
	["kriss_reflex"] = "hud_icon_kriss_reflex",
	["m14ebr_scope"] = "hud_icon_m14ebr_scope",
	["m16a4"] = "hud_icon_m16a4",
	["m16a4_acog"] = "hud_icon_m16a4_acog",
	["m16a4_grenade"] = "hud_icon_m16a4_grenade",
	["m16a4_reflex"] = "hud_icon_m16a4_reflex",
	["m240"] = "hud_icon_m240",
	["m240_acog"] = "hud_icon_m240_acog",
	["m240_reflex"] = "hud_icon_m240_reflex",
	["m249saw_mounted"] = "hud_icon_m249saw_mounted",
	["m4_grenadier"] = "hud_icon_m4_grenadier",
	["m4_grenadier_acog"] = "hud_icon_m4_grenadier_acog",
	["m4_grenadier_eotech"] = "hud_icon_m4_grenadier_eotech",
	["m4_grenadier_reflex"] = "hud_icon_m4_grenadier_reflex",
	["m4_grunt"] = "hud_icon_m4_grunt",
	["m4"] = "hud_icon_m4carbine",
	["m4m203"] = "hud_icon_m4_grenadier",
	["beretta"] = "hud_icon_m9beretta",
	["masada"] = "hud_icon_masada",
	["masada_acog"] = "hud_icon_masada_acog",
	["masada_eotech"] = "hud_icon_masada_eotech",
	["masada_grenadier_eotech"] = "hud_icon_masada_grenadier_eotech",
	["masada_reflex"] = "hud_icon_masada_reflex",
	["uzi"] = "hud_icon_mini_uzi",
	["model1887"] = "hud_icon_model1887",
	["mp5k"] = "hud_icon_mp5k",
	["mp5k_silencer"] = "hud_icon_mp5k_silencer",
	["tmp"] = "hud_icon_mp9",
	["tmp_reflex"] = "hud_icon_mp9_reflex",
	["p90"] = "hud_icon_p90",
	["p90_acog"] = "hud_icon_p90_acog",
	["p90_reflex"] = "hud_icon_p90_reflex",
	["p90_silencer"] = "hud_icon_p90_silencer",
	["pistol"] = "hud_icon_pistol",
	["pp2000"] = "hud_icon_pp2000",
	["pp2000_reflex"] = "hud_icon_pp2000_reflex",
	["rpd"] = "hud_icon_rpd",
	["rpd_acog"] = "hud_icon_rpd_acog",
	["rpd_reflex"] = "hud_icon_rpd_reflex",
	["rpg"] = "hud_icon_rpg",
	["sa80"] = "hud_icon_sa80_lmg",
	["sa80_scope"] = "hud_icon_sa80_lmg_scope",
	["scar_h"] = "hud_icon_scar_h",
	["scar_h_acog"] = "hud_icon_scar_h_acog",
	["scar_h_grenadier"] = "hud_icon_scar_h_grenadier",
	["scar_h_reflex"] = "hud_icon_scar_h_reflex",
	["scar_h_shotgun"] = "hud_icon_scar_h_shotgun",
	["scar_h_thermal"] = "hud_icon_scar_h_thermal",
	["shotgun"] = "hud_icon_shotgun",
	["spas12"] = "hud_icon_spas12_eotech",
	["spas12_eotech"] = "hud_icon_spas12_eotech",
	["aug"] = "hud_icon_steyr",
	["aug_reflex"] = "hud_icon_steyr_reflex",
	["aug_scope"] = "hud_icon_steyr_scope",
	["striker"] = "hud_icon_striker",
	["striker_reflex"] = "hud_icon_striker_reflex",
	["tavor"] = "hud_icon_tavor",
	["tavor_acog"] = "hud_icon_tavor_acog",
	["tavor_eotech"] = "hud_icon_tavor_eotech",
	["tavor_mars"] = "hud_icon_tavor_mars",
	["tavor_reflex"] = "hud_icon_tavor_reflex",
	["ump45_acog"] = "hud_icon_ump45_acog",
	["ump45_eotech"] = "hud_icon_ump45_eotech",
	["ump45_reflex"] = "hud_icon_ump45_reflex",
	["usp"] = "hud_icon_usp_45",
	["usp_silencer"] = "hud_icon_usp_45_silencer",
	["wa2000"] = "hud_icon_wa2000",
	["wa2000_thermal"] = "hud_icon_wa2000_thermal",
}

local iconsizes = {
    ["beretta"] = {50, 50},
    ["deserteagle"] = {50, 50},
    ["tmp"] = {50, 50},
    ["tmp_reflex"] = {50, 50},
    ["coltanaconda"] = {50, 50}
}

function gethudicon(weapon)
    local matches = {}

    for k, v in pairs(hudicons) do
        local match = weapon:match(k)
        if (match ~= nil) then
            table.insert(matches, {
                match = match,
                value = v
            })
        end
    end

    if (#matches == 0) then
        return
    end

    table.sort(matches, function(a, b)
        return #b.match < #a.match
    end)

    return matches[1].value
end

function createwallbuy(origin, angles, weapon, cost, ammocost, lookatradius)
    lookatradius = lookatradius or 20

    local model = game:spawn("script_model", origin)
    model.angles = angles
    model:setmodel(game:getweaponmodel(weapon))

    local iconwidth = iconsizes[weapon] ~= nil and iconsizes[weapon][1] or 100
    local iconheight = iconsizes[weapon] ~= nil and iconsizes[weapon][2] or 50

    local hintstring = createhintstring({
        radius = 100,
        entity = model,
        lookatradius = lookatradius,
        text = string.format("Press ^3[{+activate}]^7 for ^3%s^7 (Cost: %i)", 
            game:getweapondisplayname(weapon),
            cost, 
            ammocost
        ),
        icon = gethudicon(weapon),
        iconwidth = iconwidth,
        iconheight = iconheight
    })
	
    game:oninterval(function()
        if (player:hasweapon(weapon) == 1) then
            hintstring.text = string.format("Press ^3[{+activate}]^7 for ammo (Cost: %i)", ammocost)
        else
            hintstring.text = string.format("Press ^3[{+activate}]^7 for ^3%s^7 (Cost: %i)", 
                game:getweapondisplayname(weapon), 
                cost, 
                ammocost
            )
        end
    end, 0)

    model:onnotify("trigger", function(player)
        if (player:hasweapon(weapon) == 1) then
            if (player.money < ammocost) then
                player:playlocalsound("ui_tk_click_error")
                return
            end

            player:givemaxammo(weapon)
            player.money = player.money - ammocost
            return
        end

        if (player.money < cost) then
            player:playlocalsound("ui_tk_click_error")
            return
        end

        local weaponslist = player:getweaponslistprimaries()
        if (#weaponslist > 1) then
            local weapontotake = player.lastusedprimary or weaponslist[1]
            player:takeweapon(weapontotake)
        end

        hintstring.text = string.format("Press ^3[{+activate}]^7 for ammo (Cost: %i)", ammocost)
        player:giveweapon(weapon)
        player:switchtoweapon(weapon)
        player.money = player.money - cost
    end)
end