local M = {}

local ags_previewers = require("advanced_git_search.fzf.previewers")
local ags_finders = require("advanced_git_search.fzf.finders")

M.search_log_content = function()
    local opts = {
        prompt = "Log> ",
        exec_empty_query = false,
        func_async_callback = false,
        fzf_opts = {
            ["--preview"] = ags_previewers.git_diff_content_previewer(),
        },
    }

    vim.print("Execute search log content")
    require("fzf-lua").fzf_live(ags_finders.git_log_content_finder, opts)
end

return M
