local utils = require("advanced_git_search.utils")
local finders = require("telescope.finders")

M = {}

local git_log_entry_maker = function(entry)
    -- dce3b0743 2022-09-09 author _ message
    local split = utils.split_string(entry, "_")
    local attrs = utils.split_string(split[1])
    local hash = attrs[1]
    local date = attrs[2]
    local author = attrs[3]
    local message = split[2]

    return {
        value = entry,
        display = hash .. " @ " .. date .. " by " .. author .. " --" .. message,
        ordinal = author .. " " .. message,
        preview_title = hash .. " -- " .. message,
        opts = {
            commit_hash = hash,
            date = date,
            author = author,
            message = message,
        },
    }
end

M.git_log_grepper_on_content = function()
    return finders.new_job(function(prompt)
        local command = {
            "git",
            "log",
            "--format=%C(auto)%h %as %C(green)%an _ %Creset %s",
            "-S",
        }
        if prompt and prompt ~= "" then
            table.insert(command, prompt)
        else
            table.insert(command, " ")
        end

        return vim.tbl_flatten(command)
    end, git_log_entry_maker)
end

M.git_log_grepper_on_location = function(filename, start_line, end_line)
    local location = string.format("-L%d,%d:%s", start_line, end_line, filename)

    return finders.new_job(function(prompt)
        local command = {
            "git",
            "log",
            location,
            "--format=%C(auto)%h %as %C(green)%an _ %Creset %s",
            "-s",
        }
        if prompt and prompt ~= "" then
            table.insert(command, "--grep=" .. prompt)
        end

        return vim.tbl_flatten(command)
    end, git_log_entry_maker)
end

M.git_log_grepper_on_file = function(filename)
    return finders.new_job(function(prompt)
        local command = {
            "git",
            "log",
            "--format=%C(auto)%h %as %C(green)%an _ %Creset %s",
            "-s",
        }
        if prompt and prompt ~= "" then
            table.insert(command, "--grep=" .. prompt)
        end

        table.insert(command, "--follow")
        table.insert(command, filename)

        return vim.tbl_flatten(command)
    end, git_log_entry_maker)
end

--- open diff for current file
--- @param commit (string) commit or branch to diff with
M.open_diff_view = function(
 commit, --[[optional]]
 file_name
)
    if file_name ~= nil and file_name ~= "" then
        vim.api.nvim_command(":Gvdiffsplit " .. commit .. ":" .. file_name)
    else
        vim.api.nvim_command(":Gvdiffsplit " .. commit)
    end
end

M.determine_historic_file_name = function(commit_hash, current_file_name)
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
        output = current_file_name
    end
    return output
end

--- returns the base branch of a branch (where fork_point is)
M.base_branch = function()
    local command =
    'git show-branch | sed "s/].*//" | grep "*" | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed "s/^.*\\[//"'
    -- local command =
    --     'git show-branch | sed "s/].*//" | grep "*" | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed "s/^.*[//"'
    local handle = io.popen(command)
    local output = handle:read("*a")
    handle:close()

    output = string.gsub(output, "\n", "")
    return output
end

return M
