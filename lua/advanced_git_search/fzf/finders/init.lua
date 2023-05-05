local fzf_preview_utils = require("advanced_git_search.fzf.previewers.utils")
local command_utils = require("advanced_git_search.commands.utils")
local finder_commands = require("advanced_git_search.commands.find")
local utils = require("advanced_git_search.utils")

local M = {}

---@param query string
---@param bufnr number|nil
---@return string
M.git_log_content_finder = function(query, bufnr)
    fzf_preview_utils.set_last_query(query)

    local prompt, author = command_utils.split_query_from_author(query)

    author = author or ""
    local command = table.concat(
        finder_commands.git_log_content(
            string.format('"%s"', utils.escape_term(prompt)),
            string.format('"%s"', author),
            bufnr
        ),
        " "
    )

    return command
end

M.git_log_location_finder = function(query, bufnr, s_start, s_end)
    fzf_preview_utils.set_last_query(query)

    local prompt, author = command_utils.split_query_from_author(query)

    author = author or ""
    local command = table.concat(
        finder_commands.git_log_location(
            string.format('"%s"', utils.escape_term(prompt)),
            string.format('"%s"', author),
            bufnr,
            s_start,
            s_end
        ),
        " "
    )

    return command
end

M.git_log_file_finder = function(query, bufnr)
    fzf_preview_utils.set_last_query(query)

    local prompt, author = command_utils.split_query_from_author(query)

    local command = table.concat(
        finder_commands.git_log_file(
            string.format('"%s"', utils.escape_term(prompt)),
            string.format('"%s"', author),
            bufnr
        ),
        " "
    )

    return command
end

return M
