local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local git_utils = require("advanced_git_search.utils.git")
local global_picker = require("advanced_git_search.global_picker")

local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local finders = require("telescope.finders")

local telescope_ags_finders = require("advanced_git_search.telescope.finders")
local telescope_ags_previewers =
    require("advanced_git_search.telescope.previewers")
local telescope_ags_mappings = require("advanced_git_search.telescope.mappings")

local M = {}

local config = require("advanced_git_search.utils.config")

--- Opens a Telescope window with all files changed on the current branch
--- Only committed changes will be displayed
M.changed_on_branch = function()
    local theme_opts = config.telescope_theme("changed_on_branch")

    pickers
        .new(vim.tbl_extend("force", {
            results_title = "Modified "
                .. git_utils.base_branch()
                .. " -> "
                .. git_utils.current_branch(),
            sorter = sorters.get_fuzzy_file(),
            finder = telescope_ags_finders.changed_files_on_current_branch_finder(),
            previewer = telescope_ags_previewers.changed_files_on_current_branch_previewer(),
        }, theme_opts))
        :find()
end

--- Opens a Telescope window with a list of local branches
M.diff_branch_file = function()
    -- local previewers = require('telescope.previewers')
    local current_branch = git_utils.current_branch()
    local bufnr = vim.fn.bufnr()

    local theme_opts = config.telescope_theme("diff_branch_file")

    pickers
        .new(vim.tbl_extend("force", {
            results_title = "Local branches :: *" .. current_branch,
            prompt_title = "Branch name",
            finder = telescope_ags_finders.git_branches_finder(),
            sorter = sorters.get_fuzzy_file(),
            previewer = telescope_ags_previewers.git_diff_branch_file_previewer(
                bufnr
            ),
            attach_mappings = function(_, map)
                telescope_ags_mappings.open_diff_view_current_file_selected_branch(
                    map
                )
                return true
            end,
        }, theme_opts))
        :find()
end

--- Opens a Telescope window with a list of previous commit logs
--- with respect to selected lines
M.diff_commit_line = function()
    local bufnr = vim.fn.bufnr()
    local s_start = vim.fn.getpos("'<")[2]
    local s_end = vim.fn.getpos("'>")[2]

    local theme_opts = config.telescope_theme("diff_commit_line")

    if s_start == 0 or s_end == 0 then
        vim.notify(
            "No visual selection",
            vim.log.levels.WARN,
            { title = "Advanced Git Search" }
        )
        return
    end

    -- git log -L741,751:'app/models/patients/patient.rb'\
    -- --format='%C(auto)%h \t %as \t %C(green)%an _ %Creset %s'
    pickers
        .new(vim.tbl_extend("force", {
            results_title = "Commits that affected the selected lines",
            prompt_title = "Commit message",
            finder = telescope_ags_finders.git_log_location_finder(
                bufnr,
                s_start,
                s_end
            ),
            previewer = telescope_ags_previewers.git_diff_commit_file_previewer(
                bufnr
            ),
            sorter = sorters.highlighter_only(),
            attach_mappings = function(_, map)
                telescope_ags_mappings.open_diff_view_current_file_selected_commit(
                    map
                )
                telescope_ags_mappings.open_selected_commit_in_browser(map)
                telescope_ags_mappings.copy_commit_hash_to_clipboard(map)
                telescope_ags_mappings.show_entire_commit(map)
                telescope_ags_mappings.toggle_entry_value(map)
                return true
            end,
        }, theme_opts))
        :find()
end

--- Opens a Telescope window with a list of previous commits.
--- Query is used to filter the results based on the
--- content of the commit (added or removed text).
M.search_log_content = function()
    local theme_opts = config.telescope_theme("search_log_content")

    -- git log -L741,751:'app/models/patients/patient.rb' \
    -- --format='%C(auto)%h \t %as \t %C(green)%an _ %Creset %s'
    pickers
        .new(vim.tbl_extend("force", {
            results_title = "Commits",
            prompt_title = "Git log content (added, removed or updated text)",
            finder = telescope_ags_finders.git_log_content_finder({}),
            previewer = telescope_ags_previewers.git_diff_content_previewer(),
            attach_mappings = function(_, map)
                telescope_ags_mappings.open_diff_view_current_file_selected_commit(
                    map
                )
                telescope_ags_mappings.open_selected_commit_in_browser(map)
                telescope_ags_mappings.copy_commit_hash_to_clipboard(map)
                telescope_ags_mappings.show_entire_commit(map)
                telescope_ags_mappings.toggle_entry_value(map)
                return true
            end,
        }, theme_opts))
        :find()
