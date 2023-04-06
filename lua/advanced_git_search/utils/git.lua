local utils = require("advanced_git_search.utils")
local file = require("advanced_git_search.utils.file")
local config = require("advanced_git_search.utils.config")
local command_util = require("advanced_git_search.utils.command")

local M = {}

local all_commit_hashes = function()
    local command = "git rev-list --all"
    local output = command_util.execute(command)

    return utils.split_string(output, "\n")
end

local all_commit_hashes_touching_file = function(git_relative_file_path)
    local command = "cd "
        .. file.git_dir()
        .. " && git log --all --follow --pretty=format:'%H' -- "
        .. git_relative_file_path

    local output = command_util.execute(command)
    return utils.split_string(output, "\n")
end

--- @param command table
--- @param git_flags_ix number|nil
--- @param git_diff_flags_ix number|nil
--- @return table Command with configured git diff flags
local git_diff_command = function(command, git_flags_ix, git_diff_flags_ix)
    git_flags_ix = git_flags_ix or 2
    git_diff_flags_ix = git_diff_flags_ix or 3

    local git_diff_flags = config.git_diff_flags()
    local git_flags = config.git_flags()

    if git_flags_ix > git_diff_flags_ix then
        vim.notify(
            "git_flags must be inserted before git_diff_flags",
            vim.log.levels.ERROR
        )
    end

    if git_diff_flags ~= nil and #git_diff_flags > 0 then
        for i, flag in ipairs(git_diff_flags) do
            table.insert(command, git_diff_flags_ix + i - 1, flag)
        end
    end

    if git_flags ~= nil and #git_flags > 0 then
        for i, flag in ipairs(git_flags) do
            table.insert(command, git_flags_ix + i - 1, flag)
        end
    end

    return command
end

M.git_diff_command = git_diff_command

M.previous_commit_hash = function(commit_hash)
    local command = "git rev-parse " .. commit_hash .. "~"

    local output = command_util.execute(command)
    return string.gsub(output, "\n", "")
end

M.branch_hash = function(branch)
    local command = "git rev-parse " .. branch

    local output = command_util.execute(command)
    return string.gsub(output, "\n", "")
end

-- local is_file_renamed = function(git_relative_file_path)
--     local command = "cd "
--         .. file.git_dir()
--         .. " && git log --all --follow --diff-filter=R --pretty=format:'%H' -- "
--         .. git_relative_file_path
--
--     local output = command_util.execute(command)
--     output = utils.split_string(output, "\n")
--     return #output > 0
-- end

local file_exists_on_commit = function(commit_hash, git_relative_file_path)
    local command = "cd "
        .. file.git_dir()
        .. " && git ls-tree --name-only "
        .. commit_hash
        .. " -- "
        .. git_relative_file_path

    local output = command_util.execute(command)

    output = string.gsub(output, "\n", "")
    return output ~= ""
end

--- Returns the file name of a file on a specific commit
--- @param commit_hash string
--- @param git_relative_file_path string
--- @return string|nil file name on commit
local file_name_on_commit = function(commit_hash, git_relative_file_path)
    if file_exists_on_commit(commit_hash, git_relative_file_path) then
        return git_relative_file_path
    end

    -- FIXME: this is a very naive implementation, but it always returns the
    -- correct filename for each commit (even if the commit didn't touch the file)

    -- first find index in all_commit_hashes
    local all_hashes = all_commit_hashes()
    if all_hashes == nil then
        return nil
    end

    local index = 0
    for i, hash in ipairs(all_hashes) do
        -- compare on first 7 chars
        if string.sub(hash, 1, 7) == string.sub(commit_hash, 1, 7) then
            index = i
            break
        end
    end

    -- then find the first commit that has a different file name
    local touched_hashes =
        all_commit_hashes_touching_file(git_relative_file_path)
    if touched_hashes == nil then
        return nil
    end

    local last_touched_hash = nil
    for i = index, #all_hashes do
        local hash = all_hashes[i]
        -- search the hash in touched_hashes
        for _, touched_hash in ipairs(touched_hashes) do
            if string.sub(touched_hash, 1, 7) == string.sub(hash, 1, 7) then
                last_touched_hash = touched_hash
                break
            end
        end

        -- print("searching next")
        if last_touched_hash ~= nil then
            break
        end
    end

    if last_touched_hash == nil then
        return nil
    end

    local command = "cd "
        .. file.git_dir()
        .. " && "
        .. "git --no-pager log -M --follow --pretty=format:'%H' --name-only "
        .. last_touched_hash
        .. "~.. -- "
        .. git_relative_file_path
        .. " | tail -1"

    local output = command_util.execute(command)
    output = string.gsub(output, "\n", "")

    return output
end

M.file_name_on_commit = file_name_on_commit

--- returns the base branch of a branch (where fork_point is)
M.base_branch = function()
    local command = [[git show-branch |\
      sed "s/].*//" |\
      grep "*" |\
      grep -v "$(git rev-parse --abbrev-ref HEAD)" |\
      head -n1 |\
      sed "s/^.*\\[//"]]

    local output = command_util.execute(command)

    return string.gsub(output, "\n", "")
end

M.current_branch = function()
    local command = "git branch --show-current"

    local output = command_util.execute(command)

    return string.gsub(output, "\n", "")
end

return M
