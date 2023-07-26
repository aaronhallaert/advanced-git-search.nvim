local file = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")
local cmd_utils = require("advanced_git_search.commands.utils")

local M = {}

--- Shows a diff of 2 commit hashes containing changes to the current file
---@param first_commit string
---@param second_commit string
---@param bufnr number
M.git_diff_file = function(first_commit, second_commit, bufnr)
    local filename_on_head = file.git_relative_path(bufnr)

    local curr_name =
        git_utils.file_name_on_commit(second_commit, filename_on_head)
    local prev_name =
        git_utils.file_name_on_commit(first_commit, filename_on_head)

    if prev_name ~= nil and curr_name ~= nil then
        return cmd_utils.format_git_diff_command({
            "git",
            "diff",
            "--color=always",
            first_commit .. ":" .. prev_name,
            second_commit .. ":" .. curr_name,
        })
    elseif prev_name == nil and curr_name ~= nil then
        return cmd_utils.format_git_diff_command({
            "git",
            "diff",
            "--color=always",
            first_commit,
            second_commit,
            "--",
            file.git_relative_path_to_relative_path(curr_name),
        })
    end
end

--- Shows a diff of the passed file with a calculated base branch
--- @param relative_filename string
M.git_diff_base_branch = function(relative_filename)
    return cmd_utils.format_git_diff_command({
        "git",
        "diff",
        "--color=always",
        "--diff-filter=ACMR",
        "--cached",
        "--merge-base",
        git_utils.base_branch(),
        "--",
        relative_filename,
    })
end

--- Shows a diff of 2 commit hashes and greps on prompt string
--- @param first_commit string|nil
--- @param second_commit string
--- @param prompt string
--- @param bufnr number|nil
M.git_diff_content = function(first_commit, second_commit, prompt, bufnr)
    local command = {}

    if first_commit == nil then
        command = cmd_utils.format_git_diff_command({
            "git",
            "show",
            "--color=always",
            second_commit,
        })
    else
        command = cmd_utils.format_git_diff_command({
            "git",
            "diff",
            "--color=always",
            first_commit,
            second_commit,
        })
    end

    if prompt and prompt ~= "" and prompt ~= '""' then
        table.insert(command, "-G")
        table.insert(command, prompt)
    end

    if bufnr and bufnr ~= "" then
        table.insert(command, "--follow")
        local filename = file.relative_path(bufnr)
        table.insert(command, filename)
    end

    return command
end

--- Shows a diff of branch and the file of the bufnr on HEAD
--- @param branch string
--- @param bufnr number
M.git_diff_branch = function(branch, bufnr)
    local branch_filename = git_utils.file_name_on_commit(
        git_utils.branch_hash(branch),
        file.git_relative_path(bufnr)
    )

    if branch_filename ~= nil then
        return cmd_utils.format_git_diff_command({
            "git",
            "diff",
            "--color=always",
            branch .. ":" .. branch_filename,
            "--",
            file.relative_path(bufnr),
        })
    else
        return cmd_utils.format_git_diff_command({
            "git",
            "diff",
            "--color=always",
            branch,
            "--",
            file.relative_path(bufnr),
        })
    end
end

return M
