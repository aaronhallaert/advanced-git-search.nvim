local preview_commands = require("advanced_git_search.commands.preview")
local git_utils = require("advanced_git_search.utils.git")
local file_utils = require("advanced_git_search.utils.file")
local fzf_previewer =
    require("advanced_git_search.fzf.previewers.fzf_previewer")

local generate_context = function()
    local opts = { source_bufnr = vim.api.nvim_get_current_buf() }

    return function(entry_str)
        local hash = string.sub(entry_str, 1, 7)
        local selected_commit_info = git_utils.commit_info(hash)

        local source_filename = file_utils.git_relative_path(opts.source_bufnr)

        return {
            "Preview displays changes on selected commit:",
            string.format("\t %s", selected_commit_info),
            "For the current file:",
            string.format("\t %s", source_filename),
            "",
            "<default> to diff against current buffer",
        }
    end
end

local generate_preview_command = function()
    local opts = { source_bufnr = vim.api.nvim_get_current_buf() }

    return function(entry_str)
        local hash = string.sub(entry_str, 1, 7)
        local prev_commit = git_utils.previous_commit_hash(hash)

        return table.concat(
            preview_commands.git_diff_file(prev_commit, hash, opts.source_bufnr),
            " "
        )
    end
end

return fzf_previewer.create(generate_preview_command(), generate_context(), nil)
