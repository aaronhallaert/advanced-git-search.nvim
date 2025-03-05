local Snacks = require("snacks")
local snack_previewers = require("advanced_git_search.snacks.previewers")
local snack_formatters = require("advanced_git_search.snacks.formatters")
local snack_finders = require("advanced_git_search.snacks.finders")

local M = {}

M.search_log_content = function()
    Snacks.picker.pick(nil, {
        finder = snack_finders.git_log_content(),
        format = snack_formatters.git_log(),
        preview = snack_previewers.git_diff_content(),
        live = true,
    })
end

return M
