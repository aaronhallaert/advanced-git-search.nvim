local file = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")
local tbl = require("advanced_git_search.utils.table")
local command_utils = require("advanced_git_search.commands.utils")

-- Specify shell commands for each finders in table format
local M = {}

M.git_branches = function(opts)
    opts = opts or { format_with_quotes = false }

    local format
    if opts["format_with_quotes"] then
        format = "--format='%(refname:short)'"
    else
        format = "--format=%(refname:short)"
    end

    return {
        "git",
        "branch",
        format,
    }
end

M.reflog = function()
    return {
        "git",
        "reflog",
        "--date=iso",
    }
end

---@param prompt? string
---@param author? string
---@param bufnr? number
---@return table
M.git_log_content = function(prompt, author, bufnr)
    local command = {
        "git",
        "log",
        "--format='%h %as %an _ %s'",
    }

    command = command_utils.format_git_log_command(command)

    if author and author ~= "" and author ~= '""' then
        table.insert(command, "--author=" .. author)
    end

    if prompt and prompt ~= "" and prompt ~= '""' then
        table.insert(command, "-G")
        table.insert(command, prompt)
        table.insert(command, "--pickaxe-all")
    end

    if bufnr then
        table.insert(command, "--follow")
        local filename = file.relative_path(bufnr)
        table.insert(command, filename)
    end

    return tbl.flatten(command)
end

---@param prompt string|nil
---@param author string|nil
---@param bufnr number
---@return table
M.git_log_file = function(prompt, author, bufnr)
    local filename = file.relative_path(bufnr)
    local command = {
        "git",
        "log",
        "--format='%h %as %an _ %s'",
    }

    command = command_utils.format_git_log_command(command)

    if author and author ~= "" and author ~= '""' then
        table.insert(command, "--author=" .. author)
    end

    if prompt and prompt ~= "" and prompt ~= '""' then
        table.insert(command, "-s")
        table.insert(command, "-i")
        table.insert(command, "--grep=" .. prompt)
    end

    table.insert(command, "--follow")
    table.insert(command, filename)

    return tbl.flatten(command)
end

---@param prompt string|nil
---@param author string|nil
---@param bufnr number
---@param start_line number
---@param end_line number
---@return table
M.git_log_location = function(prompt, author, bufnr, start_line, end_line)
    local filename = file.relative_path(bufnr)
    local location = string.format("-L%d,%d:%s", start_line, end_line, filename)
    local command = {
        "git",
        "log",
        location,
        "--no-patch",
        "--format='%h %as %an _ %s'",
    }

    command = command_utils.format_git_log_command(command)

    if author and author ~= "" and author ~= '""' then
        table.insert(command, "--author=" .. author)
    end

    if prompt and prompt ~= "" and prompt ~= '""' then
        table.insert(command, "-s")
        table.insert(command, "-i")
        table.insert(command, "--grep=" .. prompt)
    end

    return tbl.flatten(command)
end

M.changed_on_branch = function()
    local command = {
        "git",
        "--no-pager",
        "diff",
        "--name-only",
        "--cached",
        "--diff-filter=ACMR",
        "--merge-base",
        git_utils.base_branch(),
        "--relative",
    }

    return tbl.flatten(command)
end

return M
