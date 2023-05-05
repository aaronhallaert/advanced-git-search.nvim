local command_utils = require("advanced_git_search.commands.utils")
local fzf_lua = require("fzf-lua")
local fzf_preview_utils = require("advanced_git_search.fzf.previewers.utils")
local utils = require("advanced_git_search.utils")
local preview_commands = require("advanced_git_search.commands.preview")
local git_utils = require("advanced_git_search.utils.git")

local M = {}

M.git_diff_content_previewer = function()
    return fzf_lua.shell.preview_action_cmd(function(items)
        local selection = items[1]
        local hash = string.sub(selection, 1, 7)

        local prev_commit = git_utils.previous_commit_hash(hash)
        local prompt, _ = command_utils.split_query_from_author(
            fzf_preview_utils.get_last_query()
        )

        local preview_command = table.concat(
            preview_commands.git_diff_content(
                prev_commit,
                hash,
                string.format('"%s"', utils.escape_term(prompt))
            ),
            " "
        )

        if prompt and prompt ~= "" and prompt ~= '""' then
            preview_command = preview_command
                .. string.format(
                    " | GREP_COLOR='3;30;105' grep -A 999999 -B 999999 --color=always '%s'",
                    prompt
                )
        end

        return preview_command
    end)
end

M.git_diff_file_previewer = function(bufnr)
    return fzf_lua.shell.preview_action_cmd(function(items)
        local selection = items[1]
        local commit_hash = string.sub(selection, 1, 7)
        local prev_commit = git_utils.previous_commit_hash(commit_hash)

        return table.concat(
            preview_commands.git_diff_file(prev_commit, commit_hash, bufnr),
            " "
        )
    end)
end

M.git_diff_branch_file_previewer = function(bufnr)
    return fzf_lua.shell.preview_action_cmd(function(items)
        local branch = items[1]

        return table.concat(
            preview_commands.git_diff_branch(branch, bufnr),
            " "
        )
    end)
end

M.git_diff_base_branch = function()
    return fzf_lua.shell.preview_action_cmd(function(items)
        local filename = items[1]

        return table.concat(
            preview_commands.git_diff_base_branch(filename),
            " "
        )
    end)
end
return M
