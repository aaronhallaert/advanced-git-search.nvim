local previewers = require("telescope.previewers")
local file = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")

local M = {}

--- Shows a diff of the commit in the finder entry, filtered on the file of the current buffer
M.git_diff_commit_file_previewer = function(bufnr)
    local filename_on_head = file.git_relative_path(bufnr)
    return previewers.new_termopen_previewer({
        title = "Changes on selected commit for: " .. file.file_name(bufnr),
        get_command = function(entry)
            local commit_hash = entry.opts.commit_hash

            local prev_commit = git_utils.previous_commit_hash(commit_hash)

            local curr_name =
                git_utils.file_name_on_commit(commit_hash, filename_on_head)
            local prev_name =
                git_utils.file_name_on_commit(prev_commit, filename_on_head)

            if prev_name ~= nil then
                return git_utils.git_diff_command({
                    "git",
                    "diff",
                    prev_commit .. ":" .. prev_name,
                    commit_hash .. ":" .. curr_name,
                })
            else
                return git_utils.git_diff_command({
                    "git",
                    "diff",
                    prev_commit,
                    commit_hash,
                    "--",
                    file.git_relative_path_to_relative_path(curr_name),
                })
            end
        end,
    })
end

--- Shows a diff of the commit in the finder entry, filtered on the prompt string for the commit content
M.git_diff_content_previewer = function()
    return previewers.new_termopen_previewer({
        title = "Changes including prompt string",
        get_command = function(entry)
            local commit_hash = entry.opts.commit_hash
            local prompt = entry.opts.prompt
            local command = git_utils.git_diff_command({
                "git",
                "diff",
                string.format("%s~", commit_hash),
                commit_hash,
            })

            if prompt and prompt ~= "" then
                table.insert(command, "-G")
                table.insert(command, prompt)
            end

            return command
        end,
    })
end

--- Shows a diff of the file in the finder entry and the fork point of the current branch
M.changed_files_on_current_branch_previewer = function()
    return previewers.new_termopen_previewer({
        title = "Diff of selected file and fork point",
        get_command = function(entry)
            return git_utils.git_diff_command({
                "git",
                "diff",
                "--diff-filter=ACMR",
                "--cached",
                "--merge-base",
                git_utils.base_branch(),
                "--",
                entry.value,
            })
        end,
    })
end

--- Shows a diff of the branch in the finder entry relative to the passed filename
M.git_diff_branch_file_previewer = function(bufnr)
    local filename = file.file_name(bufnr)
    return previewers.new_termopen_previewer({
        title = "Diff of current buffer and selected branch for: " .. filename,
        get_command = function(entry)
            local branch = entry.value
            local current_hash = git_utils.branch_hash("HEAD")

            local branch_filename = git_utils.file_name_on_commit(
                git_utils.branch_hash(branch),
                file.git_relative_path(bufnr)
            )

            if branch_filename ~= nil then
                return git_utils.git_diff_command({
                    "git",
                    "diff",
                    branch .. ":" .. branch_filename,
                    current_hash .. ":" .. file.git_relative_path(bufnr),
                })
            else
                return git_utils.git_diff_command({
                    "git",
                    "diff",
                    branch,
                    current_hash,
                    "--",
                    file.relative_path(bufnr),
                })
            end
        end,
    })
end

return M
