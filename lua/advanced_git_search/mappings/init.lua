local actions = require("telescope.actions")
local ags_actions = require("advanced_git_search.actions")
local action_state = require("telescope.actions.state")
local file = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")

-- Map a key to both insert and normal modes
local function omnimap(map_func, key, handler)
    map_func("i", key, handler)
    map_func("n", key, handler)
end

local M = {}

M.omnimap = omnimap

--- Open browser at commmit (from entry) with <C-o>
M.open_selected_commit_in_browser = function(map)
    omnimap(map, "<C-o>", function(prompt_bufnr)
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        vim.api.nvim_command(":GBrowse " .. selection.opts.commit_hash)
    end)
end

--- Open diff view of commmit (from entry) with <CR>
M.open_diff_view_current_file_selected_commit = function(map)
    omnimap(map, "<CR>", function(prompt_bufnr)
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local commit_hash = selection.opts.commit_hash

        ags_actions.open_diff_view(commit_hash)
    end)
end
--
--- Open diff view of branch (from entry) with <CR>
M.open_diff_view_current_file_selected_branch = function(map)
    omnimap(map, "<CR>", function(prompt_bufnr)
        local filename = file.git_relative_path(vim.fn.bufnr())
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local branch = selection.value

        ags_actions.open_diff_view(
            branch,
            git_utils.file_name_on_commit(branch, filename)
        )
    end)
end

--- open entire commit diff with <C-e>
M.show_entire_commit = function(map)
    omnimap(map, "<C-e>", function(prompt_bufnr)
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local commit_hash = selection.opts.commit_hash

        local command = {
            "git",
            "diff",
            string.format("%s~", commit_hash),
            commit_hash,
            "\n",
        }

        vim.api.nvim_command("split new") -- split a new window
        vim.api.nvim_win_set_height(0, 30) -- set the window height
        local buf_handle = vim.api.nvim_win_get_buf(0) -- get the buffer handler
        local jobID = vim.api.nvim_call_function("termopen", { "$SHELL" })
        vim.api.nvim_buf_set_option(buf_handle, "modifiable", true)
        vim.api.nvim_chan_send(jobID, table.concat(command, " "))
    end)
end

--- Checkout the selected reflog entry with <CR>
M.checkout_reflog_entry = function(map)
    omnimap(map, "<CR>", function(prompt_bufnr)
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
    end)
end

return M
