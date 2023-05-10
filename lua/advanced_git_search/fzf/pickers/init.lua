local M = {}

local fzf_previewers = require("advanced_git_search.fzf.previewers")
local fzf_finders = require("advanced_git_search.fzf.finders")
local fzf_mappings = require("advanced_git_search.fzf.mappings")
local fzf_picker_utils = require("advanced_git_search.fzf.pickers.utils")
local global_picker = require("advanced_git_search.global_picker")

M.search_log_content = function()
    local bufnr = vim.fn.bufnr()
    local opts = {
        prompt = "Log> ",
        exec_empty_query = true,
        func_async_callback = false,
        fzf_opts = {
            ["--preview"] = fzf_previewers.git_diff_content_previewer(),
        },
        fn_transform = function(x)
            return fzf_picker_utils.make_entry(x)
        end,
        actions = vim.tbl_extend(
            "keep",
            fzf_mappings.open_commit_in_brower(),
            fzf_mappings.open_diff_buffer_with_selected_commit(bufnr),
            fzf_mappings.show_entire_commit(),
            fzf_mappings.copy_commit_hash()
        ),
    }

    require("fzf-lua").fzf_live(function(query)
        return fzf_finders.git_log_content_finder(query, nil)
    end, opts)
end

M.search_log_content_file = function()
    local bufnr = vim.fn.bufnr()

    local opts = {
        prompt = "Log> ",
        exec_empty_query = false,
        func_async_callback = false,
        fzf_opts = {
            ["--preview"] = fzf_previewers.git_diff_content_previewer(),
        },
        fn_transform = function(x)
            return fzf_picker_utils.make_entry(x)
        end,
        actions = vim.tbl_extend(
            "keep",
            fzf_mappings.open_commit_in_brower(),
            fzf_mappings.open_diff_buffer_with_selected_commit(bufnr),
            fzf_mappings.show_entire_commit(),
            fzf_mappings.copy_commit_hash()
        ),
    }

    require("fzf-lua").fzf_live(function(query)
        return fzf_finders.git_log_content_finder(query, bufnr)
    end, opts)
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

    local opts = {
        prompt = "Commit message> ",
        exec_empty_query = true,
        func_async_callback = false,
        fzf_opts = {
            ["--preview"] = fzf_previewers.git_diff_file_previewer(bufnr),
        },
        fn_transform = function(x)
            return fzf_picker_utils.make_entry(x)
        end,
        actions = vim.tbl_extend(
            "keep",
            fzf_mappings.open_commit_in_brower(),
            fzf_mappings.open_diff_buffer_with_selected_commit(bufnr),
            fzf_mappings.show_entire_commit(),
            fzf_mappings.copy_commit_hash()
        ),
    }

    require("fzf-lua").fzf_live(function(query)
        return fzf_finders.git_log_location_finder(query, bufnr, s_start, s_end)
    end, opts)
end

M.diff_commit_file = function()
    local bufnr = vim.fn.bufnr()

    local opts = {
        prompt = "Commit message> ",
        exec_empty_query = true,
        func_async_callback = false,
        fzf_opts = {
            ["--preview"] = fzf_previewers.git_diff_file_previewer(bufnr),
        },
        fn_transform = function(x)
            return fzf_picker_utils.make_entry(x)
        end,
        actions = vim.tbl_extend(
            "keep",
            fzf_mappings.open_commit_in_brower(),
            fzf_mappings.open_diff_buffer_with_selected_commit(bufnr),
            fzf_mappings.show_entire_commit(),
            fzf_mappings.copy_commit_hash()
        ),
    }

    require("fzf-lua").fzf_live(function(query)
        return fzf_finders.git_log_file_finder(query, bufnr)
    end, opts)
end

M.diff_branch_file = function()
    local bufnr = vim.fn.bufnr()

    local opts = {
        prompt = "Branch> ",
        func_async_callback = false,
        fzf_opts = {
            ["--preview"] = fzf_previewers.git_diff_branch_file_previewer(
                bufnr
            ),
        },
        actions = vim.tbl_extend(
            "keep",
            fzf_mappings.open_commit_in_brower(),
            fzf_mappings.open_diff_buffer_with_selected_commit(bufnr),
            fzf_mappings.copy_commit_hash()
        ),
    }

    require("fzf-lua").fzf_exec(
        table.concat(
            require("advanced_git_search.commands.find").git_branches(),
            " "
        ),
        opts
    )
end

M.changed_on_branch = function()
    local opts = {
        prompt = "File> ",
        func_async_callback = false,
        fzf_opts = {
            ["--preview"] = fzf_previewers.git_diff_base_branch(),
        },
    }

    require("fzf-lua").fzf_exec(
        table.concat(
            require("advanced_git_search.commands.find").changed_on_branch(),
            " "
        ),
        opts
    )
end

M.checkout_reflog = function()
    local opts = {
        func_async_callback = false,
        fn_transform = function(x)
            return fzf_picker_utils.make_reflog_entry(x)
        end,
        actions = {
            ["default"] = function(selected)
                local selection = selected[1]
                local commit = string.sub(selection, 1, 7)

                require("advanced_git_search.actions").checkout_commit(commit)
            end,
        },
    }

    require("fzf-lua").fzf_exec(
        table.concat(require("advanced_git_search.commands.find").reflog(), " "),
        opts
    )
end

--- Opens a selector for all advanced git search functions
M.show_custom_functions = function()
    local keys = global_picker.keys("fzf_lua")

    local opts = {
        prompt = "AdvancedGitSearch> ",
        func_async_callback = false,
        actions = {
            ["default"] = function(selected)
                local selection = selected[1]

                global_picker.execute_git_function(selection, "fzf_lua")
            end,
        },
    }

    require("fzf-lua").fzf_exec(keys, opts)
end

return M
