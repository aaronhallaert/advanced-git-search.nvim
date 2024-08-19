local M = {}
local config = require("advanced_git_search.utils.config")
local setup = require("advanced_git_search.utils.setup")

M.setup = function(opts)
    opts.git_diff_flags =
        vim.tbl_extend("force", opts.git_diff_flags or {}, { "--color=always" })

    config.setup(opts)

    local pickers = require("advanced_git_search.fzf.pickers")
    setup.setup_user_command(pickers)
end

return M
