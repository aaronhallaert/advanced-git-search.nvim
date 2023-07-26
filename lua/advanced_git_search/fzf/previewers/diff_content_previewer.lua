local command_utils = require("advanced_git_search.commands.utils")
local fzf_preview_utils = require("advanced_git_search.fzf.previewers.utils")
local utils = require("advanced_git_search.utils")
local preview_commands = require("advanced_git_search.commands.preview")
local git_utils = require("advanced_git_search.utils.git")
local fzf_previewer =
    require("advanced_git_search.fzf.previewers.fzf_previewer")

local generate_context = function(entry_str)
    local hash = string.sub(entry_str, 1, 7)

    -- CONTEXT
    local selected_commit_info = git_utils.commit_info(hash)

    return {
        "Preview changes on selected commit",
        string.format("\t %s", selected_commit_info),
        "<CR> to diff against current buffer",
    }
end

local generate_preview_command = function(entry_str)
    local hash = string.sub(entry_str, 1, 7)

    -- PREVIEW
    local prev_commit = git_utils.previous_commit_hash(hash)
    local prompt, _ = command_utils.split_query_from_author(
        fzf_preview_utils.get_last_query()
    )

    return table.concat(
        preview_commands.git_diff_content(
            prev_commit,
            hash,
            string.format('"%s"', utils.escape_term(prompt)),
            nil
        ),
        " "
    )
end

local callback = function(previewbuf)
    return function()
        local prompt, _ = command_utils.split_query_from_author(
            fzf_preview_utils.get_last_query()
        )

        vim.api.nvim_buf_call(previewbuf, function()
            vim.fn.clearmatches()

            if prompt and prompt ~= "" and prompt ~= '""' then
                vim.fn.matchadd("IncSearch", prompt, 10)
            end
        end)
    end
end

return fzf_previewer.create(
    generate_preview_command,
    generate_context,
    callback
)
