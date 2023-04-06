local M = {}

--- Executes a command and returns the output
--- @param command string
--- @return string returns empty string upon error
M.execute = function(command)
    local handle = io.popen(command)

    if handle == nil then
        return ""
    end

    local output = handle:read("*a")
    handle:close()

    return output
end

return M
