local M = {}

M.git_diff_content_previewer = function()
    return require("advanced_git_search.fzf.previewers.diff_content_previewer")
end

M.git_diff_content_file_previewer = function()
    return require(
        "advanced_git_search.fzf.previewers.diff_content_file_previewer"
    )
end

M.git_diff_file_previewer = function()
    return require("advanced_git_search.fzf.previewers.diff_file_previewer")
end

M.git_diff_branch_file_previewer = function()
    return require(
        "advanced_git_search.fzf.previewers.diff_branch_file_previewer"
    )
end

M.git_diff_base_branch_previewer = function()
    return require(
        "advanced_git_search.fzf.previewers.diff_base_branch_previewer"
    )
end

return M
