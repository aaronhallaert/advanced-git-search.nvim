local global_actions = require("advanced_git_search.actions")
local git_utils = require("advanced_git_search.utils.git")
local config = require("advanced_git_search.utils.config")
local file_utils = require("advanced_git_search.utils.file")

---@class AdvancedGitSearch.Snacks.Mapping
---@field key string
---@field action fun(picker: snacks.picker, item: snacks.picker.finder.Item)

local M = {}

---@type AdvancedGitSearch.Snacks.Mapping
M.open_commit_in_browser = {
    key = config.get_keymap("open_commit_in_browser") or "<C-o>",
    action = function(_, item)
        global_actions.open_in_browser(item.commit)
    end,
}

---@param bufnr number
---@return AdvancedGitSearch.Snacks.Mapping
M.open_diff_buffer_with_selected_commit = function(bufnr)
    return {
        key = "<CR>",
        action = function(_, item)
            global_actions.open_diff_view(
                item.commit,
                file_utils.git_relative_path(bufnr)
            )
        end,
    } ---@type AdvancedGitSearch.Snacks.Mapping
end

---@param bufnr number
---@return AdvancedGitSearch.Snacks.Mapping
M.diff_buffer_with_branch = function(bufnr)
    return {
        key = "<CR>",
        action = function(_, item)
            local branch = item.text
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

---@type AdvancedGitSearch.Snacks.Mapping
M.show_entire_commit = {
    key = config.get_keymap("show_entire_commit") or "<C-e>",
    action = function(_, item)
        global_actions.open_commit(item.commit)
    end,
}

---@type AdvancedGitSearch.Snacks.Mapping
M.copy_commit_hash = {
    key = config.get_keymap("copy_commit_hash") or "<C-y>",
    action = function(_, item)
        global_actions.copy_to_clipboard(item.commit)
    end,
}

return M