end

--- Same as `search_log_content` but with respect to the current file
M.search_log_content_file = function()
    -- local file_name = vim.fn.expand("%")
    -- local relative_file_name = vim.fn.expand("%:~:.")

    local theme_opts = config.telescope_theme("search_log_content_file")

    -- git log -L741,751:'app/models/patients/patient.rb' \
    -- --format='%C(auto)%h \t %as \t %C(green)%an _ %Creset %s'
    pickers
        .new(vim.tbl_extend("force", {
            results_title = "Commits",
            prompt_title = "Git log content (added, removed or updated text in this file)",
            finder = telescope_ags_finders.git_log_content_finder({
                bufnr = vim.fn.bufnr(),
            }),
            previewer = telescope_ags_previewers.git_diff_content_previewer({
                bufnr = vim.fn.bufnr(),
            }),
            attach_mappings = function(_, map)
                telescope_ags_mappings.open_diff_view_current_file_selected_commit(
                    map
                )
                telescope_ags_mappings.open_selected_commit_in_browser(map)
                telescope_ags_mappings.copy_commit_hash_to_clipboard(map)
                telescope_ags_mappings.show_entire_commit(map)
                telescope_ags_mappings.toggle_entry_value(map)

                return true
            end,
        }, theme_opts))
        :find()
end

-- Opens a Telescope window with a list of git commits which changed the current file (renames included)
M.diff_commit_file = function()
    local bufnr = vim.fn.bufnr()

    local theme_opts = config.telescope_theme("diff_commit_file")

    pickers
        .new(vim.tbl_extend("force", {
            results_title = "Commits that affected this file (renamed files included)",
            prompt_title = "Commit message",
            finder = telescope_ags_finders.git_log_file_finder(bufnr),
            previewer = telescope_ags_previewers.git_diff_commit_file_previewer(
                bufnr
            ),
            sorter = sorters.highlighter_only(),
            attach_mappings = function(_, map)
                telescope_ags_mappings.open_diff_view_current_file_selected_commit(
                    map
                )
                telescope_ags_mappings.show_entire_commit(map)
                telescope_ags_mappings.toggle_entry_value(map)
                telescope_ags_mappings.open_selected_commit_in_browser(map)
                telescope_ags_mappings.copy_commit_hash_to_clipboard(map)

                return true
            end,
        }, theme_opts))
        :find()
end

--- Opens a Telescope window with all reflog entries
M.checkout_reflog = function()
    local theme_opts = config.telescope_theme("checkout_reflog")

    pickers
        .new(vim.tbl_extend("force", {
            results_title = "Git Reflog, <CR> to checkout",
            finder = finders.new_oneshot_job(
                require("advanced_git_search.commands.find").reflog()
            ),
            sorter = sorters.get_fuzzy_file(),
            attach_mappings = function(_, map)
                telescope_ags_mappings.checkout_reflog_entry(map)
                return true
            end,
        }, theme_opts))
        :find()
end

--- Opens a selector for all advanced git search functions
M.show_custom_functions = function()
    local keys = global_picker.keys("telescope")

    local theme_opts = config.telescope_theme("show_custom_functions")

    pickers
        .new(vim.tbl_extend("force", {
            prompt_title = "Git actions",
            finder = finders.new_table(keys),
            sorter = sorters.get_fuzzy_file(),
            attach_mappings = function(_, map)
                telescope_ags_mappings.omnimap(
                    map,
                    "<CR>",
                    function(prompt_bufnr)
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        global_picker.execute_git_function(
                            selection.value,
                            "telescope"
                        )
                    end
                )

                return true
            end,
        }, theme_opts))
        :find()
end

return M
