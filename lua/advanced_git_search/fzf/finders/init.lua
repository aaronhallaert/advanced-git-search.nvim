local preview_utils = require("advanced_git_search.fzf.previewers.utils")
local cmd_utils = require("advanced_git_search.commands.utils")
local finder_cmds = require("advanced_git_search.commands.find")
local utils = require("advanced_git_search.utils")

local M = {}

M.git_log_content_finder = function(query)
    preview_utils.set_last_query(query)

    local prompt, author = cmd_utils.split_query_from_author(query)

    return table.concat(
        finder_cmds.git_log_content(utils.escape_term(prompt), author),
        " "
    )
end

return M
