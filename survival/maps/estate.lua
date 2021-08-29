require("spawner")
require("objects/hintstring")
require("objects/wallbuy")
require("objects/ammo")

game:precacheshader("hud_icon_40mm_grenade")
game:precacheshader("hud_icon_aa12")
game:precacheshader("hud_icon_ak47")
game:precacheshader("hud_icon_ak47_acog")
game:precacheshader("hud_icon_ak47_eotech")
game:precacheshader("hud_icon_ak47_grenadier")
game:precacheshader("hud_icon_ak47_reflex")
game:precacheshader("hud_icon_ak47_shotgun")
game:precacheshader("hud_icon_barrett50cal")
game:precacheshader("hud_icon_bayonet")
game:precacheshader("hud_icon_benelli_m4")
game:precacheshader("hud_icon_c4")
game:precacheshader("hud_icon_cheytac")
game:precacheshader("hud_icon_claymore")
game:precacheshader("hud_icon_cobra")
game:precacheshader("hud_icon_colt_anaconda")
game:precacheshader("hud_icon_desert_eagle")
game:precacheshader("hud_icon_dragunov")
game:precacheshader("hud_icon_famas")
game:precacheshader("hud_icon_famas_eotech")
game:precacheshader("hud_icon_famas_reflex")
game:precacheshader("hud_icon_fn2000_acog")
game:precacheshader("hud_icon_fn2000_eotech")
game:precacheshader("hud_icon_fn2000_reflex")
game:precacheshader("hud_icon_fn2000_thermal")
game:precacheshader("hud_icon_glock")
game:precacheshader("hud_icon_javelin")
game:precacheshader("hud_icon_kriss_reflex")
game:precacheshader("hud_icon_m14ebr_scope")
game:precacheshader("hud_icon_m16a4")
game:precacheshader("hud_icon_m16a4_acog")
game:precacheshader("hud_icon_m16a4_grenade")
game:precacheshader("hud_icon_m16a4_reflex")
game:precacheshader("hud_icon_m240")
game:precacheshader("hud_icon_m240_acog")
game:precacheshader("hud_icon_m240_reflex")
game:precacheshader("hud_icon_m249saw_mounted")
game:precacheshader("hud_icon_m4_grenadier")
game:precacheshader("hud_icon_m4_grenadier_acog")
game:precacheshader("hud_icon_m4_grenadier_eotech")
game:precacheshader("hud_icon_m4_grenadier_reflex")
game:precacheshader("hud_icon_m4_grunt")
game:precacheshader("hud_icon_m4carbine")
game:precacheshader("hud_icon_m4_grenadier")
game:precacheshader("hud_icon_m9beretta")
game:precacheshader("hud_icon_masada")
game:precacheshader("hud_icon_masada_acog")
game:precacheshader("hud_icon_masada_eotech")
game:precacheshader("hud_icon_masada_grenadier_eotech")
game:precacheshader("hud_icon_masada_reflex")
game:precacheshader("hud_icon_mini_uzi")
game:precacheshader("hud_icon_model1887")
game:precacheshader("hud_icon_mp5k")
game:precacheshader("hud_icon_mp5k_silencer")
game:precacheshader("hud_icon_mp9")
game:precacheshader("hud_icon_mp9_reflex")
game:precacheshader("hud_icon_p90")
game:precacheshader("hud_icon_p90_acog")
game:precacheshader("hud_icon_p90_reflex")
game:precacheshader("hud_icon_p90_silencer")
game:precacheshader("hud_icon_pistol")
game:precacheshader("hud_icon_pp2000")
game:precacheshader("hud_icon_pp2000_reflex")
game:precacheshader("hud_icon_rpd")
game:precacheshader("hud_icon_rpd_acog")
game:precacheshader("hud_icon_rpd_reflex")
game:precacheshader("hud_icon_rpg")
game:precacheshader("hud_icon_sa80_lmg")
game:precacheshader("hud_icon_sa80_lmg_scope")
game:precacheshader("hud_icon_scar_h")
game:precacheshader("hud_icon_scar_h_acog")
game:precacheshader("hud_icon_scar_h_grenadier")
game:precacheshader("hud_icon_scar_h_reflex")
game:precacheshader("hud_icon_scar_h_shotgun")
game:precacheshader("hud_icon_scar_h_thermal")
game:precacheshader("hud_icon_shotgun")
game:precacheshader("hud_icon_spas12_eotech")
game:precacheshader("hud_icon_spas12_eotech")
game:precacheshader("hud_icon_steyr")
game:precacheshader("hud_icon_steyr_reflex")
game:precacheshader("hud_icon_steyr_scope")
game:precacheshader("hud_icon_striker")
game:precacheshader("hud_icon_striker_reflex")
game:precacheshader("hud_icon_tavor")
game:precacheshader("hud_icon_tavor_acog")
game:precacheshader("hud_icon_tavor_eotech")
game:precacheshader("hud_icon_tavor_mars")
game:precacheshader("hud_icon_tavor_reflex")
game:precacheshader("hud_icon_ump45_acog")
game:precacheshader("hud_icon_ump45_eotech")
game:precacheshader("hud_icon_ump45_reflex")
game:precacheshader("hud_icon_usp_45")
game:precacheshader("hud_icon_usp_45_silencer")
game:precacheshader("hud_icon_wa2000")
game:precacheshader("hud_icon_wa2000_thermal")

