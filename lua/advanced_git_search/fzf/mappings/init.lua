local M = {}
local utils = require("advanced_git_search.utils")

local global_actions = require("advanced_git_search.actions")
local file_utils = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")
local config = require("advanced_git_search.utils.config")

---FZF: <C-w> Toggle date or author in picker entry
---@return table
M.toggle_entry_value = function()
    return {
        [config.get_keymap("toggle_date_author", "ctrl") or "ctrl-w"] = {
            fn = function(_, _)
                require("advanced_git_search.fzf.pickers.utils").toggle_show_date_instead_of_author()
            end,
            reload = true,
        },
    }
end

---FZF: <C-o> Opens the selected commit in browser
---@return table
M.open_commit_in_brower = function()
    return {
        [config.get_keymap("open_commit_in_browser", "ctrl") or "ctrl-o"] = function(
            selected,
            _
        )
            local selection = selected[1]
            local hash = utils.split_string(selection, " ")[1]

            global_actions.open_in_browser(hash)
        end,
    }
end

---FZF: <default> Open diff view of passed bufnr with selected commit
---@param bufnr number
---@return table
M.open_diff_buffer_with_selected_commit = function(bufnr)
    return {
        ["default"] = function(selected, _)
            local selection = selected[1]
            local commit_hash = utils.split_string(selection, " ")[1]

            global_actions.open_diff_view(
                commit_hash,
                file_utils.git_relative_path(bufnr)
            )
        end,
    }
end

---FZF: <C-e> Show entire commit in nvim
---@return table
M.show_entire_commit = function()
    return {
        [config.get_keymap("show_entire_commit", "ctrl") or "ctrl-e"] = function(
            selected,
            _
        )
            local selection = selected[1]
            local commit_hash = utils.split_string(selection, " ")[1]

            global_actions.open_commit(commit_hash)
        end,
    }
end

---FZF: <default> Open diff view of passed buffer with selected branch
---@param bufnr number
---@return table
M.diff_buffer_with_branch = function(bufnr)
    return {
        ["default"] = function(selected, _)
            local branch = selected[1]

            global_actions.open_diff_view(
                branch,
                git_utils.file_name_on_commit(
                    branch,
                    file_utils.git_relative_path(bufnr)
                )
            )
        end,
    }
end

---FZF: <C-y> Copy the selected commit hash to clipboard
---@return table
M.copy_commit_hash = function()
    return {
        [config.get_keymap("copy_commit_hash", "ctrl") or "ctrl-y"] = function(
            selected,
            _
        )
            local selection = selected[1]
            local commit_hash = utils.split_string(selection, " ")[1]

            global_actions.copy_to_clipboard(commit_hash)
        end,
    }
end

return M
