local finders = require("telescope.finders")
local telescope_finder_utils =
    require("advanced_git_search.telescope.finders.utils")
local command_utils = require("advanced_git_search.commands.utils")
local finder_commands = require("advanced_git_search.commands.find")
local utils = require("advanced_git_search.utils")

local M = {}

M.git_branches_finder = function()
    return finders.new_oneshot_job(finder_commands.git_branches(), {})
end

--- Returns all commits that changed the visual selection in the buffer
M.git_log_location_finder = function(bufnr, start_line, end_line)
    return finders.new_job(function(query)
        local prompt, author = command_utils.split_query_from_author(query)

        telescope_finder_utils.set_last_prompt(prompt)

        return finder_commands.git_log_location(
            prompt,
            author,
            bufnr,
            start_line,
            end_line
        )
    end, telescope_finder_utils.git_log_entry_maker)
end

--- Returns all commits that contains the prompt string in the commit content
--- @param opts table with optional key `bufnr` to filter on the file of the buffer
M.git_log_content_finder = function(opts)
    opts = opts or {}

    return finders.new_job(function(query)
        local prompt, author = command_utils.split_query_from_author(query)

        telescope_finder_utils.set_last_prompt(utils.escape_term(prompt))
        return finder_commands.git_log_content(
            utils.escape_term(prompt),
            author,
            opts.bufnr
        )
    end, telescope_finder_utils.git_log_entry_maker)
end

--- Returns all commits that changed the file of the passed buffer
M.git_log_file_finder = function(bufnr)
    return finders.new_job(function(query)
        local prompt, author = command_utils.split_query_from_author(query)

        telescope_finder_utils.set_last_prompt(prompt)
        return finder_commands.git_log_file(prompt, author, bufnr)
    end, telescope_finder_utils.git_log_entry_maker)
end

M.changed_files_on_current_branch_finder = function()
    return finders.new_oneshot_job(finder_commands.changed_on_branch(), {})
end

return M