local map = {
    spawners = {},
    shotguns = {"striker", "model1887", "striker_woodland", "striker_reflex", "aa12"},
    smgs = {"pp2000", "mp5_silencer", "kriss_reflex", "tmp_reflex", "uzi", "ump45_eotech"},
    rifles = {"ak47_reflex", "ak47_shotgun", "m16_acog", "fn2000_acog", "m240_reflex", "scar_h", "famas_woodland_eotech", "tavor_reflex", "aug_scope"}
}

function addspawner(origin)
    table.insert(map.spawners, createspawner(origin))
end

addspawner(vector:new(1126.573242, 1780.502197, 9.193225))
addspawner(vector:new(2290.340820, 6.724380, -76.226883))
addspawner(vector:new(1048.935913, -139.416672, 12.125000))
addspawner(vector:new(307.121582, -1350.584717, -128.297714))
addspawner(vector:new(-636.915161, -438.174561, 73.223846))
addspawner(vector:new(-894.372559, 421.094574, -48.787975))
addspawner(vector:new(-394.250793, 1345.180054, -8.597933))
addspawner(vector:new(182.042725, 1960.793823, 15.925760))
addspawner(vector:new(-252.697083, 3165.550537, -181.242966))
addspawner(vector:new(-449.325348, 3806.973877, -252.231354))
addspawner(vector:new(-1277.660034, 3715.824951, -321.568146))
addspawner(vector:new(-2300.147705, 3736.670898, -254.521179))
addspawner(vector:new(-2688.986572, 3145.832275, -459.789612))
addspawner(vector:new(-2029.914062, 4549.178711, -185.838455))
addspawner(vector:new(-1676.898071, 5061.569336, -253.039474))
addspawner(vector:new(-2660.078857, 5536.583008, -213.202301))
addspawner(vector:new(-3730.803711, 6689.648438, 240.901901))
addspawner(vector:new(-4893.791504, 5671.172363, 758.527161))
addspawner(vector:new(4196.951172, 2304.112793, -143.275146))
addspawner(vector:new(4364.206543, 1780.880249, -124.499313))
addspawner(vector:new(4297.375488, 1043.208984, -138.940216))
addspawner(vector:new(4106.221680, 394.945709, -119.875000))
addspawner(vector:new(4472.529297, 366.977203, -121.561424))
addspawner(vector:new(3816.923340, -487.869446, -102.613892))
addspawner(vector:new(2912.891357, -1067.762817, -236.138992))
addspawner(vector:new(2360.776123, -456.341278, -109.129791))
addspawner(vector:new(-27.402725, 986.990662, 154.308578))
addspawner(vector:new(861.850891, 1309.666260, 132.544754))
addspawner(vector:new(758.679016, 652.721069, 22.682041))

local spawners = game:getspawnerteamarray("axis")
for i = 1, #spawners do
    spawners[i].preserve = true
end

local fence = game:getent("final_area_fence", "targetname")
fence.preserve = true

local doorcollision = game:getent("breach_solid", "targetname")
doorcollision.preserve = true
doorcollision.origin = vector:new(1000000, 1000000, 1000000)
doorcollision.angles = vector:new(0, 0, 0)
player.preserve = true

local ents = game:getentarray()
for i = 1, #ents do
    if (not ents[i].preserve) then
        ents[i]:delete()
    end
end

