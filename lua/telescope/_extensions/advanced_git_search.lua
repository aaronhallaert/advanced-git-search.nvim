local pickers = require("advanced_git_search.telescope.pickers")
local config = require("advanced_git_search.utils.config")
local setup = require("advanced_git_search.utils.setup")

return require("telescope").register_extension({
    setup = function(ext_config, _)
        config.setup(ext_config)

        setup.setup_user_command(pickers)
    end,
    exports = pickers,
})
