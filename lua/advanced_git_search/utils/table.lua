local M = {}

--- @param array table
--- @param value any pattern to match
--- @return number index of value in array, -1 if not found
M.index_of = function(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return -1
end

return M
