require("utils")
require("survival_utils")
require("symbols")
local res, err = require("main")

if (game:getdvar("so_debug") == "1") then
    print(res, err)
end