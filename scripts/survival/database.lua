local json = require("utils/json")

local database = {}
local path = "./survival/database.json"

local base = {
    records = {
        kills = 0,
        wave = 0,
        score = 0
    },
    total = {
        kills = 0,
        deaths = 0,
        score = 0,
        matches = 0
    },
    matches = {}
}

function createifnotexist()
    if (not io.fileexists(path)) then
        io.writefile(path, json.encode(base), false)
    end
end

createifnotexist()

database.read = function()
    createifnotexist()
    local data = io.readfile(path)
    return json.decode(data)
end

database.write = function(db)
    io.writefile(path, json.encode(db), false)
end

database.addmatch = function(match)
    local db = database.read()
    if (db.matches == nil) then
        db.matches = {}
    end

    match.time = os.time()
    table.insert(db.matches, match)
    database.write(db)
end

database.increase = function(key, value)
    local db = database.read()

    if (db.total == nil) then
        db.total = base.total
    end

    if (db.total[key] == nil) then
        return
    end

    db.total[key] = db.total[key] + value
    database.write(db)
end

database.trysetrecord = function(key, value)
    local db = database.read()

    if (db.records == nil) then
        db.records = base.records
    end

    if (db.records[key] == nil) then
        return
    end

    if (db.records[key] < value) then
        db.records[key] = value
        database.write(db)
    end
end

database.set = function(key, value)
    local db = database.read()
    db[key] = value
    database.write(db)
end

database.get = function(key)
    local db = database.read()
    return db[key]
end

setmetatable(database, {
    __newindex = function(t, key, value)
        database.set(key, value)
    end,
    __index = function(t, key)
        return database.get(key)
    end
})

return database