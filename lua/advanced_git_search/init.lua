local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local git_utils = require("advanced_git_search.utils.git")

local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local finders = require("telescope.finders")
local ags_finders = require("advanced_git_search.finders")
local ags_previewers = require("advanced_git_search.previewers")
local ags_mappings = require("advanced_git_search.mappings")

local M = {}

--- Opens a Telescope window with all files changed on the current branch
--- Only committed changes will be displayed
M.changed_on_branch = function()
    pickers
        .new({
            results_title = "Modified "
                .. git_utils.base_branch()
                .. " -> "
                .. git_utils.current_branch(),
            sorter = sorters.get_fuzzy_file(),
            finder = ags_finders.changed_files_on_current_branch_finder(),
            previewer = ags_previewers.changed_files_on_current_branch_previewer(),
        })
        :find()
end

--- Opens a Telescope window with a list of local branches
M.diff_branch_file = function()
    -- local previewers = require('telescope.previewers')
    local current_branch = git_utils.current_branch()
    local bufnr = vim.fn.bufnr()

    pickers
        .new({
            results_title = "Local branches :: *" .. current_branch,
            prompt_title = "Branch name",
            finder = ags_finders.git_branches_finder(),
            sorter = sorters.get_fuzzy_file(),
            previewer = ags_previewers.git_diff_branch_file_previewer(bufnr),
            attach_mappings = function(_, map)
                ags_mappings.open_diff_view_current_file_selected_branch(map)
                return true
            end,
        })
        :find()
end

--- Opens a Telescope window with a list of previous commit logs
--- with respect to selected lines
M.diff_commit_line = function()
    local bufnr = vim.fn.bufnr()
    local s_start = vim.fn.getpos("'<")[2]
    local s_end = vim.fn.getpos("'>")[2]

    -- git log -L741,751:'app/models/patients/patient.rb'\
    -- --format='%C(auto)%h \t %as \t %C(green)%an _ %Creset %s'
    pickers
        .new({
            results_title = "Commits that affected the selected lines",
            prompt_title = "Commit message",
            finder = ags_finders.git_log_location_finder(bufnr, s_start, s_end),
            previewer = ags_previewers.git_diff_commit_file_previewer(bufnr),
            sorter = sorters.highlighter_only(),
            attach_mappings = function(_, map)
                ags_mappings.open_diff_view_current_file_selected_commit(map)
                ags_mappings.open_selected_commit_in_browser(map)
                ags_mappings.copy_commit_hash_to_clipboard(map)
                ags_mappings.show_entire_commit(map)
                return true
            end,
        })
        :find()
end

--- Opens a Telescope window with a list of previous commits.
--- Query is used to filter the results based on the
--- content of the commit (added or removed text).
M.search_log_content = function()
    -- git log -L741,751:'app/models/patients/patient.rb' \
    -- --format='%C(auto)%h \t %as \t %C(green)%an _ %Creset %s'
    pickers
        .new({
            results_title = "Commits",
            prompt_title = "Git log content (added, removed or updated text)",
            finder = ags_finders.git_log_content_finder({}),
            previewer = ags_previewers.git_diff_content_previewer(),
            attach_mappings = function(_, map)
                ags_mappings.open_diff_view_current_file_selected_commit(map)
                ags_mappings.open_selected_commit_in_browser(map)
                ags_mappings.copy_commit_hash_to_clipboard(map)
                ags_mappings.show_entire_commit(map)
                return true
            end,
        })
        :find()
end

--- Same as `search_log_content` but with respect to the current file
M.search_log_content_file = function()
    -- local file_name = vim.fn.expand("%")
    -- local relative_file_name = vim.fn.expand("%:~:.")

    -- git log -L741,751:'app/models/patients/patient.rb' \
    -- --format='%C(auto)%h \t %as \t %C(green)%an _ %Creset %s'
    pickers
        .new({
            results_title = "Commits",
            prompt_title = "Git log content (added, removed or updated text in this file)",
            finder = ags_finders.git_log_content_finder({
                bufnr = vim.fn.bufnr(),
            }),
            previewer = ags_previewers.git_diff_content_previewer(),
            -- sorter = sorters.highlighter_only(),
            attach_mappings = function(_, map)
                ags_mappings.open_diff_view_current_file_selected_commit(map)
                ags_mappings.open_selected_commit_in_browser(map)
                ags_mappings.copy_commit_hash_to_clipboard(map)
                ags_mappings.show_entire_commit(map)

                return true
            end,
        })
        :find()
end

-- Opens a Telescope window with a list of git commits which changed the current file (renames included)
M.diff_commit_file = function()
    local bufnr = vim.fn.bufnr()
    pickers
        .new({
            results_title = "Commits that affected this file (renamed files included)",
            prompt_title = "Commit message",
            finder = ags_finders.git_log_file_finder(bufnr),
            previewer = ags_previewers.git_diff_commit_file_previewer(bufnr),
            sorter = sorters.highlighter_only(),
            attach_mappings = function(_, map)
                ags_mappings.open_diff_view_current_file_selected_commit(map)
                ags_mappings.show_entire_commit(map)
                ags_mappings.open_selected_commit_in_browser(map)
                ags_mappings.copy_commit_hash_to_clipboard(map)

                return true
            end,
        })
        :find()
end

--- Opens a Telescope window with all reflog entries
M.checkout_reflog = function()
    pickers
        .new({
            results_title = "Git Reflog, <CR> to checkout",
            finder = finders.new_oneshot_job({ "git", "reflog", "--date=iso" }),
            sorter = sorters.get_fuzzy_file(),
            attach_mappings = function(_, map)
                ags_mappings.checkout_reflog_entry(map)
                return true
            end,
        })
        :find()
end

local git_functions = {
    { value = "Changed on current branch", func = M.changed_on_branch },
    { value = "Find in repo log content", func = M.search_log_content },
    { value = "Find in file log content", func = M.search_log_content_file },
    { value = "Diff file with branch", func = M.diff_branch_file },
    { value = "Diff file with previous commit", func = M.diff_commit_file },
    {
        value = "Diff file with selected line history",
        func = M.diff_commit_line,
    },
    { value = "Checkout from reflog", func = M.checkout_reflog },
}

local function map_item(git_functions_table, f)
    local t = {}
    for k, v in pairs(git_functions_table) do
        t[k] = f(v)
    end
    return t
end

local function execute_git_function(value)
    for _, v in pairs(git_functions) do
        if v["value"] == value then
            v["func"]()
            return
        end
    end
end

--- Opens all a selector for all advanced git search functions
M.show_custom_functions = function()
    pickers
        .new({
            results_title = "Git action",
            finder = finders.new_table(map_item(git_functions, function(item)
                return item["value"]
            end)),
            sorter = sorters.get_fuzzy_file(),
            attach_mappings = function(_, map)
                ags_mappings.omnimap(map, "<CR>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    execute_git_function(selection.value)
                end)

                return true
            end,
        })
        :find()
end

return M
