function mapfunction(name, file, id, boolreturn)
    _G[name] = function(...)
        if (boolreturn) then
            return game:scriptcall(file, id, ...) == 1
        else
            return game:scriptcall(file, id, ...)
        end
    end
end

function mapmethod(name, file, id, boolreturn)
    entity[name] = function(ent, ...)
        if (boolreturn) then
            return ent:scriptcall(file, id, ...) == 1
        else
            return ent:scriptcall(file, id, ...)
        end
    end
end

-- functions
mapfunction("getclosest", "common_scripts/utility", "_ID16182")
mapfunction("musicstop", "maps/_utility", "_ID24584")

-- methods
mapmethod("displayhint", "maps/_utility", "_ID11085")
mapmethod("forceuseweapon", "maps/_utility", "_ID14803")
mapmethod("placeweaponon", "maps/_utility", "_ID26720")
mapmethod("isflashed", "common_scripts/utility", "_ID20747", true)
