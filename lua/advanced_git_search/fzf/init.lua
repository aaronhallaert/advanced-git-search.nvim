local M = {}
local config = require("advanced_git_search.utils.config")

M.setup = function(opts)
    config.setup(opts)

    vim.api.nvim_create_user_command(
        "AdvancedGitSearch",
        "lua require('advanced_git_search.fzf').show_custom_functions()",
        { range = true }
    )
end

M.search_log_content =
    require("advanced_git_search.fzf.pickers").search_log_content

M.search_log_content_file =
    require("advanced_git_search.fzf.pickers").search_log_content_file

M.diff_commit_line = require("advanced_git_search.fzf.pickers").diff_commit_line

M.diff_commit_file = require("advanced_git_search.fzf.pickers").diff_commit_file

M.diff_branch_file = require("advanced_git_search.fzf.pickers").diff_branch_file

M.show_custom_functions =
    require("advanced_git_search.fzf.pickers").show_custom_functions

return M
