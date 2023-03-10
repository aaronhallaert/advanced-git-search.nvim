local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local gu = require("advanced_git_search.git_utils")
local file = require("advanced_git_search.utils.file")

local previewers = require("telescope.previewers")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local finders = require("telescope.finders")

M = {}

-- Map a key to both insert and normal modes
local function omnimap(map_func, key, handler)
    map_func("i", key, handler)
    map_func("n", key, handler)
end

--- Opens a Telescope window with a list of local branches
---
--- <CR> opens a diff for the current file with the selected branch
M.diff_branch_file = function()
    -- local previewers = require('telescope.previewers')
    local current_branch = vim.fn.system("git branch --show-current")
    current_branch = string.gsub(current_branch, "\n", "")
    local file_name = file.git_relative_path(vim.fn.bufnr())
    pickers
        .new({
            results_title = "Local branches :: *" .. current_branch,
            prompt_title = "Branch name",
            finder = finders.new_oneshot_job({
                "git",
                "branch",
                "--format=%(refname:short)",
            }),
            sorter = sorters.get_fuzzy_file(),
            previewer = previewers.new_termopen_previewer({
                get_command = function(entry)
                    local branch = entry.value

                    return {
                        "git",
                        "diff",
                        branch,
                        "--",
                        file_name,
                    }
                end,
            }),
            attach_mappings = function(_, map)
                omnimap(map, "<CR>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local branch = selection.value

                    gu.open_diff_view(branch, gu.determine_historic_file_name(branch, file_name))
                end)

                return true
            end,
        })
        :find()
end

--- Opens a Telescope window with a list of previous commit logs
--- with respect to selected lines
---
--- <CR> opens a diff for the current file with the selected commit
--- <C-o> opens a the selected commit in the browser
M.diff_commit_line = function()
    local bufnr = vim.fn.bufnr()
    local s_start = vim.fn.getpos("'<")[2]
    local s_end = vim.fn.getpos("'>")[2]

    -- git log -L741,751:'app/models/patients/patient.rb' --format='%C(auto)%h \t %as \t %C(green)%an _ %Creset %s'
    pickers
        .new({
            results_title = "Commits that affected the selected lines",
            prompt_title = "Commit message",
            finder = gu.git_log_grepper_on_location(bufnr, s_start, s_end),
            -- finder = finders.new_oneshot_job({'git', 'log', location}),
            previewer = gu.git_diff_previewer_file(bufnr),
            sorter = sorters.highlighter_only(),
            attach_mappings = function(_, map)
                omnimap(map, "<CR>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local commit_hash = selection.opts.commit_hash

                    gu.open_diff_view(commit_hash)
                end)
                omnimap(map, "<C-o>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()

                    vim.api.nvim_command(":GBrowse " .. selection.opts.commit_hash)
                end)

                return true
            end,
        })
        :find()
end

--- Opens a Telescope window with a list of previous commits.
--- Query is used to filter the results based on the
--- content of the commit (added or removed text).
---
--- <CR> opens a diff for the current file with the selected commit
--- <C-o> opens a the selected commit in the browser
M.search_log_content = function()
    -- local file_name = vim.fn.expand("%")
    -- local relative_file_name = vim.fn.expand("%:~:.")

    -- git log -L741,751:'app/models/patients/patient.rb' --format='%C(auto)%h \t %as \t %C(green)%an _ %Creset %s'
    pickers
        .new({
            results_title = "Commits",
            prompt_title = "Git log content (added, removed or updated text)",
            finder = gu.git_log_grepper_on_content({}),
            -- finder = finders.new_oneshot_job({'git', 'log', location}),
            previewer = previewers.new_termopen_previewer({
                get_command = function(entry)
                    local commit_hash = entry.opts.commit_hash
                    local prompt = entry.opts.prompt
                    local command = {
                        "git",
                        "diff",
                        string.format("%s~", commit_hash),
                        commit_hash,
                    }

                    if prompt and prompt ~= "" then
                        table.insert(command, "-G")
                        table.insert(command, prompt)
                    end

                    return command
                end,
            }),
            -- sorter = sorters.highlighter_only(),
            attach_mappings = function(_, map)
                omnimap(map, "<CR>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local commit_hash = selection.opts.commit_hash

                    gu.open_diff_view(commit_hash)
                end)
                omnimap(map, "<C-o>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()

                    vim.api.nvim_command(":GBrowse " .. selection.opts.commit_hash)
                end)

                return true
            end,
        })
        :find()
end

