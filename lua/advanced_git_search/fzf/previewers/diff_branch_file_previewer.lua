local fzf_previewer =
    require("advanced_git_search.fzf.previewers.fzf_previewer")
local preview_commands = require("advanced_git_search.commands.preview")

local generate_context = function(branch)
    return {
        "Preview changes of current buffer with selected branch",
        string.format("\t %s", branch),
        "<CR> to open diff in new buffer",
    }
end

local generate_preview_command = function()
    local current_buf = vim.api.nvim_get_current_buf()
    return function(branch)
        return table.concat(
            preview_commands.git_diff_branch(branch, current_buf),
            " "
        )
    end
end

return fzf_previewer.create(generate_preview_command(), generate_context, nil)
