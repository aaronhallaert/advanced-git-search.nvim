local file = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")
local cmd_utils = require("advanced_git_search.commands.utils")

local M = {}

local empty_tree_commit = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"

---@param bufnr? number
---@param first_commit string
---@param second_commit string
---@return string|nil prev_name, string|nil curr_name
local function filename_commit(bufnr, first_commit, second_commit)
    if bufnr == nil then
        return nil, nil
    end

    local filename_on_head = file.git_relative_path(bufnr)

    local curr_name =
        git_utils.file_name_on_commit(second_commit, filename_on_head)

    local prev_name =
        git_utils.file_name_on_commit(first_commit, filename_on_head)

    return prev_name, curr_name
end

--- Shows a diff of 2 commit hashes containing changes to the current file
---@param first_commit string
---@param second_commit string
---@param bufnr number
M.git_diff_file = function(first_commit, second_commit, bufnr)
    if not git_utils.is_commit(first_commit) then
        first_commit = empty_tree_commit
    end

    local prev_name, curr_name =
        filename_commit(bufnr, first_commit, second_commit)

    local base_cmd = {
        "git",
        "diff",
    }

    if prev_name ~= nil and curr_name ~= nil then
        table.insert(base_cmd, first_commit .. ":" .. prev_name)
        table.insert(base_cmd, second_commit .. ":" .. curr_name)
    elseif prev_name == nil and curr_name ~= nil then
        table.insert(base_cmd, first_commit)
        table.insert(base_cmd, second_commit)
        table.insert(base_cmd, "--")
        table.insert(
            base_cmd,
            file.git_relative_path_to_relative_path(curr_name)
        )
    end

    return cmd_utils.format_git_diff_command(base_cmd)
end

--- Shows a diff of the passed file with a calculated base branch
--- @param relative_filename string
M.git_diff_base_branch = function(relative_filename)
    return cmd_utils.format_git_diff_command({
        "git",
        "diff",
        "--diff-filter=ACMR",
        "--cached",
        "--merge-base",
        git_utils.base_branch(),
        "--",
        relative_filename,
    })
end

--- Shows a diff of 2 commit hashes and greps on prompt string
--- @param first_commit string
--- @param second_commit string
--- @param prompt string
--- @param opts? {bufnr?: number}
M.git_diff_content = function(first_commit, second_commit, prompt, opts)
    opts = opts or {}

    local prev_name, curr_name =
        filename_commit(opts.bufnr, first_commit, second_commit)

    if not git_utils.is_commit(first_commit) then
        first_commit = empty_tree_commit
    end

    local base_cmd = {
        "git",
        "diff",
    }

    if prev_name == nil and curr_name == nil then
        table.insert(base_cmd, first_commit)
        table.insert(base_cmd, second_commit)
    elseif prev_name ~= nil and curr_name ~= nil then
        table.insert(base_cmd, first_commit .. ":" .. prev_name)
        table.insert(base_cmd, second_commit .. ":" .. curr_name)
    elseif prev_name == nil and curr_name ~= nil then
        table.insert(base_cmd, first_commit)
        table.insert(base_cmd, second_commit)
        table.insert(base_cmd, "--")
        table.insert(
            base_cmd,
            file.git_relative_path_to_relative_path(curr_name)
        )
    end

    local command = cmd_utils.format_git_diff_command(base_cmd)

    if prompt and prompt ~= "" and prompt ~= '""' then
        table.insert(command, "-G")
        table.insert(command, prompt)
    end

    return command
end

--- Shows a diff of branch and the file of the bufnr on HEAD
--- @param branch string
--- @param bufnr number
M.git_diff_branch = function(branch, bufnr)
    local current_hash = git_utils.branch_hash("HEAD")

    local branch_filename = git_utils.file_name_on_commit(
        git_utils.branch_hash(branch),
        file.git_relative_path(bufnr)
    )

    if branch_filename ~= nil then
        return cmd_utils.format_git_diff_command({
            "git",
            "diff",
            branch .. ":" .. branch_filename,
            current_hash .. ":" .. file.git_relative_path(bufnr),
        })
    else
        return cmd_utils.format_git_diff_command({
            "git",
            "diff",
            branch,
            current_hash,
            "--",
            file.relative_path(bufnr),
        })
    end
end

return M