--- Same as `search_log_content` but with respect to the current file
---
--- <CR> opens a diff for the current file with the selected commit
--- <C-o> opens a the selected commit in the browser
M.search_log_content_file = function()
    -- local file_name = vim.fn.expand("%")
    -- local relative_file_name = vim.fn.expand("%:~:.")

    -- git log -L741,751:'app/models/patients/patient.rb' --format='%C(auto)%h \t %as \t %C(green)%an _ %Creset %s'
    pickers
        .new({
            results_title = "Commits",
            prompt_title = "Git log content (added, removed or updated text in this file)",
            finder = gu.git_log_grepper_on_content({ bufnr = vim.fn.bufnr() }),
            -- finder = finders.new_oneshot_job({'git', 'log', location}),
            previewer = previewers.new_termopen_previewer({
                get_command = function(entry)
                    local commit_hash = entry.opts.commit_hash
                    local prompt = entry.opts.prompt
                    local command = {
                        "git",
                        "diff",
                        string.format("%s~", commit_hash),
                        commit_hash,
                    }

                    if prompt and prompt ~= "" then
                        table.insert(command, "-G")
                        table.insert(command, prompt)
                    end

                    return command
                end,
            }),
            -- sorter = sorters.highlighter_only(),
            attach_mappings = function(_, map)
                omnimap(map, "<CR>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local commit_hash = selection.opts.commit_hash

                    gu.open_diff_view(commit_hash)
                end)
                omnimap(map, "<C-o>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()

                    vim.api.nvim_command(":GBrowse " .. selection.opts.commit_hash)
                end)

                return true
            end,
        })
        :find()
end

-- Opens a Telescope window with a list of git commits which changed the current file (renames included)
--
-- <CR> Opens a diff of the current file with the selected commit
-- <C-e> Opens an entire git diff of the selected commit
-- <C-o> Open the selected commit in the browser
M.diff_commit_file = function()
    local bufnr = vim.fn.bufnr()
    pickers
        .new({
            results_title = "Commits that affected this file (renamed files included)",
            prompt_title = "Commit message",
            finder = gu.git_log_grepper_on_file(bufnr),
            previewer = gu.git_diff_previewer_file(bufnr),
            sorter = sorters.highlighter_only(),
            attach_mappings = function(_, map)
                omnimap(map, "<CR>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local commit_hash = selection.opts.commit_hash
                    local old_file_name = gu.determine_historic_file_name(commit_hash, bufnr)

                    gu.open_diff_view(commit_hash, old_file_name)
                end)
                omnimap(map, "<C-e>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local commit_hash = selection.opts.commit_hash

                    local command = {
                        "git",
                        "diff",
                        string.format("%s~", commit_hash),
                        commit_hash,
                        "\n",
                    }

                    vim.api.nvim_command("split new") -- split a new window
                    vim.api.nvim_win_set_height(0, 30) -- set the window height
                    local buf_handle = vim.api.nvim_win_get_buf(0) -- get the buffer handler
                    local jobID = vim.api.nvim_call_function("termopen", { "$SHELL" })
                    vim.api.nvim_buf_set_option(buf_handle, "modifiable", true)
                    vim.api.nvim_chan_send(jobID, table.concat(command, " "))
                end)
                omnimap(map, "<C-o>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local commit_hash = selection.opts.commit_hash

                    vim.api.nvim_command(":GBrowse " .. commit_hash)
                end)

                return true
            end,
        })
        :find()
end

--- Opens a Telescope window with all reflog entries
---
--- <CR> checkout on the reflog entry
M.checkout_reflog = function()
    pickers
        .new({
            results_title = "Git Reflog, <CR> to checkout",
            finder = finders.new_oneshot_job({ "git", "reflog", "--date=iso" }),
            sorter = sorters.get_fuzzy_file(),
            attach_mappings = function(_, map)
                omnimap(map, "<CR>", function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local reflog_entry = selection.value

                    Splitted_reflog_entry = {}
                    Count = 1
                    for i in string.gmatch(reflog_entry, "%S+") do
                        Splitted_reflog_entry[Count] = i
                        Count = Count + 1
                    end
                    vim.api.nvim_command(":!git checkout " .. Splitted_reflog_entry[1])
                end)

                return true
            end,
        })
        :find()
end

local git_functions = {
    { value = "Find in repo log content", func = M.search_log_content },
    { value = "Find in file log content", func = M.search_log_content_file },
    { value = "Diff file with branch", func = M.diff_branch_file },
    { value = "Diff file with previous commit", func = M.diff_commit_file },
    { value = "Diff file with selected line history", func = M.diff_commit_line },
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
                omnimap(map, "<CR>", function(prompt_bufnr)
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
