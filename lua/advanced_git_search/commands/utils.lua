local config = require("advanced_git_search.utils.config")
local utils = require("advanced_git_search.utils")

local M = {}

--- @param command table
--- @param git_flags_ix number|nil
--- @param git_diff_flags_ix number|nil
--- @return table Command with configured git diff flags
M.format_git_diff_command = function(command, git_flags_ix, git_diff_flags_ix)
    git_flags_ix = git_flags_ix or 2
    git_diff_flags_ix = git_diff_flags_ix or 3

    local git_diff_flags = config.git_diff_flags()
    local git_flags = config.git_flags()

    if git_flags_ix > git_diff_flags_ix then
        vim.notify(
            "git_flags must be inserted before git_diff_flags",
            vim.log.levels.ERROR
        )
    end

    if git_diff_flags ~= nil and #git_diff_flags > 0 then
        for i, flag in ipairs(git_diff_flags) do
            table.insert(command, git_diff_flags_ix + i - 1, flag)
        end
    end

    if git_flags ~= nil and #git_flags > 0 then
        for i, flag in ipairs(git_flags) do
            table.insert(command, git_flags_ix + i - 1, flag)
        end
    end

    return command
end

--- @param command table
--- @param git_flags_ix number|nil
--- @param git_log_flags_ix number|nil
--- @return table Command with configured git log flags
M.format_git_log_command = function(command, git_flags_ix, git_log_flags_ix)
    git_flags_ix = git_flags_ix or 2
    git_log_flags_ix = git_log_flags_ix or 3

    local git_log_flags = config.git_log_flags()
    local git_flags = config.git_flags()

    if git_flags_ix > git_log_flags_ix then
        vim.notify(
            "git_flags must be inserted before git_log_flags",
            vim.log.levels.ERROR
        )
    end

    if git_log_flags ~= nil and #git_log_flags > 0 then
        for i, flag in ipairs(git_log_flags) do
            table.insert(command, git_log_flags_ix + i - 1, flag)
        end
    end

    if git_flags ~= nil and #git_flags > 0 then
        for i, flag in ipairs(git_flags) do
            table.insert(command, git_flags_ix + i - 1, flag)
        end
    end

    return command
end

M.split_query_from_author = function(query)
    local author = nil
    local prompt = nil
    if query ~= nil and query ~= "" then
        -- starts with @
        if query:sub(1, 1) == "@" then
            author = query:sub(2)
            return prompt, author
        end

        local split = utils.split_string(query, "@")
        prompt = split[1]

        -- remove last space from prompt
        if prompt:sub(-1) == " " then
            prompt = prompt:sub(1, -2)
        end

        author = split[2]
    end

    prompt = prompt or ""
    author = author or ""
    return prompt, author
end

return M
