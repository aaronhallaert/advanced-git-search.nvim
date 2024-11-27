local utils = require("advanced_git_search.utils")
local command_utils = require("advanced_git_search.commands.utils")
local file = require("advanced_git_search.utils.file")
local command_util = require("advanced_git_search.utils.command")

local M = {}

local all_commit_hashes = function()
    local command = "git rev-list HEAD"
    local output = command_util.execute(command)

    return utils.split_string(output, "\n")
end

local all_commit_hashes_touching_file = function(git_relative_file_path)
    local git_log_cmd = {
        "git",
        "log",
        "--follow",
        "--pretty=format:'%H'",
        "--",
        git_relative_file_path,
    }

    git_log_cmd = command_utils.format_git_log_command(git_log_cmd)

    local command = "cd "
        .. file.git_dir()
        .. " && "
        .. table.concat(git_log_cmd, " ")

    local output = command_util.execute(command)
    return utils.split_string(output, "\n")
end

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
--         .. " && git log --follow --diff-filter=R --pretty=format:'%H' -- "
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

M.file_exists_on_commit = file_exists_on_commit

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

    -- first find index of the passed commit_hash in all_commit_hashes
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
            if
                touched_hash ~= nil
                and hash ~= nil
                and string.sub(touched_hash, 1, 7) == string.sub(hash, 1, 7)
            then
                last_touched_hash = touched_hash
                break
            end
        end

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
        .. "git --no-pager log --follow --pretty=format:'%H' --name-only "
        .. last_touched_hash
        .. "~.. -- "
        .. git_relative_file_path
        .. " | tail -1"

    local output = command_util.execute(command)
    output = string.gsub(output, "\n", "")

    if file_exists_on_commit(commit_hash, output) then
        return output
    else
        return nil
    end
end

M.file_name_on_commit = file_name_on_commit

--- Returns true if hash is a commit
--- @param commit_hash string
--- @return boolean is_commit true if hash is commit
local is_commit = function(commit_hash)
    local command = "cd "
        .. file.git_dir()
        .. " && git cat-file -t "
        .. commit_hash

    local output = command_util.execute(command)

    output = string.gsub(output, "\n", "")
    return output == "commit"
end

M.is_commit = is_commit

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
