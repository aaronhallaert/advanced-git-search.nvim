local M = {}
local config = require("advanced_git_search.utils.config")
local setup = require("advanced_git_search.utils.setup")

M.setup = function(opts)
    config.setup(opts)

    local pickers = require("advanced_git_search.fzf.pickers")
    setup.setup_user_command(pickers)
end

return M
