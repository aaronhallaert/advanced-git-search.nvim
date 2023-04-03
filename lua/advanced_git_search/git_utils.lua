local file = require("advanced_git_search.utils.file")
local utils = require("advanced_git_search.utils")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local config = require("advanced_git_search.utils.config")

local last_prompt = nil
local M = {}

local split_query_from_author = function(query)
    local author = nil
    local prompt = nil
    if query ~= nil and query ~= "" then
        -- starts with @
        if query:sub(1, 1) == "@" then
            author = query:sub(2)
            return prompt, author
        end

        local split = utils.split_string(query, "@")
        prompt = split[1]

        -- remove last space from prompt
        if prompt:sub(-1) == " " then
            prompt = prompt:sub(1, -2)
        end

        author = split[2]
    end

    return prompt, author
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

local git_log_entry_maker = function(entry)
    -- dce3b0743 2022-09-09 author _ message
    -- FIXME: will break if author contains _
    local split = utils.split_string(entry, "_")
    local attrs = utils.split_string(split[1])
    local hash = attrs[1]
    local date = attrs[2]
    local author = attrs[3]
    -- join split from second element
    local message = split[2]
    if #split > 2 then
        for i = 3, #split do
            message = message .. "_" .. split[i]
        end
    end

    return {
        value = entry,
        display = date .. " by " .. author .. " --" .. message,
        -- display = hash .. " @ " .. date .. " by " .. author .. " --" .. message,
        ordinal = author .. " " .. message,
        preview_title = hash .. " -- " .. message,
        opts = {
            commit_hash = hash,
            date = date,
            author = author,
            message = message,
            prompt = last_prompt,
        },
    }
end

M.git_log_grepper_on_content = function(opts)
    opts = opts or {}

    return finders.new_job(function(query)
        local command = {
            "git",
            "log",
            "--format=%C(auto)%h %as %C(green)%an _ %Creset %s",
        }

        local prompt, author = split_query_from_author(query)

        if author and author ~= "" then
            table.insert(command, "--author=" .. author)
        end

        if prompt and prompt ~= "" then
            table.insert(command, "-G" .. prompt)
            table.insert(command, "--pickaxe-all")
            -- table.insert(command, [[-G']] .. prompt .. [[']])
        end

        if opts.bufnr then
            table.insert(command, "--follow")
            local filename = file.relative_path(opts.bufnr)
            table.insert(command, filename)
        end

        last_prompt = prompt
        return vim.tbl_flatten(command)
    end, git_log_entry_maker)
end

M.git_log_grepper_on_location = function(bufnr, start_line, end_line)
    local filename = file.relative_path(bufnr)
    local location = string.format("-L%d,%d:%s", start_line, end_line, filename)

    return finders.new_job(function(query)
        local command = {
            "git",
            "log",
            location,
            "--no-patch",
            "--format=%C(auto)%h %as %C(green)%an _ %Creset %s",
        }

        local prompt, author = split_query_from_author(query)

        if author and author ~= "" then
            table.insert(command, "--author=" .. author)
        end

        if prompt and prompt ~= "" then
            table.insert(command, "-s")
            table.insert(command, "-i")
            table.insert(command, "--grep=" .. prompt)
        end

        last_prompt = prompt
        return vim.tbl_flatten(command)
    end, git_log_entry_maker)
end

M.git_log_grepper_on_file = function(bufnr)
    local filename = file.relative_path(bufnr)
    return finders.new_job(function(query)
        local command = {
            "git",
            "log",
            "--format=%C(auto)%h %as %C(green)%an _ %Creset %s",
        }

        local prompt, author = split_query_from_author(query)

        if author and author ~= "" then
            table.insert(command, "--author=" .. author)
        end

        if prompt and prompt ~= "" then
            table.insert(command, "-s")
            table.insert(command, "-i")
            table.insert(command, "--grep=" .. prompt)
        end

        table.insert(command, "--follow")
        table.insert(command, filename)

        last_prompt = prompt
        return vim.tbl_flatten(command)
    end, git_log_entry_maker)
