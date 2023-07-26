local M = {}
local utils = require("advanced_git_search.utils")
local last_query = ""

M.set_last_query = function(query)
    last_query = query
end

M.get_last_query = function()
    return last_query
end

---
---@param bufnr any
---@param callback function|nil
---@return function
M.append_data = function(bufnr, callback)
    local baleia = require("baleia").setup({})
    local all_data = {}
    return function(_, data)
        for i, line in ipairs(data) do
            data[i] = string.gsub(line, "\27%[K", "")
        end

        table.insert(all_data, table.concat(data))

        if data[#data]:match("%(END%)") or data[#data] == "" then
            -- remove last line
            local lastline = vim.api.nvim_buf_line_count(bufnr)
            local text = table.concat(all_data)
            baleia.buf_set_lines(
                bufnr,
                lastline,
                lastline,
                true,
                utils.split_string(text, "\r")
            )

            if callback ~= nil then
                callback()
            end

            all_data = {}
        end
    end
end

return M
