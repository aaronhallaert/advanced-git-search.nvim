local pickers = require("advanced_git_search.telescope.pickers")
local config = require("advanced_git_search.utils.config")

return require("telescope").register_extension({
    setup = function(ext_config, _)
        config.setup(ext_config)

        vim.api.nvim_create_user_command(
            "AdvancedGitSearch",
            "lua require('telescope').extensions.advanced_git_search.show_custom_functions()",
            { range = true }
        )
    end,
    exports = pickers,
})