end

local previous_commit_hash = function(commit_hash)
    local command = "git rev-parse " .. commit_hash .. "~"
    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    output = string.gsub(output, "\n", "")
    return output
end

local all_commit_hashes = function()
    local command = "git rev-list --all"
    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    return utils.split_string(output, "\n")
end

local all_commit_hashes_touching_file = function(git_relative_file_path)
    local command = "cd "
        .. file.git_dir()
        .. " && git log --all --follow --pretty=format:'%H' -- "
        .. git_relative_file_path
    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    output = utils.split_string(output, "\n")
    return output
end

local is_file_renamed = function(git_relative_file_path)
    local command = "cd "
        .. file.git_dir()
        .. " && git log --all --follow --diff-filter=R --pretty=format:'%H' -- "
        .. git_relative_file_path
    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    output = utils.split_string(output, "\n")
    return #output > 0
end

local file_exists_on_commit = function(commit_hash, git_relative_file_path)
    local command = "cd "
        .. file.git_dir()
        .. " && git ls-tree --name-only "
        .. commit_hash
        .. " -- "
        .. git_relative_file_path
    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    output = string.gsub(output, "\n", "")

    return output ~= ""
end

local file_name_on_commit = function(commit_hash, git_relative_file_path)
    if file_exists_on_commit(commit_hash, git_relative_file_path) then
        return git_relative_file_path
    end

    -- FIXME: this is a very naive implementation, but it always returns the
    -- correct filename for each commit (even if the commit didn't touch the file)

    -- first find index in all_commit_hashes
    local all_hashes = all_commit_hashes()
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

    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    output = string.gsub(output, "\n", "")

    return output
end

M.git_diff_previewer_file = function(bufnr)
    return previewers.new_termopen_previewer({
        get_command = function(entry)
            local filename_on_head = file.git_relative_path(bufnr)

            local commit_hash = entry.opts.commit_hash

            local prev_commit = previous_commit_hash(commit_hash)
            local curr_name = nil
            local prev_name = nil

            curr_name = file_name_on_commit(commit_hash, filename_on_head)
            prev_name = file_name_on_commit(prev_commit, filename_on_head)

            if prev_name ~= nil then
                return git_diff_command({
                    "git",
                    "diff",
                    prev_commit .. ":" .. prev_name,
                    commit_hash .. ":" .. curr_name,
                })
            else
                return git_diff_command({
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

--- open diff for current file
--- @param commit (string) commit or branch to diff with
M.open_diff_view = function(
    commit, --[[optional]]
    file_name
)
    local diff_plugin = config.diff_plugin()

    if file_name ~= nil and file_name ~= "" then
        if diff_plugin == "diffview" then
            vim.api.nvim_command(
                ":DiffviewOpen " .. commit .. " -- " .. file_name
            )
        elseif diff_plugin == "fugitive" then
            vim.api.nvim_command(":Gvdiffsplit " .. commit .. ":" .. file_name)
        end
    else
        if diff_plugin == "diffview" then
            vim.api.nvim_command(":DiffviewOpen " .. commit)
        elseif diff_plugin == "fugitive" then
            vim.api.nvim_command(":Gvdiffsplit " .. commit)
        end
    end
end

--- returns the base branch of a branch (where fork_point is)
M.base_branch = function()
    local command = [[git show-branch |\
      sed "s/].*//" |\
      grep "*" |\
      grep -v "$(git rev-parse --abbrev-ref HEAD)" |\
      head -n1 |\
      sed "s/^.*\\[//"]]

    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    output = string.gsub(output, "\n", "")
    return output
end

M.current_branch = function()
    local command = "git branch --show-current"
    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    output = string.gsub(output, "\n", "")
    return output
end

M.file_name_on_commit = file_name_on_commit
M.git_diff_command = git_diff_command

return M
