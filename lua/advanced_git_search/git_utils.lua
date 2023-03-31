local file = require("advanced_git_search.utils.file")
local utils = require("advanced_git_search.utils")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")

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

local determine_historic_file_name = function(commit_hash, bufnr)
    local current_file_name = file.relative_path(bufnr)

    local command = "git log -M --diff-filter=R --follow --name-status --summary "
        .. commit_hash
        .. ".. -- "
        .. current_file_name
        .. " | grep ^R | tail -1 | cut -f2,2"

    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    output = string.gsub(output, "\n", "")
    if output == "" then
        output = file.git_relative_path(bufnr)
    end

    -- output is relative to git root
    return output
end

M.git_diff_previewer_file = function(bufnr)
    return previewers.new_termopen_previewer({
        get_command = function(entry)
            local commit_hash = entry.opts.commit_hash

            local prev_commit = string.format("%s~", commit_hash)
            return {
                "git",
                "diff",
                prev_commit
                    .. ":"
                    .. determine_historic_file_name(prev_commit, bufnr),
                commit_hash
                    .. ":"
                    .. determine_historic_file_name(commit_hash, bufnr),
            }
        end,
    })
end

--- open diff for current file
--- @param commit (string) commit or branch to diff with
M.open_diff_view = function(
    commit, --[[optional]]
    file_name
)
    if
        vim.fn.exists(":DiffviewOpen") == 0
        and vim.fn.exists(":Gvdiffsplit") == 0
    then
        vim.notify(
            "Could not open diff: diffview.nvim or git-fugitive is not installed",
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
    end

    if file_name ~= nil and file_name ~= "" then
        if vim.fn.exists(":DiffviewOpen") > 0 then
            vim.api.nvim_command(
                ":DiffviewOpen " .. commit .. " -- " .. file_name
            )
        elseif vim.fn.exists(":Gvdiffsplit") > 0 then
            vim.api.nvim_command(":Gvdiffsplit " .. commit .. ":" .. file_name)
        end
    else
        if vim.fn.exists(":DiffviewOpen") > 0 then
            vim.api.nvim_command(":DiffviewOpen " .. commit)
        elseif vim.fn.exists(":Gvdiffsplit") > 0 then
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

M.determine_historic_file_name = determine_historic_file_name

return M
