local file = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")

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

---@param prompt string|nil
---@param author string|nil
---@param bufnr number|nil
---@return table
M.git_log_content = function(prompt, author, bufnr)
    local command = {
        "git",
        "log",
        "--format='%h %as %an _ %s'",
    }

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

    return vim.tbl_flatten(command)
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

    return vim.tbl_flatten(command)
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

    if author and author ~= "" and author ~= '""' then
        table.insert(command, "--author=" .. author)
    end

    if prompt and prompt ~= "" and prompt ~= '""' then
        table.insert(command, "-s")
        table.insert(command, "-i")
        table.insert(command, "--grep=" .. prompt)
    end

    return vim.tbl_flatten(command)
end

---@param bufnr number
---@param start_line number
---@param end_line number
---@return table
M.git_blame_location = function(bufnr, start_line, end_line)
    local filename = file.relative_path(bufnr)
    local location = string.format("-L%d,%d", start_line, end_line)
    local command = {
        "git",
        "--no-pager",
        "blame",
        "-w", --ignore whitespace
        "-C",
        "-C",
        "-C", -- 3 times: copy from other file in any commit
        location,
        "-M",
        filename,
        "--date=short",
    }

    return vim.tbl_flatten(command)
end

M.changed_on_branch = function()
    return vim.tbl_flatten({
        "git",
        "--no-pager",
        "diff",
        "--name-only",
        "--cached",
        "--diff-filter=ACMR",
        "--merge-base",
        git_utils.base_branch(),
        "--relative",
    })
end

return M
