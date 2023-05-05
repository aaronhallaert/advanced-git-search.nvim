local M = {}
local last_query = ""

M.set_last_query = function(query)
    last_query = query
end

M.get_last_query = function()
    return last_query
end

return M
