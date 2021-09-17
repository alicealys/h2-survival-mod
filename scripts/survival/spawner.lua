function spawnenemy(origin)
    local spawner = level.spawner
    if (spawner == nil) then
        print("No spawner set for this map!")
        return
    end

    spawner.origin = origin
    spawner.count = 99999

    return spawner:stalingradspawn()
end

function createspawner(origin)
    local spawner = {}
    spawner.origin = origin

    function spawner.spawn()
        local enemy = spawnenemy(origin)

        local listener = nil
        local lasthit = nil

        enemy:onnotifyonce("death", function(attacker)
            listener:clear()

            if (attacker ~= nil) then
                if (lasthit == "j_head") then
                    attacker:notify("headshot")
                end

                attacker:notify("killed_enemy")
            end
        end)

        listener = enemy:onnotify("damage", function(damage, attacker, a3, a4, a5, a6, a7, bone)
            lasthit = bone

            if (attacker ~= nil) then
                attacker:notify("damaged_enemy")
            end
        end)

        return enemy
    end

    return spawner
end