local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local global_actions = require("advanced_git_search.actions")

local file_utils = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")

-- Map a key to both insert and normal modes
local function omnimap(map_func, key, handler)
    map_func("i", key, handler)
    map_func("n", key, handler)
end

local M = {}

M.omnimap = omnimap

-- create a local function and assign it to a map to get which_key description
-------------------------------------------------------------------------------
local toggle_date_author = function(prompt_bufnr)
    require("advanced_git_search.telescope.finders.utils").toggle_show_date_instead_of_author()
    action_state.get_current_picker(prompt_bufnr):refresh()
end

M.toggle_entry_value = function(map)
    omnimap(map, "<C-w>", toggle_date_author)
end

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

    global_actions.open_diff_view(commit_hash)
end

--- Open diff view of commmit (from entry) with <CR>
M.open_diff_view_current_file_selected_commit = function(map)
    omnimap(map, "<CR>", diff_current_buffer_with_commit)
end

-------------------------------------------------------------------------------
local diff_current_buffer_with_branch = function(prompt_bufnr)
    local filename = file_utils.git_relative_path(vim.fn.bufnr())
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local branch = selection.value

    global_actions.open_diff_view(
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

    global_actions.open_commit(commit_hash)
end

--- open entire commit diff with <C-e>
M.show_entire_commit = function(map)
    omnimap(map, "<C-e>", open_entire_commit)
end

-------------------------------------------------------------------------------
local copy_commit_hash = function(_)
    local selection = action_state.get_selected_entry()
    local commit_hash = selection.opts.commit_hash

    global_actions.copy_to_clipboard(commit_hash)
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

    global_actions.checkout_commit(splitted_reflog_entry[1])
end

--- Checkout the selected reflog entry with <CR>
M.checkout_reflog_entry = function(map)
    omnimap(map, "<CR>", checkout)
end

-------------------------------------------------------------------------------

return M
