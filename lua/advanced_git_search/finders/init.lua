local finders = require("telescope.finders")
local file = require("advanced_git_search.utils.file")
local finder_utils = require("advanced_git_search.finders.utils")
local git_utils = require("advanced_git_search.utils.git")

local M = {}

M.git_branches_finder = function()
    return finders.new_oneshot_job({
        "git",
        "branch",
        "--format=%(refname:short)",
    })
end

--- Returns all commits that changed the visual selection in the buffer
M.git_log_location_finder = function(bufnr, start_line, end_line)
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

        local prompt, author = finder_utils.split_query_from_author(query)

        if author and author ~= "" then
            table.insert(command, "--author=" .. author)
        end

        if prompt and prompt ~= "" then
            table.insert(command, "-s")
            table.insert(command, "-i")
            table.insert(command, "--grep=" .. prompt)
        end

        finder_utils.set_last_prompt(prompt)
        return vim.tbl_flatten(command)
    end, finder_utils.git_log_entry_maker)
end

--- Returns all commits that contains the prompt string in the commit content
--- @param opts table with optional key `bufnr` to filter on the file of the buffer
M.git_log_content_finder = function(opts)
    opts = opts or {}

    return finders.new_job(function(query)
        local command = {
            "git",
            "log",
            "--format=%C(auto)%h %as %C(green)%an _ %Creset %s",
        }

        local prompt, author = finder_utils.split_query_from_author(query)

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

        finder_utils.set_last_prompt(prompt)
        return vim.tbl_flatten(command)
    end, finder_utils.git_log_entry_maker)
end

--- Returns all commits that changed the file of the passed buffer
M.git_log_file_finder = function(bufnr)
    local filename = file.relative_path(bufnr)
    return finders.new_job(function(query)
        local command = {
            "git",
            "log",
            "--format=%C(auto)%h %as %C(green)%an _ %Creset %s",
        }

        local prompt, author = finder_utils.split_query_from_author(query)

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

        finder_utils.set_last_prompt(prompt)
        return vim.tbl_flatten(command)
    end, finder_utils.git_log_entry_maker)
end

M.changed_files_on_current_branch_finder = function()
    return finders.new_oneshot_job(vim.tbl_flatten({
        "git",
        "--no-pager",
        "diff",
        "--name-only",
        "--cached",
        "--diff-filter=ACMR",
        "--merge-base",
        git_utils.base_branch(),
        "--relative",
    }))
end

return M
