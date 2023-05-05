local cmd_utils = require("advanced_git_search.commands.utils")
local fzf_lua = require("fzf-lua")
local preview_utils = require("advanced_git_search.fzf.previewers.utils")
local utils = require("advanced_git_search.utils")
local preview_commands = require("advanced_git_search.commands.preview")
local git_utils = require("advanced_git_search.utils.git")

local M = {}

M.git_diff_content_previewer = function()
    return fzf_lua.shell.preview_action_cmd(function(items)
        local selection = items[1]
        local hash = string.sub(selection, 1, 7)

        local prev_commit = git_utils.previous_commit_hash(hash)
        -- local preview_command =
        --     string.format("git --no-pager diff %s~ %s", hash, hash)
        --
        local prompt, _ =
            cmd_utils.split_query_from_author(preview_utils.get_last_query())

        -- preview_command = preview_command .. string.format(" --color=always")
        --
        -- -- command
        -- if prompt and prompt ~= "" then
        --     preview_command = preview_command
        --         .. " -G '"
        --         .. utils.escape_term(prompt)
        --         .. "'"
        -- end
        --
        local preview_command = table.concat(
            preview_commands.git_diff_content(prev_commit, hash, prompt),
            " "
        )

        preview_command = preview_command
            .. string.format(
                " | GREP_COLOR='3;30;105' grep -A 999999 -B 999999 --color=always '%s'",
                prompt
            )

        return preview_command
    end)
end

return M