function createdoor(door)
    local collisionangles = door.angles + vector:new(0, 105, 0)
    local colllisionforward = collisionangles + vector:new(0, 90, 0)
    local collisionorigin = door.origin + collisionangles:toforward() * 30 + colllisionforward:toforward() * -10

    local collision = game:spawn("script_model", collisionorigin)
    collision.angles = door.angles + vector:new(0, 105, 0)
    collision:clonebrushmodeltoscriptmodel(doorcollision)
    
    local model = game:spawn("script_model", door.origin)
    model:setmodel("h2_est_com_door_02")
    model.angles = door.angles

    local hintstring = createhintstring({
        text = string.format("Press ^3[{+activate}]^7 to open Door (Cost: %i)", door.cost),
        entity = collision,
        radius = 50
    })

    local listener = nil
    listener = collision:onnotify("trigger", function()
        if (player.money < door.cost) then
            player:playlocalsound("ui_tk_click_error")
            return
        end

        listener:clear()
        hintstring.enabled = false

        player.money = player.money - door.cost

        model:rotateto(door.openangles, 0.8, 0.1, 0.4)
        collision:delete()

        local collisionangles = door.openangles + vector:new(0, 105, 0)
        local colllisionforward = collisionangles + vector:new(0, 90, 0)
        local collisionorigin = door.origin + collisionangles:toforward() * 30 + colllisionforward:toforward() * -10

        local newcollision = game:spawn("script_model", collisionorigin)
        newcollision.angles = collisionangles
        newcollision:clonebrushmodeltoscriptmodel(doorcollision)
    end)
end

createdoor({
    origin = vector:new(451.934479, -15.394572, 296.000000),
    angles = vector:new(0.000000, 75, 0.000000),
    openangles = vector:new(0.000000, -50, 0.000000),
    cost = 2000
})

createdoor({
    origin = vector:new(538.125488, 175.294739, 16.000006),
    angles = vector:new(0.000000, 75, 0.000000),
    openangles = vector:new(0.000000, -30, 0.000000),
    cost = 2000
})

createwallbuy(vector:new(328.605988, 246.585999, 57.099998), vector:new(0.000000, 345.000000, 0.000000), "deserteagle", 4000, 500, 15)
createwallbuy(vector:new(305.809998, 252.694000, 58.200001), vector:new(0.000000, 345.000000, 0.000000), "pp2000_reflex", 2000, 500, 15)
createwallbuy(vector:new(308.515015, 251.970001, 69.000000), vector:new(0.000000, 345.000000, 0.000000), "beretta", 500, 500)
createwallbuy(vector:new(329.186005, 246.431000, 70.400002), vector:new(0.000000, 345.000000, 0.000000), "tmp_reflex", 2000, 500, 15)
createwallbuy(vector:new(278.795013, 258.898010, 76.199997), vector:new(0.000000, 345.000000, 0.000000), "aug_reflex", 3500, 500)
createwallbuy(vector:new(280.855988, 258.863007, 56.799999), vector:new(0.000000, 345.000000, 0.000000), "p90_reflex", 3000, 500)
createwallbuy(vector:new(312.958008, 250.779007, 77.900002), vector:new(0.000000, 345.000000, 0.000000), "spas12_eotech", 2000, 500)
createwallbuy(vector:new(275.414001, 259.803986, 91.199997), vector:new(0.000000, 345.000000, 0.000000), "wa2000_thermal", 4000, 500)
createwallbuy(vector:new(237.712006, 270.941010, 57.700001), vector:new(0.000000, 345.000000, 0.000000), "sa80", 6000, 500)
createwallbuy(vector:new(236.552994, 271.252014, 74.400002), vector:new(0.000000, 345.000000, 0.000000), "aa12", 2500, 500)
createwallbuy(vector:new(236.940002, 271.148010, 91.800003), vector:new(0.000000, 345.000000, 0.000000), "fn2000_thermal", 2500, 500)
createwallbuy(vector:new(234.684998, 271.234985, 41.099998), vector:new(0.000000, 345.000000, 0.000000), "ak47_shotgun", 4500, 500)
createwallbuy(vector:new(312.958008, 250.779007, 41.400002), vector:new(0.000000, 345.000000, 0.000000), "m4m203_reflex", 4500, 500)
createwallbuy(vector:new(275.673004, 260.769989, 41.299999), vector:new(0.000000, 345.000000, 0.000000), "kriss_reflex", 3000, 500)
createwallbuy(vector:new(319.679993, 248.046005, 92.900002), vector:new(0.000000, 345.000000, 0.000000), "tavor_eotech", 4000, 500)

createammocache(vector:new(234.059998, 405.677002, 53.000000), 1500)

level.spawner = game:getent("pf1_auto182", "targetname")

player:setorigin(vector:new(276, 270, 168))

local interval = nil
interval = game:oninterval(function()
    if (level.started == 1) then
        interval:clear()
        return
    end

    player:setstance("stand")
    player:setplayerangles(vector:new(0, 65, 0))
end, 0)

level:onnotify("start", function()
    interval:clear()
end)

return map