local map = {
    spawners = {},
    startweapon = "beretta",
    shotguns = {"model1887", "ranger"},
    smgs = {"uzi", "glock_akimbo", "mp5", "uzi_akimbo"},
    rifles = {"ak47", "ak47_reflex", "m4_grunt", "fal_shotgun", "rpd_reflex", "ak47_acog", "ak47_grenadier", "masada_grenadier_acog", "fal", "fal_reflex"},
    blackout = 3000
}

map.premain = function()
    game:setdvar("beautiful_corner", 1)

    -- Don't delete axis spawners
    game:detour("_ID43797", "_ID44261", function() end)
end

map.main = function()
    require("spawner")
    require("objects/hintstring")
    require("objects/wallbuy")
    require("objects/ammo")

    function addspawner(origin)
        table.insert(map.spawners, createspawner(origin))
    end

    addspawner(vector:new(-3251.675049, -430.503998, 656.125000))
    addspawner(vector:new(-3133.541748, -548.528931, 656.125000))
    addspawner(vector:new(-3110.180664, -388.348206, 656.125000))
    addspawner(vector:new(-3233.946045, -261.160400, 656.125000))
    addspawner(vector:new(-3472.893066, -142.666748, 657.139160))
    addspawner(vector:new(-3371.211670, -18.330751, 657.748352))
    addspawner(vector:new(-3252.125977, -102.606422, 654.564392))
    addspawner(vector:new(-3013.949951, 193.158142, 656.745056))
    addspawner(vector:new(-3073.237061, 282.636841, 656.125000))
    addspawner(vector:new(-3014.131104, 284.532104, 656.125000))
    addspawner(vector:new(-2913.461426, 298.299194, 656.125000))
    addspawner(vector:new(-3037.164795, 403.758209, 656.125000))
    addspawner(vector:new(-2428.648926, 116.614990, 656.429077))
    addspawner(vector:new(-2452.606445, 244.201874, 658.098572))
    addspawner(vector:new(-2714.142090, -122.847946, 657.004211))
    addspawner(vector:new(-2439.741699, -154.375793, 658.180237))
    addspawner(vector:new(-2430.369385, -321.566986, 656.630737))
    addspawner(vector:new(-2736.937256, -71.874855, 656.708679))
    addspawner(vector:new(-2716.416016, -417.054565, 656.125000))
    addspawner(vector:new(-2768.324463, -506.014313, 656.125000))
    addspawner(vector:new(-2858.008789, -607.403381, 656.125000))
    addspawner(vector:new(-2786.502686, -713.900879, 656.125000))
    addspawner(vector:new(-2842.606201, -1152.305298, 656.125000))
    addspawner(vector:new(-2795.246826, -1314.212036, 656.125000))
    addspawner(vector:new(-2721.398438, -1705.126221, 656.125000))
    addspawner(vector:new(-2614.833740, -1618.530762, 656.125000))
    addspawner(vector:new(-2474.351318, -1706.679077, 656.125000))
    addspawner(vector:new(-2398.651367, -1415.388916, 653.985596))
    addspawner(vector:new(-1853.114868, -779.486084, 656.125000))
    addspawner(vector:new(-2352.627930, -953.096252, 666.494202))
    addspawner(vector:new(-2119.112793, -625.877014, 658.930359))
    addspawner(vector:new(-2126.119385, -551.442627, 656.855469))
    addspawner(vector:new(-2437.211426, -539.097290, 656.125000))
    addspawner(vector:new(-2502.392822, -736.717285, 656.125000))
    addspawner(vector:new(-3320.849365, -830.505066, 656.125000))
    addspawner(vector:new(-3217.025879, -1307.192261, 656.125000))
    addspawner(vector:new(-3173.279297, -1401.568481, 654.994385))
    addspawner(vector:new(-3168.775879, -1604.857910, 655.051453))
    addspawner(vector:new(-2968.975098, -1474.271240, 653.082764))
    addspawner(vector:new(-3682.302490, -1181.834717, 656.125000))
    addspawner(vector:new(-3580.266113, -1544.699951, 662.125000))
    addspawner(vector:new(-3785.245117, -1471.465088, 654.159119))
    addspawner(vector:new(-4105.153320, -1299.712158, 656.620361))
    addspawner(vector:new(-3825.063232, -1188.039062, 656.125000))
    addspawner(vector:new(-3924.381104, -992.969666, 653.674622))
    addspawner(vector:new(-4067.939209, -610.151978, 655.495422))
    addspawner(vector:new(-3799.498291, -690.512939, 656.125000))
    addspawner(vector:new(-3675.806152, -835.413879, 656.125000))
    addspawner(vector:new(-3674.345703, -689.820007, 656.125000))
    addspawner(vector:new(-3929.069824, -193.146515, 657.892761))
    addspawner(vector:new(-3687.650146, -57.471478, 657.028748))
    addspawner(vector:new(-3872.409912, 124.115425, 656.031189))
    addspawner(vector:new(-3942.996582, -77.838791, 656.125000))
    addspawner(vector:new(-4093.218506, 30.094360, 656.125000))
    addspawner(vector:new(-3883.182373, 399.819885, 657.827271))
    addspawner(vector:new(-4175.875000, 661.258484, 657.948303))
    addspawner(vector:new(-3967.020508, 780.495667, 660.125000))
    addspawner(vector:new(-4166.287109, 966.009827, 657.372925))
    addspawner(vector:new(-4382.653320, 1083.322632, 668.449768))
    addspawner(vector:new(-4466.868164, 1430.960571, 675.362549))
    addspawner(vector:new(-4547.977051, 1283.374634, 670.224182))
    addspawner(vector:new(-4697.551758, 1642.385254, 775.855164))
    addspawner(vector:new(-4652.123535, 1765.288696, 778.556152))
    addspawner(vector:new(-5190.647461, 1965.373535, 779.740845))
    addspawner(vector:new(-5242.243164, 2199.075195, 779.188904))
    addspawner(vector:new(-5697.453613, 2244.576660, 779.244507))
    addspawner(vector:new(-5670.212402, 2563.670166, 776.125000))
    addspawner(vector:new(-6300.432617, 2633.739746, 774.539001))
    addspawner(vector:new(-6361.244629, 2587.486084, 816.125000))
    addspawner(vector:new(-6639.504883, 2443.435547, 851.594971))
    addspawner(vector:new(-6480.598145, 2322.975586, 840.243164))
    addspawner(vector:new(-6234.090820, 2368.304688, 795.529724))
    addspawner(vector:new(-5795.273438, 1971.697021, 926.711914))
    addspawner(vector:new(-5486.247559, 2087.303955, 781.214172))
    addspawner(vector:new(-3890.365967, 409.064056, 657.586853))
    addspawner(vector:new(-3689.846436, 272.100739, 653.336792))
    addspawner(vector:new(-3515.599365, 158.021393, 656.219238))
    addspawner(vector:new(-3415.702393, 242.312805, 656.592957))
    addspawner(vector:new(-3196.268799, 255.617615, 658.968628))
    addspawner(vector:new(-5206.724121, 1218.029297, 1144.093262))
    addspawner(vector:new(-5135.776367, 988.332764, 1152.125000))
    addspawner(vector:new(-5354.709961, 933.188416, 1119.647217))
    addspawner(vector:new(-5669.450684, 1067.064209, 1088.974243))
    addspawner(vector:new(-5679.466797, 1353.895508, 1047.629150))
    addspawner(vector:new(-5766.690918, 1660.726562, 1000.452209))
    addspawner(vector:new(-5943.272949, 1627.204956, 1008.434204))
    addspawner(vector:new(-6128.687500, 1787.126221, 1016.125000))
    addspawner(vector:new(-5939.257812, 1852.857544, 1024.125000))
    addspawner(vector:new(-6158.129883, 2012.758789, 944.125000))
    addspawner(vector:new(-6266.080078, 1483.792969, 1184.125000))
    addspawner(vector:new(-6204.190918, 1383.043701, 1184.125000))
    addspawner(vector:new(-6004.715820, 1448.470215, 1184.125000))
    addspawner(vector:new(-6488.281250, 1758.698120, 1184.125000))
    addspawner(vector:new(-6632.809082, 1838.508789, 1184.125000))
    addspawner(vector:new(-6749.340820, 1709.808350, 1185.547363))
    addspawner(vector:new(-7014.971680, 1511.226929, 1179.009277))
    addspawner(vector:new(-7329.974609, 1462.268677, 1248.639282))
    addspawner(vector:new(-7731.562988, 1660.027832, 1295.971558))
    addspawner(vector:new(-7236.691406, 1197.652588, 1380.125000))
    addspawner(vector:new(-7133.750977, 696.706787, 1540.125000))
    addspawner(vector:new(-7552.033203, 978.961365, 1568.125000))
    addspawner(vector:new(-6993.430176, 1229.734863, 1504.125000))
    addspawner(vector:new(-6720.812012, 1087.701660, 1504.125000))
    addspawner(vector:new(-6573.270508, 444.781006, 1498.012939))
    addspawner(vector:new(-6299.613281, 690.645447, 1472.125000))
    addspawner(vector:new(-5859.386719, -26.223234, 1531.547607))
    addspawner(vector:new(-6034.720215, -319.264465, 1632.125000))
    addspawner(vector:new(-5766.216797, 110.128136, 1632.125000))
    addspawner(vector:new(-6522.192383, 211.162567, 1760.104492))
    addspawner(vector:new(-7060.135254, 20.216116, 1750.163086))
    addspawner(vector:new(-7000.943359, 519.168213, 1760.125000))
    addspawner(vector:new(-7528.544922, 321.362701, 1758.848511))
    addspawner(vector:new(-7584.772461, 800.256653, 1752.125000))
    addspawner(vector:new(-7842.458984, 815.532898, 1800.125000))
    addspawner(vector:new(-8136.745605, 662.261536, 1799.625000))
    addspawner(vector:new(-8175.561035, 964.169922, 1767.338013))

    local ents = game:getentarray()
    for i = 1, #ents do
        if ((ents[i].classname and (ents[i].classname:match("trigger") or ents[i].classname:match("weapon"))) 
            or (ents[i].model and (ents[i].model:match("chicken") or ents[i].model:match("soccer")))) then
            ents[i]:delete()
        end
    end

    function findentity(callback, value, type)
        local ents = nil
        if (value and type) then
            ents = game:getentarray(value, type)
        else
            ents = game:getentarray()
        end

        for i = 1, #ents do
            if (callback(ents[i])) then
                return ents[i]
            end
        end
    end

    local ammocaches = game:getentarray("ammo_cache", "targetname")
    for i = 1, #ammocaches do
        local ammocachetrigger = findentity(function(ent)
            return ent ~= ammocaches[i] and ent.origin.x == ammocaches[i].origin.x and ent.origin.y == ammocaches[i].origin.y
        end)
        if (ammocachetrigger) then
            createammocache(ammocachetrigger.origin, 1500)
            ammocachetrigger:delete()
        end
    end

    level.spawner = game:getent("pf0_auto55", "targetname")

    player:setorigin(vector:new(-1855.542236, -1334.430542, 658.118042))
    player:setplayerangles(vector:new(0, 170, 0))
    player:allowprone(true)
    player:allowcrouch(true)
    player:allowstand(true)

    game:musicstop()
end

return map