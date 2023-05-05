local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local ags_actions = require("advanced_git_search.actions")

local file = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")
local config = require("advanced_git_search.utils.config")

-- Map a key to both insert and normal modes
local function omnimap(map_func, key, handler)
    map_func("i", key, handler)
    map_func("n", key, handler)
end

local M = {}

M.omnimap = omnimap

-- create a local function and assign it to a map to get which_key description
-------------------------------------------------------------------------------
local open_commit_in_browser = function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()

    vim.api.nvim_command(":GBrowse " .. selection.opts.commit_hash)
end

--- Open browser at commmit (from entry) with <C-o>
M.open_selected_commit_in_browser = function(map)
    omnimap(map, "<C-o>", open_commit_in_browser)
end

-------------------------------------------------------------------------------
local diff_current_buffer_with_commit = function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local commit_hash = selection.opts.commit_hash

    ags_actions.open_diff_view(commit_hash)
end

--- Open diff view of commmit (from entry) with <CR>
M.open_diff_view_current_file_selected_commit = function(map)
    omnimap(map, "<CR>", diff_current_buffer_with_commit)
end

-------------------------------------------------------------------------------
local diff_current_buffer_with_branch = function(prompt_bufnr)
    local filename = file.git_relative_path(vim.fn.bufnr())
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local branch = selection.value

    ags_actions.open_diff_view(
        branch,
        git_utils.file_name_on_commit(branch, filename)
    )
end

--- Open diff view of branch (from entry) with <CR>
M.open_diff_view_current_file_selected_branch = function(map)
    omnimap(map, "<CR>", diff_current_buffer_with_branch)
end

-------------------------------------------------------------------------------
local open_entire_commit = function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local commit_hash = selection.opts.commit_hash

    local diff_plugin = config.diff_plugin()
    if diff_plugin == "diffview" then
        vim.api.nvim_command(
            ":DiffviewOpen -uno " .. commit_hash .. "~.." .. commit_hash
        )
    elseif diff_plugin == "fugitive" then
        vim.api.nvim_command(":Gedit " .. commit_hash)
    end
end

--- open entire commit diff with <C-e>
M.show_entire_commit = function(map)
    omnimap(map, "<C-e>", open_entire_commit)
end

-------------------------------------------------------------------------------
local copy_commit_hash = function(_)
    local selection = action_state.get_selected_entry()
    local commit_hash = selection.opts.commit_hash
    vim.notify(
        "Copied commit hash " .. commit_hash .. " to clipboard",
        vim.log.levels.INFO,
        { title = "Advanced Git Search" }
    )

    vim.fn.setreg("+", commit_hash)
    vim.fn.setreg("*", commit_hash)
end

--- copy commit hash to clipboard with <C-y>
M.copy_commit_hash_to_clipboard = function(map)
    omnimap(map, "<C-y>", copy_commit_hash)
end

-------------------------------------------------------------------------------
local checkout = function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local reflog_entry = selection.value

    local splitted_reflog_entry = {}
    local count = 1
    for i in string.gmatch(reflog_entry, "%S+") do
        splitted_reflog_entry[count] = i
        count = count + 1
    end
    vim.api.nvim_command(":!git checkout " .. splitted_reflog_entry[1])
end

--- Checkout the selected reflog entry with <CR>
M.checkout_reflog_entry = function(map)
    omnimap(map, "<CR>", checkout)
end

-------------------------------------------------------------------------------

return M
