local Snacks = require("snacks")
local snack_previewers = require("advanced_git_search.snacks.previewers")
local snack_formatters = require("advanced_git_search.snacks.formatters")
local snack_finders = require("advanced_git_search.snacks.finders")
local global_picker = require("advanced_git_search.global_picker")
local snacks_actions = require("advanced_git_search.snacks.actions")

local M = {}

---@return table
local commit_actions = function()
    return {
        win = {
            input = {
                keys = {
                    [snacks_actions.open_commit_in_browser.key] = {
                        "open_commit_in_browser",
                        mode = { "n", "i" },
                    },
                    [snacks_actions.copy_commit_hash.key] = {
                        "copy_commit_hash",
                        mode = { "n", "i" },
                    },
                    [snacks_actions.show_entire_commit.key] = {
                        "show_entire_commit",
                        mode = { "n", "i" },
                    },
                },
            },
        },
        actions = {
            open_commit_in_browser = snacks_actions.open_commit_in_browser.action,
            copy_commit_hash = snacks_actions.copy_commit_hash.action,
            show_entire_commit = snacks_actions.show_entire_commit.action,
            confirm = snacks_actions.open_diff_buffer_with_selected_commit(
                vim.fn.bufnr()
            ).action,
        },
    }
end

M.search_log_content = function()
    Snacks.picker.pick(nil, {
        finder = snack_finders.git_log_content(),
        format = snack_formatters.git_log(),
        preview = snack_previewers.git_diff_content(),
        live = true,
        actions = commit_actions().actions,
        win = commit_actions().win,
    })
end

M.search_log_content_file = function()
    local bufnr = vim.fn.bufnr()

    Snacks.picker.pick(nil, {
        finder = snack_finders.git_log_content({ bufnr = bufnr }),
        format = snack_formatters.git_log(),
        preview = snack_previewers.git_diff_content({ bufnr = bufnr }),
        actions = commit_actions().actions,
        win = commit_actions().win,
        live = true,
    })
end

M.diff_commit_line = function()
    local bufnr = vim.fn.bufnr()
    local s_start = vim.fn.getpos("'<")[2]
    local s_end = vim.fn.getpos("'>")[2]

    if s_start == 0 or s_end == 0 then
        vim.notify(
            "No visual selection",
            vim.log.levels.WARN,
            { title = "Advanced Git Search" }
        )
        return
    end

    Snacks.picker.pick(nil, {
        finder = snack_finders.git_log_location(bufnr, s_start, s_end),
        format = snack_formatters.git_log(),
        preview = snack_previewers.git_diff_file({ bufnr = bufnr }),
        actions = commit_actions().actions,
        win = commit_actions().win,
        live = true,
    })
end

M.diff_commit_file = function()
    local bufnr = vim.fn.bufnr()

    Snacks.picker.pick(nil, {
        finder = snack_finders.git_log_file(bufnr),
        format = snack_formatters.git_log(),
        preview = snack_previewers.git_diff_file({ bufnr = bufnr }),
        actions = commit_actions().actions,
        win = commit_actions().win,
        live = true,
    })
end

M.diff_branch_file = function()
    local bufnr = vim.fn.bufnr()

    Snacks.picker.pick(nil, {
        finder = snack_finders.git_branches(),
        preview = snack_previewers.git_diff_branch({ bufnr = bufnr }),
        actions = {
            confirm = snacks_actions.diff_buffer_with_branch(bufnr).action,
        },
    })
end

M.show_custom_functions = function()
    local keys = global_picker.keys("snacks")

    local items = {} ---@type snacks.picker.finder.Item[]

    for _, key in ipairs(keys) do
        table.insert(items, { text = key })
    end

    -- Snacks.picker.
    Snacks.picker.pick(nil, {
        items = items,
        win = {
            input = {
                keys = {
                    ["<CR>"] = { "open_picker", mode = { "n", "i" } },
                },
            },
        },
        actions = {
            open_picker = function(picker, item)
                picker:close()
                global_picker.execute_git_function(item.text, "snacks")
            end,
        },
        format = function(item)
            local ret = {} ---@type snacks.picker.Highlight[]
            ret[#ret + 1] = { item.text, "SnacksPickerGitMsg" }
            return ret
        end,
    })
end

return M
