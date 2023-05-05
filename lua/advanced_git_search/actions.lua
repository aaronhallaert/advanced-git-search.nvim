local config = require("advanced_git_search.utils.config")

local M = {}

---General action: Open entire commit with fugitive or diffview
---@param commit_hash string
M.open_commit = function(commit_hash)
    local diff_plugin = config.diff_plugin()

    if diff_plugin == "diffview" then
        vim.api.nvim_command(
            ":DiffviewOpen -uno " .. commit_hash .. "~.." .. commit_hash
        )
    elseif diff_plugin == "fugitive" then
        vim.api.nvim_command(":Gedit " .. commit_hash)
    end
end

---General action: open diff for current file
---@param commit string commit or branch to diff with
---@param file_name string|nil file name to diff
M.open_diff_view = function(commit, file_name)
    local diff_plugin = config.diff_plugin()

    if file_name ~= nil and file_name ~= "" then
        if diff_plugin == "diffview" then
            vim.api.nvim_command(
                ":DiffviewOpen -uno " .. commit .. " -- " .. file_name
            )
        elseif diff_plugin == "fugitive" then
            vim.api.nvim_command(":Gvdiffsplit " .. commit .. ":" .. file_name)
        end
    else
        if diff_plugin == "diffview" then
            vim.api.nvim_command(":DiffviewOpen -uno " .. commit)
        elseif diff_plugin == "fugitive" then
            vim.api.nvim_command(":Gvdiffsplit " .. commit)
        end
    end
end

---General action: Copy commit hash to system clipboard
---@param commit_hash string
M.copy_to_clipboard = function(commit_hash)
    vim.notify(
        "Copied commit hash " .. commit_hash .. " to clipboard",
        vim.log.levels.INFO,
        { title = "Advanced Git Search" }
    )

    vim.fn.setreg("+", commit_hash)
    vim.fn.setreg("*", commit_hash)
end

---General action: Open commit in browser
---@param commit_hash string
M.open_in_browser = function(commit_hash)
    vim.api.nvim_command(":GBrowse " .. commit_hash)
end

---General action: Checkout commit
---@param commit_hash string
M.checkout_commit = function(commit_hash)
    vim.api.nvim_command(":!git checkout " .. commit_hash)
end

return M
