local config = require("advanced_git_search.utils.config")

local M = {}

--- open diff for current file
--- @param commit string commit or branch to diff with
--- @param file_name string|nil file name to diff
M.open_diff_view = function(commit, file_name)
    local diff_plugin = config.diff_plugin()

    if file_name ~= nil and file_name ~= "" then
        if diff_plugin == "diffview" then
            vim.api.nvim_command(
                ":DiffviewOpen " .. commit .. " -- " .. file_name
            )
        elseif diff_plugin == "fugitive" then
            vim.api.nvim_command(":Gvdiffsplit " .. commit .. ":" .. file_name)
        end
    else
        if diff_plugin == "diffview" then
            vim.api.nvim_command(":DiffviewOpen " .. commit)
        elseif diff_plugin == "fugitive" then
            vim.api.nvim_command(":Gvdiffsplit " .. commit)
        end
    end
end

return M
