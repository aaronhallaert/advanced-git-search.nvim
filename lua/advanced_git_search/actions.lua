local config = require("advanced_git_search.utils.config")
local command_utils = require("advanced_git_search.commands.utils")
local command_util = require("advanced_git_search.utils.command")
local file_utils = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")

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

---General action: Copy commit patch to system clipboard
---@param commit_hash string
---@param bufnr? number
M.copy_patch_to_clipboard = function(commit_hash, bufnr)
    local command = { "git", "show" }
    command = command_utils.format_git_diff_command(command)
    table.insert(command, commit_hash)

    if bufnr ~= nil then
        local filename = file_utils.git_relative_path(bufnr)
        local commit_file = git_utils.file_name_on_commit(commit_hash, filename)
        table.insert(command, "--")
        table.insert(command, commit_file or filename)
    end

    local patch = command_util.execute(table.concat(command, " "))

    vim.notify(
        "Copied commit patch " .. commit_hash .. " to clipboard",
        vim.log.levels.INFO,
        { title = "Advanced Git Search" }
    )

    vim.fn.setreg("+", patch)
    vim.fn.setreg("*", patch)
end

---General action: Open commit in browser
---@param commit_hash string
M.open_in_browser = function(commit_hash)
    vim.api.nvim_command(":" .. config.get_browse_command(commit_hash))
end

---General action: Checkout commit
---@param commit_hash string
M.checkout_commit = function(commit_hash)
    vim.api.nvim_command(":!git checkout " .. commit_hash)
end

--------------------------------------------------------------------------------
-- Range patch support (A..B), repo-wide or file-scoped with rename follow
--------------------------------------------------------------------------------
local function build_range_diff_cmd(start_hash, end_hash, bufnr)
    local cmd = { "git", "diff" }
    cmd = command_utils.format_git_diff_command(cmd)

    if bufnr == nil then
        table.insert(cmd, start_hash .. ".." .. end_hash)
        return table.concat(cmd, " ")
    end

    local head_rel = file_utils.git_relative_path(bufnr)
    local left_name = git_utils.file_name_on_commit(start_hash, head_rel)
    local right_name = git_utils.file_name_on_commit(end_hash, head_rel)

    if left_name ~= nil and right_name ~= nil then
        table.insert(cmd, start_hash .. ":" .. left_name)
        table.insert(cmd, end_hash .. ":" .. right_name)
        return table.concat(cmd, " ")
    end

    table.insert(cmd, start_hash)
    table.insert(cmd, end_hash)
    table.insert(cmd, "--")
    table.insert(cmd, file_utils.relative_path(bufnr))
    return table.concat(cmd, " ")
end

M.copy_range_patch_to_clipboard = function(start_hash, end_hash, bufnr)
    if not start_hash or not end_hash or start_hash == "" or end_hash == "" then
        vim.notify(
            "Need two commits selected to copy a range patch",
            vim.log.levels.WARN,
            { title = "Advanced Git Search" }
        )
        return
    end
    local shell = build_range_diff_cmd(start_hash, end_hash, bufnr)
    local patch = command_util.execute(shell)
    if patch == "" then
        vim.notify(
            "No diff between " .. start_hash .. " and " .. end_hash,
            vim.log.levels.INFO,
            { title = "Advanced Git Search" }
        )
        return
    end
    vim.fn.setreg("+", patch)
    vim.fn.setreg("*", patch)
    local scope = bufnr and " (file)" or ""
    vim.notify(
        ("Copied patch %s..%s%s to clipboard"):format(
            start_hash,
            end_hash,
            scope
        ),
        vim.log.levels.INFO,
        { title = "Advanced Git Search" }
    )
end

return M
