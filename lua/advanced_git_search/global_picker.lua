local M = {}

local config = require("advanced_git_search.utils.config")

---@param finder_plugin "telescope"|"fzf_lua"
---@return table
local custom_git_functions = function(finder_plugin)
    local pickers_table = {}
    if finder_plugin == "telescope" then
        pickers_table = require("advanced_git_search.telescope.pickers")
    elseif finder_plugin == "fzf_lua" then
        pickers_table = require("advanced_git_search.fzf.pickers")
    end

    return {
        {
            value = "Search in repo log content",
            func = pickers_table.search_log_content,
        },
        {
            value = "Search in file log content",
            func = pickers_table.search_log_content_file,
        },
        {
            value = "Diff current file with commit",
            func = pickers_table.diff_commit_file,
        },
        {
            value = "Diff current file with selected line history",
            func = pickers_table.diff_commit_line,
        },
        {
            value = "Diff file with branch",
            func = pickers_table.diff_branch_file,
        },
        {
            value = "Changed on current branch (experimental)",
            func = pickers_table.changed_on_branch,
        },
        {
            value = "Checkout from reflog",
            func = pickers_table.checkout_reflog,
        },
    }
end

---@param finder_plugin "telescope"|"fzf_lua"
---@return table
local builtin_git_functions = function(finder_plugin)
    local builtin_functions = {}
    if finder_plugin == "telescope" then
        builtin_functions = require("telescope.builtin")
    elseif finder_plugin == "fzf_lua" then
        builtin_functions = require("fzf-lua")
    end

    return {
        {
            value = "Git commits [builtin]",
            func = builtin_functions.git_commits,
        },
        {
            value = "Git branches [builtin]",
            func = builtin_functions.git_branches,
        },
        {
            value = "Git status [builtin]",
            func = builtin_functions.git_status,
        },
        {
            value = "Git stash [builtin]",
            func = builtin_functions.git_stash,
        },
    }
end

local function map_item(git_functions_table, f)
    local t = {}
    for k, v in pairs(git_functions_table) do
        t[k] = f(v)
    end
    return t
end

---@param finder_plugin "telescope"|"fzf_lua"
---@return table
local git_functions_table = function(finder_plugin)
    local t = {}
    for _, v in pairs(custom_git_functions(finder_plugin)) do
        t[#t + 1] = v
    end

    if config.show_builtin_git_pickers() then
        for _, v in pairs(builtin_git_functions(finder_plugin)) do
            t[#t + 1] = v
        end
    end

    return t
end

---@param value any
---@param finder_plugin "telescope"|"fzf_lua"
M.execute_git_function = function(value, finder_plugin)
    for _, v in pairs(git_functions_table(finder_plugin)) do
        if v["value"] == value then
            v["func"]()
            return
        end
    end
end

---@param finder_plugin "telescope"|"fzf_lua"
---@return table
M.keys = function(finder_plugin)
    return map_item(git_functions_table(finder_plugin), function(v)
        return v["value"]
    end)
end

return M
