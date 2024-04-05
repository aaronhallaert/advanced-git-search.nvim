local previewers = require("telescope.previewers")
local file_utils = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")
local preview_commands = require("advanced_git_search.commands.preview")

local M = {}

--- Shows a diff of the commit in the finder entry, filtered on the file of the current buffer
M.git_diff_commit_file_previewer = function(bufnr)
    return previewers.new_termopen_previewer({
        title = "Changes on selected commit for: "
            .. file_utils.file_name(bufnr),
        get_command = function(entry)
            local commit_hash = entry.opts.commit_hash
            local prev_commit = git_utils.previous_commit_hash(commit_hash)
            return preview_commands.git_diff_file(
                prev_commit,
                commit_hash,
                bufnr
            )
        end,
    })
end

--- Shows a diff of the commit in the finder entry, filtered on the prompt string for the commit content
---@param opts table|nil
---@return table
M.git_diff_content_previewer = function(opts)
    opts = opts or {}

    return previewers.new_termopen_previewer({
        title = "Changes including prompt string",
        get_command = function(entry)
            local commit_hash = entry.opts.commit_hash
            local prompt = entry.opts.prompt
            local prev_commit = git_utils.previous_commit_hash(commit_hash)
            return preview_commands.git_diff_content(
                prev_commit,
                commit_hash,
                prompt,
                { bufnr = opts.bufnr }
            )
        end,
    })
end

--- Shows a diff of the file in the finder entry and the fork point of the current branch
M.changed_files_on_current_branch_previewer = function()
    return previewers.new_termopen_previewer({
        title = "Diff of selected file and fork point",
        get_command = function(entry)
            return preview_commands.git_diff_base_branch(entry.value)
        end,
    })
end

--- Shows a diff of the branch in the finder entry relative to the passed filename
M.git_diff_branch_file_previewer = function(bufnr)
    local filename = file_utils.file_name(bufnr)
    return previewers.new_termopen_previewer({
        title = "Diff of current buffer and selected branch for: " .. filename,
        get_command = function(entry)
            local branch = entry.value
            return preview_commands.git_diff_branch(branch, bufnr)
        end,
    })
end

return M
