function table.find(t, value)
    for i = 1, #t do
        if (t[i] == value) then
            return t[i]
        end
    end
end

function table.filter(t, callback)
    local result = {}

    for i = 1, #t do
        if (callback(t[i])) then
            table.insert(result, t[i])
        end
    end

    return result
end